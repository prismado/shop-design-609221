#!/bin/bash

mariadb-dump -h "$DB_HOST" -u root -p$DB_ROOT_PASS \
  --default-character-set=utf8mb4 \
  --routines --events --triggers \
  "$DB_NAME" > "full_dump_${DB_NAME}.sql"
