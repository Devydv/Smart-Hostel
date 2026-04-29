#!/usr/bin/env bash
set -euo pipefail

BACKUP_DIR=${BACKUP_DIR:-./backups}
TS=$(date +%Y%m%d_%H%M%S)

mkdir -p "$BACKUP_DIR"

printf 'Backing up MySQL...\n'
docker exec smart-hostel-mysql mysqldump -uroot -prootpass hostel_management > "$BACKUP_DIR/mysql_${TS}.sql"

printf 'Backing up Grafana data...\n'
docker run --rm \
  -v smart-hostel_grafana_data:/var/lib/grafana \
  -v "$BACKUP_DIR":/backup \
  alpine:3.20 \
  sh -c "tar -czf /backup/grafana_${TS}.tar.gz -C /var/lib/grafana ."

printf 'Backup complete: %s\n' "$BACKUP_DIR"
