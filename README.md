# 🛡️ Safe Runner Template

**Run untrusted code securely during interviews and audits.**

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/dzentota/safe-runner)

This repository is a hardened sandbox designed to execute untrusted code (like interview test tasks) without risking your local machine. It leverages ephemeral environments (GitHub Codespaces) and strict container policies (Defense in Depth).

## 🚀 The Philosophy
1.  **Secure by Default:** Execution relies on aggressive flags (e.g., `npm --ignore-scripts`).
2.  **Deny by Default:** Network ports and root privileges are locked down.
3.  **Disposable:** The environment is designed to self-destruct after 2 hours.

## ⚡ Quick Start

1.  **Do NOT clone the untrusted repo directly.**
2.  Click the **"Open in GitHub Codespaces"** badge above (or fork this repo and create a Codespace).
3.  Once inside the VS Code terminal, create a subfolder and clone the untrusted code into it:
    ```bash
    mkdir target
    git clone <UNTRUSTED_REPO_URL> target
    cd target
    ```
4.  Run the automated audit and installer:
    ```bash
    ../audit.sh  # Check for red flags
    ../run.sh    # Install and run safely
    ```

## 🔒 Security Features

### 1. Hardened Container (`devcontainer.json`)
The environment runs with minimized Linux kernel capabilities:
* `--cap-drop=ALL`: Removes all root capabilities.
* `--security-opt=no-new-privileges`: Prevents `sudo` or SUID binary escalation.
* `--pids-limit=256`: Prevents fork-bomb DoS attacks.

### 2. Static Audit (`audit.sh`)
Automatically scans for "Red Flags" in the codebase:
* `postinstall`, `preinstall` scripts in `package.json` / `composer.json`.
* `child_process`, `exec`, `shell_exec` usage in source files.
* Suspicious network calls (`curl`, `wget`).
* Hidden directories.

### 3. Safe Execution Rules (`rules/`)
Instead of running standard install commands (which execute arbitrary code), we use language-specific guardrails:

* **Node.js:** Uses `npm ci --ignore-scripts`. Blocks malware triggers during installation.
* **PHP:** Uses `composer install --no-scripts` and runs the server with `-d disable_functions=exec,shell_exec...`.
* **Python:** Uses `pip install --no-build-isolation --no-deps`.

### 4. Network & Time Guardrails
* Apps are forced to bind to `127.0.0.1` to prevent public internet exposure.
* **Time Bomb:** A background process will kill the session automatically after 2 hours to prevent persistence.

## ⚠️ Disclaimer
This tool mitigates common attacks (droppers, script-based malware) but may not stop zero-day kernel exploits. **Always review code before running it, even in a sandbox.**
