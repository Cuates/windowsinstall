"""
Unified package installer for Windows 11 using pip, Chocolatey, or Winget.
Supports skip logic, emoji logging, version reporting, and summary output.
"""

import subprocess
import sys
import logging
import ctypes
from pathlib import Path
from enum import Enum
from logging.handlers import RotatingFileHandler
import time
from typing import List, Tuple, Protocol

class Installer(str, Enum):
    """Enum representing supported package managers."""
    PIP = "pip"
    CHOCO = "choco"
    WINGET = "winget"

class InstallChecker(Protocol):
    """Protocol for checking if a package is already installed."""
    def __call__(self, pkg: str) -> bool: ...

class InstallCommandBuilder(Protocol):
    """Protocol for building install commands for a given package."""
    def __call__(self, pkg: str) -> List[str]: ...

def is_admin() -> bool:
    """Checks if the script is running with administrator privileges."""
    try:
        return ctypes.windll.shell32.IsUserAnAdmin() != 0
    except (AttributeError, OSError):
        return False

def log_success(message: str) -> None:
    """Logs a success message with ✅ prefix."""
    logging.info("✅ %s", message)

def log_error(message: str) -> None:
    """Logs an error message with ❌ prefix."""
    logging.error("❌ %s", message)

def log_warning(message: str) -> None:
    """Logs a warning message with 📛 prefix."""
    logging.warning("📛 %s", message)

def log_inspection(message: str) -> None:
    """Logs an inspection message with 🔍 prefix."""
    logging.info("🔍 %s", message)

def setup_logger() -> None:
    """Initializes a rotating UTF-8 logger next to the script."""
    script_dir: Path = Path(__file__).resolve().parent if '__file__' in globals() else Path.cwd()
    log_path: Path = script_dir / "install_packages.log"
    handler: RotatingFileHandler = RotatingFileHandler(log_path, maxBytes=100_000, backupCount=3, encoding="utf-8")
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s [%(levelname)s] %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
        handlers=[handler]
    )

def read_package_list(file_path: Path) -> List[str]:
    """Reads package names from a text file, skipping blank lines and comments."""
    with open(file_path, 'r', encoding='utf-8') as file:
        return [line.strip() for line in file if line.strip() and not line.startswith('#')]

def is_pip_installed(pkg: str) -> bool:
    """Checks if a pip package is already installed."""
    result = subprocess.run(
        [sys.executable, "-m", "pip", "show", pkg],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        check=False
    )
    return result.returncode == 0

def is_choco_installed(pkg: str) -> bool:
    """Checks if a Chocolatey package is already installed."""
    result = subprocess.run(
        ["choco", "list", "--exact", pkg],
        capture_output=True,
        text=True,
        check=False
    )
    return pkg.lower() in result.stdout.lower()

def is_winget_installed(pkg: str) -> bool:
    """Checks if a Winget package is already installed."""
    result = subprocess.run(
        ["winget", "list", "--id", pkg],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        check=False
    )
    return result.returncode == 0

def pip_cmd(pkg: str) -> List[str]:
    """Builds the pip install command for a given package."""
    return [sys.executable, "-m", "pip", "install", pkg]

def choco_cmd(pkg: str) -> List[str]:
    """Builds the Chocolatey install command for a given package."""
    return ["choco", "install", pkg, "-y"]

def winget_cmd(pkg: str) -> List[str]:
    """Builds the Winget install command for a given package."""
    return [
        "winget", "install", "--id", pkg,
        "--silent", "--accept-package-agreements", "--accept-source-agreements"
    ]

def _get_pip_version(pkg: str) -> str:
    """Retrieves the installed version of a pip package."""
    result = subprocess.run(
        [sys.executable, "-m", "pip", "show", pkg],
        capture_output=True,
        text=True,
        check=False
    )
    for line in result.stdout.splitlines():
        if line.startswith("Version:"):
            return line.split(":", 1)[1].strip()
    return "unknown"

def _get_choco_version(pkg: str) -> str:
    """Retrieves the installed version of a Chocolatey package."""
    result = subprocess.run(
        ["choco", "list", "--exact", pkg],
        capture_output=True,
        text=True,
        check=False
    )
    for line in result.stdout.splitlines():
        if line.lower().startswith(pkg.lower()):
            parts = line.strip().split()
            if len(parts) == 2:
                return parts[1]
    return "unknown"

def _get_winget_version(pkg: str, timeout: int = 60, interval: int = 5) -> str:
    """Waits for a Winget package to be installed and retrieves its version."""
    print(f"Waiting for {pkg} to be fully installed...")

    start_time = time.time()
    while time.time() - start_time < timeout:
        result = subprocess.run(
            ["winget", "list", "--id", pkg, "--source", "winget"],
            capture_output=True,
            text=True,
            check=False
        )
        output = result.stdout
        lines = output.splitlines()

        for i, line in enumerate(lines):
            if "Name" in line and "Id" in line and "Version" in line:
                header = line
                separator_index = i + 1
                break
        else:
            time.sleep(interval)
            continue

        version_start = header.find("Version")
        for line in lines[separator_index + 1:]:
            if pkg.lower() in line.lower():
                version = line[version_start:].strip()
                print(f"{pkg} installed with version: {version}")
                return version

        time.sleep(interval)

    print(f"Timeout reached. {pkg} not found.")
    return "unknown"

def get_installed_version(installer: Installer, pkg: str) -> str:
    """
    Dispatches to the appropriate version retrieval function based on installer type.

    Args:
        installer: The installer enum (pip, choco, winget).
        pkg: The package name.

    Returns:
        The installed version string, or "unknown" if not found.
    """
    try:
        if installer == Installer.PIP:
            return _get_pip_version(pkg)
        if installer == Installer.CHOCO:
            return _get_choco_version(pkg)
        if installer == Installer.WINGET:
            return _get_winget_version(pkg, timeout=60, interval=5)
    except subprocess.SubprocessError as error:
        log_warning(f"[{installer}] Could not retrieve version for {pkg}: {error}")
    return "unknown"

def install_packages(
    packages: List[str],
    installer_name: Installer,
    is_installed_fn: InstallChecker,
    install_cmd_fn: InstallCommandBuilder
) -> None:
    """
    Installs a list of packages using the specified installer logic.

    Args:
        packages: List of package names to install.
        installer_name: The installer enum (pip, choco, winget).
        is_installed_fn: Function to check if a package is already installed.
        install_cmd_fn: Function to build the install command for a package.
    """
    installed: List[str] = []
    skipped: List[str] = []
    failed: List[str] = []

    for pkg in packages:
        if is_installed_fn(pkg):
            print(f"[{installer_name}] {pkg} is already installed. Skipping.")
            log_inspection(f"[{installer_name}] {pkg} already installed. Skipped.")
            skipped.append(pkg)
        else:
            print(f"[{installer_name}] Installing {pkg}... Please wait.")
            try:
                subprocess.run(
                    install_cmd_fn(pkg),
                    stdout=sys.stdout,
                    stderr=sys.stderr,
                    text=True,
                    check=True
                )
                version = get_installed_version(installer_name, pkg)
                log_success(f"[{installer_name}] {pkg} installed successfully (version: {version})")
                installed.append(f"{pkg} ({version})")
            except subprocess.CalledProcessError as error:
                print(f"[{installer_name}] Failed to install {pkg}.")
                log_error(f"[{installer_name}] Failed to install {pkg}. Error: {error.stderr.strip()}")
                failed.append(pkg)

    print_summary(installer_name, installed, skipped, failed)

def print_summary(installer: Installer, installed: List[str], skipped: List[str], failed: List[str]) -> None:
    """
    Prints and logs a summary of installation results.

    Args:
        installer: The installer enum.
        installed: List of successfully installed packages.
        skipped: List of skipped packages.
        failed: List of failed packages.
    """
    print(f"\n=== {installer.value.upper()} Install Summary ===")
    print(f"Installed: {installed if installed else 'None'}")
    print(f"Skipped: {skipped if skipped else 'None'}")
    print(f"Failed: {failed if failed else 'None'}")

    log_inspection(f"=== {installer.value.upper()} Install Summary ===")
    log_inspection(f"Installed: {installed if installed else 'None'}")
    log_inspection(f"Skipped: {skipped if skipped else 'None'}")
    log_inspection(f"Failed: {failed if failed else 'None'}")

def main() -> None:
    """
    Main entry point for the script. Validates input, loads package list,
    and dispatches to the appropriate installer logic.
    """
    setup_logger()

    if not is_admin():
        print("⚠️  This script should be run as Administrator for Chocolatey and Winget installs.")
        log_warning("Script not running with administrator privileges. Winget and Chocolatey may fail.")

    if len(sys.argv) != 2:
        print("Usage: python install_packages.py [pip|choco|winget]")
        log_error("Invalid usage. Expected one argument: pip, choco, or winget.")
        sys.exit(1)

    try:
        installer: Installer = Installer(sys.argv[1].lower())
    except ValueError:
        print("Invalid installer. Choose from: pip, choco, winget")
        log_error(f"Invalid installer choice: {sys.argv[1]}")
        sys.exit(1)

    base_path: Path = Path(__file__).resolve().parent if '__file__' in globals() else Path.cwd()

    file_map: dict[Installer, Path] = {
        Installer.PIP: base_path / "pip_packages.txt",
        Installer.CHOCO: base_path / "choco_packages.txt",
        Installer.WINGET: base_path / "winget_packages.txt"
    }

    logic_map: dict[Installer, Tuple[InstallChecker, InstallCommandBuilder]] = {
        Installer.PIP: (is_pip_installed, pip_cmd),
        Installer.CHOCO: (is_choco_installed, choco_cmd),
        Installer.WINGET: (is_winget_installed, winget_cmd)
    }

    package_file: Path = file_map[installer]
    if not package_file.exists():
        print(f"Package list file not found: {package_file.name}")
        log_error(f"Package list file missing: {package_file}")
        sys.exit(1)

    packages: List[str] = read_package_list(package_file)
    if not packages:
        print(f"No packages found in {package_file.name}. Nothing to install.")
        log_warning(f"Package list file {package_file.name} is empty. No packages to install.")
        sys.exit(0)

    is_installed_fn, install_cmd_fn = logic_map[installer]
    install_packages(packages, installer, is_installed_fn, install_cmd_fn)

if __name__ == "__main__":
    main()
