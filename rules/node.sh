#!/usr/bin/env bash
set -e

# Output Colors
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}[*] Installing Node.js dependencies safely...${NC}"
# --ignore-scripts: CRITICAL. Blocks 'postinstall' scripts (malware vectors).
# --no-audit: Speeds up install (we rely on manual audit).
npm install --ignore-scripts --no-audit

echo -e "${GREEN}[*] Attempting to start application...${NC}"

# Force the HOST to localhost (127.0.0.1) to prevent external network exposure.
export HOST=127.0.0.1 

if grep -q "\"dev\"" package.json; then
    echo "[*] Running 'dev' script..."
    npm run dev -- --ignore-scripts
elif grep -q "\"start\"" package.json; then
    echo "[*] Running 'start' script..."
    npm run start -- --ignore-scripts
else
    echo "[!] No standard 'dev' or 'start' script found in package.json."
    echo "[!] Run manually: HOST=127.0.0.1 npm run <script> --ignore-scripts"
fi
