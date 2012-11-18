
# This script should be portable to bash, and maybe ksh

# ####################
# SET UP LOCALE
# ####################

export LANG='en_GB.UTF-8'
export LC_ALL='en_GB.UTF-8'
export LC_COLLATE='en_GB.UTF-8'
export LC_CTYPE='en_GB.UTF-8'
export LC_MESSAGES='en_GB.UTF-8'
export LC_MONETARY='en_GB.UTF-8'
export LC_NUMERIC='en_GB.UTF-8'
export LC_TIME='en_GB.UTF-8'



# ###################################################################################
# CMD — basically a wrapper for `type`
# 
# cmd <command> always returns a file
# cmd -a <command> prefers a file, but if one is not found it will return other types
# cmd -t <command> always returns a type (like 'function')
# 
# This function is critical for much of this script!
# ###################################################################################

# $shell will indicate the current shell
# This is NOT the same as $SHELL, which always returns the log-in shell
# (This is somewhat overly complicated, but it works with BSD, GNU, and BusyBox)
# We're defining this here instead of below because it's necessary for `cmd`
shell="`ps | grep -E "^[\\t ]*$$" | awk '{ print \$NF }' | sed ${sedopt} 's/^-//'`"

function cmd {
	# Usage information
	if [[ ! -n $1 ]] || [[ "$1" == '-help' ]] || [[ "$1" == '--help' ]]; then
		echo "$0 — Wrapper for \`type\`"
		echo ''
		echo 'usage:'
		echo "  $0 <command>     —  Return path of first <command> in PATH"
		echo "  $0 -a <command>  —  Return non-file matches if <command> can't be found in PATH"
		echo "  $0 -t <command>  —  Return type of <command>"
		echo ''
		echo "\`$0\` has no output if the specified <command> can't be found."
		return 6
	fi

	# `type` behaves differently between shells
	# (Note that `type` is an alias to `whence` in ksh and zsh)
	# (csh has no `type` at all, but none of this is portable to it anyway)
	if [[ "${shell}" == 'bash' ]]; then
		local  cmd='type'
		local popt='-P'
		local topt='-t'
	elif [[ "${shell}" == 'zsh' ]]; then
		local  cmd='type'
		local popt='-p'
		local topt=''
	elif [[ "${shell}" == 'ksh' ]]; then
		local  cmd='type'
		local popt='-p'
		local topt='-v'
	elif [[ "${shell}" == 'ash' ]]; then
		local  cmd='type'
		local popt='-p'
		local topt=''
	else
		return 2
	fi

	# Set $arg to the very last argument
	eval local arg="\$$#"

	# Determine how to proceed based on arguments provided
	while getopts ':at' opt; do
		case $opt in
			# -a: Allow non-file return values
			a)
				# If there's no file match, try something else
				if [[ "`type ${popt} ${arg} > /dev/null 2>&1; echo $?`" -gt 0 ]]; then
					# If it's available as a function, alias, or shell built-in, just return what we provided
					if [[ "`type ${topt} ${arg}`" != '' ]] && [[ "`type ${topt} ${arg}`" != *' not found' ]]; then
						echo "${arg}"
						return 0
					# Otherwise, die with error
					else
						return 1
					fi

				# If there is a file match, print the path
				else
					local output="`type ${popt} ${arg} | awk '{ print $NF }'`"

					# ash will still output stuff if there's a non-file match even if you use -p
					# (similar to how this very argument is meant to work) — catch this
					if [[ "${output}" != './'* ]] && [[ "${output}" != '/'* ]]; then
						return 1
					else
						echo "${output}"
						return 0
					fi
				fi
				;;

			# -t: Return only type
			t)
				# If there's a match, get the type
				if [[ "`type ${arg} > /dev/null 2>&1; echo $?`" == '0' ]]; then
					case "`type ${topt} ${arg} 2>&1`" in
						'function'|*' is a shell function')
							echo 'function'
							return 0
							;;

						'alias'|*' is an alias for '*)
							echo 'alias'
							return 0
							;;

						'builtin'|*' is a shell builtin')
							echo 'built-in'
							return 0
							;;

						'keyword'|*' is a reserved word')
							echo 'reserved word'
							return 0
							;;

						# If this seems un-intuitive, it's because it is —
						# ash and ksh use the term 'tracked alias' to describe hashed commands
						'file'|*' is a tracked alias for '*|*' is /'*)
							echo 'file'
							return 0
							;;
					esac

					# Die with error if something else happens
					return 1

				# Otherwise, die with error
				else
					return 1
				fi
				;;

			\?)
				;;
		esac
	done

	# If there's no match, don't output anything — just return 1
	if [[ "`type ${popt} ${arg} > /dev/null 2>&1; echo $?`" == '1' ]]; then
		return 1

	# Otherwise, print the path of the command
	else
		local output="`type ${popt} ${arg} | awk '{ print $NF }'`"

		# ash will still output stuff if there's a non-file match even if you use -p
		# (similar to how this very argument is meant to work) — catch this
		if [[ "${output}" != './'* ]] && [[ "${output}" != '/'* ]]; then
			return 1
		else
			echo "${output}"
			return 0
		fi
	fi
}



# #########################################################
# WHAT AM I?
# Although zsh behaves more or less the same on any system,
# a lot of the so-called 'standard' utilities do not. Here
# we can determine what system we're on and how to behave
# in the functions defined below. This is also helpful for
# increasing the portability of this script.
# #########################################################

# $os will indicate the operating system
# OS X  = 'Darwin'
# Linux = 'Linux'
os="`uname`"


# $kernel will indicate the kernel version
# OS X  = '12.2.0' (e.g.)
# Linux = '3.0.4'  (e.g.)
kernel="`uname -r`"


# $osxver will indicate the OS X version (if applicable)
if [[ "${os}" == 'Darwin' ]]; then
	osxver="`sw_vers | awk '/ProductVersion/ { print $NF }'`"
else
	osxver=''
fi


# $distro will indicate the Linux distribution name (if applicable)

# Use `lsb_release`, if it's available
if [[ "`cmd lsb_release`" != '' ]]; then
	distro="`lsb_release -a 2> /dev/null | awk '/Distributor ID/ { print $NF }'`"

else
	if [[ "${os}" == 'Linux' ]]; then
		distro='unknown'
	else
		distro=''
	fi
fi


# $cipafilter will indicate whether this is a CIPAFilter-based system
# $cipaver will indicate the CIPAFilter version
if [[ -e /usr/cipafilter/VERSION ]]; then
	cipafilter='yes'
	   cipaver="`cat /usr/cipafilter/VERSION`.`cat /usr/cipafilter/SUBVERSION`"
else
	cipafilter='no'
	   cipaver=''
fi


# $busybox will indicate whether we're on a BusyBox-based system
# (Some systems have BusyBox installed but don't use it for much;
#  this will accurately match those that do)

# This gets a count of the symlinks to busybox in /usr/bin
busyboxes="`ls -l /usr/bin | egrep 'busybox$' | wc -l`"

# If there are more than 25 busybox symlinks, we can safely
# conclude that this system is BusyBox-based
if [[ $busyboxes -gt 25 ]]; then
	busybox='yes'
else
	busybox='no'
fi


# $uclibc will indicate whether we're on a uClibc-based system
uclibcs="`find /lib -name 'ld-uClibc*' 2> /dev/null | wc -l`"

if [[ $uclibcs -gt 0 ]]; then
	uclibc='yes'
else
	uclibc='no'
fi


# $host will indicate the (short) host name
host="`hostname -s`"


# $lsver will indicate the version of `ls` we're using
lsv="`ls --version 2>&1`"

# BSD ls
if [[ "${lsv}" == 'ls: illegal option'* ]]; then
	lsver='BSD'
# GNU ls
elif [[ "${lsv}" == *'GNU coreutils'* ]]; then
	lsver='GNU'
# BusyBox ls
elif [[ "${lsv}" == *'BusyBox'* ]]; then
	lsver='BusyBox'
# ???
else
	lsver='unknown'
fi


# $findver will indicate the version of `find` we're using:
# $findopt will indicate the 'follow symlinks' option for our version
findv="`find --version 2>&1`"

# BSD find
if [[ "${findv}" == 'find: illegal option'* ]]; then
	findver='BSD'
	findopt='-L'
# GNU find
elif [[ "${findv}" == *'GNU findutils'* ]]; then
	findver='GNU'
	findopt='-L'
# BusyBox find
elif [[ "${findv}" == *'BusyBox'* ]]; then
	findver='BusyBox'
	findopt='-follow'
# ???
else
	if [[ "`cmd find`" != '' ]]; then
		findver='unknown'
	else
		findver='none'
	fi

	findopt=''
fi


# $sedver will indicate the version of `sed` we're using;
# $sedopt will indicate the 'extended' option for our version
sedv="`sed --version 2>&1`"

# BSD sed
if [[ "${sedv}" == 'sed: illegal option'* ]]; then
	sedver='BSD'
	sedopt='-E'
# GNU sed
elif [[ "${sedv}" == 'GNU sed version '* ]]; then
	sedver='GNU'
	sedopt='-r'
# BusyBox sed
elif [[ "${sedv}" == 'This is not GNU sed'* ]]; then
	sedver='BusyBox'
	sedopt='-r'
# ???
else
	if [[ "`cmd sed`" != '' ]]; then
		sedver='unknown'
	else
		sedver='none'
	fi

	sedopt=''
fi


# $grepver will indicate the version of `grep` we're using
# $grepopt will indicate the colour-negating option for our version
grepv="`grep --version 2>&1`"

# BSD grep
if [[ "${grepv}" == *'BSD grep'* ]]; then
	grepver='BSD'
	grepopt='--color=never'
# GNU grep
elif [[ "${grepv}" == *'GNU grep'* ]]; then
	grepver='GNU'
	grepopt='--color=never'
# BusyBox grep
elif [[ "${grepv}" == *'BusyBox'* ]]; then
	grepver='BusyBox'
	grepopt=''
# ???
else
	if [[ "`cmd grep`" != '' ]]; then
		grepver='unknown'
	else
		grepver='none'
	fi

	grepopt=''
fi


# $routever will indicate the version of `route` we're using
# $ip will indicate the IPv4 address of the default interface
# $gw will indicate the IPv4 address of the default gateway of the default interface
routev="`route --version 2>&1`"

# BSD route
if [[ "${routev}" == *'route: illegal option'* ]]; then
	routever='BSD'
	ip="`ifconfig $(route -n get default | awk '/interface:/ { print $NF }') | awk '/inet / { print $2 }'`"
	gw="`route -n get default | awk '/gateway:/ { print $NF }'`"
# net-tools route
elif [[ "${routev}" == 'net-tools'* ]]; then
	routever='net-tools'
	ip="`ifconfig $(route -n | awk '/^0\.0\.0\.0[\t ]/ { print $NF }') | awk '/inet addr:/ { print substr($2, 6) }'`"
	gw=`route -n | awk '/^0\.0\.0\.0[\t ]/ { print $2 }'`
# BusyBox route
elif [[ "${routev}" == *'BusyBox'* ]]; then
	routever='BusyBox'
	ip="`ifconfig $(route -n | awk '/^0\.0\.0\.0[\t ]/ { print $NF }') | awk '/inet addr:/ { print substr($2, 6) }'`"
	gw=`route -n | awk '/^0\.0\.0\.0[\t ]/ { print $2 }'`
# ???
else
	if [[ "`cmd route`" != '' ]]; then
		routever='unknown'
	else
		routever='none'
	fi

	ip='127.0.0.1'
	gw=''
fi


# $ps will indicate the version of `ps` we're using
psv="`ps --version 2>&1`"

# BSD ps
if [[ "${psv}" == *'ps: illegal option'* ]]; then
	psver='BSD'
# net-tools route
elif [[ "${psv}" == 'procps'* ]]; then
	psver='procps'
# BusyBox route
elif [[ "${psv}" == *'BusyBox'* ]]; then
	psver='BusyBox'
# ???
else
	if [[ "`cmd ps`" != '' ]]; then
		psver='unknown'
	else
		psver='none'
	fi
fi


# $column will indicate whether `column` is available and usable
# (`column` is broken on uClibc-based systems)
if [[ "`cmd column`" == '' ]] || [[ "${uclibc}" == 'yes' ]]; then
	column='no'
else
	column='yes'
fi


# $perl will indicate whether perl is installed
if [[ "`cmd perl`" != '' ]]; then
	perl='yes'
else
	perl='no'
fi


# $python will indicate whether python is installed
if [[ "`cmd python`" != '' ]]; then
	python='yes'
else
	python='no'
fi


# SEE ABOVE FOR $shell


# $id will indicate the current user's ID number
# (so we don't have to call `id -u` every time we need to see if we're root)
id="`id -u`"


# $parent will indicate the shell's parent process
if [[ "${psver}" != 'BusyBox' ]]; then
	parent="`ps -e -o pid,comm | grep -E "^[\t ]*${PPID}\b" | awk '{ print $2 }'`"
else
	parent="`ps | grep -E "^[\t ]*${PPID}\b" | awk '{ print $5 }'`"
fi


# $ssh will indicate whether we're logged on through ssh,
# by checking the name of the shell's parent process
# (This works with dropbear, unlike $SSH_CLIENT)
if [[ "${parent}" == 'sshd' ]] || [[ "${parent}" == 'dropbear' ]]; then
	ssh='yes'
else
	ssh='no'
fi


# $terminal will indicate the name of the terminal application
# (as set by either $TERM_PROGRAM or $LC_TERM_PROGRAM)

# Check for $LC_TERM_PROGRAM first —
# this would be passed through (e.g.) ssh
if [[ "${LC_TERM_PROGRAM}" != '' ]]; then
	# This variable is named stupidly because, by default,
	# sshd will only accept locale variables passed from the client.
	# I fully realise that this is abusive
	terminal="${LC_TERM_PROGRAM}"

# If there's no $LC_TERM_PROGRAM, check for $TERM_PROGRAM
elif [[ "${TERM_PROGRAM}" != '' ]]; then
	terminal="${TERM_PROGRAM}"

# Otherwise, ???
else
	terminal='unknown'
fi


export \
	os kernel osxver distro cipafilter cipaver \
	busybox uclibc host	lsver findver findopt \
	sedver sedopt grepver routever ip gw psver \
	column perl python shell id parent ssh terminal



# ####################
# SET UP COLOURS
# ####################

export TERM=xterm-256color

if [[ "${shell}" == 'zsh' ]]; then
	autoload colors
	colors
fi

# BSD ls colours
CLICOLOR=1
LSCOLORS=gxdxcxcxbxdxdxbxbxgxgx

# Linux/GNU ls colours
LS_COLORS='di=36:ln=33:so=32:pi=32:ex=31:bd=33:cd=33:su=31:sg=31:tw=36:ow=36:'

# grep colour
GREP_COLOR='0;31'

export CLICOLOR LSCOLORS LS_COLORS GREP_COLOR

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



# ####################
# SET UP PROMPTS
# ####################

if [[ "${shell}" == 'zsh' ]]; then
	# These are all like this:
	# host:dir %

	# GREEN left prompt for personal work stations
	if [[ "${host}" == 'kapche-lanka' ]] || [[ "${host}" == 'rondolina' ]] || [[ "${host}" == 'proserpina' ]]; then
		PROMPT="%{${fg_green}%}%m%{${at_normal}%}%{${fg_grey2}%}:%{${at_normal}%}%c %{${fg_green}%}%#%{${at_normal}%} "

	# RED left prompt for satanism (eggdrop)
	elif [[ "${host}" == 'ester' ]]; then
		PROMPT="%{${fg_red}%}satanism%{${at_normal}%}%{${fg_grey2}%}:%{${at_normal}%}%c %{${fg_red}%}%#%{${at_normal}%} "

	# CYAN left prompt for personal Web servers
	elif [[ "${host}" == 'odin' ]]; then
		PROMPT="%{${fg_cyan}%}%m%{${at_normal}%}%{${fg_grey2}%}:%{${at_normal}%}%c %{${fg_cyan}%}%#%{${at_normal}%} "

	elif [[ "${host}" == 'washingtondc' ]]; then
		PROMPT="%{${fg_cyan}%}dreamhost%{${at_normal}%}%{${fg_grey2}%}:%{${at_normal}%}%c %{${fg_cyan}%}%#%{${at_normal}%} "

	# YELLOW left prompt for routers and other servers
	elif [[ "${host}" == 'iserlohn' ]]; then
		PROMPT="%{${fg_yellow}%}%m%{${at_normal}%}%{${fg_grey2}%}:%{${at_normal}%}%c %{${fg_yellow}%}%#%{${at_normal}%} "

	# GREEN left prompt for anything else
	else
		PROMPT="%{${fg_green}%}%m%{${at_normal}%}%{${fg_grey2}%}:%{${at_normal}%}%c %{${fg_green}%}%#%{${at_normal}%} "
	fi

	# If we're running a shell on top of another shell, show an indicator
	# with the number of shells to the bottom
	# (Sometimes this happens and i forget)
	if [[ ${SHLVL} -gt 1 ]]; then
		RPROMPT="%{${fg_black2}%}$(($SHLVL - 1)) ↩%{${at_normal}%}"
	fi

elif [[ "${shell}" == 'bash' ]]; then
	# Emulate csh-style prompt character
	if [[ "${id}" == '0' ]]; then
		cprompt='#'
	else
		cprompt='%'
	fi

	# Set terminal title and prompt — CIPAFilter
	if [[ "${cipafilter}" == 'yes' ]]; then
		PS1="\[\033]0;\h:\W\007\]" # tab title
		PS1="${PS1}\[${fg_yellow}\]\h"
		PS1="${PS1}\[${fg_grey2}\]:"
		PS1="${PS1}\[${fg_grey}\]${cipaver}"
		PS1="${PS1}\[${fg_grey2}\]:"
		PS1="${PS1}\[${at_normal}\]\W "
		PS1="${PS1}\[${fg_yellow}\]${cprompt}\[${at_normal}\] "
		export PS1

	# Set terminal title and prompt — other
	else
		PS1="\[\033]0;\h:\W\007\]" # tab title
		PS1="${PS1}\[${fg_green}\]\h"
		PS1="${PS1}\[${fg_grey2}\]:"
		PS1="${PS1}\[${at_normal}\]\W "
		PS1="${PS1}\[${fg_green}\]${cprompt}\[${at_normal}\] "
		export PS1
	fi
fi



# ##############################################
# UPDATE CWD FOR APPLE TERMINAL
# zsh function borrowed from Super User —
# bash function borrowed from OS X's /etc/bashrc
# ##############################################
if [[ "${terminal}" == 'Apple_Terminal' ]] && [[ "${shell}" == 'zsh' ]]; then
	update_terminal_cwd() {
		# Identify the directory using a 'file:' scheme URL, including
		# the host name to disambiguate local vs remote paths

		# Percent-encode the path name
		local URL_PATH=''
		{
			# Use LANG=C to process text byte-by-byte
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

		local PWD_URL="file://${host}${URL_PATH}"
		printf '\e]7;%s\a' "${PWD_URL}"
	}

	# Register the function so it is called whenever the working
	# directory changes.
	autoload add-zsh-hook
	add-zsh-hook chpwd update_terminal_cwd

	# Tell the terminal about the initial directory.
	update_terminal_cwd

elif [[ "${terminal}" == 'Apple_Terminal' ]] && [[ "${shell}" == 'bash' ]]; then
	update_terminal_cwd() {
		# Identify the directory using a "file:" scheme URL,
		# including the host name to disambiguate local vs.
		# remote connections. Percent-escape spaces.
		local SEARCH=' '
		local REPLACE='%20'
		local PWD_URL="file://$HOSTNAME${PWD//$SEARCH/$REPLACE}"
		printf '\e]7;%s\a' "$PWD_URL"
	}

	PROMPT_COMMAND="update_terminal_cwd; $PROMPT_COMMAND"
fi



# #################################################
# PRECMD BEHAVIOUR
# Update the tab title before each prompt is shown;
# also, do some stuff for work
# #################################################

# This executes after a command completes but before the prompt is shown.
# Mainly useful for when the directory changes.
if [[ "${shell}" == 'zsh' ]]; then
	precmd() {
		# Get last command return code
		local lastret=$?

		# Get last command entered
		local lastcmd="$history[$[HISTCMD-1]]"

		# Update title: host:directory
		print -Pn "\e]0;%m:%c\a"

		# Update CWD for Apple Terminal if we've just ended an ssh session
		if [[ "${lastcmd}" == 'ssh '* ]] && [[ "${terminal}" == 'Apple_Terminal' ]]; then
			update_terminal_cwd
		fi

		# Don't proceed if we're not on my work network,
		# or if we're not on a Mac
		if [[ "${ip}" != '172.'* ]] || [[ "${os}" != 'Darwin' ]]; then
			return

		# If we might be...
		else
			# Check to see if we've just completed an SSH session on heinessen
			if [[ "${lastcmd}" != 'ssh heinessen'* ]]; then
				# If not, return
				return

			# If so...
			else
				# If we returned something aside from 255, return
				if [[ $lastret != 255 ]]; then
					return

				# Otherwise...
				else
					# Get the Wi-Fi device name
					local wlandev="`networksetup -listallhardwareports | grep -A1 'Wi-Fi' | awk '/Device/ { print $NF }'`"

					# Get the current Wi-Fi network (if any)
					local wlan="`networksetup -getairportnetwork ${wlandev} | awk -F ':' '{ print substr($NF, 2) }'`"

					# Set prefix or exit based on the above
					if [[ "${wlan}" == *'Conference' ]]; then
						local locprefix='Wi-Fi'

					elif [[ "${wlan}" == '' ]]; then
						local locprefix='Ethernet'

					else
						return
					fi

					# Check to see if we're on DHCP already
					local location="`networksetup -getcurrentlocation`"

					# If we are, who cares
					if [[ "${location}" == "${locprefix} (via DHCP)" ]]; then
						return

					# If we're not...
					else
						# Go through DHCP
						scselect "${locprefix} (via DHCP)" > /dev/null

						# Launch a script to check for heinessen's return
						# ~/Development/work/check-for-heinessen.sh $locprefix
						(~/Development/work/check-for-heinessen.sh $locprefix &) 2> /dev/null > /dev/null
					fi
				fi
			fi
		fi
	}
fi

# Use this in .ssh/config to automatically update the title for ssh:
# PermitLocalCommand  yes
# LocalCommand        print -Pn "\e]0;ssh\a"



# ######################################
# FIX VARIOUS KEY BINDINGS
# (Somehow i broke these in Terminal
#  when i was messing with vim bindings)
# ######################################

if [[ "${shell}" == 'zsh' ]]; then
	bindkey ''    beginning-of-line
	bindkey ''    end-of-line

	bindkey 'b'   backward-word
	bindkey 'f'   forward-word

	bindkey	'[3~' delete-char

	# Make Shift+Tab go backwards in auto-complete menus
	bindkey '[Z' reverse-menu-complete

	# Ctrl+K: kill entire line from any cursor position
	bindkey ''    kill-whole-line
	# Ctrl+U: kill line from cursor position to beginning of line
	bindkey ''    backward-kill-line

	# Make Ctrl+W also use slash as a delimiter
	# (basically re-implement readline's unix-filename-rubout)
	# (e.g., 'cd /usr/share/doc^w' will delete 'doc' instead of the full path)
	unix-filename-rubout() {
		local WORDCHARS="${WORDCHARS:s@/@}"
		zle backward-kill-word
	}

	zle -N unix-filename-rubout
	bindkey '' unix-filename-rubout

elif [[ "${shell}" == 'bash' ]]; then
	bind '"\C-a":  beginning-of-line'
	bind '"\C-e":  end-of-line'

	bind '"\eb":   backward-word'
	bind '"\ef":   forward-word'

	bind '"\e[3~": delete-char'

	# Tab and Shift+Tab
	bind '"\t":    menu-complete'
	bind '"\e[Z":  "\e-1\C-i"'

	# Ctrl+K: kill entire line from any cursor position
	bind '"\C-k":  kill-whole-line'
	# Ctrl+U: kill line from cursor position to beginning of line
	bind '"\C-u":  backward-kill-line'

	# Make Ctrl+W also use slash as a delimiter
	stty werase undef
	bind '"\C-w":  unix-filename-rubout'

	bind 'set completion-ignore-case on'
	bind 'set show-all-if-ambiguous  on'
	bind 'set skip-completed-text    on'
	bind 'set horizontal-scroll-mode off'
fi



# ######################################################################
# DON'T USE VI MODE
# (Since i use vim for my editor some shells will do this by default...)
# ######################################################################

if   [[ "${shell}" == 'zsh' ]]; then
	bindkey -e
elif [[ "${shell}" == 'bash' ]]; then
	set -o emacs
fi



# ###########################
# MISC. FUNCTIONS AND ALIASES
# ###########################

# Assign my SSH client address to $me, and update .ssh/config
# This makes it easier to scp things when i'm on the VPN
export me=''

# I'm sorry to say that only very recent versions of `dropbear` provide any
# environmental variables, so this is pretty much limited to OpenSSH
if [[ "${SSH_CLIENT}" != '' ]]; then
	export me="`echo "${SSH_CLIENT}" | awk '{ print $1 }'`"

	if [[ -f ~/.ssh/config ]] && [[ "`cmd perl`" != '' ]] && [[ "`cmd tee`" != '' ]]; then
		# Make a back-up
		cp ~/.ssh/config ~/.ssh/config.bak

		# Since `perl -i` breaks symlinks, we'll use `tee`
		cat ~/.ssh/config | perl -0777 -pe 's/\n(Host\s+)me\n(HostName\s+)[^\s\n]*/\n\1me\n\2$ENV{"me"}/' | tee ~/.ssh/config > /dev/null 2>&1
	fi
fi


# `ls` options — use colours, always follow symlinks

# GNU `ls`
if   [[ "${lsver}" == 'GNU' ]]; then
	alias ls='ls -H --color=auto'

# Use GNU `ls` on BusyBox systems which have it
elif [[ "${lsver}" == 'BusyBox' ]]; then
	alias ls='ls --color=auto'

	# Get a list of all of the `ls`es available on this system
	for ls in $(type -a ls | awk '!/ is( an)? alias/ { print $NF }'); do
		lsv="`${ls} --version 2>&1`"

		# If we have a GNU `ls`, alias `ls` to it
		if [[ "${lsv}" == *'GNU coreutils'* ]]; then
			alias ls="${ls} -H --color=auto"
		fi
	done

# BSD `ls`
else
	alias ls='ls -H'
fi

alias lsa='ls -A'


# `grep` options
if [[ "${grepver}" == 'BusyBox' ]]; then
	alias grep='grep -E -i'
	alias egrep='grep -E -i'
else
	alias grep='grep --color=auto -E -i'
	alias egrep='grep --color=auto -E -i'
fi


# Too lazy to type out the full source command
if   [[ "${shell}" == 'zsh' ]]; then
	alias reload="source ~/.zshrc"
elif [[ "${shell}" == 'bash' ]]; then
	alias reload="source ~/.bash_profile"
elif [[ "${shell}" == 'ksh' ]]; then
	alias reload="exec ~/.profile"
fi


if [[ "${os}" == 'Darwin' ]]; then
	# Show hidden files in Finder
	alias show="defaults write com.apple.Finder AppleShowAllFiles TRUE && killall Finder"

	# Hide hidden files in Finder
	alias hide="defaults write com.apple.Finder AppleShowAllFiles FALSE && killall Finder"
fi


# `killall` is so hard to spell
alias kilall='killall'
alias kilalll='killall'
alias killal='killall'
alias killalll='killall'
alias killlal='killall'
alias kilallal='killall'


# Aliases for `ipkg`
if [[ "`cmd ipkg`" != '' ]]; then
	 alias ipkg-update='ipkg update'
	alias ipkg-upgrade='ipkg upgrade'
	alias ipkg-install='ipkg install'
	 alias ipkg-remove='ipkg remove'
	   alias ipkg-list='ipkg list'
	 alias ipkg-search='ipkg search'
	   alias ipkg-info='ipkg info'

	if [[ "`cmd apt-get`" == '' ]]; then
		alias apt-get='ipkg'
	fi

	if [[ "`cmd port`" == '' ]]; then
		 alias port='ipkg'
		alias ports='ipkg'
	fi
fi


# Aliases for `port`
if [[ "`cmd port`" != '' ]]; then
	alias ports='port'

	if [[ "`cmd apt-get`" == '' ]]; then
		alias apt-get='ipkg'
	fi
fi


# Alias for `sudo` on systems that don't have it
if [[ "`cmd sudo`" == '' ]]; then

	# If we're already root, we can just continue like nothing happened
	if [[ "${id}" == '0' ]]; then
		alias sudo='echo "\`sudo\` not found, and you are already root. Proceeding normally."; true;'

	# Otherwise, use `su root -c`
	else
		function sudo {
			echo '`sudo` not found; using `su root -c` instead. The root password is required.'
			su root -c "${@:2}"
		}
	fi

# Make `sudo` respect aliases on systems that do have it
else
	alias sudo='sudo '
fi


# Make certain usages of BSD `route` behave like net-tools
if [[ "${routever}" == 'BSD' ]]; then
	function route {
		# If we've just tried to do `route`, use `netstat -r`
		if [[ "$@" == '' ]] && [[ "`cmd netstat`" != '' ]]; then
			echo "BSD \`route\` doesn't support this usage; executing \`netstat -r\` instead." 
			netstat -r

		# If we've just tried to do `route -n`, use `netstat -nr`
		elif [[ "$@" == '-n' ]] && [[ "`cmd netstat`" != '' ]]; then
			echo "BSD \`route\` doesn't support this usage; executing \`netstat -nr\` instead."
			netstat -nr

		# Otherwise, proceed normally
		else
			`cmd route` "$@"
		fi
	}
fi


# Display useful shell vars
function shellvars {
	eq="${fg_black2}=${at_normal}"

	# This is actually slightly confusing:
	# We're using NON-BREAKING spaces (Opt+space) as the column delimiters here
	shellvars=$(echo "\
${fg_red}\$os${at_normal} ${eq} ${os:- } ${fg_black2}# operating system${at_normal}\\n\
${fg_red}\$kernel${at_normal} ${eq} ${kernel:- } ${fg_black2}# kernel version${at_normal}\\n\
${fg_red}\$osxver${at_normal} ${eq} ${osxver:- } ${fg_black2}# OS X version${at_normal}\\n\
${fg_red}\$distro${at_normal} ${eq} ${distro:- } ${fg_black2}# Linux distribution${at_normal}\\n\
${fg_red}\$cipafilter${at_normal} ${eq} ${cipafilter:- } ${fg_black2}# CIPAFilter-based system?${at_normal}\\n\
${fg_red}\$cipaver${at_normal} ${eq} ${cipaver:- } ${fg_black2}# CIPAFilter version${at_normal}\\n\
${fg_red}\$busybox${at_normal} ${eq:- } ${busybox} ${fg_black2}# BusyBox-based system?${at_normal}\\n\
${fg_red}\$uclibc${at_normal} ${eq:- } ${uclibc} ${fg_black2}# uClibc-based system?${at_normal}\\n\
${fg_red}\$host${at_normal} ${eq} ${host:- } ${fg_black2}# host name${at_normal}\\n\
${fg_red}\$ip${at_normal} ${eq} ${ip:- } ${fg_black2}# IP of the default interface${at_normal}\\n\
${fg_red}\$gw${at_normal} ${eq} ${gw:- } ${fg_black2}# default gateway of the default interface${at_normal}\\n\
${fg_red}\$ssh${at_normal} ${eq} ${ssh:- } ${fg_black2}# connecting via SSH?${at_normal}\\n\
${fg_red}\$me${at_normal} ${eq} ${me:- } ${fg_black2}# IP of the connecting SSH client${at_normal}\\n\
${fg_red}\$terminal${at_normal} ${eq} ${terminal:- } ${fg_black2}# terminal application${at_normal}\\n\
${fg_red}\$parent${at_normal} ${eq} ${parent:- } ${fg_black2}# shell's parent process${at_normal}\\n\
${fg_red}\$shell${at_normal} ${eq} ${shell:- } ${fg_black2}# current shell name${at_normal}\\n\
${fg_red}\$id${at_normal} ${eq} ${id:- } ${fg_black2}# current user ID${at_normal}\\n\
${fg_red}\$lsver${at_normal} ${eq} ${lsver:- } ${fg_black2}# \`ls\` type${at_normal}\\n\
${fg_red}\$findver${at_normal} ${eq} ${findver:- } ${fg_black2}# \`find\` type${at_normal}\\n\
${fg_red}\$findopt${at_normal} ${eq} ${findopt:- } ${fg_black2}# 'follow symlinks' option for \`find\`${at_normal}\\n\
${fg_red}\$sedver${at_normal} ${eq} ${sedver:- } ${fg_black2}# \`sed\` type${at_normal}\\n\
${fg_red}\$sedopt${at_normal} ${eq} ${sedopt:- } ${fg_black2}# 'extended' option for \`sed\`${at_normal}\\n\
${fg_red}\$grepver${at_normal} ${eq} ${grepver:- } ${fg_black2}# \`grep\` type${at_normal}\\n\
${fg_red}\$routever${at_normal} ${eq} ${routever:- } ${fg_black2}# \`route\` type${at_normal}\\n\
${fg_red}\$psver${at_normal} ${eq} ${psver:- } ${fg_black2}# \`ps\` type${at_normal}\\n\
${fg_red}\$column${at_normal} ${eq} ${column:- } ${fg_black2}# \`column\` available?${at_normal}\\n\
${fg_red}\$perl${at_normal} ${eq} ${perl:- } ${fg_black2}# \`perl\` available?${at_normal}\\n\
${fg_red}\$python${at_normal} ${eq} ${python:- } ${fg_black2}# \`python\` available?${at_normal}\\n\
—\\n\
${fg_red}\$USER${at_normal} ${eq} ${USER:- } ${fg_black2}# user name${at_normal}\\n\
${fg_red}\$HOME${at_normal} ${eq} ${HOME:- } ${fg_black2}# home directory${at_normal}\\n\
${fg_red}\$SHELL${at_normal} ${eq} ${SHELL:- } ${fg_black2}# log-in shell path${at_normal}\\n\
${fg_red}\$TERM${at_normal} ${eq} ${TERM:- } ${fg_black2}# terminal type${at_normal}\\n\
${fg_red}\$TERM_PROGRAM${at_normal} ${eq} ${TERM_PROGRAM:- } ${fg_black2}# terminal application${at_normal}\
")

	# Use `column` if possible
	if [[ "${column}" == 'yes' ]]; then
		echo -e $shellvars	| column -s ' ' -t | sed $sedopt 's/^—$//'
	else
		echo -e $shellvars | sed $sedopt 's/ / /g; s/^—$//'
	fi
}


# Get relative path to a given file
function relative {
	# Make sure python is available
	if [[ "${python}" == 'no' ]]; then
		echo "python not found. Aborting."
		return 1
	fi

	# Usage information
	if [[ ! -n $1 ]] || [[ "$1" == '-help' ]] || [[ "$1" == '--help' ]]; then
		echo "$0 — Get relative path from one directory to another"
		echo ''
		echo 'usage:'
		echo "  $0 [<from directory>] <to directory/file>"
		echo ''
		echo 'If no <from directory> is provided, the current working directory is assumed.'
		return 6
	fi

	# If there's no argument, assume that we want the realpath of the CWD
	if [[ ! -n $2 ]]; then
		python -c "import os, sys; print os.path.relpath('$1', '`pwd`')"
	else
		python -c "import os, sys; print os.path.relpath('$2', '$1')"
	fi
}


# Get absolute path of a given file
function absolute {
	# Make sure python is available
	if [[ "${python}" == 'no' ]]; then
		echo "python not found. Aborting."
		return 1
	fi

	# Usage information
	if [[ ! -n $1 ]] || [[ "$1" == '-help' ]] || [[ "$1" == '--help' ]]; then
		echo "$0 — Get absolute path of a given file"
		echo ''
		echo 'usage:'
		echo "  $0 [<file>]"
		echo ''
		echo "\`$0\` does NOT follow symlinks."
		return 6
	fi

	# If there's no argument, assume that we want the realpath of the CWD
	if [[ ! -n $1 ]]; then
		python -c "import os, sys; print os.path.abspath('`pwd`')"
	else
		python -c "import os, sys; print os.path.abspath('$1')"
	fi
}


# Get absolute path of a symlink target
function realpath {
	# Make sure python is available
	if [[ "${python}" == 'no' ]]; then
		echo "python not found. Aborting."
		return 1
	fi

	# Usage information
	if [[ ! -n $1 ]] || [[ "$1" == '-help' ]] || [[ "$1" == '--help' ]]; then
		echo "$0 — Get absolute path of a symlink target"
		echo ''
		echo 'usage:'
		echo "  $0 [<symlink>]"
		echo ''
		echo "\`$0\` also works with non-symlinked files — but see \`absolute\`."
		return 6
	fi

	# If there's no argument, assume that we want the realpath of the CWD
	if [[ ! -n $1 ]]; then
		python -c "import os, sys; print os.path.realpath('`pwd`')"
	else
		python -c "import os, sys; print os.path.realpath('$1')"
	fi
}


# String length
function len {
	# Usage information
	if [[ ! -n $1 ]] || [[ "$1" == '-help' ]] || [[ "$1" == '--help' ]]; then
		echo "$0 — Get length of a string"
		echo ''
		echo 'usage:'
		echo "  $0 <string>"
		return 6
	fi

	echo -n "$@" | awk '{ print length(); }'
}


# Battery charge level for Macs
function charge {
	# We'll still define this even if we're not on a Mac,
	# just for consistency's sake
	if [[ "${os}" != 'Darwin' ]]; then
		echo "$0 is available only on Mac OS X. Aborting."
		return 1
	fi

	# Usage information
	if [[ "$1" == '-help' ]] || [[ "$1" == '--help' ]]; then
		echo "$0 — Display lap-top battery charge information"
		echo ''
		echo 'usage:'
		echo "  $0     —  Display charge percentage"
		echo "  $0 -r  —  Display 'raw' charge percentage (useful for scripting)"
		echo "  $0 -s  —  Display charge and adaptor state"
		echo "  $0 -t  —  Display time remaining until charged/discharged"
		echo "  $0 -v  —  Display verbose information"
		echo "  $0 -V  —  Display a visual indicator of charge percentage"
		return 6
	fi

	# Get the battery state information via `ioreg`
	local isc=`ioreg -rc AppleSmartBattery | awk '/IsCharging/ { print $NF }'`
	local ful=`ioreg -rc AppleSmartBattery | awk '/FullyCharged/ { print $NF }'`
	local ext=`ioreg -rc AppleSmartBattery | awk '/ExternalConnected/ { print $NF }'`

	local tim=`ioreg -rc AppleSmartBattery | awk '/TimeRemaining/ { print $NF }'`
	local  th=$(($tim / 60))
	local  tm=$(($tim - ($tim / 60) * 60))

	local cur=`ioreg -rc AppleSmartBattery | awk '/CurrentCapacity/ { print $NF }'`
	local max=`ioreg -rc AppleSmartBattery | awk '/MaxCapacity/ { print $NF }'`
	local pct=$((100 * $cur / $max))

	# If the charge information is empty, it's probably not a lap-top
	if [[ "${cur}" == '' ]] || [[ "${max}" == '' ]]; then
		return 1
	fi

	# If not empty, determine how to proceed based on the arguments provided
	while getopts ':rstvV' opt; do
		case $opt in
			# -r: Raw
			r)
				echo "${pct}"

				return 0
				;;

			# -s: Charge state
			s)
				# Echo the adaptor state
				if [[ "${ext}" == 'Yes' ]]; then
					echo 'Plugged in'
				else
					echo 'Unplugged'
				fi

				# Echo the charge state
				if [[ "${ful}" == 'Yes' ]]; then
					echo 'Fully charged'
				else
					echo 'Charging'
				fi

				# Echo the time remaining
				if [[ "${isc}" == 'Yes' ]]; then
					printf "%02i:%02i until fully charged\n" $th $tm
				elif [[ "${ful}" == 'Yes' ]] && [[ "${th}${tm}" == '00' ]]; then
					printf "%02i:%02i until fully charged\n" $th $tm
				else
					printf "%02i:%02i until fully discharged\n" $th $tm
				fi

				return 0
				;;

			# -t: Time remaining
			t)
				printf "%02i:%02i\n" $th $tm

				return 0
				;;

			# -v: Verbose
			v)
				# Get charge/discharge time
				if [[ "${isc}" == 'Yes' ]]; then
					local remaining="`printf "Time until charged: %02i:%02i" $th $tm`"
				elif [[ "${ful}" == 'Yes' ]] && [[ "${th}${tm}" == '00' ]]; then
					local remaining="`printf "Time until charged: %02i:%02i" $th $tm`"
				else
					local remaining="`printf "Time until discharged: %02i:%02i" $th $tm`"
				fi

				# Echo current and max capacities in mAh, plus the percentage at capacity
				local out="
Current capacity: ${cur} mAh
Maximum capacity: ${max} mAh
Percentage of capacity: ${pct}%
—
Plugged in: ${ext}
Currently charging: ${isc}
Fully charged: ${ful}
—
${remaining}"

				echo -e $out | column -s ' ' -t | sed $sedopt 's/^—$//'

				return 0
				;;

			# -V: Visual
			V)
				# Echo the percentage along with a little battery icon
				if [[ ${pct} -lt 12 ]]; then
					echo "${pct}% □□▪"
				elif [[ ${pct} -lt 25 ]]; then
					echo "${pct}% ■□▪"
				elif [[ ${pct} -gt 24 ]]; then
					echo "${pct}% ■■▪"
				fi

				return 0
				;;

			\?)
				;;
		esac
	done

	echo "${pct}%"
}


# Quick Look (wrapper for `qlmanage -p`)
if [[ "${os}" == 'Darwin' ]]; then
	function ql {
		# Usage information
		if [[ ! -n $1 ]] || [[ "$1" == '-help' ]] || [[ "$1" == '--help' ]]; then
			echo "$0 — Wrapper for \`qlmanage -p\`"
			echo ''
			echo 'usage:'
			echo "  $0 <file>"
			return 6
		fi

		# Run in a sub-shell so it doesn't print out bull shit
		(qlmanage -p "$@" >& /dev/null &)
	}
fi


# Aliases for `open`
if [[ "${os}" == 'Darwin' ]]; then
	   alias preview='open -a Preview'
	  alias textedit='open -a TextEdit'
	   alias firefox='open -a "Firefox Aurora"'
	    alias chrome='open -a "Google Chrome"'
	    alias safari='open -a Safari'
	     alias opera='open -a Opera'
	    alias movist='open -a Movist'
	       alias vlc='open -a VLC'
	 alias unarchive='open -a "The Unarchiver"'
	alias unarchiver='open -a "The Unarchiver"'
fi


# rot13 function (why would i ever use this, lol i dunno)
function rot13 {
	echo "$@" | tr "[a-m][n-z][A-M][N-Z]" "[n-z][a-m][N-Z][A-M]"
}


# Better md5 utility
# This improves on the built-in command(s) in a few ways:
# (1) If used on a single file, it returns only the sum
# (2) If used on a directory, it iterates through it
# (3) It does not return irritating 'is a directory' errors
# (4) The output format is consistent and improved
function md5sum {
	# Check to see which kind of md5 utility we have

	# `md5` seems to be used on OS X / BSD
	if [[ "`cmd md5`" != '' ]]; then
		local cmd="`cmd md5`"
		local opt='-q'

	# `md5sum` seems to be used on Linux
	elif [[ "`cmd md5sum`" != '' ]]; then
		local cmd="`cmd md5sum`"
		local opt=''

	# i dunno
	else
		echo 'No md5 utility found. Aborting.'
		return 1
	fi


	# Make sure perl and python are available
	if [[ "${perl}" == 'no' ]] || [[ "${python}" == 'no' ]]; then
		# If not, just pass straight through to the md5 utility
		$cmd "$@"
		return 2
	fi


	# Usage information
	if [[ ! -n $1 ]] || [[ "$1" == '-help' ]] || [[ "$1" == '--help' ]]; then
		echo "$0 — Wrapper for \`${md5cmd}\`"
		echo ''
		echo 'usage:'
		echo "  $0 <file/folder>"
		return 6
	fi


	# If there's more than one arg and the first arg is NOT -r, pass straight through to the md5 utility
	if   [[ "$1" != '-r' ]] && [[ -n $2 ]]; then
		$cmd "$@"
		return $?

	# Otherwise, proceed
	elif [[ -n $1 ]]; then
		# Check to see if we're calling with -r (recursive)
		if [[ "$1" == '-r' ]] && [[ -n $2 ]]; then
			local depth1=''
			local depth2=''
			local file="$2"
		else
			# BusyBox doesn't support -maxdepth; sry buds
			if [[ "${findver}" != 'BusyBox' ]]; then
				local depth1='-maxdepth'
				local depth2='1'
			else
				local depth1=''
				local depth2=''
			fi

			local file="$1"
		fi

		# If this is a regular file, print out the check sum
		if   [[ -f "${file}" ]]; then
			$cmd $opt "${file}" | awk '{ print $1 }'

		# If this is a symlink to a file, print out its check sum
		elif [[ -L "${file}" ]] && [[ -f "`readlink "${file}"`" ]]; then
			$cmd $opt  "${file}" | awk '{ print $1 }'

		# If this is a directory or a symlink to a directory, iterate through it
		elif [[ -d "${file}" ]] || [[ -d "`readlink "${file}"`" ]]; then
			local dir="${file}"

			# If this is a symlink, use `realpath` to get its actual location,
			# then `relative` to get its (actual) relative location
			if [[ "`realpath "${file}"`" != "`absolute "${file}"`" ]]; then
				dir="$(relative $(realpath "${file}"))"
			fi

			# BSD output
			if [[ $opt == '-q' ]]; then
				find ${findopt} "${dir}" ${depth1} ${depth2} -exec ${cmd} {} 2> /dev/null \; | awk '{ print $2 " " $4 }' | perl -pe 's/^\((.+?)\)\s+([a-f0-9]{32})/\1: \2/; s/^\.\///' | sort -f | column -t

			# GNU / BusyBox output
			else
				# Have to do this to fix sorting of dot-files
				LC_ALL='C'
				LC_COLLATE='C'

				# BusyBox's `find` syntax is inexplicably different from everyone else's
				if [[ "${findver}" == 'BusyBox' ]]; then
					# `column` is broken on uClibc-based systems
					if [[ "${column}" == 'yes' ]]; then
						find "${dir}" ${findopt} ${depth1} ${depth2} -exec ${cmd} {} 2> /dev/null \; | perl -pe 's/^([a-f0-9]{32})  (.\/)?(.+)$/\3: \1/' | sort -f | column -t
					else
						find "${dir}" ${findopt} ${depth1} ${depth2} -exec ${cmd} {} 2> /dev/null \; | perl -pe 's/^([a-f0-9]{32})  (.\/)?(.+)$/\3: \1/' | sort -f
					fi

				elif [[ "${findver}" == 'GNU' ]]; then
					# `column` is broken on uClibc-based systems
					if [[ "${column}" == 'yes' ]]; then
						find ${findopt} "${dir}" ${depth1} ${depth2} -exec ${cmd} {} 2> /dev/null \; | perl -pe 's/^([a-f0-9]{32})  (.\/)?(.+)$/\3: \1/' | sort -f | column -t
					else
						find ${findopt} "${dir}" ${depth1} ${depth2} -exec ${cmd} {} 2> /dev/null \; | perl -pe 's/^([a-f0-9]{32})  (.\/)?(.+)$/\3: \1/' | sort -f
					fi
				fi

				LC_ALL='en_GB.UTF-8'
				LC_COLLATE='en_GB.UTF-8'
			fi
		fi

	fi
}

alias md5='md5sum'


# Colour conversion
function colours {
	# Usage information
	if [[ ! -n $1 ]] || [[ "$1" == '-help' ]] || [[ "$1" == '--help' ]]; then
		echo "$0 — Convert between hex and RGB colour values"
		echo ''
		echo 'usage:'
		echo "  $0 <colour value>"
		echo ''
		echo "$0 automatically determines the appropriate conversion."
		return 6
	fi

	# hex
	if [[ "`echo "$@" | grep ${grepopt} '^((background-)?color:\s*)?#?[0-9a-f]{6};?$'`" == "$@" ]]; then
		local triplet1="`echo "$@" | tr '[A-Z]' '[a-z]' | sed $sedopt 's/^((background-)?color:\s*)?#?([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2});?$/0x\3/'`"
		local triplet2="`echo "$@" | tr '[A-Z]' '[a-z]' | sed $sedopt 's/^((background-)?color:\s*)?#?([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2});?$/0x\4/'`"
		local triplet3="`echo "$@" | tr '[A-Z]' '[a-z]' | sed $sedopt 's/^((background-)?color:\s*)?#?([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2});?$/0x\5/'`"

		local rgb1="`printf '%d' ${triplet1}`"
		local rgb2="`printf '%d' ${triplet2}`"
		local rgb3="`printf '%d' ${triplet3}`"

		echo "${rgb1},${rgb2},${rgb3}"

	# rgb
	elif [[ `echo "$@" | grep ${grepopt} '^((background-)?color:\s*)?(rgba?\()?([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])[, ]+([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])[, ]+([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])(,\s*([01](\.[0-5]{1,4})?)?)?\)?;?$'` == "$@" ]]; then
		local triplet1="`echo "$@" | tr '[A-Z]' '[a-z]' | sed ${sedopt} 's/^((background-)?color:\s*)?(rgba?\()?([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])[, ]+([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])[, ]+([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])(,\s*([01](\.[0-5]{1,4})?)?)?\)?;?$/\4/'`"
		local triplet2="`echo "$@" | tr '[A-Z]' '[a-z]' | sed ${sedopt} 's/^((background-)?color:\s*)?(rgba?\()?([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])[, ]+([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])[, ]+([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])(,\s*([01](\.[0-5]{1,4})?)?)?\)?;?$/\5/'`"
		local triplet3="`echo "$@" | tr '[A-Z]' '[a-z]' | sed ${sedopt} 's/^((background-)?color:\s*)?(rgba?\()?([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])[, ]+([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])[, ]+([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])(,\s*([01](\.[0-5]{1,4})?)?)?\)?;?$/\6/'`"

		local hex1="`printf "%02x" ${triplet1}`"
		local hex2="`printf "%02x" ${triplet2}`"
		local hex3="`printf "%02x" ${triplet3}`"

		echo "#${hex1}${hex2}${hex3}"
	fi
}

alias rgb='colours'
alias hex='colours'



# ####################
# SET EDITOR AND PAGER
# ####################

# MacVim — only use if we're not connecting via ssh
if   [[ -x `cmd mvim` ]] && [[ "${ssh}" == 'no' ]]; then
	export EDITOR="`cmd mvim`"
# vim
elif [[ -x `cmd vim` ]]; then
	export EDITOR="`cmd vim`"
# nano
elif [[ -x `cmd nano` ]]; then
	export EDITOR="`cmd nano`"
# ee
elif [[ -x `cmd ee` ]]; then
	export EDITOR="`cmd ee`"
else
	export EDITOR="`cmd vi`"
fi

alias edit="$EDITOR"


# Use `cat` for paging on CIPAFilters; otherwise `psql` behaves stupidly
if [[ "${cipafilter}" == 'yes' ]]; then
	export PAGER='cat'
fi



# ################################################
# CONFIG-COPY
# Copies config files to my other machines via scp
# (This is very lazy and relies on ssh aliases)
# ################################################
function config-copy {
	# Make sure there is at least one argument
	if [[ -n $1 ]]; then
		local destination=''

		case "$2" in
			zsh|zshrc|.zshrc)
				local configfile="${HOME}/.zshrc"
				;;
			vim|vimrc|.vimrc)
				local configfile="${HOME}/.vimrc"
				;;
			colors|colours|monok*)
				local configfile="${HOME}/.vim/colors/Monokai-mod.vim"
				destination="/.vim/colors"
				;;
			*)
				# Assume .zshrc by default
				local configfile="${HOME}/.zshrc"
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

function man {
	if [[ ! -n $2 ]]; then

		# If we're using Apple Terminal (and not connecting via ssh), use the 
		# x-man-page:// URI scheme; this will open the man page in a new terminal window
		if [[ "${TERM_PROGRAM}" == 'Apple_Terminal' ]] && [[ "${ssh}" == 'no' ]]; then
			open x-man-page://$1
			return

		# If we're not using Apple's Terminal...
		elif [[ "${ssh}" == 'no' ]]; then
			# And if we're not on a BusyBox-based system...
			if [[ "${busybox}" == 'no' ]]; then

				# And if we have `col`...
				if [[ "`cmd col`" != '' ]]; then
					# Get our preferred browser.
					# This is determined (somewhat inaccurately) by listing all of the user's processes, 
					# finding ones that might be browsers, and picking the one with the highest CPU time
					local browserps="`ps -o time,command -u "${USER}" | grep -iE '\b(chrome|firefox|aurora|opera|safari)\b' | sort -n -t : -k 1,1 -k 2,2 -k 3,3 | tail -1`"

					local browser=''

					case "${browserps}" in
						chrome)
							browser="`cmd chrome`"
							;;
						firefox)
							browser="`cmd firefox`"
							;;
						aurora)
							browser="`cmd aurora`"
							;;
						opera)
							browser="`cmd opera`"
							;;
						safari)
							browser="`cmd safari`"
							;;
						*)
							browser=''
							;;
					esac

					# If we got a browser, use it			
					if [[ "${browser}" != '' ]]; then
						# Set MANPAGER to output to a temp file
						local oldMANPAGER="${MANPAGER}"

						local mantemp="`mktemp -t man`"

						MANPAGER="col -b > ${mantemp} && ${browser} 'file://${mantemp}'"

						# Do the needful
						`cmd man` $1

						MANPAGER="${OLDMANPAGER}"

						return
					fi
				fi
			fi

		# If we're connecting via ssh, use `cat`
		else
			export MANPAGER='cat -s'
			`cmd man` $1
		fi

	# If there's more than one arg, use `cat`
	else
		export MANPAGER='cat -s'
		`cmd man` "$@"
	fi
}


# ####################
# PNGCRUSH
# ####################

# I only want this on my local machine actually
if [[ "`cmd pngcrush`" != '' ]]; then
	function pc {
		if [[ -n $1 ]] && [[ ! -n $2 ]]; then
			local pngdir="`dirname $1`"
			local pngfile="`basename -s .png $1`"

			mv "${pngdir}/${pngfile}.png" "${pngdir}/${pngfile}.original.png"

			if [ $? -eq 0 ]; then
				pngcrush -rem gAMA -rem cHRM -rem iCCP -rem sRGB \
				  "${pngdir}/${pngfile}.original.png" "${pngdir}/${pngfile}.png"
			else
				echo 'Failed to crush file.'
			fi

		else
			pngcrush -rem gAMA -rem cHRM -rem iCCP -rem sRGB "$@"
		fi
	}
fi



# ######################################################################
# PYWIKIPEDIABOT FUNCTIONS
# Typing the full commands for the pywikipediabot scripts is irritating,
# so here are some shortcuts
# ######################################################################

# I only want this on my local machine actually
if [[ "${host}" == 'kapche-lanka' ]]; then
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
	grep --color=NEVER -E -i $@ | \
	perl -pe '
		s/.*(\(null\),[0-9]{4},[0-9]{4}|D,[0-9]{4},[0-9]{4}).*\n//g;
		s/.*\.ass:Format:.*\n//g;
		s/.*TITLE:.*Legend of Galactic Heroes.*\n//g;
		s/^LOGH Episode ([0-9]+).+?\.ass./Episode $1 \.ass:/g;
		s/(^|\.ass:)(Dialogue|Command|Comment): //;
		s/^Overture to a New War\.ass:(Dialogue|Command|Comment): /ONW: /g;
		s/0,([0-9]+:[0-9]+:[0-9]+)\.[0-9]+,([0-9]+:[0-9]+:[0-9]+\.[0-9]+),(def2|mactitle),(\.)*/$1 /g;
		s/{\\c&.*?&.*?}//g;
		s/(\.){0,4},[0-9]{4},[0-9]{4},[0-9]{4},,/ /g;
		s/Comment,[0-9]{4},[0-9]{4},[0-9]{4},,/COMMENT: /g;
		s/{\\a[0-9]}//g;
		s/\\N/ /g
	'
}



# ########################
# CONFIGURE TAB COMPLETION
# ########################

if [[ "${shell}" == 'zsh' ]]; then
	# load some shit
	autoload -U compinit
	compinit
	zmodload zsh/complist

	# Automatically complete the first result, then cycle
	setopt MENU_COMPLETE

	# Complete even in the middle of words
	setopt COMPLETE_IN_WORD

	# Correct misspelt commands
	setopt CORRECT

	# Completion options
	zstyle ':completion:*' completer _complete _expand _ignored _match _approximate

	# Max number of errors for 'approximate' matching
	zstyle ':completion:*:approximate:*' max-errors 3 numeric

	# Show 'completing ____' in the menu thing
	zstyle ':completion:*:descriptions' format $'%{\e[0;35m%}completing %B%d:%b%{\e[0m%}'

	# Display a selection box around the completion menu items
	zstyle ':completion:*' menu select=2

	# Ignore completion functions
	zstyle ':completion:*:functions' ignored-patterns '_*'

	# Colour process IDs for `kill` red
	zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=0;31'


	# Helper function for `killall` completion
	_killall() {
		local psresults
		local psarray

		# If we're doing `sudo killall` rather than `killall`, list ALL processes
		if [[ "${BUFFER}" == 'sudo killall'* ]]; then 
			psresults=$(ps -c -e -o comm | sed $sedopt 's/(^[ ]*|[ ]*$)//g; /^[ ]*COMM[ ]*$/d; s/-(.+)sh$/\1sh/; s/^\((.+)\)$/\1/;' | sort -df)

		# Otherwise, list only processes for the current user
		else
			psresults=$(ps -c -U "$USER" -o comm | sed $sedopt 's/(^[ ]*|[ ]*$)//g; /^[ ]*COMM[ ]*$/d; s/-(.+)sh$/\1sh/; s/^\((.+)\)$/\1/;' | sort -df)
		fi

		psarray=(${(f)psresults})
		compadd -M 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' -V unsorted -aQ psarray
	}

	zle -N _killall

	# Provide better completion for `killall`
	if   [[ "${os}" == 'Darwin' ]]; then
		zstyle ':completion:*:processes-names' command '_killall'

	elif [[ "${os}" == 'Linux' ]]; then
		zstyle ':completion:*:processes-names' command "ps -U '${USER}' -o comm | sed '/^COMMAND$/d'"
	fi


	# Define 'users' as all users not beginning with a '_';
	# also, make sure 'kine', 'dana', and 'root' are always present
	if   [[ "${os}" == 'Darwin' ]]; then
		zstyle ':completion:*' users \
			$( (dscacheutil -q user | awk '/^name:/ { $1 = ""; if (substr($0, 2) !~ /^_/) print substr($0, 2); }'; echo 'dana'; echo 'kine'; echo 'root') | sort -ufd )

	else
		zstyle ':completion:*' users \
			$( (awk -F ':' '$1 !~ /^_/ { print $1 }' /etc/passwd; echo 'dana'; echo 'kine'; echo 'root') | sort -ufd )
	fi

	# Ignore un-interesting users
	zstyle ':completion:*:*:*:users' ignored-patterns \
		Guest nobody daemon macports \
		backup bin Debian-exim dovecot games gnats \
		irc libuuid list lp mail man messagebus \
		mysql news postfix proxy sshd statd sync \
		sys uucp vmail www-data \
		cipafilter_email_archive clamav deb-dak \
		dhcp klog ntpd quagga smmsp smmta spam \
		syslog bind defang postgres snmp test nas


	# Always list users and hosts separately
	zstyle ':completion:*:hosts' group-name hosts
	zstyle ':completion:*:users' group-name users

	# Also list files separately for `scp`
	zstyle ':completion:*:*:scp:*:all-files' group-name all-files

	# Define the order and display names of groups for `scp`
	zstyle ':completion:*:*:scp:*' tag-order 'files all-files:all-files:file/directory hosts:hosts:host users'
	zstyle ':completion:*:*:scp:*' group-order 'files all-files hosts users'

	# kdjf
	zstyle ':completion:*:*:(cat|mv|rm):*' tag-order \
		'files:files:file/directory all-files:all-files:file/directory globbed-files:globbed-files:file/directory'

	# Use only .ssh/config hosts for `ssh` and `scp`, if possible
	if [[ -e ~/.ssh/config ]] && [[ "`cmd perl`" != '' ]]; then
		zstyle ':completion:*:*:(ssh|scp):*' hosts \
			$(perl -ne 'print if s/^Host[\t ]+(?!\*)([^\t\n ]+).*/\1/' ~/.ssh/config)
	fi

	# Define the order and display names of groups for `ssh`
	zstyle ':completion:*:*:ssh:*' tag-order 'hosts:hosts:host users:users:user'
	zstyle ':completion:*:*:ssh:*' group-order 'hosts users'


	# Use host names from .ssh/config for `ping`;
	# also make sure that 'google.com' and each of our default gateways are always listed
	if [[ -e ~/.ssh/config ]] && [[ "`cmd perl`" != '' ]]; then
		if [[ "${os}" == 'Darwin' ]]; then
			zstyle ':completion:*:*:ping:*' hosts \
				$( (netstat -rn | awk '/^default/ { print $2 }'; perl -ne 'print if s/^HostName[\t ]+(?!\*)([^\t\n ]+).*/\1/' ~/.ssh/config; echo 'google.com') | sort -fdu )
		else
			zstyle ':completion:*:*:ping:*' hosts \
				$( (netstat -rn | awk '/^0\.0\.0\.0[\t ]/ { print $2 }'; perl -ne 'print if s/^HostName[\t ]+(?!\*)([^\t\n ]+).*/\1/' ~/.ssh/config; echo 'google.com') | sort -fdu )
		fi

	# If there's no .ssh/config, just use 'google.com' and our default gateways
	else
		if [[ "${os}" == 'Darwin' ]]; then
			zstyle ':completion:*:*:ping:*' hosts \
				$( (netstat -rn | awk '/^default/ { print $2 }'; echo 'google.com') | sort -dfu )
		else
			zstyle ':completion:*:*:ping:*' hosts \
				$( (netstat -rn | awk '/^0\.0\.0\.0[\t ]/ { print $2 }'; echo 'google.com') | sort -dfu )
		fi
	fi


	# Colour directories for 'ls'
	# (This just loads LS_COLORS in, which is quite nice ('ma' is the menu selection box))
	zstyle ':completion:*:default' list-colors "${(s.:.)LS_COLORS}:ma=0;45"


	# Make completion case-insensitive
	zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|[._-]=** r:|=**' 'l:|=* r:|=*'


	# Make it so we only have to press Return one time in the menu
	bindkey -M menuselect '' .accept-line
fi



# ###############################
# TELNET SHORTCUT FOR SATANISM
# (Just saves me a little typing)
# ###############################
if [[ "${host}" == 'ester' ]]; then
	function telnet {
		if [[ $# -gt 1 ]]; then
			`type -p telnet` "$@"
		else
			`type -p telnet` localhost 3389
		fi
	}
fi



# ####################
# PATHs
# ####################
unset CDPATH

# MacPorts
if [[ -d /opt/local ]]; then
	export PATH="/opt/local/bin:/opt/local/sbin:${PATH}"
fi

# iMac
if [[ "${host}" == 'kapche-lanka' ]]; then
	export PATH="/Volumes/Garga\ Falmul/Development/ginei-tools/ginei-names:${PATH}"
fi

# router
if [[ "${host}" == 'iserlohn' ]]; then
	export PATH="/opt/scripts:${PATH}"
fi

# CIPAFilters
if [[ "${cipafilter}" == 'yes' ]]; then
	# Add /usr/cipafilter/www/scripts and /usr/cipafilter/init.d to PATH
	export PATH="${PATH}:/usr/cipafilter/www/scripts:/usr/cipafilter/init.d"
fi



# ####################
# WORK STUFF
# ####################
if [[ -e ~/.zsh/.zshrc.work ]]; then
	source ~/.zsh/.zshrc.work
fi



# ####################
# SYNTAX HIGHLIGHTING
# ####################
if [[ "${shell}" == 'zsh' ]] && [[ -e ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
	source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

	# Add additional highlighters
	ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)

	# Colour for unknown tokens and errors
	ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=black,bold'

	# Colour for commands, aliases, built-ins, and functions
	        ZSH_HIGHLIGHT_STYLES[alias]='fg=red'
	      ZSH_HIGHLIGHT_STYLES[builtin]='fg=red'
	     ZSH_HIGHLIGHT_STYLES[function]='fg=red'
	      ZSH_HIGHLIGHT_STYLES[command]='fg=red'
	   ZSH_HIGHLIGHT_STYLES[precommand]='fg=red'
	ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=red' # matches 'if', 'for', &c.

	# Colour for arguments
	ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=red,bold'
	ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=red,bold'

	# Colour for paths
	ZSH_HIGHLIGHT_STYLES[path]='fg=blue'

	# Colour for pipes, semi-colons, &c.
	ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=blue,bold'

	# Colour for brackets
	ZSH_HIGHLIGHT_STYLES[bracket-level-1]='fg=blue,bold'
	ZSH_HIGHLIGHT_STYLES[bracket-level-2]='fg=blue,bold'
	ZSH_HIGHLIGHT_STYLES[bracket-level-3]='fg=blue,bold'
	ZSH_HIGHLIGHT_STYLES[bracket-level-4]='fg=blue,bold'
fi



# ################
# HISTORY SETTINGS
# ################

if [[ "${shell}" == 'zsh' ]]; then
	# Create ~/.zsh if it doesn't exist
	if [[ ! -e ~/.zsh ]]; then
		mkdir -p ~/.zsh
	fi

	HISTFILE="${HOME}/.zsh/.histfile"
	HISTSIZE=1000
	SAVEHIST=1000

elif [[ "${shell}" == 'bash' ]]; then
	# Create ~/.zsh if it doesn't exist
	if [[ ! -e ~/.bash ]]; then
		mkdir -p ~/.bash
	fi

	HISTFILE="${HOME}/.bash/.histfile"

	# Append to history instead of overwriting after each session
	shopt -s histappend

	# If connecting via ssh, save history at each prompt instead of session end
	if [[ "${ssh}" == 'yes' ]]; then
		PROMPT_COMMAND="history -a; $PROMPT_COMMAND"
	fi
fi



# #######################
# TERM_PROGRAM FORWARDING
# #######################

# Exporting (or re-exporting) this variable with the current value
# of $terminal will allow ssh to pass the value to remote hosts, which
# mostly accept LC_* vars by default
export LC_TERM_PROGRAM="${terminal}"


