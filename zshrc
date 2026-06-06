# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Preserve Omarchy's environment, aliases, and functions
OMARCHY_BASH=~/.local/share/omarchy/default/bash
[ -f "$OMARCHY_BASH/envs" ] && source "$OMARCHY_BASH/envs"
[ -f "$OMARCHY_BASH/aliases" ] && source "$OMARCHY_BASH/aliases"
[ -f "$OMARCHY_BASH/functions" ] && source "$OMARCHY_BASH/functions"

# Init tools
if command -v mise &> /dev/null; then
  eval "$(mise activate zsh)"
fi

if command -v starship &> /dev/null; then
  eval "$(starship init zsh)"
fi

if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
fi

if command -v fzf &> /dev/null; then
  for fzf_dir in /usr/share/fzf /usr/share/zsh/site-functions /usr/local/opt/fzf/shell; do
    [ -f "$fzf_dir/completion.zsh" ] && source "$fzf_dir/completion.zsh" && break
  done
  for fzf_dir in /usr/share/fzf /usr/share/zsh/site-functions /usr/local/opt/fzf/shell; do
    [ -f "$fzf_dir/key-bindings.zsh" ] && source "$fzf_dir/key-bindings.zsh" && break
  done
fi

# History
HISTSIZE=100000
SAVEHIST=100000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_REDUCE_BLANKS
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS

# Completion
autoload -Uz compinit promptinit
compinit
promptinit

# User aliases
alias dev='cd ~/dev'
alias dev-web='cd ~/dev/web'
alias dev-java='cd ~/dev/java'
alias dev-cli='cd ~/dev/cli'
alias dev-backend='cd ~/dev/backend'
alias dev-scripts='cd ~/dev/scripts'
alias dev-notes='cd ~/dev/notes'
alias dev-work='cd ~/dev/work'

# bat theme
export BAT_THEME=ansi
export PATH="$HOME/.local/bin:$PATH"
