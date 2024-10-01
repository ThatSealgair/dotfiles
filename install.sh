#!/bin/bash

LOG_FILE="setup_log.txt"

log_info() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') - INFO - $1" | tee -a "$LOG_FILE"
}

log_error() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') - ERROR - $1" | tee -a "$LOG_FILE" >&2
}

run_command() {
  local command="$1"
  local use_sudo="$2"

  if [[ "$use_sudo" == "true" && "$EUID" -ne 0 ]]; then
    command="sudo $command"
  fi

  if eval "$command"; then
    log_info "Command succeeded: $command"
  else
    log_error "Command failed: $command"
    exit 1
  fi
}

update_system() {
  log_info "Updating system..."
  run_command "apt update && apt upgrade -y" true
}

install_zig() {
  local version="0.14.0"
  log_info "Installing Zig $version..."
  local zig_url="https://ziglang.org/download/${version}/zig-linux-x86_64-${version}.tar.xz"
  local zig_tar="zig-linux-x86_64-${version}.tar.xz"
  local zig_folder="zig-linux-x86_64-${version}"

  run_command "wget $zig_url -P /tmp"
  run_command "tar -xf /tmp/$zig_tar -C /tmp"

  if [[ -d "/opt/zig" ]]; then
    run_command "sudo rm -rf /opt/zig"
  fi

  run_command "sudo mv /tmp/$zig_folder /opt/zig"
  run_command "sudo ln -sf /opt/zig/zig /usr/local/bin/zig"
  run_command "zig version"
}

install_zls() {
  log_info "Installing ZLS (Zig Language Server)..."
  run_command "apt install -y git cmake build-essential" true
  run_command "git clone https://github.com/zigtools/zls /tmp/zls"
  run_command "cd /tmp/zls && zig build -Drelease-safe"

  if [[ -f "/opt/zls" ]]; then
    run_command "sudo rm -f /opt/zls"
  fi

  run_command "sudo mv /tmp/zls/zig-out/bin/zls /opt/zls"
  run_command "sudo ln -sf /opt/zls /usr/local/bin/zls"
  run_command "zls --version"
}

install_rust_and_cli_tools() {
  log_info "Installing Rust and Rust-based CLI tools..."
  run_command "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"
  run_command "source $HOME/.cargo/env"
  run_command "sudo add-apt-repository ppa:maveonair/helix-editor"
  update_system
  run_command "sudo apt install helix -y"

  local rust_tools=(
    "cargo-audit" "cargo-edit" "cargo-outdated" "cargo-watch"
    "checkexec" "coreutils" "du-dust" "fd" "git-delta"
    "hyperfine" "just" "lsp-ai" "nu" "ripgrep" "starship"
    "systemfd" "watchexec" "--locked zellij"
  )

  for tool in "${rust_tools[@]}"; do
    run_command "cargo install $tool"
  done
}

install_lua_and_luarocks() {
  log_info "Installing Lua and LuaRocks..."
  run_command "sudo apt install -y lua5.4 lua5.4-dev luarocks" true
}

install_go_and_cli_tools() {
  log_info "Installing Go and Go-based CLI tools..."
  run_command "sudo apt install -y golang" true

  local go_tools=(
    "golangci-lint" "gopls" "staticcheck" "hey" "cobra-cli"
  )

  for tool in "${go_tools[@]}"; do
    run_command "go install github.com/${tool}@latest"
  done
}

install_bun_and_expressjs() {
  log_info "Installing Bun (TypeScript runtime) and ExpressJS..."
  run_command "curl -fsSL https://bun.sh/install | bash"
  run_command "source $HOME/.bashrc"
  run_command "bun add express --global"
}

install_nushell() {
  log_info "Installing Nushell..."
  run_command "sudo apt install -y nushell" true
  run_command "sudo chsh -s /usr/bin/nushell $USER"
}

install_dev_tools() {
  log_info "Installing essential development tools..."
  local tools=(
    "build-essential" "cmake" "git" "curl" "pkg-config"
    "libsystemd-dev" "libelf-dev" "libseccomp-dev" "libclang-dev"
    "libssl-dev" "libseccomp2" "htop" "jq" "fzf" "docker"
    "docker-compose" "git-lfs" "python3-pip" "clangd" "llvm"
    "python3-venv" "python3-dev" "mypy" "black" "pylint" "flake8"
    "python3-pytest" "python3-coverage"
  )
  run_command "sudo apt install -y ${tools[*]}"
}

install_node() {
  log_info "Installing Node.js and npm..."
  run_command "curl -fsSL https://deb.nodesource.com/setup_16.x | sudo bash -" true
  run_command "sudo apt install -y nodejs" true
}

install_python_tools() {
  log_info "Installing Python development tools..."
  local python_tools=(
    "poetry" "pipenv" "virtualenv" "ipython" "jupyter"
    "black" "isort" "mypy" "pylint" "flake8" "pytest"
    "coverage" "tox" "pre-commit" "pyright"
  )
  run_command "python3 -m pip install --user ${python_tools[*]}"
}

setup_git() {
  log_info "Setting up Git..."
  run_command 'git config --global user.email "your.email@example.com"'
  run_command 'git config --global user.name "Your Name"'
}

setup_development_environment() {
  update_system
  install_dev_tools
  install_zig
  install_zls
  install_rust_and_cli_tools
  install_lua_and_luarocks
  install_go_and_cli_tools
  install_bun_and_expressjs
  install_node
  install_python_tools
  install_nushell
  setup_git

  log_info "Development environment setup completed! Nushell is now the default shell."
  echo "Please log out and log back in for all changes to take effect."
  echo "Remember to update your Git configuration with your actual email and name."
}

if [[ "$EUID" -eq 0 ]]; then
  echo "Please run this script without sudo. It will ask for elevation when needed."
  exit 1
fi

setup_development_environment
