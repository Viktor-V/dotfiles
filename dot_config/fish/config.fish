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

# Over SSH, hide Windows interop paths so platform probes (for example
# Moshi's cmd.exe check) see a Unix host instead of Windows.
if set -q SSH_CONNECTION
    set -gx PATH (string match -v '/mnt/*' $PATH)
end

# Herdr helpers: create a tab in a named workspace, optionally starting OpenCode.
function htab --description 'Create a Herdr tab in a named workspace'
    if test (count $argv) -lt 1
        echo "usage: htab <workspace> [cwd]" >&2
        return 1
    end

    set -l workspace $argv[1]
    set -l cwd $argv[2]
    if test -z "$cwd"
        set cwd "$HOME/projects/"(string lower -- $workspace)
    end

    set -l wsid (herdr workspace list 2>/dev/null | python3 -c '
import json, sys
label = sys.argv[1].lower()
for ws in json.load(sys.stdin).get("result", {}).get("workspaces", []):
    if (ws.get("label") or "").lower() == label:
        print(ws["workspace_id"])
        break
' "$workspace")

    if test -z "$wsid"
        echo "Workspace '$workspace' not found; creating it..." >&2
        herdr workspace create --label "$workspace" --cwd "$cwd" --focus >/dev/null
        set wsid (herdr workspace list 2>/dev/null | python3 -c '
import json, sys
label = sys.argv[1].lower()
for ws in json.load(sys.stdin).get("result", {}).get("workspaces", []):
    if (ws.get("label") or "").lower() == label:
        print(ws["workspace_id"])
        break
' "$workspace")
    end

    if test -z "$wsid"
        echo "Could not find or create workspace '$workspace'" >&2
        return 1
    end

    set -l out (herdr tab create --workspace "$wsid" --cwd "$cwd" --label "$workspace" --focus)
    set -l pane (printf '%s' "$out" | python3 -c '
import json, sys
data = json.load(sys.stdin)
print(data.get("result", {}).get("root_pane", {}).get("pane_id", ""))
')
    if test -z "$pane"
        echo "Could not create a Herdr tab" >&2
        return 1
    end

    echo "$pane"
end

function hchat --description 'Create a Herdr tab and start OpenCode'
    set -l pane (htab $argv)
    if test -z "$pane"
        return 1
    end
    herdr pane run "$pane" opencode
    echo "Started OpenCode in '$argv[1]' ($pane)"
end

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
