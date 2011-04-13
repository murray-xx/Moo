#
# .bashrc
#
# @(#) $Revision: 1.9.6
#
# @(#) most recent version always available at
# @(#)   http://github.com/murray/Moo/tree/master/.bashrc
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
export PS1="${TITLEBAR}\[\033[02;34m\][\h \w]$ \[\033[0m\]"
export TERM=vt220  # we like vt220 because less keys work under it...
export EDITOR=vi

_LESS=`which less`;
if [ -n "$_LESS" ] && [ -x $_LESS ] ; then
    export PAGER="$_LESS"
    #LESS="-sriX -k$HOME/.less"
    export LESS="-sriXMq -PM ?lLine %lb:--less--.?L/%L.?p (%pB\%).?f in %f.%t"
    export LESSKEY="${HOME}/.less"
    alias more="$_LESS"
else
    # oh no's...
    export PAGER='more'
    alias less='more'
fi
unset _LESS

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
        if [ `hostname -s` == "$home_host" ]; then
            alias gvim='gvim --remote-tab-silent'
        fi
    ;;
    hpux*)
        alias bdf="~/bin/bdf.pl"
        export TERM=xterm
    ;;

esac

functions () {
    perl -ne 'next unless s|^(\w+)\s*\(\s*\)\s*{\s*|$1|; push @ff, "$_\n"; END{print sort @ff}' ~/.bashrc
}

cnf () {
    perl -le '$ARGV[0]||($ARGV[0]="."); opendir f, $ARGV[0] or die $!; ++$c while readdir f; print $c' $1
}

epoch2date () {
# convert epochs to human readable :)
    perl -MPOSIX -le 'print strftime("%a %F %R:%S", localtime '$1')'
}

who () {
# we like to know who we are really dealing with...
  /usr/bin/who | \
    perl -ne '$gecos = (getpwnam((split)[0]))[6];
              print $gecos, " " x (21 - length($gecos)), $_;'
}

w () {
# we like to know who we are really dealing with...
  /usr/bin/w | \
    perl -ne 'print and next if /load average/;
              $gecos = (getpwnam((split)[0]))[6];
              print $gecos, " " x (21 - length($gecos)), $_;'
}

perlmods () {
    /usr/bin/find `perl -e 'print "@INC"'` -name '*.pm' -print | grep -v "^./"
}

perlmodver () {
# print the version of a module
# eg perlmodver Net::LDAP
# some modules may not set $VERSION :-l
    perl -M$1 -le 'print "'$1' : ", $'$1'::VERSION';
}

hogs () {
    echo " VSZ   PID COMMAND"
    # need UNIX95 option for HPUX and possibly older Solaris
    # lets party like it's 2010 and display vsz in Mb...
    UNIX95= /bin/ps -eo vsz,pid,args | awk '{$1=sprintf("%0.2fM", $1/1024); print}' | sort -rn | head -10
}

perms2 () {
# perms2 == permissions to...
# could have called it "permsonpath" but perms2 is shorter :)
    file=`rel2abs $arg`

    # version below uses perl File::Spec::Unix module to convert relative paths to absolute but I don't 
    # have that available everywhere I live either...
    ##perl -MFile::Spec::Unix -e '$ff=`pwd` if ( ! $ARGV[0] or $ARGV[0] eq "."); $ff=File::Spec::Unix->rel2abs($ARGV[0]); map {if($_){$f=join "/",$f,$_; system("ls -ald $f")}} split m|/|, $ff' $1

    perl -e '$ARGV[0]=`pwd` if ( ! $ARGV[0] or $ARGV[0] eq "."); map {if($_){$f=join "/",$f,$_;system("ls -ald $f")}} split m|/|,shift' $file
}

rel2abs () {
    relpath=$1
    if [ `echo $relpath | grep -c "^/"` -le 0 ]; then
        # we have a relative path
        # convert it to absolute
        D=`dirname "$relpath"`
        B=`basename "$relpath"`
        abs="`cd \"$D\" 2>/dev/null && pwd || echo \"$D\"`/$B"
    else
        abs=$1
    fi
    echo $abs
}

lstimes () {
# stat will show all of these if you are on an OS with stat...
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

histcmd () {
    if [ -n "$1" ]; then
        history | grep $1 | perl -lane '{shift @F; print "@F"}' | sort -u
    else
        echo "Please specify what to look for in your history."
    fi
}

unset _shell_is_interactive


