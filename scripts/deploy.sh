#!/usr/bin/env bash
# ==============================================================================
# Automated Application Deployment Script for Azure Linux Virtual Machine
# ==============================================================================

set -euo pipefail

APP_DIR="/opt/devops-webapp"
NODE_PORT="${PORT:-3000}"

echo ">>> [1/5] Creating application target directory: ${APP_DIR}..."
sudo mkdir -p "${APP_DIR}"
sudo chown -R "$USER:$USER" "${APP_DIR}"

echo ">>> [2/5] Copying application artifacts..."
cp -r app/* "${APP_DIR}/"

echo ">>> [3/5] Installing production npm packages..."
cd "${APP_DIR}"
npm install --omit=dev --no-audit --no-fund

echo ">>> [4/5] Starting application process with PM2 Process Manager..."
if command -v pm2 >/dev/null 2>&1; then
    pm2 stop devops-app || true
    pm2 start server.js --name devops-app --update-env
    pm2 save
else
    echo "PM2 not found. Starting with background node process..."
    nohup node server.js > app.log 2>&1 &
fi

echo ">>> [5/5] Performing local health probe..."
sleep 3
if curl -fs "http://127.0.0.1:${NODE_PORT}/api/health" >/dev/null 2>&1; then
    echo "=========================================================="
    echo "SUCCESS: Web Application deployed and healthy on port ${NODE_PORT}!"
    echo "=========================================================="
else
    echo "WARNING: Health check probe did not respond immediately. Check app.log."
fi
