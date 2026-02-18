#!/bin/bash

# Configuration
BACKUP_ROOT="$HOME/db_backups"
USER="postgres"
HOST="localhost"
DEFAULT_PASS="example"

usage() {
	echo "Usage: $0 -d <database_name> [-u <user>] [-h <host>]"
	exit 1
}

while getopts "d:u:h:" opt; do
	case $opt in
	d) DB_NAME="$OPTARG" ;;
	u) USER="$OPTARG" ;;
	h) HOST="$OPTARG" ;;
	*) usage ;;
	esac
done

if [[ -z "$DB_NAME" ]]; then usage; fi

# Set Password
export PGPASSWORD=${PGPASSWORD:-$DEFAULT_PASS}

# --- 1. Prepare Environment ---
# Generate date in YYYY-MM-DD_HH-MM format for the filename
DATE_STAMP=$(date +%Y-%m-%d_%H-%M-%S)
TARGET_DIR="$BACKUP_ROOT/$DB_NAME"
BACKUP_FILE="$TARGET_DIR/$DATE_STAMP.sql"

# Create directory if it doesn't exist
mkdir -p "$TARGET_DIR"

echo "🐘 Starting backup for database: $DB_NAME..."

# --- 2. Execute Backup ---
# We use -Fp for plain text (SQL).
# Change to -Fc (custom format) if you want compressed/restorable via pg_restore.
pg_dump -h "$HOST" -U "$USER" -d "$DB_NAME" -Fp >"$BACKUP_FILE"

# --- 3. Verify and Cleanup ---
if [ $? -eq 0 ]; then
	SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
	echo "✅ Success!"
	echo "📍 Location: $BACKUP_FILE"
	echo "📦 Size: $SIZE"
else
	echo "❌ Error: pg_dump failed."
	# Remove the empty file if it failed
	rm -f "$BACKUP_FILE"
	exit 1
fi

unset PGPASSWORD
