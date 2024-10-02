import os
import subprocess
import shutil
import sys
import logging
from typing import List, Callable
from pathlib import Path

USER_EMAIL = "user.name@example.com"
USER_NAME = "user"
NODE_JS_VERSION = "22.x"
GO_TAR = "go1.23.2.linux-amd64.tar.gz"
ZIG_TAR = "zig-linux-x86_64-0.14.0-dev.1694+3b465ebec.tar.xz"

logging.basicConfig(filename='setup_log.txt', level=logging.INFO,
                    format='%(asctime)s - %(levelname)s - %(message)s')

def run_command(command: str, use_sudo: bool = False) -> None:
    try:
        if use_sudo and os.geteuid() != 0:
            command = f"sudo {command}"
        result = subprocess.run(command, shell=True, check=True, capture_output=True, text=True)
        print(f"Command succeeded: {command}")
        logging.info(f"Command succeeded: {command}")
        if result.stdout:
            logging.info(f"Output: {result.stdout}")
    except subprocess.CalledProcessError as e:
        print(f"Command failed: {command}\nError: {e.stderr}")
        logging.error(f"Command failed: {command}\nError: {e.stderr}")
        sys.exit(1)

def install_zig() -> None:
    print("Install Zig")
    zig_url = f"https://ziglang.org/builds/{ZIG_TAR}"
    zig_folder = f"{ZIG_TAR}" # Remove .tar.xz

    run_command(f"wget {zig_url} -P /tmp")
    run_command(f"tar -xf /tmp/{ZIG_TAR} -C /tmp")

    if Path("/opt/zig").exists():
        shutil.rmtree("/opt/zig")
    shutil.move(f"/tmp/{zig_folder}", "/opt/zig")

    run_command("ln -sf /opt/zig/zig /usr/local/bin/zig", use_sudo=True)
    run_command("zig version")

def install_zls() -> None:
    print("Installing ZLS")
    run_command("apt install -y git cmake build-essential", use_sudo=True)
    run_command("git clone https://github.com/zigtools/zls /tmp/zls")
    run_command("zig build -Drelease-safe", cwd="/tmp/zls")

    if Path("/opt/zls").exists():
        os.remove("/opt/zls")
    shutil.move("/tmp/zls/zig-out/bin/zls", "/opt/zls")

    run_command("ln -sf /opt/zls /usr/local/bin/zls", use_sudo=True)
    run_command("zls --version")

def install_rust() -> None:
    print("Installing Rust")
    run_command("curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y")

def install_rust_cli_tools() -> None:
    print("Installing Rust CLI Tools")

    rust_tools: List[str] = [
        "cargo-audit", "cargo-edit", "cargo-outdated", "cargo-watch",
        "checkexec", "coreutils", "du-dust", "fd", "git-delta" "hyperfine", "just",
        "nu", "ripgrep", "starship", "stylua", "systemfd", "watchexec",
        "--locked zellij"
    ]

    for tool in rust_tools:
        run_command(f"cargo install {tool}")

def install_go() -> None:
    print("Installing Go")
    # Haveuser enter download version
    go_url = f"https://go.dev/dl/{GO_TAR}"
    run_command(f"wget {go_url} -P /tmp")
    run_command(f"tar -C /usr/local/bin -xzf {GO_TAR}", use_sudo=True)
    run_command("go --version")

def install_go_cli_tools() -> None:
    go_tools: List[str] = [
        "golangci/golangci-lint/cmd/golangci-lint",
        "golang.org/x/tools/gopls",
        "honnef.co/go/tools/cmd/staticcheck",
        "rakyll/hey",
        "spf13/cobra-cli",
        "pkg/errors",
        "vektra/mockery/v2",
        "golang.org/x/tools/cmd/goimports",
        "kisslinux/govisualizer",
        "oligot/go-mod-upgrade"
    ]

    for tool in go_tools:
        run_command(f"go install github.com/{tool}@latest")

def install_frontend_languages() -> None:
    print("Installing Node.js, PNPM, Deno, and Bun")

    print(f"Installing NodeJS Version {NODE_JS_VERSION}")
    run_command(f"curl -fsSL https://deb.nodesource.com/setup_{NODE_JS_VERSION} -o nodesource_setup.sh")
    run_command("-E bash nodesource_setup.sh", use_sudo=True)

    print("Installing Bun")
    run_command("curl -fsSL https://bun.sh/install | bash")

    print("Installing Deno")
    run_command("curl -fsSL https://deno.land/install.sh | sh")

    print("Installing PNPM")
    run_command("wget -qO- https://get.pnpm.io/install.sh | ENV=\"$HOME/.bashrc\" SHELL=\"$(which bash)\" bash -")

def install_python_tools() -> None:
    print("Installing Python development tools...")

    run_command("curl -sSf https://rye.astral.sh/get | bash")

    python_tools: List[str] = [
        "black", "isort", "mypy", "pylint", "ruff", "pytest",
        "tox", "pre-commit", "pyright", "pylyzer", "python-lsp-server",
        "debugpy"
    ]
    for tool in python_tools:
        run_command(f"pipx install {tool}")

def setup_git() -> None:
    print("Setting up Git...")
    run_command(f"git config --global user.email \"{USER_EMAIL}\"")
    run_command(F"git config --global user.name \"{USER_NAME}\"")

def setup_development_environment() -> None:
    functions: List[Callable[[], None]] = [
        install_zig,
        install_rust,
        install_rust_cli_tools,
        install_go,
        install_go_cli_tools,
        install_frontend_languages,
        install_python_tools,
        setup_git,
        install_zls,
    ]

    for func in functions:
        func()

    print("Development environment setup completed! Nushell is now the default shell.")
    print("Please log out and log back in for all changes to take effect.")
    print("Remember to update your Git configuration with your actual email and name.")

if __name__ == "__main__":
    if os.geteuid() == 0:
        print("Please run this script without sudo. It will ask for elevation when needed.")
        sys.exit(1)
    setup_development_environment()
