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

# WSL specific (only define when Windows drives are mounted)
if test -d /mnt/c
    alias winhome='cd /mnt/c/Users/viktorv'
end
alias desk='cd ~/Desktop 2>/dev/null || mkdir -p ~/Desktop && cd ~/Desktop'

# Set default editor
set -gx EDITOR nvim
set -gx VISUAL nvim

# PATH additions (missing dirs are ignored, so this is safe on all OSes)
fish_add_path $HOME/.local/bin
fish_add_path $HOME/.opencode/bin
fish_add_path /opt/homebrew/bin
fish_add_path /usr/local/bin
fish_add_path /usr/local/go/bin

# Windows Terminal "Campbell" colors
set -g fish_color_normal '#CCCCCC'
set -g fish_color_command '#3B78FF'
set -g fish_color_param '#F2F2F2'
set -g fish_color_quote '#16C60C'
set -g fish_color_redirection '#61D6D6'
set -g fish_color_end '#B4009E'
set -g fish_color_error '#E74856'
set -g fish_color_comment '#767676'
set -g fish_color_operator '#3A96DD'
set -g fish_color_escape '#F9F1A5'
set -g fish_color_autosuggestion '#767676'
set -g fish_color_cwd '#3B78FF'
set -g fish_color_cwd_root '#E74856'
set -g fish_color_user '#16C60C'
set -g fish_color_host '#3B78FF'
set -g fish_color_host_remote '#16C60C'
set -g fish_color_cancel --reverse
set -g fish_pager_color_completion '#CCCCCC'
set -g fish_pager_color_description '#767676'
set -g fish_pager_color_prefix '#3B78FF'

# Enable vi mode
fish_vi_key_bindings

if type -q fzf
    fzf --fish | source
end
