#
# .bashrc
#
# @(#) $Revision: 1.4
#
# @(#) most recent version always available at
# @(#)   http://github.com/murray-xx/Moo/tree/master/utils/
#
# Murray's .bashrc
# with a tip of the hat to Boyd's favourite .bashrc -
#    http://www.users.on.net/~boyd.adamson/boyds.bashrc
#
#

[[ $- == *i* ]] && _shell_is_interactive=1

PATH=`~/bin/pe ++~/bin || echo $PATH`

export TITLEBAR='\[\033]0;\h\007\]'
export PS1="${TITLEBAR}[\h \w]\$ "
[ -z "$TERM" ] && export TERM=xterm-256color
if [ -n "$TMUX" ]; then
    export TERM=screen-256color
fi
export EDITOR=vi
export PAGER='less'
export LESS="-iRXM"

[[ "$_shell_is_interactive" == 1 ]] && stty erase "^?"

# Shell options
shopt -s checkwinsize histreedit

# If I hit <tab> on a blank line, I DON'T want to see a list of all 
# the comands in my PATH - who would EVER want that??
shopt -s no_empty_cmd_completion

#Only put duplicate lines in the history once
HISTCONTROL=ignoredups

_HISTDIR=$HOME/.bash_history
HISTFILE=${_HISTDIR}/${HOSTNAME}
if [ ! -d $_HISTDIR ]; then
    if [ -f $_HISTDIR ]; then
        mv $_HISTDIR $_HISTDIR.tmp
        mkdir $_HISTDIR
        mv $_HISTDIR.tmp $HISTFILE
    else
        mkdir $_HISTDIR
    fi
fi

unset _HISTDIR

if [ $EUID -eq 0  -o "$LOGNAME" = "root" ]; then
    export TMOUT=600;
    HISTFILE=${HISTFILE}.root
    PS1="${TITLEBAR}\[\033[0;31m\][\h \w]# \[\033[0m\]"
    alias rm='rm -i'
    alias cp='cp -i'
    alias mv='mv -i'
else
    umask 077
fi

export HISTFILE

# dircolors --print-database
export LS_COLORS='no=00:fi=00:di=01;34:ln=38;5;24:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=38;5;22:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:';

alias more='less'
alias path='echo $PATH'
alias root='sudo $BASH'
alias isodate='date +"%Y%m%d"'
alias epochs='perl -leprint+time'
alias pstree='pstree -a -c -l -n -h -p'
alias ls='ls --color -CF'
alias gvim='gvim --remote-tab-silent'
alias src='. ~/.bashrc'

llpstat () {
    lpstat -p $1 -o $1
}

cnf () {
    # we subtract 2 to remove . and .. :)
    perl -le '$ARGV[0] ||= "."; opendir my $d, $ARGV[0] or die $!; ++$c while readdir $d; print $c - 2' "$1"
}

epoch2date () {
# convert epochs to human readable :)
    #perl -MPOSIX -le 'print strftime("%a %F %R:%S", localtime '$1')'
    /bin/date -d "@${1#@}"
}

drwho () {
  who | \
    perl -ne '$gecos = (getpwnam((split)[0]))[6];
              print $gecos, " " x (21 - length($gecos)), $_;'
}

perlmods () {
# I always forget this... 
    /usr/bin/find `perl -e 'print "@INC"'` -name '*.pm' -print
}

hogs () {
    echo " VSZ   PID COMMAND"
    /bin/ps -eo vsz,pid,args | sort -nr | head -10
}

own () {
    sudo chown "$(id -u):$(id -g)" "$@"
}

unset _shell_is_interactive


