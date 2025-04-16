#!/bin/bash

# === Static Config ===
STANZA="pgdb"
PGUSER="postgres"
LOG_FILE="/var/log/pgbackrest_incremental_backup.log"

# === Logging ===
log() {
    echo "[$(date)] $1" | tee -a "$LOG_FILE"
}

# === Check if running as root ===
if [ "$(id -u)" -ne 0 ]; then
    log "Please run this script as root."
    exit 1
fi

# === Perform incremental backup ===
log "Starting incremental backup..."
sudo -u "$PGUSER" pgbackrest --stanza="$STANZA" backup --type=incr
if [ $? -eq 0 ]; then
    log "Incremental backup completed successfully"
else
    log "Incremental backup failed"
    exit 1
fi

# === Verify backup ===
log "Verifying backup..."
sudo -u "$PGUSER" pgbackrest --stanza="$STANZA" verify
if [ $? -eq 0 ]; then
    log "Backup verification successful"
else
    log "Backup verification failed"
    exit 1
fi

log "Incremental backup process completed successfully" 