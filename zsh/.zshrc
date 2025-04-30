# Set up the prompt
prompt_status() {
    printf %s "%(?|%S%F{yellow}✔%f%s|%S%F{red}✘%f%s) "
}
prompt_jobs() {
    printf %s "%1(j| %F{8}[%j]%f|)"
}
prompt_host() {
    printf %s "[${USER}@$(hostname)]"
}
prompt_pwd() {
    if test -e "${PWD}"; then
        printf %s "%F{yellow}%(5~|…/|)%4~%f"
    else
        printf %s "%F{red}%(5~|…/|)%4~%f"
    fi
}
prompt_git_branch() {
    set -o pipefail

    if ! git rev-parse --is-inside-work-tree >/dev/null 2>/dev/null; then
        return
    fi

    local branch=$(
        { git symbolic-ref HEAD 2>/dev/null | sed -E -e 's|^refs/heads/||' -e 's|^(.{20}).+|\1…|'; } ||
        { git status 2>/dev/null | head -n 1 | sed 's|^HEAD detached at |@|'; }
    )

    test -n "$(git status --porcelain 2>/dev/null)" &&
        printf %s " (%F{green}$branch%f*)" ||
        printf %s " (%F{green}$branch%f)"
}
prompt_venv() {
    test -n "$VIRTUAL_ENV" &&
        printf " %%F{blue}(%s)%%f" "$(basename "$VIRTUAL_ENV")"
}
prompt_datetime() {
    printf "%%F{8}[%s]%%f" "$(date +%H:%M:%S)"
}

VIRTUAL_ENV_DISABLE_PROMPT=1

autoload -Uz promptinit
promptinit
setopt prompt_subst
PROMPT='$(prompt_status)$(prompt_pwd)$(prompt_git_branch)$(prompt_venv)$(prompt_jobs) %F{8}%B%#%b%f%k '

precmd() {
    # Print ^C when prompt is calcelled
    TRAPINT() {
        print -n "\x1b[1;7m^C\x1b[m"
        return $(( 128 + $1 ))
    }
}
preexec() {
    TRAPINT() {}
}

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

# command history
setopt histignorealldups histignorespace sharehistory
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.local/share/zsh/history

# cd history
DIRSTACKSIZE=20
setopt autopushd pushdignoredups
alias cdh='cd "$(dirs -l -p | fzf)"'

# set LS_COLORS variable
eval "$(dircolors -b)"

# set locale variables
# For an interactive shell always set locale to "C", regardless of what
# the system default is. This avoids suprises, where coreutils depend
# on locale settings where no one expects them to (especially when they
# are used in scripts)
export LANG=C.UTF-8
unset LC_ADDRESS
unset LC_IDENTIFICATION
unset LC_MEASUREMENT
unset LC_MONETARY
unset LC_NAME
unset LC_NUMERIC
unset LC_PAPER
unset LC_TELEPHONE
unset LC_TIME

# Use modern completion system
autoload -Uz compinit
compinit -d ~/.cache/zsh/zcompdump

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'


test -d ~/.config/zsh/zsh-autosuggestions && source ~/.config/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

test -d ~/.config/zsh/zsh-fzf-history-search && {
    ZSH_FZF_HISTORY_SEARCH_EVENT_NUMBERS=0
    ZSH_FZF_HISTORY_SEARCH_DATES_IN_SEARCH=0
    source ~/.config/zsh/zsh-fzf-history-search/zsh-fzf-history-search.zsh
}

ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh


# Remove '/' from WORDCHARS to stop <a-backspace> on directory separators
# Also remove '='
WORDCHARS='*?_-.[]~&;!#$%^(){}<>'
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

bindkey "$key[Up]" up-line-or-local-history
bindkey "$key[Down]" down-line-or-local-history
bindkey '^[[1;5A' up-history
bindkey '^[[1;5B' down-history

up-line-or-local-history() {
    zle set-local-history 1
    zle up-line-or-search
    zle set-local-history 0
}
down-line-or-local-history() {
    zle set-local-history 1
    zle down-line-or-search
    zle set-local-history 0
}
zle -N up-line-or-local-history
zle -N down-line-or-local-history

alias diff='git diff --no-index --unified=15'
alias grep='grep --color=auto'
alias ip='ip --color=auto'

function ls {
    command ls --color=auto -h --time-style="$(printf '+%s' ' %Y-%b-%d %H:%M')" "$@"
}

