
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000


# ####################
# SET LOCALE
# set terminal locale
# ####################

export LANG="en_GB.UTF-8"
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
CLICOLOR=1
LSCOLORS=gxdxcxcxbxdxdxbxbxgxgx
LS_COLORS=LSCOLORS
export LSCOLORS LS_COLORS CLICOLOR

autoload colors
colors

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

# right prompt: time — DISABLED
# RPROMPT="%{${fg_grey}%}^%D{%H:%M:%S}%{${at_normal}%}"

# left prompt: bash style (no colour) — DISABLED
# PROMPT="%m:%c %n$ "

# left prompt: bash style (with colour) — DISABLED
# PROMPT="%{${fg_grey}%}%m%{${at_normal}%}:%{${fg_cyan}%}%c %{${fg_grey}%}%n%{${fg_red}%}$%{${at_normal}%} "

# left prompt: — DISABLED
# PROMPT="%c %{${fg_red}%}%#%{${at_normal}%} "

# GREEN left prompt for local
PROMPT="%{${fg_green2}%}%m%{${at_normal}%}%{${fg_grey2}%}:%{${at_normal}%}%c %{${fg_green2}%}%#%{${at_normal}%} "

# RED left prompt for satanism — DISABLED
# PROMPT="%{${fg_red2}%}satanism%{${at_normal}%}%{${fg_grey2}%}:%{${at_normal}%}%c %{${fg_red2}%}%#%{${at_normal}%} "

# CYAN left prompt for dreamhost — DISABLED
# PROMPT="%{${fg_cyan2}%}dreamhost%{${at_normal}%}%{${fg_grey2}%}:%{${at_normal}%}%c %{${fg_cyan2}%}%#%{${at_normal}%} "


# #####################################
# ENABLE HOME/END/DELETE KEYS
# (this doesn't actually work, i dunno)
# #####################################

bindkey '^[[H'  beginning-of-line
bindkey '^[[F'  end-of-line

bindkey	"^[[3~"  delete-char
bindkey	"^[3;5~" delete-char


# #########################################
# SET EDITOR
# Let's set the default editor to TextMate,
# and then make an alias from 'edit'
# #########################################
export EDITOR='mate -w'
alias edit=$EDITOR


# ############################################################################
# X-MAN-PAGE
# Opening links using the URI scheme x-man-page://command will open the
# specified man page in a new Terminal window which uses the 'Man Page' theme.
# This is fantastic compared to reading it in the current Terminal tab, so
# let's create a function especially for that...
# ############################################################################
function man {
	# Check to see if 'open' is installed (this is Mac-specific)
	if [[ -n `whereis open` ]]; then
		# If there's a second argument, just return the normal man command
		if [[ -n $2 ]]; then
			`whereis man` $@
		# If there's only one argument, use 'open' to raise a new window
		else
			open x-man-page://$1
		fi
	# If 'open' isn't installed, return the normal man command
	else
		`whereis man` $@
	fi
}


# ######################################################################
# PYWIKIPEDIABOT FUNCTIONS
# Typing the full commands for the pywikipediabot scripts is irritating,
# so here are some shortcuts
# ######################################################################
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


# ########################
# CONFIGURE TAB COMPLETION
# ########################

# load some shit
autoload -U compinit
compinit

# set some shit lol i dunno
zstyle ':completion:*' completer _complete _expand _ignored _match _approximate

# max number of errors for 'approximate' matching
zstyle ':completion:*:approximate:*' max-errors 3 numeric

# case-insensitive completion
# zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' matcher-list 'm:{A-Z}={a-z}' 'm:{a-z}={A-Z}' 'r:|[._-]=** r:|=**' 'l:|=* r:|=*'

# show 'completing ____' in the menu thing
zstyle ':completion:*:descriptions' format $'%{\e[0;35m%}completing %B%d%b%{\e[0m%}'

# automatically complete the first result, then cycle
setopt MENU_COMPLETE

# display a box thingie around the completion menu items
zstyle ':completion:*' menu select=2 

# complete even in the middle of words
setopt COMPLETE_IN_WORD

# correct misspelt commands
setopt correct

# this is for colours in completions
zmodload zsh/complist

# colour process IDs for 'kill' red
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'

# colour directories for 'ls'
zstyle ':completion:*:default' list-colors 'no=0:fi=0:di=36:ln=33:ex=31'


# ################################################
# UNSET CDPATH
# tab completion is really irritating otherwise :(
# ################################################
unset CDPATH


##############
# FOR MACPORTS
# ############
export PATH=/opt/local/bin:/opt/local/sbin:$PATH
