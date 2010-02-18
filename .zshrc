# Andrew's zshrc file, derived from jontow and pwnz3r's (which was derived from
# spyderous').
# Heavy trimming and reworking done by myself 10-06-06

setopt autocd
bindkey -v

autoload -U compinit
compinit

# print contents of TODO file :) - stolen from jon
if [ -f ~/TODO ]; then
	echo ""
	echo " ---- TODO ----"
	cat ~/TODO
fi

echo ""
echo "Today's date: "
date +"%Y-%m-%d	%H:%M" #"'" fix stupid quoting bug

# The prompt begins with ^ if the last command was a success, _ if it failed
# username is highlighed in red if we're running with privileges
PROMPT=$'%(?,^,_)%(!,${red},${cyan})%n${cyan}@%m${NC}:: '

# set the right edge prompt with the pwd
#RPROMPT=$'${NC}[${green}%.${NC}]'
# *new* prompt. Set it to the pwd (max last 2 components)
# and truncate it to 15 characters (inspired by lucas)
RPROMPT=$'[%(?,${green},${red})%(3~,../%15<<%2~,%15<../<%~)${NC}]'

export COLORTERM=yes
export CC=gcc
export MANPAGER=more
export PAGER=more
export EDITOR=vim
export CLICOLOR=YES
export PATH=$HOME/bin:$PATH

# make home/end work in as many places as possible
case $TERM in
    *xterm*|*rxvt|(dt|k|E|a)term|vt100)
		case `uname -s` in
			SunOS|NetBSD|IRIX*|DragonFly|OpenBSD)
			bindkey "\e[H" beginning-of-line
			bindkey "\e[F" end-of-line
			;;
			*) # freebsd? linux?
			bindkey "\e[7~" beginning-of-line
			bindkey "\e[8~" end-of-line
			;;
		esac
    ;;
    screen*)
	bindkey "\e[1~" beginning-of-line
	bindkey "\e[4~" end-of-line
	;;
	cons25)
	# TODO - check this on NETBSD and other OSes
	bindkey "\e[H" beginning-of-line
	bindkey "\e[F" end-of-line
	;;
esac

# bind ^P to show start/end times of previous command
displaytimes() {
	if [ "x$STARTTIME" != "x" ]; then
		# giant hack to trick the prompt into containing the timestamps..
		OPROMPT=$PROMPT
		PROMPT="${STARTTIME} - ${ENDTIME}
${PROMPT}"
		zle reset-prompt
		PROMPT=$OPROMPT
	fi
}
zle -N displaytimes

bindkey "^P" displaytimes

# Aliases, how I love thee
alias mutt="mutt -y"
alias rdesktop="rdesktop -g 90% -a 8"

# use the vim less macro, where available
if [ `uname` = "SunOS" ]; then # goddamn solaris
	VIMLESS=`ls /usr/(pkg|local)/share/vim/vim??/macros/less.sh | sort -u | /usr/xpg4/bin/tail -n 1`
elif [ `uname` = "Linux" ]; then
	VIMLESS=`ls /usr/share/vim/vim??/macros/less.sh | sort -u | tail -n 1`
else
	VIMLESS=`ls /usr/(pkg|local)/share/vim/vim??/macros/less.sh | sort -u | tail -n 1`
fi
if [ "x$VIMLESS" != "x" ]; then 
	alias realmore=`which more`
	alias more="$VIMLESS"
fi

# make 'aliases' print the list of aliases
alias aliases=alias

#switch between dvorak and back
alias asdf="setxkbmap dvorak && xmodmap ~/.Xmodmap"
alias aoeu="setxkbmap us && xmodmap ~/.Xmodmap"

#Colors
export red=$'%{\e[0;31m%}'
export RED=$'%{\e[1;31m%}'
export green=$'%{\e[0;32m%}'
export GREEN=$'%{\e[1;32m%}'
export yellow=$'%{\e[0;33m%}'
export YELLOW=$'%{\e[1;33m%}'
export blue=$'%{\e[0;34m%}'
export BLUE=$'%{\e[1;34m%}'
export purple=$'%{\e[0;35m%}'
export PURPLE=$'%{\e[1;35m}'
export cyan=$'%{\e[0;36m%}'
export CYAN=$'%{\e[1;36m%}'
export white=$'%{\e[0;37m%}'
export WHITE=$'%{\e[1;37m%}'
export NC=$'%{\e[0m%}' 

# Stolen from old .zshrc, unknown attribution
# Set the titlebar for the window, and also the window title in screen :)
#
# I don't want to be cocky, but this is all my own stuff and I'm frikking
# proud of it.

# This function sets the window tile to user@host:/workingdir before each
# prompt. If you're using screen, it sets the window title (works
# wonderfully for hardstatus lines :)
precmd () {
	ENDTIME=`date`
  [[ -t 1 ]] || return
  case $TERM in
    *xterm*|*rxvt|(dt|k|E|a)term) print -Pn "\e]2;%n@%m::%(3~,../%20<<%2~,%20<../<%~)\a"
    ;;
    screen*) print -Pn "\e\"%n@%m::%(3~,../%15<<%2~,%15<../<%~)\e\134"
  esac
}

# This sets the window title to the last run command.
#[[ -t 1 ]] || return

preexec() {
	STARTTIME=`date`
	case $TERM in
		*xterm*|*rxvt|(dt|k|E|a)term)
		# if we're doing some screen shit, set the window title to 
		# screen@hostname instead of the generic screen -x or whatever
		if [[ $1 == screen ]] || [[ ${${=1}[0]} == screen ]]; then
			print -Pn "\e]2;screen@%M\a"
		else
			print -Pn "\e]2;%20>..>$1%<<\a"
		fi
		;;
		screen*)
		print -Pn "\e\"%15>..>$1%<<\e\134"
		;;
	esac
}

#completion stuff, selectively taken from old zshrc
zstyle ':completion:*' menu select=1

# Expand partial paths
zstyle ':completion:*' expand 'yes'
zstyle ':completion:*' squeeze-slashes 'yes'

# include non-hidden directories in globbed file completions
# for certain commands
zstyle ':completion::complete:*' '\' #'

# use menuselection for pid completion
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:kill:*' force-list always

# With commands like rm, it's annoying if you keep getting offered the same
# file multiple times. This fixes it. Also good for cp, et cetera..
zstyle ':completion:*:rm:*' ignore-line yes
zstyle ':completion:*:cp:*' ignore-line yes

# Follow GNU LS_COLORS
zmodload -i zsh/complist
#eval "`dircolors ~/.dir_colors`"
export ZLSCOLORS="${LS_COLORS}"
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# zsh options
setopt menu_complete NO_beep hist_no_store prompt_subst HIST_IGNORE_DUPS

# load a local file to do per-machine overrides
if test -f ~/.zshrclocal; then
	source ~/.zshrclocal
fi

echo ""
