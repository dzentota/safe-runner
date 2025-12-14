#!/usr/bin/env bash
set -e

# Output Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}[*] 🛡️  Starting Deep Security Audit...${NC}"

# ==============================================================================
# PHASE 1: SCA (Software Composition Analysis) - Checking Dependencies
# ==============================================================================
echo -e "\n${YELLOW}[Phase 1] Checking Dependencies for Known Vulnerabilities (OSV)...${NC}"

# OSV-Scanner checks lockfiles (package-lock.json, requirements.txt, composer.lock)
# against the global Open Source Vulnerability database.
if command -v osv-scanner &> /dev/null; then
    # We run it but don't exit on error (just warn), so user can decide.
    osv-scanner -r . || echo -e "${RED}[!] Vulnerabilities found in dependencies! Check output above.${NC}"
else
    echo -e "${RED}[!] osv-scanner not found. Skipping SCA.${NC}"
fi

# ==============================================================================
# PHASE 2: Native Package Manager Audits
# ==============================================================================
echo -e "\n${YELLOW}[Phase 2] Running Native Package Manager Audits...${NC}"

if [ -f package.json ]; then
    echo -e "${BLUE}[Node] Running npm audit...${NC}"
    npm audit --audit-level=high || echo -e "${RED}[!] High severity npm issues found.${NC}"
fi

if [ -f composer.json ]; then
    echo -e "${BLUE}[PHP] Running composer audit...${NC}"
    composer audit || echo -e "${RED}[!] Composer issues found.${NC}"
fi

# ==============================================================================
# PHASE 3: SAST (Static Application Security Testing) - Code Analysis
# ==============================================================================
echo -e "\n${YELLOW}[Phase 3] Scanning Source Code with Semgrep...${NC}"

if command -v semgrep &> /dev/null; then
    echo -e "${BLUE}[*] Downloading and running security rules...${NC}"

    # Semgrep Rules:
    # - p/security-audit: General security best practices
    # - p/secrets: Detects hardcoded API keys, tokens, passwords
    # - p/javascript: JS specific dangerous patterns (eval, etc)
    # - p/python: Python specific patterns (exec, pickles)
    # --error: Forces exit code 1 if issues are found (optional, we keep it loose here)

    semgrep scan \
        --config=p/security-audit \
        --config=p/secrets \
        --quiet \
        . || echo -e "${RED}[!] Semgrep found potential issues in the code!${NC}"
else
    echo -e "${RED}[!] Semgrep not installed. Skipping SAST.${NC}"
fi

# ==============================================================================
# PHASE 4: Anti-Obfuscation & Suspicious Files (Classic Checks)
# ==============================================================================
echo -e "\n${YELLOW}[Phase 4] Checking for Obfuscation & Suspicious Files...${NC}"

# Check for high-entropy strings or huge lines (common in minified malware) in non-minified files
# This uses grep to find lines longer than 1000 chars in source files
grep -r . -I --exclude-dir=node_modules --exclude-dir=vendor --exclude-dir=.git --exclude="*.min.js" --exclude="*.map" | awk 'length($0) > 2000 {print "WARNING: Very long line detected in " $1 " (possible obfuscated payload)"}'

# Check for hidden directories again (classic dropper hideout)
find . -type d -name ".*" -not -name "." -not -name ".." -not -name ".git" -not -name ".devcontainer" -not -name ".vscode"

echo -e "\n${GREEN}[*] Audit Complete. If 'osv-scanner' or 'semgrep' showed red errors, DO NOT RUN THIS CODE.${NC}"