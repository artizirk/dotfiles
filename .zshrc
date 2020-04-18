# vim: tabstop=8 expandtab shiftwidth=4 softtabstop=4
# Virtualenv support
function virtual_env_prompt () {
    REPLY=${VIRTUAL_ENV+(${VIRTUAL_ENV:t}) }
}
grml_theme_add_token  virtual-env -f virtual_env_prompt '%F{magenta}' '%f'

function config_env_prompt () {
    REPLY=${CONFIG_ENV+(${CONFIG_ENV:t}) }
}
grml_theme_add_token config-env -f config_env_prompt

zstyle ':prompt:grml:left:setup' items rc config-env virtual-env change-root user at host path vcs percent

# Disable right side sad smiley, works nicer with resized terminal
zstyle ':prompt:grml:right:setup' use-rprompt false

# Git based dotfiles setup start
function _config_activate {
    export GIT_DIR=$HOME/.cfg/
    export GIT_WORK_TREE=$HOME
    CONFIG_ENV="config"
}

function _config_deactivate {
    unset GIT_DIR GIT_WORK_TREE CONFIG_ENV
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
zstyle ':chpwd:profiles:/home/arti/code/milrem(|/|/*)' profile milrem
function chpwd_profile_milrem() {
    [[ ${profile} == ${CHPWD_PROFILE} ]] && return 1

    export GIT_AUTHOR_EMAIL="arti.zirk@milrem.com"
    export GIT_COMMITER_EMAIL="arti.zirk@milrem.com"
}
function chpwd_leave_profile_milrem() {
    unset GIT_AUTHOR_EMAIL GIT_COMMITER_EMAIL
}
chpwd_profiles

hash -d milrem=~/code/milrem  # shorten dir name in prompt

# Enable or disable python virtual env
function chpwd_auto_python_venv() {
    local venv_dir
    local cur_dir="${PWD}"
    while [[ "${cur_dir}" != / ]]; do
        if [[ -f "${cur_dir}/venv/bin/activate" ]]; then
            venv_dir="${cur_dir}/venv"
            break
        fi
        # :P does `realpath(3)`
        # :h removes 1 trailing pathname component
        cur_dir="${cur_dir:P:h}"
    done
    if [[ -z "${VIRTUAL_ENV}" ]] && [[ -n "${venv_dir}" ]]; then
        # we found venv dir that is not yet activated
        source "${venv_dir}"/bin/activate
    elif [[ -z "${venv_dir}" ]] && [[ -n "${VIRTUAL_ENV}" ]]; then
        # we have activated virtual env but we cant find venv folder anymore
        deactivate
    fi
}
chpwd_functions+=(chpwd_auto_python_venv)

if [[ -f /etc/profile.d/vte.sh ]]; then
    source /etc/profile.d/vte.sh
fi

function new-scratch {
  cur_dir="$HOME/scratch"
  new_dir="$HOME/tmp/scratch-`date +'%s'`"
  mkdir -p $new_dir
  ln -nfs $new_dir $cur_dir
  cd $cur_dir
  echo "New scratch dir ready for grinding ;>"
}

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
alias cal="cal -w3"
alias gitg="LANG=en_US.UTF-8 gitg"

if [[ -f /usr/share/zaw/zaw.zsh ]]; then
    source /usr/share/zaw/zaw.zsh

    bindkey '^R' zaw-history
    bindkey -M filterselect '^R' down-line-or-history
    bindkey -M filterselect '^S' up-line-or-history
    bindkey -M filterselect '^E' accept-search

    zstyle ':filter-select:highlight' matched fg=green
    zstyle ':filter-select' max-lines 3
    zstyle ':filter-select' extended-search yes
fi

EDITOR=nvim
VISUAL=nvim

# iostat colors
export S_COLORS=auto

if [[ -f /usr/share/zsh/site-functions/git-flow-completion.zsh ]];then
    source /usr/share/zsh/site-functions/git-flow-completion.zsh
fi

export PATH="/home/arti/.bin:$(ruby -e 'print Gem.user_dir')/bin:$PATH"


HISTSIZE=100000
SAVEHIST=100000

unsetopt share_history
setopt INC_APPEND_HISTORY_TIME


#pkg not found
if [ -f /usr/share/doc/pkgfile/command-not-found.zsh ]; then
    source /usr/share/doc/pkgfile/command-not-found.zsh
fi

function gedit {
    local REAL_PATH=$PATH;
    if [ -n "$_OLD_VIRTUAL_PATH" ] ; then
        REAL_PATH=$_OLD_VIRTUAL_PATH;
    fi
    PATH=$REAL_PATH env -u VIRTUAL_ENV /usr/bin/gedit $@;
}

# i don't like that systemd by default uses a pager
export SYSTEMD_PAGER=''

# set man max width
export MANWIDTH=80

# make npm gyp faster
export JOBS=8
