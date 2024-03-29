#!/usr/bin/env bash
# Installer!

# TODOs:
#   * Can we get vscode settings in here?
#   * delete ST2 settings
#   * iterm2 settings, particularly from gunsch-macbookpro2?

set -e;

function print_header {
  echo "###############################################################################"
  echo "# $1"
  echo "###############################################################################"
}

function symlink() {
  if [[ $# -lt 2 ]]; then
    echo "Too few args to symlink";
    exit 1;
  fi;

  if [[ -e "$2" || -L "$2" ]]; then
    if [[ "$($READLINK -f "$1")" == "$($READLINK -f "$2")" ]]; then
      # The file already exists, and it's the same symlink.
      return;
    fi

    local prefixed_backup_location="$($DOT/bin/relpath $1)"
    local backup_location="$DOT/backups/${prefixed_backup_location#dotfiles/}";

    echo "- $2 already exists. Replace with $1?";
    if $DOT/bin/prompt "- $2 will be backed up at ${backup_location})"; then
      mkdir -p "$(dirname "${backup_location}")";
      mv "$2" "${backup_location}";
      # Fall through to symlinking.
    else
      return 0;
    fi;
  fi;

  echo "Symlinking $2...";
  ln -s "$1" "$2";
}

function download() {
  if [[ $# -lt 2 ]]; then
    echo "Too few args to download";
    exit 1;
  fi;

  local download_output="$DOT/download/${2}"
  if [[ -e "${download_output}" ]]; then
    return;
  fi;

  echo "Downloading $1...";
  mkdir -p "$DOT/download";
  curl "$1" --silent -o "${download_output}"
}


###############################################################################
# Initial configuration / setup
###############################################################################

if [[ "${USER}" == "root" ]]; then
  echo "This should not be run as root!"
  exit 2
fi

DOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "dotfiles root: ${DOT}"

# Find "readlink".
if [[ "$(uname -s)" == "Darwin" ]]; then
  if [[ ! $(which greadlink) ]]; then
    echo "greadlink not found. Try \`brew install coreutils\`";
    exit 1;
  fi;
  READLINK="greadlink"
else
  READLINK="readlink"
fi
echo "readlink utility: ${READLINK}"

if [[ "$($READLINK -f "$(dirname "${BASH_SOURCE[0]}" )")" != "$($READLINK -f ~/dotfiles)" ]]; then
  echo "Dotfiles should be checked out to ~/dotfiles".
  exit 1;
fi

###############################################################################
# OS-specific sub-scripts
###############################################################################
print_header "OS-specific sub-scripts"

if [[ "$(uname -s)" == "Darwin" ]]; then
  $DOT/install/osx.sh
elif [[ "$(uname -s)" == "Linux" ]]; then
  $DOT/install/linux.sh
fi

host_script="$DOT/install/host/$(hostname -s).sh"
if [ -f $host_script ]; then
  echo "Executing $host_script..."
  $host_script;
fi

###############################################################################
# Symlink things to places we want
###############################################################################
print_header "Make sure our symlinks are in place..."

symlink $DOT/config/zshrc ~/.zshrc
symlink $DOT/config/bashrc ~/.bashrc
symlink $DOT/config/bashrc ~/.bash_profile
symlink $DOT/config/vimrc ~/.vimrc
mkdir -p ~/.vim && symlink $DOT/config/vimtemplates ~/.vim/templates
symlink $DOT/config/gitconfig ~/.gitconfig
symlink $DOT/config/sshconfig ~/.ssh/config
symlink $DOT/bin ~/bin

# Make a simple symlink at "host/current" to "host/$(hostname)" for config
# files that can't do shell expansion.
if [[ ! -L $DOT/host/current ]]; then
  ln -s $DOT/host/$(hostname -s) $DOT/host/current;
fi

# sshconfig dependency: needs .ssh/controlmasters to exist
mkdir -p ~/.ssh/controlmasters/ && chmod 700 ~/.ssh/controlmasters/

###############################################################################
# Sublime Text configs
###############################################################################
print_header "Set up Sublime Text configs..."

# Note: not using ST2 these days
#if [[ "$(uname -s)" == "Darwin" ]]; then
#  symlink $DOT/sublime ~/Library/Application\ Support/Sublime\ Text\ 2/Packages/User
#else
#  symlink $DOT/sublime ~/.config/sublime-text-2/Packages/User
#fi

###############################################################################
# Developer tools
###############################################################################
print_header "Downloading command-line/developer tools..."

# bash completion utils for git
download \
    https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash \
    git-completion.bash

# gcloud
if [[ ! -e ~/google-cloud-sdk ]]; then
  curl https://sdk.cloud.google.com | bash;
fi

# FZF
if [[ ! -e $DOT/download/.fzf ]]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git $DOT/download/.fzf
  $DOT/download/.fzf/install
fi

# diff-so-fancy
# TODO(2020-05-08): not sure if `sudo npm` here is right for all systems,
# tested on Serendipity
sudo npm install -g diff-so-fancy

# Chromium's depot_tools
if [[ ! -e ~/depot_tools ]]; then
  ( cd ~ && git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git );
fi

