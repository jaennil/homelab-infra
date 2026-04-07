#!/usr/bin/env bash
set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/jaennil/guide_helper.git}"
APP_DIR="${APP_DIR:-/home/jaennil/services/guide_helper}"
CLAUDE_DIR="${APP_DIR}/claude-code-api"
PROXY_URL="${PROXY_URL:-http://10.43.101.33:1081}"
SERVICE_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/claude-code-api.service"

mkdir -p "$(dirname "${APP_DIR}")"

if [ -d "${APP_DIR}/.git" ]; then
  git -C "${APP_DIR}" fetch origin main
  git -C "${APP_DIR}" checkout main
  git -C "${APP_DIR}" pull --ff-only origin main
else
  git clone "${REPO_URL}" "${APP_DIR}"
fi

cd "${CLAUDE_DIR}"
python3 -m venv .venv
HTTP_PROXY="${PROXY_URL}" HTTPS_PROXY="${PROXY_URL}" .venv/bin/pip install --upgrade pip setuptools wheel
HTTP_PROXY="${PROXY_URL}" HTTPS_PROXY="${PROXY_URL}" .venv/bin/pip install -e .

sudo install -o root -g root -m 0644 "${SERVICE_FILE}" /etc/systemd/system/claude-code-api.service
sudo systemctl daemon-reload
sudo systemctl enable --now claude-code-api.service
sudo systemctl restart claude-code-api.service
sudo systemctl --no-pager --full status claude-code-api.service
