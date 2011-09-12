# This script contains a number of terminal commands to alter OS X system 
# settings. Some of these settings are modifiable from the GUI, but many of 
# them are not. If this script itself is run via the terminal, all of the 
# uncommented lines will be run and the changes will be applied at once, 
# followed by the forced restarting of all affected applications (like 
# Finder and the Dock).

# inspired heavily by mathiasbynens's dotfiles/.osx:
# https://github.com/mathiasbynens/dotfiles/blob/master/.osx


# ######################################################################
# GLOBAL SETTINGS
# ######################################################################

# Disable spelling auto-correction
defaults write -g NSAutomaticSpellingCorrectionEnabled -bool false

# Enable full keyboard access (tabbing, &c.) for window controls
defaults write -g AppleKeyboardUIMode -int 3

# Enable minimising of windows upon double-clicking title bar
defaults write -g AppleMiniaturizeOnDoubleClick -bool true


# ######################################################################
# FINDER SETTINGS
# ######################################################################

# Show the path bar
defaults write com.apple.Finder ShowPathbar -int 1

# Show the status bar
defaults write com.apple.Finder ShowStatusBar -int 1

# Always show file extensions
defaults write -g AppleShowAllExtensions -int 1

# Disable warning when changing a file's extension
defaults write com.apple.Finder FXEnableExtensionChangeWarning -int 0

# Show hard drives, external hard drives, and removable media on the Desktop
defaults write com.apple.Finder ShowExternalHardDrivesOnDesktop -int 1
defaults write com.apple.Finder ShowHardDrivesOnDesktop -int 1
defaults write com.apple.Finder ShowRemovableMediaOnDesktop -int 1

# Automatically open a new Finder window when a volume is mounted
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true

# Prevent the creation of .DS_Store files on network volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Show the ~/Library folder
chflags nohidden ~/Library

# Fix for the ancient UTF-8 bug in QuickLook (http://mths.be/bbo)
echo "0x08000100:0" > ~/.CFUserTextEncoding


# ######################################################################
# DOCK SETTINGS
# ######################################################################

# Enable the 2D Dock
defaults write com.apple.dock no-glass -bool true


# ######################################################################
# TEXTEDIT SETTINGS
# ######################################################################

# Change the keyboard shortcut for 'Don't Save' back to ⌘D
defaults write -g NSSavePanelStandardDesktopShortcutOnly -bool true


# ######################################################################
# FINISH UP
# ######################################################################

# Kill all affected applications
for app in Safari Finder Dock Mail; do killall "$app"; done

