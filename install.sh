#!/bin/bash

set -e

echo "Installing pgBackRest for PostgreSQL backup and restore..."

# Function to check if pgBackRest is already installed
check_pgbackrest() {
    if command -v pgbackrest &> /dev/null; then
        echo "pgBackRest is already installed: $(pgbackrest --version)"
        return 0
    else
        return 1
    fi
}

# If pgBackRest is already installed, exit
if check_pgbackrest; then
    echo "pgBackRest is already installed. No action needed."
    exit 0
fi

# Determine OS and package manager
if command -v apt-get &> /dev/null; then
    echo "Debian/Ubuntu system detected. Using apt..."
    
    # Install dependencies
    sudo apt-get update
    sudo apt-get install -y curl gnupg2 lsb-release
    
    # Add PostgreSQL repository if not already added
    if [ ! -f /etc/apt/sources.list.d/pgdg.list ]; then
        curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo gpg --dearmor -o /usr/share/keyrings/postgresql-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/postgresql-keyring.gpg] http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list > /dev/null
        sudo apt-get update
    fi
    
    # Install pgBackRest
    sudo apt-get install -y pgbackrest
    
elif command -v yum &> /dev/null; then
    echo "RHEL/CentOS/Fedora system detected. Using yum..."
    
    # Install PostgreSQL repository if not already installed
    if [ ! -f /etc/yum.repos.d/pgdg-redhat-repo-latest.noarch.rpm ]; then
        sudo yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-$(rpm -E %{rhel})-x86_64/pgdg-redhat-repo-latest.noarch.rpm
    fi
    
    # Install pgBackRest
    sudo yum install -y pgbackrest
    
elif command -v brew &> /dev/null; then
    echo "macOS with Homebrew detected. Using brew..."
    
    # Install pgBackRest
    brew install pgbackrest
    
else
    echo "Unsupported package manager. Please install pgBackRest manually."
    echo "Visit: https://pgbackrest.org/installation.html"
    exit 1
fi

# Verify installation
if check_pgbackrest; then
    echo "pgBackRest installation successful!"
    echo "Next steps:"
    echo "1. Configure pgbackrest.conf with your backup settings"
    echo "2. Create the repository directory"
    echo "3. Configure PostgreSQL for WAL archiving"
    echo "4. Set up cron jobs for scheduled backups"
    exit 0
else
    echo "ERROR: pgBackRest installation failed or verification failed."
    exit 1
fi 