#!/bin/bash

# === Prompt user for sensitive inputs ===
read -p "Enter your Wasabi Access Key: " WASABI_KEY
read -s -p "Enter your Wasabi Secret Key: " WASABI_SECRET
echo
read -p "Enter your Wasabi Region (e.g., ap-southeast-1): " WASABI_REGION
read -p "Enter your Wasabi Bucket Name: " WASABI_BUCKET

# === Static Config ===
STANZA="pgdb"
PGDATA="/var/lib/postgresql/12/main"
PGUSER="postgres"
PGSERVICE="postgresql"
CONF_PATH="/etc/pgbackrest/pgbackrest.conf"
LOG_FILE="/var/log/pgbackrest_restore.log"

# === Logging ===
log() {
    echo "[$(date)] $1" | tee -a "$LOG_FILE"
}

check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        log "Please run this script as root."
        exit 1
    fi
}

confirm_restore() {
    read -p "⚠️ This will DELETE existing PostgreSQL data and restore from backup. Continue? (yes/no): " yn
    case $yn in
        [Yy][Ee][Ss] ) ;;
        * ) log "Aborted by user."; exit 1 ;;
    esac
}

generate_pgbackrest_conf() {
    log "Generating /etc/pgbackrest/pgbackrest.conf"
    mkdir -p /etc/pgbackrest
    cat > "$CONF_PATH" <<EOF
[global]
repo1-type=s3
repo1-path=/eenadu_backup
repo1-retention-full=2
repo1-s3-key=$WASABI_KEY
repo1-s3-key-secret=$WASABI_SECRET
repo1-s3-bucket=$WASABI_BUCKET
repo1-s3-endpoint=s3.$WASABI_REGION.wasabisys.com
repo1-s3-region=$WASABI_REGION
repo1-s3-verify-ssl=n

[$STANZA]
pg1-path=$PGDATA
pg1-port=5432

[global:archive-push]
compress-level=3
EOF
    chmod 640 "$CONF_PATH"
}

stop_postgres() {
    log "Stopping PostgreSQL service..."
    systemctl stop "$PGSERVICE"
}

clean_pgdata() {
    log "Cleaning existing PostgreSQL data directory: $PGDATA"
    rm -rf "$PGDATA"/*
}

create_stanza() {
    log "Creating pgBackRest stanza..."
    sudo -u "$PGUSER" pgbackrest --stanza="$STANZA" stanza-create
}

run_restore() {
    log "Restoring PostgreSQL from Wasabi backup..."
    sudo -u "$PGUSER" pgbackrest --stanza="$STANZA" restore
}

start_postgres() {
    log "Starting PostgreSQL service..."
    systemctl start "$PGSERVICE"
}

# === Main Flow ===
check_root
confirm_restore
generate_pgbackrest_conf
stop_postgres
clean_pgdata
create_stanza
run_restore
start_postgres

log "✅ Restore from Wasabi completed successfully!"
