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
   chmod +x install.sh restore.sh
   ```

3. Run the installation script:
   ```bash
   sudo ./install.sh
   ```

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

## Troubleshooting

If you encounter issues:

1. Check the log file:
   ```bash
   cat /var/log/pgbackrest_restore.log
   ```

2. Verify pgBackRest installation:
   ```bash
   pgbackrest --version
   ```

3. Ensure PostgreSQL service is running:
   ```bash
   systemctl status postgresql
   ```

## Additional Resources

- [pgBackRest Documentation](https://pgbackrest.org/)
- [Wasabi Documentation](https://docs.wasabi.com/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/) 