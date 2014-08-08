#!/usr/bin/env bash
# Installer!

set -e;

function symlink() {
  if [[ $# -lt 2 ]]; then
    echo "Too few args to symlink";
    exit 1;
  fi;

  if [[ -e $2 ]]; then
    if [[ "$($READLINK -f "$1")" == "$($READLINK -f "$2")" ]]; then
      # The file already exists, and it's the same symlink.
      return;
    fi

    local prefixed_backup_location="$($DOT/bin/relpath $1)"
    local backup_location="$DOT/backups/${prefixed_backup_location#dotfiles/}";
    local printable_backup_location="~/$($DOT/bin/relpath ${backup_location})"

    echo "- $2 already exists. Replace with $1?";
    if $DOT/bin/prompt "- $2 will be backed up at ${printable_backup_location})"; then
      mkdir -p "$(dirname "${backup_location}")";
      mv "$2" "${backup_location}";
      # Fall through to symlinking.
    else
      return;
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


##############################################
# Installer start.

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

# 1) Test that dotfiles is in the expected location.
if [[ "$($READLINK -f "$(dirname "${BASH_SOURCE[0]}" )")" != "$($READLINK -f ~/dotfiles)" ]]; then
  echo "Dotfiles should be checked out to ~/dotfiles".
  exit 1;
fi

DOT="$($READLINK -f ~/dotfiles)";

# 2) Link standard alias files
symlink $DOT/shell/zshrc ~/.zshrc
symlink $DOT/shell/bashrc ~/.bashrc
symlink $DOT/shell/vimrc ~/.vimrc

# 3) Sublime Text alias: OS-specific
if [[ "$(uname -s)" == "Darwin" ]]; then
  symlink $DOT/sublime ~/Library/Application\ Support/Sublime\ Text\ 2/Packages/User
else
  symlink $DOT/sublime ~/.config/sublime-text-2/Packages/User
fi

# 4) Prompt for password and write it to $DOT/password.
# This is used to authenticate server-side tools.
# TODO

# 5) Download other libraries as needed.
download \
    https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash \
    git-completion.bash
