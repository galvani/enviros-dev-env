#!/bin/bash
set -euo pipefail

SQL_FILE="data/eis_test.sql"
DEFAULT_DB="enviros"
TARGET_DB="${1:-$DEFAULT_DB}"

echo "Dropping and creating database '${TARGET_DB}'..."
docker compose exec -T mariadb mariadb -uroot -pkasdjasdjasjd -e "DROP DATABASE IF EXISTS \`${TARGET_DB}\`"
docker compose exec -T mariadb mariadb -uroot -pkasdjasdjasjd -e "CREATE DATABASE \`${TARGET_DB}\`"

echo "Importing database from '${SQL_FILE}' (filtered)..."
sed -E '/^\s*(DROP\s+DATABASE|CREATE\s+DATABASE|USE)\s+`[^`]+`;?/Id' "${SQL_FILE}" \
    | docker compose exec -T mariadb mariadb -uroot -pkasdjasdjasjd "${TARGET_DB}"

echo "Running composer install..."
docker compose exec -T php composer install

echo "Running migrations non-interactively..."
docker compose exec -T php vendor/bin/doctrine-migrations migrations:migrate --all-or-nothing --no-interaction

echo "Running fixtures..."
docker compose exec -T php bin/fixtures.php