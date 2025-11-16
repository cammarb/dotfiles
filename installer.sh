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
info_msg="${light_blue}INFO${endcolor}"
warn_msg="${yellow}WARNING${endcolor}"
error_msg="${red}ERROR${endcolor}"
success_msg="${green}SUCCESS${endcolor}"

# Banner
echo -e "${red}     _       _    __ _ _"
echo -e "${light_red}  __| | ___ | |_ / _(_) | ___  ___"
echo -e "${yellow} / _\` |/ _ \\| __| |_| | |/ _ \\/ __|"
echo -e "${green}| (_| | (_) | |_|  _| | |  __/\\__ \\"
echo -e "${blue} \\__,_|\\___/ \\__|_| |_|_|\\___||___/ ${endcolor}installer\n"
echo -e "@cammarb\n\n"

os=${1}

valid_os=(
  "arch"
  "fedora"
  "ubuntu"
  "macos"
)

echo -e "$info_msg: Installing packages."


install_cmd() {
  if [[ $os == "macos" ]]; then
    ./macos.sh "$os"
  else
    ./linux "$os"
  fi
}

echo -e "$info_msg: Running stow"

stow_dirs=(git nvim zsh ghostty)

for dir in "${stow_dirs[@]}"; do
  echo -e "$info_msg: Running stow for directory $dir."
  if ! stow "$dir"; then
    echo -e "$error_msg: Stow operation for $dir failed."
    exit 1
  fi
done

# Wallpapers
echo -e "$info_msg: Copying wallpapers"
if ! cp -pr /wallpapers ~/Pictures/; then
  echo -e "$error_msg: Copying wallpaper folder failed."
  exit 1
fi

echo -e "$info_msg: For all of your configuration to take effect you'll have to log out and log in again."
