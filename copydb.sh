#!/bin/bash

# Default values
USER="postgres"
HOST="localhost"
DEFAULT_PASS="example"
FORCE=

usage() {
	echo "Usage: $0 -s <source_db> -t <target_db> [-u <user>] [-h <host>]"
	exit 1
}

while getopts "s:t:u:h:f" opt; do
	case $opt in
	s) SOURCE_DB="$OPTARG" ;;
	t) TARGET_DB="$OPTARG" ;;
	u) USER="$OPTARG" ;;
	h) HOST="$OPTARG" ;;
	f) FORCE="true" ;;
	*) usage ;;
	esac
done

if [[ -z "$SOURCE_DB" || -z "$TARGET_DB" ]]; then usage; fi

export PGPASSWORD=${PGPASSWORD:-$DEFAULT_PASS}

# --- 1. Check if Target Exists ---
# This query returns '1' if the DB exists, '0' otherwise
DB_EXISTS=$(psql -h "$HOST" -U "$USER" -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='$TARGET_DB'")

if [[ "$DB_EXISTS" = "1" ]]; then
	if [[ "$FORCE" != "true" ]]; then
		echo "⚠️  Target database '$TARGET_DB' already exists."
		read -p "Do you want to delete it and create a fresh one? (y/N): " confirm
		if [[ $confirm != [yY] ]]; then
			echo "Operation cancelled. Target database was not modified."
			exit 0
		fi
	fi

	# Step A: Kill connections (Independent call)
	psql -h "$HOST" -U "$USER" -d postgres -c "REVOKE CONNECT ON DATABASE \"$TARGET_DB\" FROM public;" >/dev/null
	psql -h "$HOST" -U "$USER" -d postgres -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$TARGET_DB' AND pid <> pg_backend_pid();" >/dev/null

	# Step B: Drop the database (Independent call - cannot be in a block)
	psql -h "$HOST" -U "$USER" -d postgres -c "DROP DATABASE \"$TARGET_DB\";" >/dev/null
fi

# --- 3. Create Fresh Target ---
psql -h "$HOST" -U "$USER" -d postgres -c "CREATE DATABASE \"$TARGET_DB\";" >/dev/null

if [ $? -ne 0 ]; then
	echo "❌ Error: Could not create database $TARGET_DB"
	exit 1
fi

# --- 4. Clone Data ---
pg_dump -h "$HOST" -U "$USER" -d "$SOURCE_DB" | psql -h "$HOST" -U "$USER" -d "$TARGET_DB" >/dev/null

if [ $? -eq 0 ]; then
	echo "✅ Success: $TARGET_DB is a fresh clone of $SOURCE_DB."
else
	echo "❌ Error: The clone failed during data transfer."
	exit 1
fi

unset PGPASSWORD
