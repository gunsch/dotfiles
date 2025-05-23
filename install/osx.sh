# OSX-specific setup.

set -e

function print_header {
  echo "###############################################################################"
  echo "# $1"
  echo "###############################################################################"
}

###############################################################################
# Applications to install
###############################################################################
print_header "brew, cask, and friends"

if [[ ! $(which brew) ]]; then
  echo "brew not found. Trying to install...";
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Permissions seem to get reset regularly?
sudo chown -R $(whoami) $(brew --prefix)/*

brew install \
    ack \
    bat \
    coreutils \
    fd \
    gh \
    htop \
    jc \
    jq \
    magic-wormhole \
    mosh \
    ncdu \
    node \
    wget \
    || true  # Note: Brew has non-zero exit status if apps are already installed :(

# Cask let you install Mac applications distributed as binaries.
brew install --cask \
    alfred \
    caffeine \
    docker \
    flux \
    github \
    signal \
    telegram \
    visual-studio-code \
    vlc

brew install --cask Google-chrome || true
brew install --cask spotify || true
# Exception here for arabelle --- previous web install
brew install --cask iterm2 || true
# Exception here for gunsch-macbookpro2 --- previous manual install
brew install --cask android-platform-tools || true

# Brew auto-update!
# autoupdate --start fails if already installed
brew tap domt4/autoupdate && brew autoupdate --start || true

# Special case (sshfs): do osxfuse, then sshfs
# Note (2022-10: doesn't seem to work on current OSX version / new laptop)
# brew install --cask osxfuse
# brew install sshfs || true

# Ask brew if everything is okay
brew doctor

###############################################################################
# Developer tools
###############################################################################
print_header "Developer tools"

# Python
# Note (2022-10: doesn't seem to work on current OSX version / new laptop)
# Python3 and pip3 come by default
# sudo easy_install pip


###############################################################################
# System-wide configuration
###############################################################################
print_header "Setting up OSX configs"

# Rewrites Caps Lock to Escape. NOTE: this seems to be keyboard-dependent and might not
# work for all Macs.
# Checking System Update. Seems to be "com.apple.keyboard.modifiermapping.<VendorId>-<ProductId>-0"
# i.e. on M1 it seems to be "com.apple.keyboard.modifiermapping.1452-834-0"
defaults write -g com.apple.keyboard.modifiermapping.1452-630-0 -array-add '<dict><key>HIDKeyboardModifierMappingDst</key><integer>30064771113</integer><key>HIDKeyboardModifierMappingSrc</key><integer>30064771129</integer></dict>'

# Deletes "Minimize" shortcut since it's annoying
defaults write -g NSUserKeyEquivalents -dict-add 'Minimize' '\0'

# Enable trackpad tap to click for this user and for the login screen.
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Display the battery charge in a percentage.
defaults write com.apple.menuextra.battery ShowPercent -string "YES"

# Disables automatic brightness changes
sudo defaults write /Library/Preferences/com.apple.iokit.AmbientLightSensor "Automatic Display Enabled" -bool false

# Disable mouse (not trackpad) acceleration.
defaults write .GlobalPreferences com.apple.mouse.scaling -int -1

# Set a keyboard repeat rate of 100ms.
defaults write NSGlobalDomain KeyRepeat -float 1.0

# Save screenshots location
if [[ ! -e "${HOME}/Screenshots" ]]; then
  mkdir ${HOME}/Screenshots
fi
defaults write com.apple.screencapture location -string "${HOME}/Screenshots"

# Disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# disable period on double-space
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -int 0

# Disable "natural" (Lion-style) scrolling
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# Set a custom wallpaper image. `DefaultDesktop.jpg` is already a symlink, and
# all wallpapers are in `/Library/Desktop Pictures/`. The default is `Wave.jpg`.
#rm -rf ~/Library/Application Support/Dock/desktoppicture.db
#sudo rm -rf /System/Library/CoreServices/DefaultDesktop.jpg
#sudo ln -s /path/to/your/image /System/Library/CoreServices/DefaultDesktop.jpg

# Disable smart quotes as they’re annoying when typing code
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# Disable smart dashes as they’re annoying when typing code
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Reveal IP address, hostname, OS version, etc. when clicking the clock
# in the login window
sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

# Disable dictionary shortcut key.
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 70 '<dict><key>enabled</key><false/></dict>'

# Disables MRU space ordering
defaults write com.apple.dock mru-spaces -bool false

# Disables emoji suggestion magic
defaults write /Library/Preferences/FeatureFlags/Domain/UIKit.plist emoji_enhancements -dict-add Enabled -bool NO

###############################################################################
# Finder                                                                      #
###############################################################################

# Finder: allow quitting via ⌘ + Q; doing so will also hide desktop icons
defaults write com.apple.finder QuitMenuItem -bool true

# Finder: disable window animations and Get Info animations
defaults write com.apple.finder DisableAllAnimations -bool true

# Finder: show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Disable the warning before emptying the Trash
defaults write com.apple.finder WarnOnEmptyTrash -bool false

# Empty Trash securely by default
defaults write com.apple.finder EmptyTrashSecurely -bool true

# Show the ~/Library folder
chflags nohidden ~/Library

###############################################################################
# Dock, Dashboard, and hot corners                                            #
###############################################################################

# Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
killall Dock

# Disable the Launchpad gesture (pinch with thumb and three fingers)
defaults write com.apple.dock showLaunchpadGestureEnabled -int 0

# Disable Dashboard
defaults write com.apple.dashboard mcx-disabled -bool true

# Don’t show Dashboard as a Space
defaults write com.apple.dock dashboard-in-overlay -bool true

###############################################################################
# Transmission.app                                                            #
###############################################################################

# Trash original torrent files
defaults write org.m0k.transmission DeleteOriginalTorrent -bool true

# Hide the donate message
defaults write org.m0k.transmission WarningDonate -bool false
# Hide the legal disclaimer
defaults write org.m0k.transmission WarningLegal -bool false

###############################################################################
# Sublime Text.app                                                            #
###############################################################################

# Change "Quit" shortcut key to Cmd+Ctrl+Shift+Q
defaults write com.sublimetext.3 NSUserKeyEquivalents -dict-add "Quit Sublime Text" -string "@^\$q"

###############################################################################
# Chrome.app                                                                  #
###############################################################################

# Change "Quit" shortcut key to Cmd+Ctrl+Shift+Q
defaults write com.google.Chrome NSUserKeyEquivalents -dict-add "Quit Google Chrome" -string "@^\$q"
# Change "Close Window" shortcut key to Cmd+Ctrl+Shift+W
defaults write com.google.Chrome NSUserKeyEquivalents -dict-add "Close Window" -string "@^~\$w"
defaults write com.google.Chrome NSUserKeyEquivalents -dict-add "Close All" -string "@^~\$a"

###############################################################################
# Hiding various apps
###############################################################################

# Disable "Hide Others" shortcut key.
defaults write "Apple Global Domain" NSUserKeyEquivalents -dict-add "Hide Others" nil
defaults write com.google.Chrome NSUserKeyEquivalents -dict-add 'Hide Google Chrome' '\0'
defaults write com.microsoft.VSCode NSUserKeyEquivalents -dict-add 'Hide Visual Studio Code' '\0'
defaults write com.googlecode.iterm2 NSUserKeyEquivalents -dict-add 'Hide iTerm2' '\0'
defaults write com.tinyspeck.slackmacgap NSUserKeyEquivalents -dict-add 'Hide Slack' '\0'

###############################################################################
# Safari.app                                                                  #
###############################################################################

# Disabling 2024-04
# Enable developer tools (hidden by default)
# defaults write com.apple.Safari IncludeDebugMenu 1
