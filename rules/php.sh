#!/usr/bin/env bash
set -e

# Output Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}[*] Safe PHP Install Detected${NC}"

if [ -f composer.json ]; then
    echo -e "${GREEN}[*] Installing Composer dependencies safely...${NC}"
    # --no-scripts: Blocks execution of 'post-install-cmd' scripts in composer.json
    # --no-plugins: Blocks Composer plugins from running code
    composer install --no-scripts --no-plugins --no-interaction --prefer-dist
else
    echo -e "${GREEN}[*] No composer.json found. Skipping dependency install.${NC}"
fi

echo -e "${GREEN}[*] Starting PHP Built-in Server (Hardened)...${NC}"

# Determine Document Root (Laravel/Symfony use /public, others use root)
DOC_ROOT="."
if [ -d "public" ]; then
    DOC_ROOT="public"
fi

echo -e "${GREEN}[*] Document Root: ${DOC_ROOT}${NC}"
echo -e "${RED}[!] SAFETY LOCK: Exec/System functions are disabled via CLI flags.${NC}"

# Start PHP Server
# -S 127.0.0.1:8000 : Bind locally only
# -t : Document root
# -d disable_functions : Disable shell execution capabilities at the runtime level
php \
    -d disable_functions=exec,passthru,shell_exec,system,proc_open,popen,curl_exec,curl_multi_exec,parse_ini_file,show_source \
    -S 127.0.0.1:8000 \
    -t "$DOC_ROOT"
