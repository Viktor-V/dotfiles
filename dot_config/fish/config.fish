# Fish shell configuration for viktorv

# Initialize Starship prompt
if type -q starship
    starship init fish | source
end

# Initialize zoxide
if type -q zoxide
    zoxide init fish | source
end

# Initialize atuin (sync history), keep up-arrow as normal history recall
if type -q atuin
    atuin init fish --disable-up-arrow | source
end

# Set default directory
cd ~

# Useful aliases
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate --all'

# New tools aliases
alias tb='btop'
alias lg='lazygit'
alias ff='fastfetch'
if type -q bat
    alias cat='bat'
else if type -q batcat
    alias cat='batcat'
end
alias grep='grep --color=auto'
alias history='atuin search -i'

# Common commands
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# WSL specific
alias winhome='cd /mnt/c/Users/viktorv'
alias desk='cd ~/Desktop 2>/dev/null || mkdir -p ~/Desktop && cd ~/Desktop'

# Set default editor
set -gx EDITOR nvim
set -gx VISUAL nvim

# PATH additions
fish_add_path $HOME/.local/bin
fish_add_path /usr/local/bin
fish_add_path /usr/local/go/bin

# Catppuccin Macchiato colors
set -g fish_color_normal '#cad3f5'
set -g fish_color_command '#8aadf4'
set -g fish_color_param '#f0c6c6'
set -g fish_color_quote '#a6da95'
set -g fish_color_redirection '#8bd5ca'
set -g fish_color_end '#c6a0f6'
set -g fish_color_error '#ed8796'
set -g fish_color_comment '#5b6078'
set -g fish_color_operator '#91d7e3'
set -g fish_color_escape '#f0c6c6'
set -g fish_color_autosuggestion '#494d64'
set -g fish_color_cwd '#8aadf4'
set -g fish_color_cwd_root '#ed8796'
set -g fish_color_user '#a6da95'
set -g fish_color_host '#8aadf4'
set -g fish_color_host_remote '#a6da95'
set -g fish_color_cancel --reverse
set -g fish_pager_color_completion '#cad3f5'
set -g fish_pager_color_description '#b8c0e0'
set -g fish_pager_color_prefix '#c6a0f6'

# Enable vi mode
fish_vi_key_bindings
