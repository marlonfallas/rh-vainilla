#!/bin/bash

# Horilla Backup Script
# Location: /nvme0n1-disk/clientes/vainilla/horilla/backup-horilla.sh

BACKUP_DIR="/sdb-disk/backups/vainilla/horilla"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
DB_CONTAINER="postgres-horilla-vainilla"
DB_NAME="horilla"
DB_USER="horilla"

# Create backup directory if not exists
mkdir -p $BACKUP_DIR

echo "Starting Horilla backup - $TIMESTAMP"

# Backup database
echo "Backing up database..."
docker exec $DB_CONTAINER pg_dump -U $DB_USER $DB_NAME | gzip > "$BACKUP_DIR/horilla_db_$TIMESTAMP.sql.gz"

# Backup media files
echo "Backing up media files..."
tar -czf "$BACKUP_DIR/horilla_media_$TIMESTAMP.tar.gz" -C /nvme0n1-disk/clientes/vainilla/horilla media/

# Backup config
echo "Backing up configuration..."
cp /nvme0n1-disk/clientes/vainilla/horilla/.env "$BACKUP_DIR/env_$TIMESTAMP.bak"

# Remove old backups (keep last 10)
echo "Cleaning old backups..."
ls -t "$BACKUP_DIR"/horilla_db_*.sql.gz | tail -n +11 | xargs -r rm
ls -t "$BACKUP_DIR"/horilla_media_*.tar.gz | tail -n +11 | xargs -r rm
ls -t "$BACKUP_DIR"/env_*.bak | tail -n +11 | xargs -r rm

echo "Backup completed successfully!"
