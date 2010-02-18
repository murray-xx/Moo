#
# .bashrc
#
# update version always available at
#   http://github.com/murray/Moo/tree/master/utils/
#
# Murray's .bashrc
# with a tip of the hat to Boyd's favourite .bashrc -
#    http://www.users.on.net/~boyd.adamson/boyds.bashrc
#
# stuff specific to locations (say current $client) goes in .bashrc.local
#
#

[[ $- == *i* ]] && _shell_is_interactive=1

[ -f $HOME/.bashrc.local ] && . $HOME/.bashrc.local
path_edit=~/bin/pe

PATH=/bin:/usr/bin:/usr/local/bin:/sbin:/usr/local/sbin:/usr/sbin
MANPATH=/usr/local/man:/usr/man:/usr/share/man:/usr/kerberos/man

[ -d ~/bin ] && PATH=$PATH:~/bin

[ -d /opt/VRTS/man ] && MANPATH=$MANPATH:/opt/VRTS/man

if [ -d /usr/X11R6 ]; then
        PATH=$PATH:/usr/X11R6/bin
        MANPATH=$MANPATH:/usr/X11R6/man
fi

if [ -d /usr/openwin ]; then
        PATH=$PATH:/usr/openwin/bin
        MANPATH=$MANPATH:/usr/openwin/man
fi

if [ -d /usr/opt/SUNWmd ]; then
        PATH=$PATH:/usr/opt/SUNWmd/sbin
        MANPATH=$MANPATH:/usr/opt/SUNWmd/man
fi

if [ -d /opt/SUNWadm ]; then
        PATH=$PATH:/opt/SUNWadm/bin
        MANPATH=$MANPATH:/opt/SUNWadm/man
fi

if [ -d /opt/OPENssh/ ]; then
    PATH=`$path_edit +/opt/OPENssh/bin || echo $PATH`
    MANPATH=$MANPATH:/opt/OPENssh/man
fi

if [ -d /opt/csw/ ]; then
    PATH=`$path_edit +/opt/csw/bin || echo $PATH`
    MANPATH=$MANPATH:/opt/csw/man
fi

export PATH MANPATH

export TITLEBAR='\[\033]0;\h\007\]'
export PS1="${TITLEBAR}[\h \w]\$ "
export TERM=vt220  # we like vt220 because less keys work under it...
export EDITOR=vi
export PAGER='less'
#LESS="-sriX -k$HOME/.less"
export LESS="-sriXMq -PM ?lLine %lb:--less--.?L/%L.?p (%pB\%).?f in %f.%t"
export LESSKEY="${HOME}/.less"

if [[ "$_shell_is_interactive" == 1 ]]; then
    stty erase "^?"
fi

# Shell options
shopt -s checkwinsize histreedit

# If I hit <tab> on a blank line, I DON'T want to see a list of all 
# the comands in my PATH - who would EVER want that??
# This option appeared in bash 2.04, so it's not in the Solaris 8 
# version of bash.  Rather than checking for the version, check for
# the existance of the option:
[[ $(shopt) == *no_empty_cmd_completion* ]] &&
    shopt -s no_empty_cmd_completion

#Only put duplicate lines in the history once
HISTCONTROL=ignoredups

HISTDIR=$HOME/.bash_history
HISTFILE=${HISTDIR}/${HOSTNAME}
if [ ! -d $HISTDIR ]; then
    if [ -f $HISTDIR ]; then
        mv $HISTDIR $HISTDIR.tmp
        mkdir $HISTDIR
        mv $HISTDIR.tmp $HISTFILE
    else
        mkdir $HISTDIR
    fi
fi

unset HISTDIR

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
export LS_COLORS='no=00:fi=00:di=01;34:ln=00;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=02;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:';

alias more='less'
alias path='echo $PATH'
alias root='sudo $BASH'
alias isodate='date +"%Y%m%d"'
alias epochs='perl -leprint+time'

while read ralias rcmd ; do
    case $ralias in
        \#*) continue ;;
        "") continue ;;
        *)
            # if the binary exists then create the alias
            [ -x $rcmd ] && alias $ralias=$rcmd
        ;;
    esac
done <<__end_of_commands
#
# for stuff I am not sure I can rely on to be present
#
firefox    /usr/local/bin/firefox
cal        ~/bin/cal
## erk, on solaris "which" is a csh script :(
which      ~/bin/which
__end_of_commands

case $OSTYPE in
    solaris*)
        ver=`uname -r`
        alias pstree='ptree'

        # the bash built in enable command conflicts with solaris's 
        # print enable so we disable it...
        if [ "`type -t enable`" == "builtin" ]; then
            enable -n enable
        fi

        case $ver in
            5.10)
                if [ `zoneadm list | wc -l` -gt 1 ]; then
                    # we have child zones!
                    alias ps='/usr/bin/ps -o zone,user,pid,ppid,c,stime,tty,time,args'
                fi
            ;;
        esac

        unset ver
    ;;
    linux*)
        alias pstree='pstree -a -c -l -n -h -p'
        alias ls='ls --color -CF'
        if [ `hostname` == "$home_host" ]; then
            alias gvim='gvim --remote-tab-silent'
        fi
    ;;
esac

pcolour () {
    case $1 in
        "")      code=30;;
        black)   code=30;;
        red)     code=31;;
        green)   code=32;;
        yellow)  code=34;;
        blue)    code=34;;
        magenta) code=35;;
        cyan)    code=36;;
        white)   code=37;;
        *) echo "unknown colour \"$1\"!"; return;;
    esac
    export PS1="\[\033[0;${code}m\][\h \w]\$ \[\033[0m\]"
}

ttitle () {
# set the terminal title to something, defaults to hostname
    case $OSTYPE in
        linux*) echo_args="-ne" ;;
    esac

    if [ -z "$1" ]; then
        title=`hostname`
    else
        title=$1
    fi

    /bin/echo $echo_args "\033]0;$title\007"
}

llpstat () {
    lpstat -p $1 -o $1
}

cnf () {
    perl -le '$ARGV[0]||($ARGV[0]="."); opendir f, $ARGV[0] or die $!; ++$c while readdir f; print $c' $1
}

epoch2date () {
# convert epochs to human readable :)
    perl -MPOSIX -le 'print strftime("%a %F %R:%S", localtime '$1')'
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
    UNIX95= /bin/ps -eo vsz,pid,args | sort -nr | head -10
}

unset _shell_is_interactive


