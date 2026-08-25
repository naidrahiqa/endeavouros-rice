export PATH=$HOME/.local/bin:$PATH

eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/caelestia.omp.json)"

# History
setopt AUTO_CD
setopt INTERACTIVE_COMMENTS
setopt EXTENDED_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

# Completion
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

bindkey -e

# ── Plugins ──────────────────────────────────────────
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ── Tools ────────────────────────────────────────────
# zoxide (smart cd)
eval "$(zoxide init zsh)"
alias cd='z'

# fzf (fuzzy finder)
source <(fzf --zsh)

# ── Aliases ──────────────────────────────────────────
# ls -> lsd
alias ls='lsd'
alias ll='lsd -la'
alias la='lsd -a'
alias lt='lsd -la --sort=time'
alias l='lsd -la'
alias tree='lsd --tree --depth=2'
alias lt3='lsd -la --tree --depth=3'

# cat -> bat
alias cat='bat --paging=never --style=plain'
alias catp='bat --style=full'

# git
alias gs='git status'
alias gp='git push'
alias gl='git log --oneline --graph -20'
alias gd='git diff'
alias ga='git add'
alias gc='git commit -m'
alias gco='git checkout'
alias gb='git branch'

# navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'

# safety
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# quick edit
alias zshrc='$EDITOR ~/.zshrc'
alias reload='source ~/.zshrc && echo "✓ zshrc reloaded"'

# system
alias update='yay -Syu'
alias install='yay -S'
alias remove='yay -Rns'
alias search='yay -Ss'
alias mirror='sudo reflector --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist'

# misc
alias path='echo $PATH | tr ":" "\n"'
alias ports='ss -tulnp'
alias myip='curl -s ifconfig.me'
alias sizeof='du -sh'
alias ff='fastfetch'
alias weather='curl -s "wttr.in/?format=4"'

# Directory shortcuts
alias docs='cd ~/Documents'
alias dl='cd ~/Downloads'
alias desk='cd ~/Desktop'

# ── NVM ──────────────────────────────────────────────
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

[ -f ~/.aliases ] && source ~/.aliases
[ -f ~/.zsh_aliases ] && source ~/.zsh_aliases


# Added by Antigravity CLI installer
export PATH="/home/naidrahiqa/.local/bin:$PATH"

# Cursor theme
export XCURSOR_THEME=Castorice
export XCURSOR_SIZE=24

# Qt theme
export QT_STYLE_OVERRIDE=kvantum
ZSH_AUTOSUGGEST_HIGHLIGHT="fg=#566160"

# ── Syntax Highlighting Colors (Caelestia) ────────────
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[default]="fg=#e1fffc"
ZSH_HIGHLIGHT_STYLES[unknown-token]="fg=#F38BA8,bold"
ZSH_HIGHLIGHT_STYLES[reserved-word]="fg=#94E2D5"
ZSH_HIGHLIGHT_STYLES[alias]="fg=#89DCEB,bold"
ZSH_HIGHLIGHT_STYLES[suffix-alias]="fg=#89DCEB,bold"
ZSH_HIGHLIGHT_STYLES[builtin]="fg=#94E2D5,bold"
ZSH_HIGHLIGHT_STYLES[function]="fg=#89DCEB,bold"
ZSH_HIGHLIGHT_STYLES[command]="fg=#89DCEB,bold"
ZSH_HIGHLIGHT_STYLES[precommand]="fg=#F9E2AF,bold"
ZSH_HIGHLIGHT_STYLES[command-separator]="fg=#566160"
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]="fg=#A6E3A1"
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]="fg=#A6E3A1"
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]="fg=#A6E3A1"
ZSH_HIGHLIGHT_STYLES[assign]="fg=#89DCEB"
ZSH_HIGHLIGHT_STYLES[redirection]="fg=#F9E2AF"
ZSH_HIGHLIGHT_STYLES[comment]="fg=#566160,italic"

# bun completions
[ -s "/home/naidrahiqa/.bun/_bun" ] && source "/home/naidrahiqa/.bun/_bun"
export PATH="/home/naidrahiqa/.bun/bin:$PATH"
