# Creates a new Python virtual environment
#
# Usage:
#   create-venv [path]              # Creates venv in specified path or current directory
#   create-venv [path] --python py  # Creates venv using specific Python executable
#
# Parameters:
#   path?: string   # Path for new virtual environment (optional, defaults to "venv")
#   --python: string # Python executable to use (optional, defaults to "python3")
#
# Examples:
#   create-venv
#   create-venv "myproject/.venv"
#   create-venv --python python3.9
def create-venv [
    path?: string = "venv",
    --python: string = "python3"  # Python executable to use
] {
    if ($path | path exists) {
        error make {msg: $"Directory ($path) already exists"}
    }
    
    let result = (do { ^$python -m venv $path })
    if ($result | is-empty) {
        print $"Created virtual environment in ($path)"
    }
}

# Activates a Python virtual environment in Nushell
#
# Usage:
#   activate-venv [path]  # Activates venv at specified path
#
# Parameters:
#   path: string # Path to activation script
#
# Examples:
#   activate-venv
#   activate-venv ".env/bin/activate"
def activate-venv [path: string = "venv/bin/activate"] {
    let venv_path = if ($path | path exists) { $path } else { "venv/bin/activate" }
    
    if not ($venv_path | path exists) {
        error make {msg: $"Virtual environment activation script not found at ($venv_path)"}
    }
    
    let activate_content = (open $venv_path)
    let parsed = ($activate_content | parse -r 'VIRTUAL_ENV="(?P<venv_dir>[^"]+)"')
    
    if ($parsed | is-empty) {
        error make {msg: "Could not parse virtual environment path"}
    }
    
    let venv_dir = $parsed.venv_dir.0
    
    $env.VIRTUAL_ENV = $venv_dir
    $env.PATH = ([$"($venv_dir)/bin" $env.PATH] | flatten | uniq | str join ":")
    let venv_name = ($venv_dir | path basename)
    $env.PROMPT_COMMAND = {|| $"($venv_name) (do $env.PROMPT_COMMAND)"}
}

# Deactivates the current Python virtual environment
#
# Usage:
#   deactivate-venv  # Deactivates current virtual environment
#
# Examples:
#   deactivate-venv
def deactivate-venv [] {
    if ($env | get -i VIRTUAL_ENV | is-empty) {
        error make {msg: "No virtual environment is currently active"}
    }

    # Remove venv from PATH
    $env.PATH = ($env.PATH | split row ':' | where { $in != $"($env.VIRTUAL_ENV)/bin" } | str join ':')
    
    # Reset prompt
    $env.PROMPT_COMMAND = {|| (do $env.PROMPT_COMMAND | str replace -r '^\([^)]+\) ' '')}
    
    # Unset VIRTUAL_ENV
    hide-env VIRTUAL_ENV
}
