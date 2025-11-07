# 🧰 Windows Package Installer

- This setup installs packages on a Windows 11 PC using your preferred package manager: `pip`, `choco`, or `winget`. It supports
  - ✅ Skipping already-installed packages
  - ✅ Graceful handling of typos, blank lines, and missing files
  - ✅ Summary reporting of installed, skipped, and failed packages
  - ✅ UTF-8 encoded rotating log file with timestamped entries
  - ✅ Full error output captured for failed installs
  - ✅ Emoji-prefixed logging for audit clarity (`✅`, `❌`, `📛`, `🔍`)
  - ✅ Logs the installed version number for each successful install
  - ✅ Uses an `Installer` enum to eliminate magic strings
  - ✅ Uses `Protocol` interfaces for install logic clarity and type safety
  - ✅ Includes `get_installed_version()` with modular helpers for audit-grade version tracking
  - ✅ Pylint-compliant structure with docstrings and type hints
  - ✅ Admin elevation check in both PowerShell and Python scripts
  - ✅ Safe exit if the selected package list is empty
  - ✅ Dynamically installs the latest Python 3.x version via Winget if missing
  - ✅ Avoids Microsoft Store alias trap by checking Winget directly
  - ✅ Instructs user to restart the terminal after Python install
  - ✅ Displays real-time install progress for each package (no more blinking cursor)


## 📦 Folder Contents

| File                   | Purpose |
|------------------------|---------|
| `windows_package_setup.ps1`  | PowerShell script to set up Python, Chocolatey, and run the installer |
| `install_packages.py`  | Python script with skip logic, logging, and summary reporting |
| `install_packages.log` | Rotating UTF-8 log file (auto-generated) |
| `pip_packages.txt`     | List of Python packages for pip |
| `choco_packages.txt`   | List of Chocolatey packages |
| `winget_packages.txt`  | List of Winget packages |
| `README.md`            | Usage instructions and overview |

## ▶️ How to Run

> ⚠️ Must have [PowerShell](https://github.com/powershell/powershell) terminal installed before executing the scripts

1. **Open PowerShell terminal as Administrator**
   - Right-click and choose "Run as Administrator"
   - This is required for Chocolatey and Winget installs
2. Navigate to the folder
      - PowerShell terminal
        ```powershell
        cd "C:\Path\To\package_installer"
        ```
3. Run the setup script
    - Execute PowerShell script in the terminal
      ```powershell
      .\windows_package_setup.ps1
      ```
4. When prompted, choose your installer
    - Choose installer (pip/choco/winget):

## 🧠 What the Script Does

- Warns and exits if not run as Administrator
- Validates Winget availability
- Installs Chocolatey if needed (for `choco`)
- Checks if Python is installed via Winget
- If missing, installs the latest Python 3.x version dynamically via Winget
- Instructs the user to restart the terminal after Python installation
- Runs the Python script to install packages from the selected `.txt` file
- Skips already-installed packages
- Logs all actions to `install_packages.log`
- Prints a summary of installed, skipped, and failed packages
- Logs full error output for any failed installs
- Logs installed version number for each successful install
- Streams real-time install output to the terminal for each package
- Uses modular helper functions for version retrieval to reduce branching and improve clarity

## 🔍 Package Search Resources: Use these official repositories to find packages for each installer

- [Search pip packages on PyPI](https://pypi.org/)
- [Search Chocolatey packages](https://community.chocolatey.org/packages)
- [Search Winget packages on Winstall](https://winstall.app/)
  - Alternative way of searching for packages using a Windows Terminal
    - `winget search <PackageName>`
    - If the package contains spaces, then surround the package name with double quotes
      - `winget search "<PackageName>"`
  - Once you find a package, copy its ID and add it to the appropriate `.txt` file.

## ✅ Best Practices

- Assign each package to only one installer to avoid duplicate installs
- Keep your `.txt` lists clean and exclusive
- Use comments (`#`) to annotate package lists
- Re-running the script is safe — it won’t reinstall anything already installed
- Check `install_packages.log` for a full audit trail, version info, and error diagnostics


## 📄 Example Package Lists

> ⚠️ Do not include the same package in multiple files — this may cause conflicts

### `pip_packages.txt`

<pre>
requests
# numpy
# pysubs2
</pre>

### `choco_packages.txt`

<pre>
googlechrome
# vlc
# git
</pre>

### `winget_packages.txt`

<pre>
Google.Chrome
# VideoLAN.VLC
# Git.Git
</pre>

![Windows 11](https://img.shields.io/badge/Platform-Windows%2011-blue)
![PowerShell](https://img.shields.io/badge/Requires-PowerShell%205%2B-green)
![Python](https://img.shields.io/badge/Python-3.10%2B-yellow)
![License](https://img.shields.io/badge/License-MIT-lightgrey)
