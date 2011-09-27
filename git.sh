# ##############################################################################
# This script is used to configure git and clone my configs repository.
# (Obviously git and SSH keys must already be in their appropriate places.)
# ##############################################################################

# Make sure git is installed (just in case i forget...)
hash git 2>&- || { 
	echo >&2 "\033[1;31mError:\033[0m"\
		"git is required but does not appear to be installed.";
	exit 1; }

# Make sure SSH is configured (just in case i forget...)
if [ ! -f ~/.ssh/id_dsa ]
then
    echo "\033[1;31mError:\033[0m"\
		"SSH must be configured first."
    exit 1
fi

# Configure git
git config --global user.name "kine"
git config --global user.email "kine@stupidkitties.com"

# Create dev folder if it doesn't exist, then clone the repository into it
mkdir -p ~/Development
git clone git@github.com:ohkine/configs.git ~/Development/configs

# Open the repository directory in Finder
open ~/Development/configs
