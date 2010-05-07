#
# .bashrc
#
# @(#) $Revision: 1.8.7
#
# @(#) most recent version always available at
# @(#)   http://github.com/murray/Moo/tree/master/utils/
#
# Murray's .bashrc
# with a tip of the hat to Boyd's favourite .bashrc -
#    http://www.users.on.net/~boyd.adamson/boyds.bashrc
#
# stuff specific to locations (say current $client) goes in .bashrc.local
#
#

[[ $- == *i* ]] && _shell_is_interactive=1

unalias -a      # my environment, my way :)

[ -f $HOME/.bashrc.local ] && . $HOME/.bashrc.local

PATH=/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin
MANPATH=/usr/man:/usr/share/man:/usr/local/man:/usr/kerberos/man

PATH=`~/bin/pe ++~/bin || echo $PATH`

while read dir bin ; do
    case $dir in
        \#*) continue ;;
        "") continue ;;
        *)
            if [ -d $dir ]; then
                bin="$dir/${bin:=bin}"
                if [ -d $bin ]; then
                    PATH=`pe +$bin || echo $PATH`
                fi
                man="$dir/man";
                if [ -d $man ]; then
                    MANPATH=$MANPATH:$man
                fi
            fi
        ;;
    esac
done <<__end_of_dirs
/usr/X11R6
/usr/openwin
/opt/SUNWadm
/opt/OPENssh
/opt/csw
/usr/opt/SUNWmd sbin
/opt/VRTS
__end_of_dirs

export PATH MANPATH

export TITLEBAR='\[\033]0;\h\007\]'
export PS1="${TITLEBAR}[\h \w]\$ "
export TERM=vt220  # we like vt220 because less keys work under it...
export EDITOR=vi
export PAGER='less'
#LESS="-sriX -k$HOME/.less"
export LESS="-sriXMq -PM ?lLine %lb:--less--.?L/%L.?p (%pB\%).?f in %f.%t"
export LESSKEY="${HOME}/.less"

[[ "$_shell_is_interactive" == 1 ]] && stty erase "^?"

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
export LS_COLORS='no=00:fi=00:di=01;34:ln=00;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=02;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:';

alias path='echo $PATH'
alias root='sudo bash'
alias isodate='date +"%Y%m%d"'
alias epochs='perl -leprint+time'
alias src='. ~/.bashrc'

while read _ralias _rcmd ; do
    case $_ralias in
        \#*) continue ;;
        "") continue ;;
        *)
            # tilde expansion to make -x happy
            _rcmd=`eval echo $_rcmd`

            if [ `echo $_rcmd | grep -c "^/"` -le 0 ]; then
                # if it's not an absolute path then make it so...
                _rcmd=`which $_rcmd`
            fi

            # if it's executable then create the alias
            [ -n "$_rcmd" ] && [ -x $_rcmd ] && alias $_ralias="$_rcmd"
        ;;
    esac
done <<__end_of_commands
#
# for stuff I am not sure I can rely on to be present
#
firefox     /usr/local/bin/firefox
# hard to believe but yes, less is not available everywhere :(
more        less
__end_of_commands

unset _rcmd _ralias

if [ -x ~/bin/perldoc-complete ]; then
    alias pod=perldoc
    complete -C perldoc-complete -o nospace -o default pod
fi

case $OSTYPE in
    solaris*)
        _ver=`uname -r`
        alias pstree='ptree'

        # the bash built in enable command conflicts with solaris's 
        # print enable so we disable it...
        if [ "`type -t enable`" == "builtin" ]; then
            enable -n enable
        fi

        llpstat () {
            lpstat -p $1 -o $1
        }


        case $_ver in
            5.10)
                _ZONEADM=`which zoneadm`
                if [ -n "$_ZONEADM" ] && [ -x $_ZONEADM ] ; then
                    if [ `$_ZONEADM list | wc -l` -gt 1 ]; then
                        # we have child zones!
                        alias ps='/usr/bin/ps -o zone,user,pid,ppid,c,stime,tty,time,args'
                    fi
                fi
                unset _ZONEADM
            ;;
        esac

        unset _ver
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
        "")          code="01;30";;
        black)       code="01;30";;
        red)         code="01;31";;
        green)       code="01;32";;
        yellow)      code="01;34";;
        blue)        code="01;34";;
        bld_blue)    code="02;34";;
        magenta)     code="01;35";;
        bld_magenta) code="01;35";;
        cyan)        code="01;36";;
        white)       code="01;37";;
        *) echo "unknown colour \"$1\"!"; return;;
    esac
    export PS1="\[\033[${code}m\][\h \w]\$ \[\033[0m\]"
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
# I always forget this... :)
    /usr/bin/find `perl -e 'print "@INC"'` -name '*.pm' -print
}

hogs () {
    echo " VSZ   PID COMMAND"
    UNIX95= /bin/ps -eo vsz,pid,args | sort -nr | head -10
}

lstimes () {
    for file in "$@" ; do
        echo -n "mtime: `ls -l "$file"`"
        echo -n "atime: `ls -l --time=atime "$file"`"
        echo -n "ctime: `ls -l --time=ctime "$file"`"
    done
}

own () {
    for file in "$@" ; do
        sudo chown `id -u`:`id -g` "$file"
    done
}

unset _shell_is_interactive


