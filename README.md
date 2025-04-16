# PostgreSQL Backup and Restore with pgBackRest and Wasabi

This repository contains scripts to help you set up and manage PostgreSQL backups using pgBackRest with Wasabi S3-compatible storage.

## Prerequisites

- PostgreSQL 12 or later installed
- Root/sudo access
- Wasabi account with:
  - Access Key
  - Secret Key
  - Bucket created
  - Region information

## Installation

1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd postgres-backup-restore
   ```

2. Make the scripts executable:
   ```bash
   chmod +x install.sh restore.sh backup.sh
   ```

3. Run the installation script:
   ```bash
   sudo ./install.sh
   ```

4. Copy the sample configuration:
   ```bash
   sudo cp pgbackrest.conf /etc/pgbackrest/pgbackrest.conf
   sudo chmod 640 /etc/pgbackrest/pgbackrest.conf
   ```

5. Set up environment variables for Wasabi credentials:
   ```bash
   sudo tee /etc/profile.d/pgbackrest.sh << EOF
   export WASABI_KEY="your-access-key"
   export WASABI_SECRET="your-secret-key"
   export WASABI_REGION="your-region"
   export WASABI_BUCKET="your-bucket"
   EOF
   ```

## Backup Configuration

The backup system is configured to:
- Perform full backups every 3 days at 2 AM
- Perform incremental backups every 2 hours
- Maintain a maximum of 3 full backups (older backups are automatically removed)
- Compress backups with level 3 compression
- Verify backups after creation

### Backup Retention

The system is configured to retain only 3 full backups (`repo1-retention-full=3` in pgbackrest.conf). When a new full backup is taken:
- The oldest full backup is automatically deleted
- Any incremental backups that depend on the deleted full backup are also removed
- This ensures your backup storage doesn't grow indefinitely

To manage backups:

```bash
# List all backups
pgbackrest --stanza=pgdb info

# Delete a specific backup
pgbackrest --stanza=pgdb --type=full --target="2024-01-01 00:00:00" delete

# Delete all backups (use with caution!)
pgbackrest --stanza=pgdb delete
```

### Backup Schedule

To set up automated backups, add the following to your crontab:

```bash
# Run full backup every 3 days at 2 AM
0 2 */3 * * /path/to/full_backup.sh

# Run incremental backup every 2 hours
0 */2 * * * /path/to/incremental_backup.sh

```

The backup schedule works as follows:
- Full backups: Every 3 days at 2 AM (using full_backup.sh)
- Incremental backups: Every 2 hours (using incremental_backup.sh)
- WAL archiving: Every 5 minutes

Each backup type has its own log file:
- Full backups: `/var/log/pgbackrest_full_backup.log`
- Incremental backups: `/var/log/pgbackrest_incremental_backup.log`

## Restoring from Wasabi Backup

The restore process will:
1. Stop the PostgreSQL service
2. Clean the existing data directory
3. Restore from your Wasabi backup
4. Restart PostgreSQL

### Steps to Restore

1. Ensure you have your Wasabi credentials ready:
   - Access Key
   - Secret Key
   - Region (e.g., ap-southeast-1)
   - Bucket Name

2. Run the restore script:
   ```bash
   sudo ./restore.sh
   ```

3. When prompted, enter your Wasabi credentials.

4. Confirm the restore operation when prompted.

### Important Notes

- The restore process will DELETE existing PostgreSQL data
- Make sure you have sufficient disk space for the restore
- The script assumes PostgreSQL 12 with default data directory at `/var/lib/postgresql/12/main`
- Logs are written to `/var/log/pgbackrest_restore.log`

## Configuration Details

The restore script uses the following default configuration:
- Stanza name: `pgdb`
- PostgreSQL data directory: `/var/lib/postgresql/12/main`
- PostgreSQL user: `postgres`
- Configuration file: `/etc/pgbackrest/pgbackrest.conf`
- Log directory: `/var/log/pgbackrest`

### Log Files

pgBackRest maintains several log files in `/var/log/pgbackrest/`:
- `pgbackrest.log` - Main log file containing all operations
- `archive-push.log` - Specific to WAL archiving operations
- `backup.log` - Backup operation logs
- `restore.log` - Restore operation logs

To view WAL archive logs in real-time:
```bash
# View all pgBackRest logs
tail -f /var/log/pgbackrest/pgbackrest.log

# View only WAL archive logs
tail -f /var/log/pgbackrest/archive-push.log

# View logs with timestamps
tail -f /var/log/pgbackrest/pgbackrest.log | grep "archive-push"
```

### Sample pgbackrest.conf

```ini
[global]
repo1-type=s3
repo1-path=/backup
repo1-retention-full=3
repo1-s3-key=${WASABI_KEY}
repo1-s3-key-secret=${WASABI_SECRET}
repo1-s3-bucket=${WASABI_BUCKET}
repo1-s3-endpoint=s3.${WASABI_REGION}.wasabisys.com
repo1-s3-region=${WASABI_REGION}
repo1-s3-verify-ssl=n

[pgdb]
pg1-path=/var/lib/postgresql/12/main
pg1-port=5432

[global:archive-push]
compress-level=3

[global:backup]
compress-level=3
start-fast=y
delta=y
```

## Troubleshooting

If you encounter issues:

1. Check the log files:
   ```bash
   cat /var/log/pgbackrest_restore.log
   cat /var/log/pgbackrest_backup.log
   ```

2. Verify pgBackRest installation:
   ```bash
   pgbackrest --version
   ```

3. Ensure PostgreSQL service is running:
   ```bash
   systemctl status postgresql
   ```

4. Check backup status:
   ```bash
   pgbackrest --stanza=pgdb info
   ```

## Additional Resources

- [pgBackRest Documentation](https://pgbackrest.org/)
- [Wasabi Documentation](https://docs.wasabi.com/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/) 