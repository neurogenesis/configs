# ##############################################################################
# This script contains a number of terminal commands to alter OS X system 
# settings. Some of these settings are modifiable from the GUI, but many of 
# them are not. If this script itself is run via the terminal, all of the 
# uncommented lines will be run and the changes will be applied at once, 
# followed by the forced restarting of all affected applications (like 
# Finder and the Dock).

# inspired heavily by mathiasbynens's dotfiles/.osx:
# https://github.com/mathiasbynens/dotfiles/blob/master/.osx
# ##############################################################################


# ------------------------------------------------------------------------------
# GLOBAL SETTINGS
# ------------------------------------------------------------------------------

# Disable spelling auto-correction
defaults write -g NSAutomaticSpellingCorrectionEnabled -bool false
echo "\033[1;33mGlobal:\033[0m Disabled spelling auto-correction"

# Enable full keyboard access (tabbing, &c.) for window controls
defaults write -g AppleKeyboardUIMode -int 3
echo "\033[1;33mGlobal:\033[0m Enabled full keyboard access for window controls"

# Enable minimising of windows upon double-clicking title bar
defaults write -g AppleMiniaturizeOnDoubleClick -bool true
echo "\033[1;33mGlobal:\033[0m Enabled minimising of windows upon double-clicking title bar"

# Copy KeyBindings from ~/Development/configs (if it's there)
if [ -f ~/Development/configs/KeyBindings/DefaultKeyBinding.dict ]
then
	cp -r ~/Development/configs/KeyBindings ~/Library
	echo "\033[1;33mGlobal:\033[0m Copied KeyBindings from ~/Development/configs"
fi


# ------------------------------------------------------------------------------
# MOUSE SETTINGS
# ------------------------------------------------------------------------------

# Disable 'natural' (reverse) scrolling; this requires a log-out though,
# for some reason, so maybe not that useful...
defaults write ~/Library/Preferences/.GlobalPreferences com.apple.swipescrolldirection -bool false
echo "\033[1;33mMouse:\033[0m Disabled natural/reverse scrolling (log-out required)"

# Enable right-clicking on Magic Mouse
defaults write com.apple.driver.AppleBluetoothMultitouch.mouse MouseButtonMode "TwoButton"
echo "\033[1;33mMouse:\033[0m Enabled Magic Mouse secondary click"

# Disable 'smart zoom' (one-finger double tap) on Magic Mouse
defaults write com.apple.driver.AppleBluetoothMultitouch.mouse MouseOneFingerDoubleTapGesture -int 0
echo "\033[1;33mMouse:\033[0m Disabled Magic Mouse smart zoom"

# Disable full-screen swipe (two-finger swipe) on Magic Mouse
defaults write com.apple.driver.AppleBluetoothMultitouch.mouse MouseTwoFingerHorizSwipeGesture -int 0
echo "\033[1;33mMouse:\033[0m Disabled Magic Mouse two-finger swipe"


# ------------------------------------------------------------------------------
# FINDER SETTINGS
# ------------------------------------------------------------------------------

# Show the path bar
defaults write com.apple.Finder ShowPathbar -int 1
echo "\033[1;33mFinder:\033[0m Enabled path bar"

# Show the status bar
defaults write com.apple.Finder ShowStatusBar -int 1
echo "\033[1;33mFinder:\033[0m Enabled status bar"

# Always show file extensions
defaults write -g AppleShowAllExtensions -int 1
echo "\033[1;33mFinder:\033[0m Enabled file extensions for all file types"

# Disable warning when changing a file's extension
defaults write com.apple.Finder FXEnableExtensionChangeWarning -int 0
echo "\033[1;33mFinder:\033[0m Disabled warning on change of file extension"

# Search the current folder (instead of the whole computer)
defaults write com.apple.Finder FXDefaultSearchScope "SCcf"
echo "\033[1;33mFinder:\033[0m Set default search scope to current folder"

# Show hard drives, external hard drives, and removable media on the Desktop
defaults write com.apple.Finder ShowExternalHardDrivesOnDesktop -int 1
defaults write com.apple.Finder ShowHardDrivesOnDesktop -int 1
defaults write com.apple.Finder ShowRemovableMediaOnDesktop -int 1
echo "\033[1;33mFinder:\033[0m Enabled Desktop volume icons"

# Automatically open a new Finder window when a volume is mounted
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
echo "\033[1;33mFinder:\033[0m Enabled new Finder window on volume mounting"

# Prevent the creation of .DS_Store files on network volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
echo "\033[1;33mFinder:\033[0m Disabled creation of .DS_Store files on network volumes"

# Show the ~/Library folder
chflags nohidden ~/Library
echo "\033[1;33mFinder:\033[0m Enabled display of ~/Library folder"

# Fix for the ancient UTF-8 bug in QuickLook (http://mths.be/bbo)
echo "0x08000100:0" > ~/.CFUserTextEncoding
echo "\033[1;33mFinder:\033[0m Corrected QuickLook UTF-8 bug"


# ------------------------------------------------------------------------------
# DOCK SETTINGS
# ------------------------------------------------------------------------------

# Enable the 2D Dock
defaults write com.apple.dock no-glass -bool true
echo "\033[1;33mDock:\033[0m Enabled 2D Dock"


# ------------------------------------------------------------------------------
# TEXTEDIT SETTINGS
# ------------------------------------------------------------------------------

# Change the keyboard shortcut for 'Don't Save' back to ⌘D
defaults write -g NSSavePanelStandardDesktopShortcutOnly -bool true
echo "\033[1;33mTextEdit:\033[0m Set keyboard shortcut for 'Don't Save' to ⌘D"

# Set plain text as the default format
defaults write com.apple.TextEdit RichText -int 0
echo "\033[1;33mTextEdit:\033[0m Set plain text as default format"

# Set plain-text font to Andale Mono 12 pt
defaults write com.apple.TextEdit NSFixedPitchFont "AndaleMono"
defaults write com.apple.TextEdit NSFixedPitchFontSize -int 12
echo "\033[1;33mTextEdit:\033[0m Set plain-text font to Andale Mono 12 pt"

# Set window width to 70 chars
defaults write com.apple.TextEdit WidthInChars -int 70
echo "\033[1;33mTextEdit:\033[0m Set default window width to 70 characters"


# ------------------------------------------------------------------------------
# TERMINAL SETTINGS
# ------------------------------------------------------------------------------

# Copy .zshrc from ~/Development/configs (if it's there)
if [ -f ~/Development/configs/.zshrc ]
then
	if [ -f ~/.zshrc ]
	then
    	mv ~/.zshrc ~/.zshrc.bak
	fi
	cp ~/Development/configs/.zshrc ~/.zshrc
	echo "\033[1;33mTerminal:\033[0m Copied .zshrc from ~/Development/configs"
fi


# ------------------------------------------------------------------------------
# FINISH UP
# ------------------------------------------------------------------------------

# Kill all affected applications
echo "\nRestarting affected applications..."
for app in Safari Finder Dock Mail; do killall "$app" &> /dev/null; done

echo "\nConfiguration completed."
