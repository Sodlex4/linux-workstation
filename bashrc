# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

export OMARCHY_PATH="$HOME/.local/share/omarchy"

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
[ -f ~/.local/share/omarchy/default/bash/rc ] && source ~/.local/share/omarchy/default/bash/rc

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'
# alias cx="claude --permission-mode=plan --allow-dangerously-skip-permissions"

alias dev='cd ~/dev'
alias dev-web='cd ~/dev/web'
alias dev-java='cd ~/dev/java'
alias dev-cli='cd ~/dev/cli'
alias dev-backend='cd ~/dev/backend'
alias dev-scripts='cd ~/dev/scripts'
alias dev-notes='cd ~/dev/notes'
alias dev-work='cd ~/dev/work'
export PATH="$HOME/.local/bin:$PATH"
