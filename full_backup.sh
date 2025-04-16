#!/bin/bash

# === Static Config ===
STANZA="pgdb"
PGUSER="postgres"
LOG_FILE="/var/log/pgbackrest_full_backup.log"

# === Logging ===
log() {
    echo "[$(date)] $1" | tee -a "$LOG_FILE"
}

# === Check if running as root ===
if [ "$(id -u)" -ne 0 ]; then
    log "Please run this script as root."
    exit 1
fi

# === Perform full backup ===
log "Starting full backup..."
sudo -u "$PGUSER" pgbackrest --stanza="$STANZA" backup --type=full
if [ $? -eq 0 ]; then
    log "Full backup completed successfully"
else
    log "Full backup failed"
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

log "Full backup process completed successfully" 