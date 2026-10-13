#!/usr/bin/env bash
# Deploy script — run ON THE SERVER from the project directory (the one
# that contains manage.py):  ./deploy.sh
set -euo pipefail

cd "$(dirname "$0")"

# manage.py defaults to local/dev settings; the server must use production.
export DJANGO_SETTINGS_MODULE=config.settings.production

# Virtualenv location (override with: VENV=/path/to/venv ./deploy.sh)
VENV="${VENV:-/srv/portal-pec/venv}"
PY="$VENV/bin/python"

echo "==> Pulling latest code"
git pull

echo "==> Installing dependencies"
"$PY" -m pip install --upgrade pip
"$PY" -m pip install -r requirements.txt

echo "==> Running database migrations"
"$PY" manage.py migrate --no-input

echo "==> Collecting static files"
"$PY" manage.py collectstatic --no-input

echo "==> Restarting gunicorn"
sudo systemctl restart portal-pec

echo "==> Deploy finished"
