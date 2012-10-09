
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000


# ####################
# SET LOCALE
# set terminal locale
# ####################

export LANG="en_GB.UTF-8"
export LC_ALL="en_GB.UTF-8"
export LC_COLLATE="en_GB.UTF-8"
export LC_CTYPE="en_GB.UTF-8"
export LC_MESSAGES="en_GB.UTF-8"
export LC_MONETARY="en_GB.UTF-8"
export LC_NUMERIC="en_GB.UTF-8"
export LC_TIME="en_GB.UTF-8"


# ####################
# SET COLOURS
# set terminal colours
# ####################

export TERM=xterm-256color
autoload colors
colors

# BSD ls colours
CLICOLOR=1
LSCOLORS=gxdxcxcxbxdxdxbxbxgxgx

# Linux/GNU ls colours
LS_OPTIONS='--color=always '
LS_COLORS='di=36:ln=33:so=32:pi=32:ex=31:bd=33:cd=33:su=31:sg=31:tw=36:ow=36:'

export CLICOLOR LSCOLORS LS_COLORS LS_OPTIONS

# foreground: normal colours
fg_black=$'\e[0;30m'
fg_red=$'\e[0;31m'
fg_green=$'\e[0;32m'
fg_yellow=$'\e[0;33m'
fg_blue=$'\e[0;34m'
fg_magenta=$'\e[0;35m'
fg_cyan=$'\e[0;36m'
fg_grey=$'\e[0;37m'

# foreground: bright colours
fg_black2=$'\e[1;30m'
fg_red2=$'\e[1;31m'
fg_green2=$'\e[1;32m'
fg_yellow2=$'\e[1;33m'
fg_blue2=$'\e[1;34m'
fg_magenta2=$'\e[1;35m'
fg_cyan2=$'\e[1;36m'
fg_grey2=$'\e[1;37m'

# background: white-on-colours
bg_black=$'\e[0;40m'
bg_red=$'\e[0;41m'
bg_green=$'\e[0;42m'
bg_yellow=$'\e[0;43m'
bg_blue=$'\e[0;44m'
bg_magenta=$'\e[0;45m'
bg_cyan=$'\e[0;46m'
bg_grey=$'\e[0;47m'

# background: black-on-colours
bg_black2=$'\e[0;30;40m'
bg_red2=$'\e[0;30;41m'
bg_green2=$'\e[0;30;42m'
bg_yellow2=$'\e[0;30;43m'
bg_blue2=$'\e[0;30;44m'
bg_magenta2=$'\e[0;30;45m'
bg_cyan2=$'\e[0;30;46m'
bg_grey2=$'\e[0;30;47m'

at_normal=$'\e[0m'


# ###########
# SET PROMPTS
# ###########

# These are all like this:
# host:dir %

# GREEN left prompt for local
if [[ `uname -n` == 'kapche-lanka'* ]]; then
	PROMPT="%{${fg_green2}%}%m%{${at_normal}%}%{${fg_grey2}%}:%{${at_normal}%}%c %{${fg_green2}%}%#%{${at_normal}%} "


# GREEN left prompt for rondolina
elif [[ `uname -n` == 'rondolina'* ]]; then
	PROMPT="%{${fg_green2}%}%m%{${at_normal}%}%{${fg_grey2}%}:%{${at_normal}%}%c %{${fg_green2}%}%#%{${at_normal}%} "

# YELLOW left prompt for iserlohn (router)
elif [[ `uname -n` == 'iserlohn'* ]]; then
	PROMPT="%{${fg_yellow2}%}%m%{${at_normal}%}%{${fg_grey2}%}:%{${at_normal}%}%c %{${fg_yellow2}%}%#%{${at_normal}%} "

# RED left prompt for satanism (eggdrop)
elif [[ `uname -n` == 'ester'* ]]; then
	PROMPT="%{${fg_red2}%}satanism%{${at_normal}%}%{${fg_grey2}%}:%{${at_normal}%}%c %{${fg_red2}%}%#%{${at_normal}%} "

# CYAN left prompt for odin (linode)
elif [[ `uname -n` == 'odin'* ]]; then
	PROMPT="%{${fg_cyan2}%}%m%{${at_normal}%}%{${fg_grey2}%}:%{${at_normal}%}%c %{${fg_cyan2}%}%#%{${at_normal}%} "

# CYAN left prompt for dreamhost
elif [[ `uname -n` == 'washingtondc'* ]]; then
	PROMPT="%{${fg_cyan2}%}dreamhost%{${at_normal}%}%{${fg_grey2}%}:%{${at_normal}%}%c %{${fg_cyan2}%}%#%{${at_normal}%} "

# GREEN left prompt for anything else
else
	PROMPT="%{${fg_green2}%}%m%{${at_normal}%}%{${fg_grey2}%}:%{${at_normal}%}%c %{${fg_green2}%}%#%{${at_normal}%} "
fi


# #################################################
# PRECMD BEHAVIOUR
# Update the tab title before each prompt is shown;
# also, do some stuff for work
# #################################################

# This executes after a command completes but before the prompt is shown.
# Mainly useful for when the directory changes.
precmd() {
	# Get last command return code
	lastret=$?

	# Update title: host:directory
	print -Pn "\e]0;%m:%c\a"


	# Check to see if we've just completed an SSH session on heinessen
	if [[ $history[$[HISTCMD-1]] != 'ssh heinessen' ]]; then
		# If not, return
		return

	# If so...
	else
		# If we returned something aside from 255, return
		if [[ $lastret != 255 ]]; then
			return

		# Otherwise...
		else
			# Get the current Wi-Fi network (if any)
			wlan=`ioreg -l -n AirPortDriver | grep -i --color=NEVER "IO80211SSID" | perl -pe "s/(^.+SSID\" = \"|\"$)//g"`

			# Set prefix or exit based on the above
			if [[ $wlan == *Conference ]]; then
				locprefix='Wi-Fi'

			elif [[ $wlan == '' ]]; then
				locprefix='Ethernet'

			else
				return
			fi

			# Check to see if we're on DHCP already
			location=`scselect | grep --color=NEVER "^\s*\*\s" | perl -pe 's/(^\s\*\s[0-9A-F\-]+\t\(|\)$)//g'`

			# If we are, who cares
			if [[ $location == "$locprefix (via DHCP)" ]]; then
				return

			# If we're not...
			else
				# Go through DHCP
				scselect "$locprefix (via DHCP)" > /dev/null

				# Launch a script to check for heinessen's return
				# ~/Development/work/check-for-heinessen.sh $locprefix
				(~/Development/work/check-for-heinessen.sh $locprefix &) 2> /dev/null > /dev/null
			fi
		fi
	fi
}

# Use this in .ssh/config to automatically update the title for ssh:
# Host *
# PermitLocalCommand yes
# LocalCommand print -Pn "\e]0;ssh\a"


# ######################################
# FIX HOME/END/DELETE KEYS
# (Somehow i broke these in Terminal
#  when i was messing with vim bindings)
# ######################################

bindkey ''    beginning-of-line
bindkey ''    end-of-line

bindkey 'b'   backward-word
bindkey 'f'   forward-word

bindkey ''    kill-line

bindkey	'[3~'  delete-char


# #############
# MISC. ALIASES
# #############
# Too lazy to type out the full source command
alias reload="source ~/.zshrc"

# Make sudo respect aliases
alias sudo='sudo '


# #########################################
# SET EDITOR
# Let's set the default editor to TextMate,
# and then make an alias from 'edit'
# #########################################
# On my local machine: TextMate; otherwise vim
if [[ `uname -n` == 'kapche-lanka'* ]]; then
	if [[ -x `which mate` ]]; then
		export EDITOR='mate -w'
	else
		export EDITOR='vim'
	fi

# On other machines: try vim
else
	if [[ -x `which vim` ]]; then
		export EDITOR='vim'
	elif [[ -x `which nano` ]]; then
		export EDITOR='nano'
	elif [[ -x `which pico` ]]; then
		export EDITOR='pico'
	elif [[ -x `which ee` ]]; then
		export EDITOR='ee'
	else
		export EDITOR='vi'
	fi
fi

alias edit=$EDITOR


# ##############################################################
# DON'T USE VI MODE
# (Since i use vim for my editor zsh will do this by default...)
# ##############################################################
bindkey -e


# ############
# GREP COLOURS
# ############
if [[ `uname -n` != 'iserlohn'* ]]; then
	alias grep="egrep --color=ALWAYS"
	alias egrep="egrep --color=ALWAYS"
fi


# ################################################
# CONFIG-COPY
# Copies config files to my other machines via scp
# (This is very lazy and relies on ssh aliases)
# ################################################
function config-copy {
	# Make sure there is at least one argument
	if [[ -n $1 ]]; then
		destination=""

		case "$2" in
			zsh|zshrc|.zshrc)
				configfile="$HOME/.zshrc"
				;;
			vim|vimrc|.vimrc)
				configfile="$HOME/.vimrc"
				;;
			colors|colours|monok*)
				configfile="$HOME/.vim/colors/Monokai-mod.vim"
				destination="/.vim/colors"
				;;
			*)
				# Assume .zshrc by default
				configfile="$HOME/.zshrc"
				;;
		esac

		case "$1" in
			kapche*)
				scp $configfile kine@kapche-lanka:/Users/kine$destination
				;;
			rondo*)
				scp $configfile kine@rondolina:/Users/kine$destination
				;;
			iser*)
				scp $configfile root@iserlohn:/root$destination
				;;
			odin)
				scp $configfile kine@odin:/home/kine$destination
				;;
			git|github|dev|development)
				cp $configfile ~/Development/configs$destination
				;;
			*)
				echo "Host not recognised."
				;;
		esac
	fi
}

alias copy-config="config-copy"
alias cp-config="config-copy"
alias config-cp="config-copy"


# ############################################################################
# X-MAN-PAGE
# Opening links using the URI scheme x-man-page://command will open the
# specified man page in a new Terminal window which uses the 'Man Page' theme.
# This is fantastic compared to reading it in the current Terminal tab, so
# let's create a function especially for that...
# ############################################################################
# I only want this on my local machine actually
if [[ `uname -n` == 'kapche-lanka'* ]] || [[ `uname -n` == 'rondolina'* ]]; then
	function man {
		# Check to see if 'open' is installed (this is Mac-specific)
		if [[ -x `which open` ]]; then
			# If there's a second argument, just return the normal man command
			if [[ -n $2 ]]; then
				`which man` $@
			# If there's only one argument, use 'open' to raise a new window
			else
				open x-man-page://$1
			fi
		# If 'open' isn't installed, return the normal man command
		else
			`which man` $@
		fi
	}
fi


# ########
# PNGCRUSH
# ########

# I only want this on my local machine actually
if [[ `uname -n` == 'kapche-lanka'* ]]; then
	function pc {
		if [[ -n $1 ]] && [[ ! -n $2 ]]; then
			pngdir=`dirname $1`
			pngfile=`basename -s .png $1`

			mv "$pngdir/$pngfile.png" "$pngdir/$pngfile.original.png"

			if [ $? -eq 0 ]; then
				pngcrush -rem gAMA -rem cHRM -rem iCCP -rem sRGB \
				  "$pngdir/$pngfile.original.png" "$pngdir/$pngfile.png"
			else
				echo "Failed to crush file."
			fi

		else
			pngcrush -rem gAMA -rem cHRM -rem iCCP -rem sRGB $@
		fi
	}
fi


# ######################################################################
# PYWIKIPEDIABOT FUNCTIONS
# Typing the full commands for the pywikipediabot scripts is irritating,
# so here are some shortcuts
# ######################################################################

# I only want this on my local machine actually
if [[ `uname -n` == 'kapche-lanka'* ]]; then
	function add_text {
		python ./add_text.py -pt:2 $@
	}
	alias addtest='add_text'

	function category {
		python ./category.py -pt:2 $@
	}

	function image {
		python ./image.py -pt:2 $@
	}

	function pagefromfile {
		if [[ $@ == *-file* ]]; then
			python ./pagefromfile.py -pt:2 -start:xxxx -end:yyyy -notitle $@
		else
			python ./pagefromfile.py -pt:2 -start:xxxx -end:yyyy -notitle -file:file1.xml $@
		fi
	}
	alias page='pagefromfile'

	function replace {
		python ./replace.py -pt:2 $@
	}

	function upload {
		python ./upload.py -pt:2 -keep -noverify $@
	}
fi


# ######################
# ASSGREP
# for greping asses, lol
# ######################
function assgrep {
	# No colour for now :(
	grep --color=NEVER -i $@ | \
	perl -pe 's/.*(\(null\),[0-9]{4},[0-9]{4}|D,[0-9]{4},[0-9]{4}).*\n//g' | \
	perl -pe 's/.*\.ass:Format:.*\n//g' | \
	perl -pe 's/.*TITLE:.*Legend of Galactic Heroes.*\n//g' | \
	perl -pe 's/^LOGH Episode ([0-9]+).+?\.ass./Episode $1 \.ass:/g' | \
	perl -pe 's/(^|\.ass:)(Dialogue|Command|Comment): //' | \
	perl -pe 's/^Overture to a New War\.ass:(Dialogue|Command|Comment): /ONW: /g' | \
	perl -pe 's/0,([0-9]+:[0-9]+:[0-9]+)\.[0-9]+,([0-9]+:[0-9]+:[0-9]+\.[0-9]+),(def2|mactitle),(\.)*/$1 /g' | \
	perl -pe 's/{\\c&.*?&.*?}//g' | \
	perl -pe 's/(\.){0,4},[0-9]{4},[0-9]{4},[0-9]{4},,/ /g' | \
	perl -pe 's/Comment,[0-9]{4},[0-9]{4},[0-9]{4},,/COMMENT: /g' | \
	perl -pe 's/{\\a[0-9]}//g' | \
	perl -pe 's/\\N/ /g'
}


# ########################
# CONFIGURE TAB COMPLETION
# ########################

# load some shit
autoload -U compinit
compinit
zmodload zsh/complist

# set some shit lol i dunno
zstyle ':completion:*' completer _complete _expand _ignored _match _approximate

# max number of errors for 'approximate' matching
zstyle ':completion:*:approximate:*' max-errors 3 numeric

# case-insensitive completion
# zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' matcher-list 'm:{A-Z}={a-z}' 'm:{a-z}={A-Z}' 'r:|[._-]=** r:|=**' 'l:|=* r:|=*'

# show 'completing ____' in the menu thing
zstyle ':completion:*:descriptions' format $'%{\e[0;35m%}completing %B%d:%b%{\e[0m%}'

# automatically complete the first result, then cycle
setopt MENU_COMPLETE

# display a box thingie around the completion menu items
zstyle ':completion:*' menu select=2

# make it so we only have to press Return one time in the menu
bindkey -M menuselect '^M' .accept-line

# complete even in the middle of words
setopt COMPLETE_IN_WORD

# correct misspelt commands
setopt correct

# colour process IDs for 'kill' red
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'

# colour directories for 'ls'
zstyle ':completion:*:default' list-colors 'no=0:fi=0:di=36:ln=33:ex=31:ma=0;45'

fpath=(~/.zsh $fpath)
autoload -U ~/.zsh/*(:t)


# ########################
# TERMINAL RESUME FOR LION
# Borrowed from Super User
# ########################
if [[ "$TERM_PROGRAM" == "Apple_Terminal" ]] && [[ -z "$INSIDE_EMACS" ]]; then
	update_terminal_cwd() {
		# Identify the directory using a "file:" scheme URL, including
		# the host name to disambiguate local vs. remote paths.

		# Percent-encode the pathname.
		local URL_PATH=''
		{
			# Use LANG=C to process text byte-by-byte.
			local i ch hexch LANG=C
			for ((i = 1; i <= ${#PWD}; ++i)); do
				ch="$PWD[i]"
				if [[ "$ch" =~ [/._~A-Za-z0-9-] ]]; then
					URL_PATH+="$ch"
				else
					hexch=$(printf "%02X" "'$ch")
					URL_PATH+="%$hexch"
				fi
			done
		}

		local PWD_URL="file://$HOST$URL_PATH"
		printf '\e]7;%s\a' "$PWD_URL"
	}

	# Register the function so it is called whenever the working
	# directory changes.
	autoload add-zsh-hook
	add-zsh-hook chpwd update_terminal_cwd

	# Tell the terminal about the initial directory.
	update_terminal_cwd
fi


# ###############################
# TELNET SHORTCUT FOR SATANISM
# (Just saves me a little typing)
# ###############################
if [[ `uname -n` == 'ester'* ]]; then
	function telnet () {
		if [[ $# -gt 1 ]]; then
			/usr/bin/telnet "$@"
		else
			/usr/bin/telnet localhost 3389
		fi
	}
fi


# ################################################
# UNSET CDPATH
# tab completion is really irritating otherwise :(
# ################################################
unset CDPATH


# ############
# FOR MACPORTS
# ############
export PATH=/opt/local/bin:/opt/local/sbin:$PATH

# My local machine only
if [[ `uname -n` == 'kapche-lanka'* ]]; then
	export PATH=/opt/local/bin:/opt/local/sbin:/Volumes/Garga\ Falmul/Development/ginei-tools/ginei-names:$PATH
fi


# ############
# FOR ISERLOHN
# ############
# Set up ls colours
# We need to prefer the (coreutils) ls in /opt/bin if it's there,
# since the busybox ls is stupid
if [[ `uname -n` == 'iserlohn'* ]]; then
	if [[ -x /opt/bin/ls ]]; then
		alias ls='/opt/bin/ls --color=always'
	else
		alias ls='ls --color=always'
	fi
fi

# Add /opt/scripts to PATH
if [[ `uname -n` == 'iserlohn'* ]]; then
	export PATH="/opt/scripts:$PATH"
fi


# ########
# FOR ODIN
# ########
# Doesn't take ls_options for some reason, too lazy to figure out why
if [[ `uname -n` == 'odin'* ]]; then
    alias ls='ls --color=always'
fi

# ##########
# WORK STUFF
# ##########
source ~/.zshrc.work
