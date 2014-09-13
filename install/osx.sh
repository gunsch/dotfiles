# OSX-specific setup.

if [[ ! $(which brew) ]]; then
  echo "brew not found. Trying to install...";
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

  sudo chown $USER /usr/local
fi

brew install ack
brew install coreutils
brew install sshfs
brew install wget

# Cask let you install Mac applications distributed as binaries.
brew install caskroom/cask/brew-cask

brew cask install alfred
brew cask install caffeine
# Formerly PCKeyboardHack
brew cask install seil

# Ask brew if everything is okay
brew doctor

# Enable trackpad tap to click for this user and for the login screen.
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Display the battery charge in a percentage.
defaults write com.apple.menuextra.battery ShowPercent -string "YES"

# Disable mouse (not trackpad) acceleration.
defaults write .GlobalPreferences com.apple.mouse.scaling -int -1

# Set a keyboard repeat rate of 2ms.
defaults write NSGlobalDomain KeyRepeat -float 0.02

