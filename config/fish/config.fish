set fish_greeting

# set -gx SSH_AUTH_SOCK "$HOME/.bitwarden-ssh-agent.sock"

if status is-interactive
    # Commands to run in interactive sessions can go here
    fish_config theme choose "ayu Dark"
    fish_config prompt choose scales

    # fzf key bindings: Ctrl-T files, Ctrl-R history, Alt-C cd
    fzf --fish | source
    set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
    set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
    set -gx FZF_ALT_C_COMMAND 'fd --type d --hidden --exclude .git'
    set -gx FZF_CTRL_T_OPTS "--preview 'bat -n --color=always {}' --preview-window right,60%"
end

function fish_prompt
    set_color -o cyan
    printf '» '
    set_color normal
end

function fish_right_prompt
end

# -gx, not -Ux: an exported UNIVERSAL var is inherited by children as a GLOBAL,
# which then shadows the universal — so editing it here would never reach shells
# descended from an older one. Global+export makes this file the sole authority.
set -gx XDG_CONFIG_HOME "$HOME/.config"

function commit
    git add -A
    git commit --allow-empty-message -m ''
    git push
end

# tms isn't installed; use sesh (same picker as tmux prefix+p)
function sesh-picker
    set session (sesh list --icons | fzf --no-sort --ansi --prompt '⚡  ')
    if test -n "$session"
        sesh connect $session
    end
    commandline -f repaint
end
bind \cf sesh-picker
bind \ck clear
bind \cg lazygit
bind \cd "nvim +DBUI"
bind \cp commit
set -gx EDITOR nvim
# Dev root. Deliberately named differently on each machine so cloud-sync apps
# don't collide; Tom's ~/dev is ~/swMac1 here. Everything else reads $DEV_DIR.
set -gx DEV_DIR "$HOME/swMac1"
alias vim nvim
alias cat bat
alias sqlite /opt/homebrew/opt/sqlite/bin/sqlite3
alias sql "nvim +DBUI"

# Task runners: `local api web` opens one tmux window per task in a 'tasks'
# session, each running $DEV_DIR/scripts/local_run_<task>.sh. Create those
# scripts to use it. `localw` is the same against $VGW_DIR (Tom's work root) —
# set VGW_DIR if you want a second root, otherwise use `local`.
function localw
    if not set -q VGW_DIR
        echo "localw: VGW_DIR is not set — use `local`, or set VGW_DIR to a second dev root." >&2
        return 1
    end
    _run_local_tasks "$VGW_DIR" $argv
end

function local
    _run_local_tasks "$DEV_DIR" $argv
end

function _run_local_tasks
    set -l root $argv[1]
    set -l tasks $argv[2..-1]
    if test (count $tasks) -eq 0
        echo "usage: local <task>... (runs $root/scripts/local_run_<task>.sh)" >&2
        return 1
    end
    tmux new -ds tasks &>/dev/null
    for task in $tasks
        set -l script "$root/scripts/local_run_$task.sh"
        if not test -x "$script"
            echo "local: no runnable script at $script" >&2
            continue
        end
        echo "Running $task..."
        tmux kill-window -t tasks:$task &>/dev/null
        tmux new-window -n $task -t tasks "$script"
    end
end

# git bindings
alias gco="git checkout"
alias gs="git status"
alias gm="git mergetool"
# Fork workflow: these reset your fork's main to the ORIGINAL repo's main and
# force-push it. They require an `upstream` remote (git remote add upstream <orig>).
# Every step is guarded with `or return` — fish does NOT stop a function on a
# failed command, so without the guards a missing upstream would fall straight
# through to `git push -f` and force-push your local main over the remote.
function gcn
    if test (count $argv) -eq 0
        echo "usage: gcn <new-branch-name>" >&2
        return 1
    end
    git rev-parse --verify --quiet refs/remotes/upstream/HEAD >/dev/null
    or git ls-remote --exit-code upstream >/dev/null 2>&1
    or begin
        echo "gcn: no `upstream` remote here — add one, or use `git checkout -b $argv`." >&2
        return 1
    end
    git checkout main; or return
    git fetch upstream main; or return
    git reset --hard upstream/main; or return
    git push -f; or return
    git checkout -b $argv
end

function gr
    git ls-remote --exit-code upstream >/dev/null 2>&1
    or begin
        echo "gr: no `upstream` remote here — use `git pull --rebase` instead." >&2
        return 1
    end
    git fetch upstream main; or return
    git rebase upstream/main; or return
    git push --force-with-lease
end

zoxide init --cmd cd fish | source

# Only auto-attach for interactive shells outside tmux; otherwise every new
# pane errors with "sessions should be nested with care" and scripts break.
if status is-interactive; and not set -q TMUX
    tmux new-session -A -s main
end

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
