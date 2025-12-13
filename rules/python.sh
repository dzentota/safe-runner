#!/usr/bin/env bash
set -e

# Output Colors
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}[*] Installing Python dependencies safely...${NC}"

# --no-deps: Prevents installing unlisted dependencies.
# --no-build-isolation: Prevents code execution during the build process.
pip install --no-build-isolation --no-deps -r requirements.txt

echo -e "${GREEN}[*] Dependencies installed.${NC}"
echo "[!] Auto-start for Python is not configured due to framework variety."
echo "[!] Please run your app manually (e.g., 'python app.py')."
echo "[!] REMINDER: Do not use 'sudo'. Do not expose ports to 0.0.0.0."
