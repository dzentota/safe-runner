#!/usr/bin/env bash
set -e

# Output Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}[*] Starting Static Security Audit...${NC}"

# --- 1. NODE.JS CHECKS ---
if [ -f package.json ]; then
    echo -e "\n${YELLOW}[?] Checking package.json for lifecycle hooks...${NC}"
    if grep -E "preinstall|postinstall|prepare|prepublish" package.json; then
        echo -e "${RED}[!] WARNING: Dangerous lifecycle scripts detected in package.json!${NC}"
        echo -e "${RED}[!] These are commonly used for malware droppers.${NC}"
    else
        echo -e "${GREEN}[+] No obvious npm lifecycle hooks found.${NC}"
    fi
fi

# --- 2. PHP CHECKS ---
if [ -f composer.json ]; then
    echo -e "\n${YELLOW}[?] Checking composer.json for script hooks...${NC}"
    if grep -E "post-install-cmd|pre-install-cmd|post-update-cmd" composer.json; then
        echo -e "${RED}[!] WARNING: Dangerous Composer scripts detected in composer.json!${NC}"
    else
        echo -e "${GREEN}[+] No obvious Composer script hooks found.${NC}"
    fi
fi

# --- 3. CODE SCANNING ---
echo -e "\n${YELLOW}[?] Scanning source code for dangerous patterns (exec, eval, shells)...${NC}"

# We exclude vendor/node_modules to avoid false positives in libraries.
# grep returns 0 if found (bad), 1 if not found. We use '|| true' to prevent script exit.
grep -rnE "child_process|exec\(|spawn\(|eval\(|shell_exec|system\(|passthru" . \
    --exclude-dir=node_modules \
    --exclude-dir=vendor \
    --exclude=audit.sh \
    --exclude=run.sh || true

# --- 4. NETWORK TOOLS SCANNING ---
echo -e "\n${YELLOW}[?] Scanning for network tools (curl, wget, nc)...${NC}"
grep -rnE "curl |wget |nc |bash -i" . \
    --exclude-dir=node_modules \
    --exclude-dir=vendor \
    --exclude=audit.sh \
    --exclude=run.sh || true

# --- 5. HIDDEN FILES CHECK ---
echo -e "\n${YELLOW}[?] Checking for suspicious hidden directories...${NC}"
find . -type d -name ".*" -not -name "." -not -name ".." -not -name ".git" -not -name ".devcontainer" || true

echo -e "\n${GREEN}[*] Audit Complete. Please review any Red warnings above.${NC}"
