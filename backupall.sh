#!/bin/bash

# Configuration
BACKUP_SCRIPT="backupdb"
DATABASES=("channel_manager" "datafetch" "datafetch2")
BACKUP_ROOT="$HOME/db_backups"

# Get today's date prefix
TODAY=$(date +%Y-%m-%d)

echo "📅 Starting Concurrent Daily Backup Batch: $TODAY"
echo "------------------------------------------"

# Function to handle individual backup logic in the background
run_backup() {
	local DB=$1
	local TARGET_DIR="$BACKUP_ROOT/$DB"

	if ls "$TARGET_DIR/$TODAY"* 1>/dev/null 2>&1; then
		echo "⏩ Skipping [$DB]: A backup for today already exists."
	else
		echo "🚀 Starting background backup for [$DB]..."

		# Call the script
		bash "$BACKUP_SCRIPT" -u "postgres" -d "$DB" >/dev/null 2>&1

		if [ $? -eq 0 ]; then
			echo "✅ [$DB] completed successfully."
		else
			echo "❌ [$DB] FAILED."
		fi
	fi
}

# Loop and fire off background processes
for DB in "${DATABASES[@]}"; do
	run_backup "$DB" &
done

# Wait for all background jobs to finish
wait

echo "------------------------------------------"
echo "🏁 All concurrent processes finished."
