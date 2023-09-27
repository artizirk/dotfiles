# vim: tabstop=8 expandtab shiftwidth=4 softtabstop=4

# Use a REAL regex engine
zmodload zsh/pcre

# Virtualenv support
function _virtual_env_prompt () {
    # new pyvenv has a seperate variable for custom prompt value
    REPLY=${VIRTUAL_ENV_PROMPT+${VIRTUAL_ENV_PROMPT}}

    # Try to read the prompt name form pyvenv.cfg
    if [[ -z "${REPLY}" && -f "$VIRTUAL_ENV/pyvenv.cfg" ]]; then
	# Matches lines with following syntax
	# prompt = 'cool prompt'
	# prompt = "cool prompt"
	# prompt = cool
	# prompt=cool prompt
	# heredoc is used here so that I don't have to
	# manually escape the regex 🤮
        local prompt_re
	read -r prompt_re <<-'EOF'
	^prompt\s*=\s*['"]?(.+?)['"]?$
	EOF

	# -m turns on multiline support, this makes ^ and $ anchor work in multiline string
	pcre_compile -m ${prompt_re}

	# And now its supper easy to get the value
	if pcre_match -- "$(<$VIRTUAL_ENV/pyvenv.cfg)"
	then
            REPLY="(${match[1]}) "
	fi
    fi

    # support old-school virtualenv
    if [[ -z "${REPLY}" ]]; then
        REPLY=${VIRTUAL_ENV+(${VIRTUAL_ENV:t}) }
    fi
}
grml_theme_add_token virtual-env -f _virtual_env_prompt '%F{magenta}' '%f'

function _config_env_prompt () {
    REPLY=${CONFIG_ENV+(${CONFIG_ENV:t}) }
}
grml_theme_add_token config-env -f _config_env_prompt

zstyle ':prompt:grml:left:setup' items rc config-env virtual-env change-root user at host path vcs percent

# Disable right side sad smiley, works nicer with resized terminal
zstyle ':prompt:grml:right:setup' use-rprompt false

# disable PROMPT_EOL_MARK or also known as % on end of line
# https://unix.stackexchange.com/a/302710
#set +o prompt_cr +o prompt_sp

# Tell to the terminal about our current working directory
# NB: turns out that alacritty snopps that info from /proc/PID/cwd
xsource ~/.config/zsh/functions/osc7-pwd.zsh

# enable OSC 133 shell prompt start/end reporting
# so that the terminal can scroll jump between prompts
xsource ~/.config/zsh/functions/semantic-prompt.zsh

# Git based dotfiles setup start
function _config_activate {
    export GIT_DIR=$HOME/.cfg/
    export GIT_WORK_TREE=$HOME
    CONFIG_ENV="config"
}

function _config_deactivate {
    unset GIT_DIR GIT_WORK_TREE CONFIG_ENV
}

function config_status {
    # Borrowed from https://mitxela.com/projects/dotfiles_management
    (
        _config_activate
        for i in $(git ls-files); do
          echo -n "$(git -c color.status=always status $i -s | sed "s#$i##")"
          echo -e "¬/$i¬\e[0;33m$(git -c color.ui=always log -1 --format="%s" -- $i)\e[0m"
        done
    ) | column -t --separator=¬ -T2
}

function config {
    if [[ -n "$1" ]]; then
        _config_activate
        git $@
        _config_deactivate
        return
    elif [[ -z "${CONFIG_ENV}" ]]; then
        _config_activate
    else
        _config_deactivate
    fi
}
# git based dotfiles setup end

# GRML profiles
zstyle ':chpwd:profiles:/home/arti/code/krakul(|/|/*)' profile krakul
function chpwd_profile_krakul() {
    [[ ${profile} == ${CHPWD_PROFILE} ]] && return 1

    export GIT_AUTHOR_EMAIL="arti@krakul.eu"
    export GIT_COMMITTER_EMAIL="arti@krakul.eu"
}
function chpwd_leave_profile_krakul() {
    [[ ${profile} == ${CHPWD_PROFILE} ]] && return 1

    unset GIT_AUTHOR_EMAIL \
        GIT_COMMITTER_EMAIL
}
chpwd_profiles


# for some reason zsh does not pick up git-subrepo custom command
# I have to add it manually to git completion
zstyle ':completion:*:*:git:*' user-commands subrepo:'perform git-subrepo operations'

# First clear grml-zsh-config provided directory hashes
hash -d -r
# shorten dir name in prompt
hash -d krakul=~/code/krakul
function hash_projects() {
    # hash everything under krakul projects
    local project_folder
    for project_folder in ~/code/krakul/*; do
        hash -d "${project_folder:t}"="${project_folder}"
    done
    unset project_folder
}
hash_projects

# remove need to add ~ in front of hashed dirs
setopt cdable_vars

# Enable or disable python virtual env
function chpwd_auto_python_venv() {
    local venv_activation_script=((../)#(.|)(v|)env/bin/activate(#qN.omY1:a))
    # dont check for (current_venv != found_venv) here because
    # we want to support swtiching between venvs
    if [[ -n "${venv_activation_script}" && -z "${VIRTUAL_ENV}" ]]; then
        # we found venv dir that is not yet activated or is different from currently active one
        source "${venv_activation_script}"
    elif [[ -z "${venv_activation_script}" && -n "${VIRTUAL_ENV}" ]]; then
        # we have activated virtual env but we cant find venv folder anymore
        deactivate
    fi
}
chpwd_functions+=(chpwd_auto_python_venv)
chpwd_auto_python_venv  # Try to enter venv on shell startup

# https://github.com/Tarrasch/zsh-autoenv
xsource ~/.config/zsh/zsh-autoenv/autoenv.zsh
# gitflow-zshcompletion-avh
xsource /usr/share/zsh/site-functions/git-flow-completion.zsh
# pkg not found
xsource /usr/share/doc/pkgfile/command-not-found.zsh


# default is 40%, and that is too much, limit to less lines
FZF_TMUX_HEIGHT=6
# other shortcuts already use reverse, except history search for some reason..
FZF_CTRL_R_OPTS="--reverse"

# Arch Linux
xsource /usr/share/fzf/key-bindings.zsh
xsource /usr/share/fzf/completion.zsh

# Debian
xsource /usr/share/doc/fzf/examples/key-bindings.zsh

# fzf history search with support for Ctrl+E history edit like with zaw widget before
if typeset -f fzf-history-widget > /dev/null; then
    # Copied form key-bindings.zsh
    # CTRL-R - Paste the selected command from history into the command line
    fzf-history-widget() {
      local selected num
      setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2> /dev/null
      selected=( $(fc -rl 1 | perl -ne 'print if !$seen{(/^\s*[0-9]+\**\s+(.*)/, $1)}++' |
        FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} $FZF_DEFAULT_OPTS -n2..,.. --tiebreak=index --bind=ctrl-r:toggle-sort --expect=ctrl-e $FZF_CTRL_R_OPTS --query=${(qqq)LBUFFER} +m" $(__fzfcmd)) )
      local ret=$?
      if [ -n "$selected" ]; then
        local accept=0
        if [[ $selected[1] == ctrl-e ]]; then
          accept=1
          shift selected
        fi
        num=$selected[1]
        if [ -n "$num" ]; then
          zle vi-fetch-history -n $num
          [[ $accept = 0 ]] && zle accept-line
        fi
      fi
      zle reset-prompt
      return $ret
    }
    zle     -N   fzf-history-widget
    bindkey '^R' fzf-history-widget
fi


# Paste handling
autoload -Uz bracketed-paste-magic
zle -N bracketed-paste bracketed-paste-magic

autoload -Uz bracketed-paste-url-magic
zle -N bracketed-paste bracketed-paste-url-magic

# Reverse `cd -<TAB>` history menu
setopt pushdminus
#
# Utility functions

function new-scratch {
  local cur_dir="$HOME/scratch"
  local new_dir="$HOME/tmp/scratch-`date +'%s'`"
  mkdir -p $new_dir
  ln -nfs $new_dir $cur_dir
  cd $cur_dir
  echo "New scratch dir ready for grinding ;>"
}

histsearch() { fc -lim "*$@*" 1 }

alias pacman="sudo pacman"
alias py="python"
alias py2="python2"
alias ll="ls -lh"
alias la="ls -a"
alias dmesg="dmesg -L"
alias disapprove="firefox 'data:text/html;base64,PGRpdiBzdHlsZT0idGV4dC1hbGlnbjpjZW50ZXI7Zm9udC1zaXplOjU1dm1pbiI+JiMzMjMyO18mIzMyMzI7PC9kaXY+Cg=='"
alias ipy="ipython"
alias htop="htop -d 10"
alias ip="ip -color=auto"
alias cp="cp --reflink=auto"
alias gitg="LANG=en_US.UTF-8 gitg"

export EDITOR=nvim
export VISUAL=nvim
MAILCHECK=0
MAIL=~/Mail

# iostat colors
export S_COLORS=auto

if command -v ruby > /dev/null; then
    ruby_gem_user_dir="$(ruby -e 'print Gem.user_dir')/bin"
else
    ruby_gem_user_dir=''
fi

# ZSH allows $PATH to be used as an array
path=(
    ~/.bin
    ~/.local/bin
    /usr/bin/site_perl
    /usr/bin/vendor_perl
    /usr/bin/core_perl
    "${ruby_gem_user_dir}"
    $path
)

export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

HISTSIZE=100000
SAVEHIST=100000

unsetopt share_history
setopt INC_APPEND_HISTORY_TIME

# by default show 3 months of calendar with week number
# but also allow to override it
function cal {
    local CALENDAR=$(which -p cal)
    if [[ $# -eq 0 ]]; then
        $CALENDAR -m -w3
    else
        $CALENDAR -m "$@"
    fi
}

# this fixes gedit python plugins that otherwise are broken under venv
function gedit {
    local REAL_PATH=$PATH;
    if [ -n "$_OLD_VIRTUAL_PATH" ] ; then
        REAL_PATH=$_OLD_VIRTUAL_PATH;
    fi
    PATH=$REAL_PATH env -u VIRTUAL_ENV /usr/bin/gedit $@;
}

# NodeJS people really love to erase the terminal scrollback buffer
# running npm through cat usually solves it
# https://nodejs.org/api/tty.html#tty
# https://github.com/facebook/create-react-app/issues/2495
function npm {
    (
    export COLOR=1
    export REACT_APP_NO_CLEAR_CONSOLE=1
    exec /usr/bin/npm $@ | cat
    )
}


function ssh {
    (
    if [[ "$TERM" == "foot" ]]; then
        export TERM=xterm-256color
    fi
    exec /usr/bin/ssh $@
    )
}

# i don't like that systemd by default uses a pager
export SYSTEMD_PAGER=''

# set man max width
export MANWIDTH=80

# make npm gyp faster
export JOBS=8

# under tmux less needs this to support scrolling
if [[ "$TERM" == "" ]]; then
    export LESS='--mouse --wheel-lines=3'
fi

# https://neovim.io/doc/user/various.html#less
function vless {
    /usr/share/nvim/runtime/macros/less.sh $@
}

# If running under windows with pageagent then use it
# https://github.com/benpye/wsl-ssh-pageant
if [[ -e /mnt/c/wsl-ssh-pageant/ssh-agent.sock ]]; then
    export SSH_AUTH_SOCK=/mnt/c/wsl-ssh-pageant/ssh-agent.sock
fi

# We are running under WSL
if [[ -e /dev/lxss ]]; then
    # Create pretty serial device names
    reg.exe query HKLM\\HARDWARE\\DEVICEMAP\\SERIALCOMM | awk '/Device/ {gsub("\r","",$3); print "/dev/ttyS" substr($3,4), "/dev/tty" substr($1,9)}' | sudo xargs -n2 ln -sf
fi


function nitroid {
    # Switch Nitrokey Start Identity
    # https://github.com/Nitrokey/pynitrokey/tree/70398d9d87d002c14402591dfa6e4fe9e7182351#switching-id

    local ID=$1

    if ! [[ "$ID" =~ [0-2] ]]; then
        echo "Usage: $0 ID"
        echo "Where identity ID is in range 0-2"
        return 1
    fi

    if gpg-connect-agent --hex "scd apdu  00 85 00 0$ID" /bye | grep -q ERR; then
        sleep 1
        gpg-connect-agent --decode "scd serialno" /bye
    else
        echo "already set"
    fi

}
compdef 'compadd -X "Identity" 0 1 2' nitroid


function cpr {
    rsync --archive -hh --partial --info=stats1,progress2 "$@"
}
