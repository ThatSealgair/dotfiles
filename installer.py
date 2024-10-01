import os
import subprocess
import shutil
import sys
import logging
from typing import List, Callable
from pathlib import Path

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

def update_system() -> None:
    print("Updating system...")
    run_command("apt update && apt upgrade -y", use_sudo=True)

def install_zig(version: str = "0.14.0") -> None:
    print(f"Installing Zig {version}...")
    zig_url = f"https://ziglang.org/download/{version}/zig-linux-x86_64-{version}.tar.xz"
    zig_tar = f"zig-linux-x86_64-{version}.tar.xz"
    zig_folder = f"zig-linux-x86_64-{version}"
    
    run_command(f"wget {zig_url} -P /tmp")
    run_command(f"tar -xf /tmp/{zig_tar} -C /tmp")
    
    if Path("/opt/zig").exists():
        shutil.rmtree("/opt/zig")
    shutil.move(f"/tmp/{zig_folder}", "/opt/zig")
    
    run_command("ln -sf /opt/zig/zig /usr/local/bin/zig", use_sudo=True)
    run_command("zig version")

def install_zls() -> None:
    print("Installing ZLS (Zig Language Server)...")
    run_command("apt install -y git cmake build-essential", use_sudo=True)
    run_command("git clone https://github.com/zigtools/zls /tmp/zls")
    run_command("zig build -Drelease-safe", cwd="/tmp/zls")

    if Path("/opt/zls").exists():
        os.remove("/opt/zls")
    shutil.move("/tmp/zls/zig-out/bin/zls", "/opt/zls")
    
    run_command("ln -sf /opt/zls /usr/local/bin/zls", use_sudo=True)
    run_command("zls --version")

def install_rust_and_cli_tools() -> None:
    print("Installing Rust and Rust-based CLI tools...")
    run_command("curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y")
    run_command("source $HOME/.cargo/env")
    run_command("add-apt-repository ppa:maveonair/helix-editor", use_sudo=True)
    update_system()
    run_command("apt install helix -y", use_sudo=True)

    rust_tools: List[str] = [
        "cargo-audit", "cargo-edit", "cargo-outdated", "cargo-watch",
        "checkexec", "coreutils", "du-dust", "fd", "git-delta" "hyperfine", "just",
        "nu", "ripgrep", "starship", "systemfd", "watchexec",
        "--locked zellij"
    ]
    
    for tool in rust_tools:
        run_command(f"cargo install {tool}")

def install_lua_and_luarocks() -> None:
    print("Installing Lua and LuaRocks...")
    run_command("apt install -y lua5.4 lua5.4-dev luarocks", use_sudo=True)

def install_go_and_cli_tools() -> None:
    print("Installing Go and Go-based CLI tools...")
    run_command("apt install -y golang", use_sudo=True)

    go_tools: List[str] = [
        "golangci-lint", "gopls", "staticcheck", "hey", "cobra-cli"
    ]
    
    for tool in go_tools:
        run_command(f"go install github.com/{tool}@latest")

def install_bun_and_expressjs() -> None:
    print("Installing Bun (TypeScript runtime) and ExpressJS...")
    run_command("curl -fsSL https://bun.sh/install | bash")
    run_command("source $HOME/.bashrc")
    run_command("bun add express --global")

def install_nushell() -> None:
    print("Installing Nushell...")
    run_command("apt install -y nushell", use_sudo=True)
    run_command("chsh -s /usr/bin/nushell $USER", use_sudo=True)

def install_dev_tools() -> None:
    print("Installing essential development tools...")
    tools: List[str] = [
        "build-essential", "cmake", "git", "curl", "pkg-config",
        "libsystemd-dev", "libelf-dev", "libseccomp-dev", "libclang-dev",
        "libssl-dev", "libseccomp2", "htop", "jq", "fzf", "docker",
        "docker-compose", "git-lfs", "python3-pip", "clangd", "llvm",
        "python3-venv", "python3-dev", "mypy", "black", "pylint", "flake8",
        "python3-pytest", "python3-coverage"
    ]
    run_command(f"apt install -y {' '.join(tools)}", use_sudo=True)

def install_node() -> None:
    print("Installing Node.js and npm...")
    run_command("curl -fsSL https://deb.nodesource.com/setup_16.x | bash -", use_sudo=True)
    run_command("apt install -y nodejs", use_sudo=True)

def install_python_tools() -> None:
    print("Installing Python development tools...")
    python_tools: List[str] = [
        "poetry", "pipenv", "virtualenv", "ipython", "jupyter",
        "black", "isort", "mypy", "pylint", "flake8", "pytest",
        "coverage", "tox", "pre-commit", "pyright"
    ]
    run_command(f"python3 -m pip install --user {' '.join(python_tools)}")

def setup_git() -> None:
    print("Setting up Git...")
    run_command('git config --global user.email "your.email@example.com"')
    run_command('git config --global user.name "Your Name"')

def setup_development_environment() -> None:
    functions: List[Callable[[], None]] = [
        update_system,
        install_dev_tools,
        install_zig,
        install_zls,
        install_rust_and_cli_tools,
        install_lua_and_luarocks,
        install_go_and_cli_tools,
        install_bun_and_expressjs,
        install_node,
        install_python_tools,
        install_nushell,
        setup_git
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
