
set -o notify
shopt -s cdspell
shopt -s checkwinsize
shopt -s cmdhist
shopt -s extglob
shopt -s histappend
shopt -s dirspell
shopt -s globstar

export EDITOR=vim
export VISUAL=vim
export PAGER=less
export MANPAGER='less -FiRs'

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
export HISTIGNORE="&:bg:fg:ls:cd:clear:exit"
export PROMPT_COMMAND="$PROMPT_COMMAND; history -a"
