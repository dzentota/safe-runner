#!/usr/bin/env bash
set -e

# Output Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}[*] Safe Runner Initialized.${NC}"

# Detect project type based on file existence
if [ -f package.json ]; then
    echo -e "${GREEN}[+] Node.js project detected.${NC}"
    bash rules/node.sh

elif [ -f requirements.txt ] || [ -f pyproject.toml ]; then
    echo -e "${GREEN}[+] Python project detected.${NC}"
    bash rules/python.sh

elif [ -f composer.json ] || [ -f index.php ]; then
    echo -e "${GREEN}[+] PHP project detected.${NC}"
    bash rules/php.sh

else
    echo -e "${RED}[!] Unknown project type.${NC}"
    echo -e "${RED}[!] No 'package.json', 'requirements.txt', or 'composer.json' found.${NC}"
    exit 1
fi
