#!/usr/bin/env bash
# We do NOT use 'set -e' globally here because we want to handle install errors manually.

# Output Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}[*] Installing Node.js dependencies safely...${NC}"

# 1. Try standard safe install
# --ignore-scripts: BLOCKS MALWARE (Critical at install time)
# --no-audit: Speeds up install
if npm install --ignore-scripts --no-audit; then
    echo -e "${GREEN}[+] Dependencies installed successfully.${NC}"
else
    echo -e "${YELLOW}[!] Standard install failed (likely dependency conflict).${NC}"
    echo -e "${YELLOW}[!] Retrying with --legacy-peer-deps...${NC}"

    # 2. Retry with legacy peer deps (fixes ERESOLVE errors)
    if npm install --ignore-scripts --no-audit --legacy-peer-deps; then
        echo -e "${GREEN}[+] Dependencies installed with legacy peer deps.${NC}"
    else
        echo -e "${RED}[!] Install failed completely. Check logs.${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}[*] Attempting to start application...${NC}"

# Force the HOST to localhost (127.0.0.1)
export HOST=127.0.0.1

if grep -q "\"dev\"" package.json; then
    echo "[*] Running 'dev' script..."
    npm run --ignore-scripts dev
elif grep -q "\"start\"" package.json; then
    echo "[*] Running 'start' script..."
    npm run --ignore-scripts start
else
    echo "[!] No standard 'dev' or 'start' script found in package.json."
    echo "[!] Run manually: HOST=127.0.0.1 npm run <script> --ignore-scripts"
fi
