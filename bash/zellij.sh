if [ -z "$ZELLIJ" ] && [ -z "$SSH_CLIENT" ] && [ -t 0 ]; then
    if [[ $- == *i* ]]; then
        if command -v zellij >/dev/null 2>&1; then
            if ! zellij list-sessions 2>/dev/null | grep -q .; then
                zellij
            else
                zellij attach -c
            fi
        fi
    fi
fi
