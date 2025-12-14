# 🛡️ Safe Runner Template

**Run untrusted code securely.**

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/dzentota/safe-runner)

This is a **hardened, paranoid sandbox** designed to execute untrusted code (like interview take-home tasks) securely.
It uses ephemeral cloud environments (GitHub Codespaces) combined with strict container policies and automated forensic tools.

## 🚀 Why Use This?
* **Defense in Depth:** Multiple layers of security (Container permissions, Network isolation, Static Analysis).
* **Disposable:** The environment self-destructs after use.
* **Smart:** Automatically detects Node.js, Python, and PHP projects and runs them safely.

---

## ⚡ Quick Start

### 1. Enable Turbo Mode (Critical!) 🏎️
*By default, Codespaces take > 5 minutes to build. Do this once to make startup **instant (15s)**.*
1.  Go to this repository's **Settings** → **Codespaces**.
2.  Under **Prebuild configurations**, click **Set up prebuild**.
3.  Select branch `main` and your region. Click **Create**.
4.  Wait for the initial build to finish (Status: "Available").

### 2. Run the untrusted code
1.  Click the **"Open in GitHub Codespaces"** badge above.
2.  In the terminal, create a folder for the untrusted code:
    ```bash
    mkdir target
    git clone <UNTRUSTED_REPO_URL> target
    cd target
    ```
3.  **Phase 1: Deep Audit**
    Run the forensic scanner. It uses **Semgrep** (SAST) and **OSV-Scanner** (SCA) to find malware and vulnerabilities:
    ```bash
    ../audit.sh
    ```
4.  **Phase 2: Safe Execution**
    If the audit passes, run the safe launcher. It installs dependencies *without* scripts and locks down the runtime:
    ```bash
    ../run.sh
    ```
5.  **Phase 3: Nuke It** 🧨
    When finished, type the magic command to instantly destroy the cloud environment:
    ```bash
    nuke
    ```

---

## 🔒 Security Architecture

### Level 1: The Jail Cell (`devcontainer.json`)
We strip the container of administrative privileges to prevent breakouts:
* `--cap-drop=SYS_ADMIN`: You cannot control the system.
* `--cap-drop=NET_ADMIN`: You cannot sniff traffic or change firewall rules.
* `--security-opt=no-new-privileges`: Blocks `sudo` and SUID binary attacks.
* `--pids-limit=256`: Prevents Fork Bomb DoS attacks.

### Level 2: Forensic Tools (`audit.sh`)
Before you run code, we scan it with industry-standard tools pre-installed in the image:
* **OSV-Scanner (Google):** Checks `package-lock.json` / `requirements.txt` against the Open Source Vulnerability database (finds compromised dependencies).
* **Semgrep:** Static analysis looking for secrets, `eval()`, `exec()`, and other dangerous patterns in source code.
* **Anti-Obfuscation:** Scans for high-entropy strings and hidden folders.

### Level 3: Deny-by-Default Execution (`rules/`)
We never run standard install commands. We use "Paranoid Mode":
* **Node.js:** `npm ci --ignore-scripts` (Blocks `postinstall` malware).
* **PHP:** `composer install --no-scripts` + Runtime `disable_functions` (exec, shell_exec, system, passthru).
* **Python:** `pip install --no-build-isolation --no-deps`.

### Level 4: The Time Bomb
* **Automatic:** The environment executes `nuke` automatically after **2 hours** to prevent persistence.
* **Manual:** The `nuke` alias runs `gh codespace delete --codespace $CODESPACE_NAME --force`.

---

## 📦 Supported Stacks

The `run.sh` script automatically detects:
* ✅ **Node.js / Next.js / React** (`package.json`)
* ✅ **Python** (`requirements.txt` / `pyproject.toml`)
* ✅ **PHP** (`composer.json` / `index.php`)

---

## ⚠️ Disclaimer
**No sandbox is inescapable.** This tool mitigates common interview attacks (droppers, script-based malware, accidental exposure) but may not stop zero-day kernel exploits or sophisticated VM escape attacks.
* **Always review code.**
* **Never enter your real credentials (AWS, SSH, Banking) inside the sandbox.**