# Virtualenv support

function virtual_env_prompt () {
    REPLY=${VIRTUAL_ENV+(${VIRTUAL_ENV:t}) }
}
grml_theme_add_token  virtual-env -f virtual_env_prompt '%F{magenta}' '%f'
zstyle ':prompt:grml:left:setup' items rc virtual-env change-root user at host path vcs percent
# Disable right side sad smiley, works nicer with resized terminal
zstyle ':prompt:grml:right:setup' use-rprompt false


source /etc/profile.d/vte.sh

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
alias ip="ip -c"
alias cp="cp --reflink=auto"
alias cal="cal -w3"
alias gitg="LANG=en_US.UTF-8 gitg"
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

source /usr/share/zaw/zaw.zsh

bindkey '^R' zaw-history
bindkey -M filterselect '^R' down-line-or-history
bindkey -M filterselect '^S' up-line-or-history
bindkey -M filterselect '^E' accept-search

zstyle ':filter-select:highlight' matched fg=green
zstyle ':filter-select' max-lines 3
zstyle ':filter-select' extended-search yes

EDITOR=nvim
VISUAL=nvim

# iostat colors
export S_COLORS=auto

source /usr/share/zsh/site-functions/git-flow-completion.zsh

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
