#!/usr/bin/env bash
set -euo pipefail

MYSQL_BACKUP=${MYSQL_BACKUP:-}
GRAFANA_BACKUP=${GRAFANA_BACKUP:-}

if [[ -z "$MYSQL_BACKUP" && -z "$GRAFANA_BACKUP" ]]; then
  echo "Set MYSQL_BACKUP and/or GRAFANA_BACKUP to restore." >&2
  exit 1
fi

if [[ -n "$MYSQL_BACKUP" ]]; then
  echo "Restoring MySQL from $MYSQL_BACKUP"
  docker exec -i smart-hostel-mysql mysql -uroot -prootpass hostel_management < "$MYSQL_BACKUP"
fi

if [[ -n "$GRAFANA_BACKUP" ]]; then
  echo "Restoring Grafana data from $GRAFANA_BACKUP"
  docker run --rm \
    -v smart-hostel_grafana_data:/var/lib/grafana \
    -v "$(dirname "$GRAFANA_BACKUP")":/backup \
    alpine:3.20 \
    sh -c "tar -xzf /backup/$(basename "$GRAFANA_BACKUP") -C /var/lib/grafana"
fi

printf 'Restore complete.\n'
