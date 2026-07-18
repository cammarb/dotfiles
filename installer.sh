#!/usr/bin/env bash

# =============================================================================
# Script Name: installer.sh
# Description: This script installs software and my dotfiles for the specified
#              environment.
#              The script accepts predefined values:
#              'arch', 'fedora', 'ubuntu', 'macos'.
#              If no argument is provided or if the argument is invalid, 
#              the script won't run.
#
# Usage:
#   ./installer.sh [value]
#
# Arguments:
#   value   - A string representing the environment. Valid values are
#             'arch', 'fedora', 'ubuntu', 'macos'.
#
# Example:
#   ./installer.sh ubuntu
# =============================================================================

# Console colors
red="\e[31m"
light_red="\e[91m"
green="\e[32m"
blue="\e[34m"
light_blue="\e[94m"
yellow="\e[33m"
endcolor="\e[0m"

# Log messages
INFO_MSG="${light_blue}INFO${endcolor}"
readonly WARN_MESSAGE="${yellow}WARNING${endcolor}"
readonly ERROR_MSG="${red}ERROR${endcolor}"
readonly SUCCESS_MSG="${green}SUCCESS${endcolor}"

# Banner
echo -e "${red}     _       _    __ _ _"
echo -e "${light_red}  __| | ___ | |_ / _(_) | ___  ___"
echo -e "${yellow} / _\` |/ _ \\| __| |_| | |/ _ \\/ __|"
echo -e "${green}| (_| | (_) | |_|  _| | |  __/\\__ \\"
echo -e "${blue} \\__,_|\\___/ \\__|_| |_|_|\\___||___/ ${endcolor}installer\n"
echo -e "@cammarb\n\n"

readonly OS=${1}
echo "OS: $OS"

echo -e "$INFO_MSG: Installing packages."

install_cmd() {
  if [[ $OS == "macos" ]]; then
    source ./scripts/macos.sh 
  else
    source ./scripts/linux.sh
  fi
}

install_cmd


echo -e "$INFO_MSG: Installing extra packages."

echo -e "$INFO_MSG: Running stow"

stow_dirs=(git zsh dot-config)
rm ~/.gitconfig
rm ~/.zshrc
rm -rf ~/.config/ghostty
rm -rf ~/.config/nvim

for dir in "${stow_dirs[@]}"; do
  echo -e "$INFO_MSG: Running stow for directory $dir."
  if [[ "$dir" == "dot-config" ]]; then
	  stow "$dir" -t $HOME/.config
  else
	stow --dotfiles "$dir" -t $HOME
  fi
  if ! stow "$dir"; then
    echo -e "$ERROR_MSG: Stow operation for $dir failed."
    exit 1
  fi
done

# Wallpapers
echo -e "$INFO_MSG: Copying wallpapers"
if ! cp -pr wallpapers ~/Pictures/; then
  echo -e "$ERROR_MSG: Copying wallpaper folder failed."
  exit 1
fi

echo -e "$INFO_MSG: For all of your configuration to take effect you'll have to log out and log in again."
