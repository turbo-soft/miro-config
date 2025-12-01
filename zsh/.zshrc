# Base directory for zsh plugins and completions
ZSH_DIR="$HOME/.config/zsh"

# Auto-install missing tools (eza, zoxide, etc.)
[ -f "$ZSH_DIR/auto-install.sh" ] && source "$ZSH_DIR/auto-install.sh"

HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000
setopt appendhistory

# some useful options (man zshoptions)
setopt autocd extendedglob nomatch menucomplete
setopt interactive_comments
stty stop undef		# Disable ctrl-s to freeze terminal.
zle_highlight=('paste:none')

# beeping is annoying
unsetopt BEEP

# completions
autoload -Uz compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
_comp_options+=(globdots)		# Include hidden files.

autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# Colors
autoload -Uz colors && colors

# ==================== Functions ====================

function zsh_add_plugin() {
    PLUGIN_NAME=$(echo $1 | cut -d "/" -f 2)
    if [ -d "$ZSH_DIR/plugins/$PLUGIN_NAME" ]; then
        [ -f "$ZSH_DIR/plugins/$PLUGIN_NAME/$PLUGIN_NAME.plugin.zsh" ] && \
            source "$ZSH_DIR/plugins/$PLUGIN_NAME/$PLUGIN_NAME.plugin.zsh" || \
            source "$ZSH_DIR/plugins/$PLUGIN_NAME/$PLUGIN_NAME.zsh"
    else
        git clone "https://github.com/$1.git" "$ZSH_DIR/plugins/$PLUGIN_NAME"
    fi
}

function zsh_add_completion() {
    PLUGIN_NAME=$(echo $1 | cut -d "/" -f 2)
    if [ -d "$ZSH_DIR/plugins/$PLUGIN_NAME" ]; then
        completion_file_path=$(ls $ZSH_DIR/plugins/$PLUGIN_NAME/_*)
        fpath+="$(dirname "${completion_file_path}")"
        [ -f "$ZSH_DIR/plugins/$PLUGIN_NAME/$PLUGIN_NAME.plugin.zsh" ] && \
            source "$ZSH_DIR/plugins/$PLUGIN_NAME/$PLUGIN_NAME.plugin.zsh"
    else
        git clone "https://github.com/$1.git" "$ZSH_DIR/plugins/$PLUGIN_NAME"
        fpath+=$(ls $ZSH_DIR/plugins/$PLUGIN_NAME/_*)
    fi
}

function mach_java_mode() {
    export SDKMAN_DIR="$HOME/.sdkman"
    [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
}

# ==================== Exports ====================

export PATH="$HOME/.local/bin":$PATH
export MANPAGER='nvim +Man!'
export MANWIDTH=999
export PATH=$HOME/.cargo/bin:$PATH
export PATH=$HOME/.local/share/go/bin:$PATH
export GOPATH=$HOME/.local/share/go
export PATH="$PATH:./node_modules/.bin"

export EDITOR="nvim"
export TERMINAL="ghostty"
export BROWSER="firefox"
export QT_QPA_PLATFORMTHEME=qt5ct

# ==================== Conda ====================

__conda_setup="$("$HOME/.miniconda/bin/conda" 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "$HOME/.miniconda/etc/profile.d/conda.sh" ]; then
        . "$HOME/.miniconda/etc/profile.d/conda.sh"
    else
        export PATH="$HOME/.miniconda/bin:$PATH"
    fi
fi
unset __conda_setup

# ==================== Vim Mode ====================

bindkey -v
export KEYTIMEOUT=1

# Use vim keys in tab complete menu:
bindkey -M menuselect '^h' vi-backward-char
bindkey -M menuselect '^k' vi-up-line-or-history
bindkey -M menuselect '^l' vi-forward-char
bindkey -M menuselect '^j' vi-down-line-or-history
bindkey -M menuselect '^[[Z' vi-up-line-or-history
bindkey -v '^?' backward-delete-char

# Change cursor shape for different vi modes.
function zle-keymap-select () {
    case $KEYMAP in
        vicmd) echo -ne '\e[1 q';;      # block
        viins|main) echo -ne '\e[5 q';; # beam
    esac
}
zle -N zle-keymap-select
zle-line-init() {
    zle -K viins
    echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q'
preexec() { echo -ne '\e[5 q' ;}

# ==================== Aliases ====================

alias j='z'
alias f='zi'
alias g='lazygit'
alias zsh-update-plugins="find "$ZSH_DIR/plugins" -type d -exec test -e '{}/.git' ';' -print0 | xargs -I {} -0 git -C {} pull -q"
alias nvimrc='nvim ~/.config/nvim/'

# get fastest mirrors

alias v="nvim"



# Colorize grep output
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# confirm before overwriting something
alias cp="cp -i"
alias mv='mv -i'
alias rm='rm -i'

# easier to read disk
alias df='df -h'
alias free='free -m'
alias cldy='claude --dangerously-skip-permissions'


alias sail="./vendor/bin/sail"


case "$(uname -s)" in
Darwin)
    alias ls='ls -G'
    ;;
Linux)
    alias ls='ls --color=auto'
    ;;
esac


autoload -Uz vcs_info

# enable only git
zstyle ':vcs_info:*' enable git

# setup a hook that runs before every prompt
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst

# check for untracked files
zstyle ':vcs_info:git*+set-message:*' hooks git-untracked
+vi-git-untracked(){
    if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == 'true' ]] && \
        git status --porcelain | grep '??' &> /dev/null ; then
        hook_com[staged]+='!'
    fi
}

zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:git:*' formats " %{$fg[blue]%}(%{$fg[red]%}%m%u%c%{$fg[yellow]%}%{$fg[magenta]%} %b%{$fg[blue]%})"

PROMPT="%B%{$fg[blue]%}%{$fg[blue]%} %(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ )%{$fg[cyan]%}%c%{$reset_color%}"
PROMPT+="\$vcs_info_msg_0_ "

# ==================== Plugins ====================

zsh_add_plugin "zsh-users/zsh-autosuggestions"
zsh_add_plugin "zsh-users/zsh-syntax-highlighting"
zsh_add_plugin "hlissner/zsh-autopair"
zsh_add_completion "esc/conda-zsh-completion" false

# ==================== Key Bindings ====================

bindkey -s '^o' 'yazi^M'
bindkey -s '^f' 'zi^M'
bindkey -s '^s' 'ncdu^M'
bindkey -s '^z' 'zi^M'
bindkey -s '^w' 'cw^M'
bindkey '^[[P' delete-char
bindkey "^p" up-line-or-beginning-search
bindkey "^n" down-line-or-beginning-search
bindkey "^k" up-line-or-beginning-search
bindkey "^j" down-line-or-beginning-search
bindkey -r "^u"
bindkey -r "^d"

# ==================== FZF ====================

[ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh
[ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
[ -f /usr/share/doc/fzf/examples/completion.zsh ] && source /usr/share/doc/fzf/examples/completion.zsh
[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f $ZSH_DIR/completion/_fnm ] && fpath+="$ZSH_DIR/completion/"

compinit

# Edit line in vim with ctrl-e:
autoload edit-command-line; zle -N edit-command-line

# Speedy keys (Linux only - xset not available on macOS)
if command -v xset &> /dev/null; then
    xset r rate 210 40
fi

# zoxide
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
