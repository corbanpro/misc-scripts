#!/bin/bash

# Default values
USER="postgres"
HOST="localhost"
DEFAULT_PASS="example"
FORCE=

usage() {
	echo "Usage: $0 -f <backup_file_path> -t <target_db> [-u <user>] [-h <host>]"
	exit 1
}

while getopts "f:t:u:h:" opt; do
	case $opt in
	f) BACKUP_FILE="$OPTARG" ;;
	t) TARGET_DB="$OPTARG" ;;
	u) USER="$OPTARG" ;;
	h) HOST="$OPTARG" ;;
	*) usage ;;
	esac
done

if [[ -z "$BACKUP_FILE" || -z "$TARGET_DB" ]]; then usage; fi

# --- 1. Pre-flight Checks ---
if [[ ! -f "$BACKUP_FILE" ]]; then
	echo "❌ Error: Backup file not found at $BACKUP_FILE"
	exit 1
fi

export PGPASSWORD=${PGPASSWORD:-$DEFAULT_PASS}

# --- 2. Handle Existing Target ---
DB_EXISTS=$(psql -h "$HOST" -U "$USER" -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='$TARGET_DB'")

if [[ "$DB_EXISTS" = "1" ]]; then
	echo "⚠️  Target database '$TARGET_DB' already exists."
	read -p "This will OVERWRITE the database. Continue? (y/N): " confirm
	if [[ $confirm != [yY] ]]; then
		echo "Operation cancelled."
		exit 0
	fi

	echo "🔄 Terminating connections and dropping '$TARGET_DB'..."
	psql -h "$HOST" -U "$USER" -d postgres -c "REVOKE CONNECT ON DATABASE \"$TARGET_DB\" FROM public;" >/dev/null
	psql -h "$HOST" -U "$USER" -d postgres -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$TARGET_DB' AND pid <> pg_backend_pid();" >/dev/null
	psql -h "$HOST" -U "$USER" -d postgres -c "DROP DATABASE \"$TARGET_DB\";" >/dev/null
fi

# --- 3. Create Fresh Target ---
echo "🏗️  Creating fresh database '$TARGET_DB'..."
psql -h "$HOST" -U "$USER" -d postgres -c "CREATE DATABASE \"$TARGET_DB\";" >/dev/null

if [ $? -ne 0 ]; then
	echo "❌ Error: Could not create database $TARGET_DB"
	exit 1
fi

# --- 4. Restore Data ---
echo "📥 Restoring data from $BACKUP_FILE..."

# Note: Using psql because the backup was created with -Fp (Plain text SQL)
psql -h "$HOST" -U "$USER" -d "$TARGET_DB" <"$BACKUP_FILE" >/dev/null

if [ $? -eq 0 ]; then
	echo "✅ Success: Database '$TARGET_DB' has been restored."
else
	echo "❌ Error: The restore failed."
	exit 1
fi

unset PGPASSWORD
