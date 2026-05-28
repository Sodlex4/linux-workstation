# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Preserve Omarchy's environment, aliases, and functions
source ~/.local/share/omarchy/default/bash/envs
source ~/.local/share/omarchy/default/bash/aliases
source ~/.local/share/omarchy/default/bash/functions

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
  source /usr/share/fzf/completion.zsh 2>/dev/null
  source /usr/share/fzf/key-bindings.zsh 2>/dev/null
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
