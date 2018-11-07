export EDITOR=vim
alias ls='ls -GAF'
[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion

function print_symlink {
    wd="$(pwd)"
    linkdir="$(readlink -n $wd)";
    if readlink -n $wd >/dev/null; then
        echo " -> $linkdir ";
    fi
}

function parse_git_branch {
  ref=$(git symbolic-ref HEAD 2> /dev/null) || return
  echo " ("${ref#refs/heads/}")"
}

export PS1='[\T]\[\e[0;32m\] \w\[\e[0;36m\]$(print_symlink)\[\e[0;31m\]$(parse_git_branch)\[\e[0m\] $ '

export HISTFILESIZE=
export HISTSIZE=
export HISTTIMEFORMAT="%Y-%m-%d %T "
export HISTCONTROL=ignoreboth
export HISTIGNORE=ls:cd
export PROMPT_COMMAND="$PROMPT_COMMAND; history -a"
