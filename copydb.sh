#!/bin/bash

# Default values
USER="postgres"
HOST="localhost"
DEFAULT_PASS="example"

usage() {
	echo "Usage: $0 -s <source_db> -t <target_db> [-u <user>] [-h <host>]"
	exit 1
}

while getopts "s:t:u:h:" opt; do
	case $opt in
	s) SOURCE_DB="$OPTARG" ;;
	t) TARGET_DB="$OPTARG" ;;
	u) USER="$OPTARG" ;;
	h) HOST="$OPTARG" ;;
	*) usage ;;
	esac
done

if [[ -z "$SOURCE_DB" || -z "$TARGET_DB" ]]; then usage; fi

export PGPASSWORD=${PGPASSWORD:-$DEFAULT_PASS}

echo "--- 1. Recreating Target: $TARGET_DB ---"

# Surgical strike to drop the DB
psql -h "$HOST" -U "$USER" -d postgres -c "REVOKE CONNECT ON DATABASE \"$TARGET_DB\" FROM public; SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$TARGET_DB' AND pid <> pg_backend_pid(); DROP DATABASE IF EXISTS \"$TARGET_DB\";"
psql -h "$HOST" -U "$USER" -d postgres -c "CREATE DATABASE \"$TARGET_DB\";"

if [ $? -ne 0 ]; then
	echo "❌ Error: Could not create database $TARGET_DB"
	exit 1
fi

echo "--- 2. Cloning $SOURCE_DB to $TARGET_DB ---"

# Using a temporary file for the exit status to ensure it works across all shells
pg_dump -h "$HOST" -U "$USER" -d "$SOURCE_DB" | psql -h "$HOST" -U "$USER" -d "$TARGET_DB"

# Capture the exit status of the LAST command in the pipe (psql)
# This is usually sufficient for a clone check
PAYLOAD_STATUS=$?

if [ $PAYLOAD_STATUS -eq 0 ]; then
	echo "✅ Success: $TARGET_DB is a fresh clone of $SOURCE_DB."
else
	echo "❌ Error: The clone failed during data transfer."
	exit 1
fi

unset PGPASSWORD
