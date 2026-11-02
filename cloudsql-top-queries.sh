#!/usr/bin/env bash
# Print the top Cloud SQL Query Insights queries for the write instance.
#
# Read-only. Uses the current gcloud account (does not switch accounts) and
# the Monitoring API v3 timeSeries.list endpoint. This gcloud (no
# `monitoring time-series list` subcommand in the stable CLI) reads the same
# metrics that export already returned:
#   cloudsql.googleapis.com/database/postgresql/insights/perquery/execution_time
#   cloudsql.googleapis.com/database/postgresql/insights/perquery/latencies
# Requires: gcloud and jq on PATH, plus curl. No Postgres connection.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: cloudsql-top-queries.sh [-n N] [-H HOURS] [--project PROJECT] [--instance INSTANCE]

  -n, --top N         How many queries to print (default 10).
  -H, --hours X       Lookback in hours (default 24). Must be a positive number.
  --project PROJECT   GCP project (default chatfunnels).
  --instance ID       Cloud SQL instance (default production-v2, the write instance).
  -h, --help          Show this help and exit 0.

Ranks by total execution time. Calls and mean come from the latency distribution.
EOF
}

TOP=10
HOURS=24
PROJECT=chatfunnels
INSTANCE=production-v2

while [[ $# -gt 0 ]]; do
  case "$1" in
    -n|--top)
      [[ $# -ge 2 ]] || { echo "missing value for $1" >&2; exit 2; }
      TOP=$2
      shift 2
      ;;
    -H|--hours)
      [[ $# -ge 2 ]] || { echo "missing value for $1" >&2; exit 2; }
      HOURS=$2
      shift 2
      ;;
    --project)
      [[ $# -ge 2 ]] || { echo "missing value for $1" >&2; exit 2; }
      PROJECT=$2
      shift 2
      ;;
    --instance)
      [[ $# -ge 2 ]] || { echo "missing value for $1" >&2; exit 2; }
      INSTANCE=$2
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if ! [[ "$TOP" =~ ^[1-9][0-9]*$ ]]; then
  echo "--top must be a positive integer" >&2
  exit 2
fi
if ! [[ "$HOURS" =~ ^([0-9]+([.][0-9]+)?|[.][0-9]+)$ ]]; then
  echo "--hours must be a positive number" >&2
  exit 2
fi
awk -v h="$HOURS" 'BEGIN { if (!(h > 0)) exit 1 }' || {
  echo "--hours must be a positive number" >&2
  exit 2
}

command -v gcloud >/dev/null || { echo "gcloud is not on PATH" >&2; exit 1; }
command -v jq >/dev/null || { echo "jq is not on PATH" >&2; exit 1; }
command -v curl >/dev/null || { echo "curl is not on PATH" >&2; exit 1; }

ALIGN=$(awk -v h="$HOURS" 'BEGIN { s = int(h * 3600); if (s < 1) s = 1; printf "%d", s }')
if [[ "$ALIGN" -lt 60 ]]; then
  echo "--hours is shorter than the 60-second minimum alignment period" >&2
  exit 2
fi

END=$(date -u +%Y-%m-%dT%H:%M:%SZ)
if date -u -v-1S +%Y-%m-%dT%H:%M:%SZ >/dev/null 2>&1; then
  START=$(date -u -v-"${ALIGN}"S +%Y-%m-%dT%H:%M:%SZ)
else
  START=$(date -u -d "${ALIGN} seconds ago" +%Y-%m-%dT%H:%M:%SZ)
fi

EXEC_METRIC="cloudsql.googleapis.com/database/postgresql/insights/perquery/execution_time"
LAT_METRIC="cloudsql.googleapis.com/database/postgresql/insights/perquery/latencies"
RESOURCE_ID="${PROJECT}:${INSTANCE}"

TOKEN=$(gcloud auth print-access-token)
WORKDIR=$(mktemp -d)
trap 'rm -rf "$WORKDIR"' EXIT

fetch_metric() {
  local metric="$1"
  local out="$2"
  local page_token=""
  local pages=0
  : >"$out"
  while true; do
    local body code
    body="${WORKDIR}/page.json"
    local curl_args=(
      -sS -G
      -H "Authorization: Bearer ${TOKEN}"
      -o "$body"
      -w '%{http_code}'
      --data-urlencode "filter=metric.type=\"${metric}\" AND resource.labels.resource_id=\"${RESOURCE_ID}\""
      --data-urlencode "interval.startTime=${START}"
      --data-urlencode "interval.endTime=${END}"
      --data-urlencode "aggregation.alignmentPeriod=${ALIGN}s"
      --data-urlencode "aggregation.perSeriesAligner=ALIGN_DELTA"
      --data-urlencode "pageSize=500"
    )
    if [[ -n "$page_token" ]]; then
      curl_args+=(--data-urlencode "pageToken=${page_token}")
    fi
    code=$(curl "${curl_args[@]}" "https://monitoring.googleapis.com/v3/projects/${PROJECT}/timeSeries")
    if [[ "$code" != "200" ]]; then
      echo "monitoring API returned HTTP ${code} for ${metric}" >&2
      jq -r '.error.message // .' "$body" >&2 || true
      exit 1
    fi
    jq -c '.timeSeries[]?' "$body" >>"$out"
    page_token=$(jq -r '.nextPageToken // empty' "$body")
    pages=$((pages + 1))
    if [[ -z "$page_token" ]]; then
      break
    fi
    if [[ "$pages" -gt 40 ]]; then
      echo "stopped after ${pages} pages for ${metric}" >&2
      exit 1
    fi
  done
}

fetch_metric "$EXEC_METRIC" "${WORKDIR}/exec.ndjson"
if [[ ! -s "${WORKDIR}/exec.ndjson" ]]; then
  echo "no series for ${EXEC_METRIC} on ${RESOURCE_ID} between ${START} and ${END}" >&2
  exit 1
fi

fetch_metric "$LAT_METRIC" "${WORKDIR}/lat.ndjson"
if [[ ! -s "${WORKDIR}/lat.ndjson" ]]; then
  echo "no series for ${LAT_METRIC} on ${RESOURCE_ID} between ${START} and ${END}" >&2
  exit 1
fi

echo "project=${PROJECT} instance=${INSTANCE} start=${START} end=${END} top=${TOP}"

jq -s -r --argjson n "$TOP" '
  def clip:
    gsub("[[:space:]]+"; " ")
    | sub("[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}.*"; "")
    | if length > 180 then .[0:180] else . end;
  def us_of:
    [ .points[]? | (.value.int64Value // "0") | tonumber ] | add // 0;
  def calls_of:
    [ .points[]? | (.value.distributionValue.count // "0") | tonumber ] | add // 0;
  (map(select(.metric.type | endswith("/execution_time"))) | map({
      key: ((.resource.labels.database // "") + "|" + (.metric.labels.query_hash // "")),
      db: (.resource.labels.database // ""),
      query: (.metric.labels.querystring // ""),
      us: us_of
    })
    | group_by(.key)
    | map({
        key: .[0].key,
        db: .[0].db,
        query: (max_by(.query | length).query),
        us: (map(.us) | add)
      })) as $exec
  | (map(select(.metric.type | endswith("/latencies"))) | map({
      key: ((.resource.labels.database // "") + "|" + (.metric.labels.query_hash // "")),
      calls: calls_of
    })
    | group_by(.key)
    | map({key: .[0].key, calls: (map(.calls) | add)})) as $lat
  | ($lat | map({(.key): .calls}) | add // {}) as $calls
  | ($exec | sort_by(-.us) | .[0:$n] | to_entries[])
  | . as $row
  | ($calls[$row.value.key] // null) as $c
  | [
      ($row.key + 1 | tostring),
      ($row.value.us / 1000000 | tostring),
      (if $c == null then "-" else ($c | tostring) end),
      (if $c != null and $c > 0 then (($row.value.us / $c) / 1000 | tostring) else "-" end),
      $row.value.db,
      ($row.value.query | clip)
    ]
  | @tsv
' "${WORKDIR}/exec.ndjson" "${WORKDIR}/lat.ndjson" | while IFS=$'\t' read -r rank secs calls mean db query; do
  printf '%s  %.1fs  calls=%s  mean_ms=%s  db=%s  %s\n' \
    "$rank" "$secs" "$calls" "$( [[ "$mean" == "-" ]] && printf '-' || awk -v m="$mean" 'BEGIN { printf "%.2f", m }' )" "$db" "$query"
done
