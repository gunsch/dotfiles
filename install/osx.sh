# OSX-specific setup.

if [[ ! $(which brew) ]]; then
  echo "brew not found. Trying to install...";
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Permissions seem to get reset regularly?
sudo chown $USER /usr/local
sudo chown $USER /usr/local/etc

brew install ack
brew install coreutils
brew install sshfs
brew install wget

# Cask let you install Mac applications distributed as binaries.
brew install caskroom/cask/brew-cask

brew cask install alfred
brew cask install caffeine
brew cask install flux
brew cask install hyperdock
brew cask install vlc

# Ask brew if everything is okay
brew doctor

###############################################################################
# System-wide configuration
###############################################################################

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

# Set a keyboard repeat rate of 2ms.
defaults write NSGlobalDomain KeyRepeat -float 0.02

# Save screenshots location
if [[ ! -e "${HOME}/Screenshots" ]]; then
  mkdir ${HOME}/Screenshots
fi
defaults write com.apple.screencapture location -string "${HOME}/Screenshots"

# Disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

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
# Chrome.app                                                                  #
###############################################################################

# Disable Cmd+Q from closing Chrome
defaults write com.google.Chrome NSUserKeyEquivalents -dict-add "Quit Google Chrome" -string '@$-^q'
