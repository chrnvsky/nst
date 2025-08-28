#!/bin/bash

set -euo pipefail

# Конфигурация
PIDFILE=/tmp/backup.pid
TIMESTAMP=$(date '+%F-%H-%M')
LIMIT=31
DIRECTORY=/mnt/backup_db
LOGFILE=/var/log/postgres_backup.log

# Docker конфигурация
CONTAINER_NAME="sync-postgres_db-1"
DB_USER="kpi_user"
DB_NAME="kpi_db"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" | tee -a $LOGFILE
}

# Проверка PID
if [ -f $PIDFILE ] && pgrep -F $PIDFILE &>/dev/null; then
    log "ERROR: Backup already running"
    exit 1
fi
echo $$ > $PIDFILE
trap 'rm -f $PIDFILE' EXIT

# Проверка контейнера
if ! docker ps --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
    log "ERROR: Container $CONTAINER_NAME not running"
    exit 1
fi

log "Starting backup for database: $DB_NAME"
mkdir -p $DIRECTORY

# Создание бэкапа для базы kpi_db
BACKUP_FILE="$DIRECTORY/kpi_db_backup_${TIMESTAMP}.sql.gz"

if docker exec $CONTAINER_NAME pg_dump \
    -U $DB_USER \
    -d $DB_NAME \
    --verbose \
    --no-owner \
    --no-privileges \
    | gzip > $BACKUP_FILE; then
    
    log "Database backup completed: $BACKUP_FILE"
    log "Backup size: $(du -h $BACKUP_FILE | cut -f1)"
else
    log "ERROR: pg_dump failed for database $DB_NAME"
    rm -f $BACKUP_FILE
    exit 1
fi

# Очистка старых бэкапов
COUNT=$(find $DIRECTORY -name "kpi_db_backup_*.sql.gz" | wc -l)
log "Current backup count: $COUNT, limit: $LIMIT"

while [ "$COUNT" -gt "$LIMIT" ]; do
    oldest=$(find $DIRECTORY -name "kpi_db_backup_*.sql.gz" | sort | head -n1)
    log "Removing old backup: $(basename $oldest)"
    rm -f "$oldest"
    COUNT=$((COUNT - 1))
done

log "Backup process for $DB_NAME completed"