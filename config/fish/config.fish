if status is-interactive
    # Starship prompt
    starship init fish | source
    
    # Zoxide (smart cd)
    zoxide init fish | source
    
    # Modern aliases
    alias ls='eza --icons --group-directories-first'
    alias ll='eza -lah --icons --group-directories-first --git'
    alias tree='eza --tree --icons'
    alias cat='bat --style=plain --paging=never'
    alias catp='bat --style=full'
    alias grep='rg'
    alias find='fd'
    alias cd='z'
    alias diff='delta'
    
    # Git aliases
    alias gs='git status'
    alias ga='git add'
    alias gc='git commit'
    alias gp='git push'
    alias gl='git log --oneline --graph --decorate'
    
    # System aliases
    alias update='sudo dnf update'
    alias clean='sudo dnf autoremove && sudo dnf clean all'
    
    # Disable greeting
    set fish_greeting
    
    # Auto start fastfetch
    if test "$TERM" != "linux"
        fastfetch
    end
end

# Cargo (Rust)
fish_add_path "$HOME/.cargo/bin"

# opencode
fish_add_path "$HOME/.opencode/bin"
