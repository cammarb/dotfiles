#!/bin/bash

# =============================================================================
# Script Name: installer.sh
# Description: This script installs software and my dotfiles for the specified
#              environment.
#              The script accepts predefined values: 'arch', 'ubuntu'.
#              If no argument is provided or if the argument is invalid, it
#              the script won't run.
#
# Usage:
#   ./installer.sh [value]
#
# Arguments:
#   value   - A string representing the environment. Valid values are
#             'arch', 'ubuntu'.
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


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Running on $SCRIPT_DIR"

distro=${1}

valid_distro=(
  "arch"
  "ubuntu"
)

install_cmd() {
  if [[ $distro == "arch" ]]; then
    sudo pacman -S --noconfirm "$1"
  elif [[ $distro == "ubuntu" ]]; then
    sudo apt install -y "$1"
  fi
}

update_cmd() {
  if [[ $distro == "arch" ]]; then
    sudo pacman -Syyu
  elif [[ $distro == "ubuntu" ]]; then
    sudo apt update -y && sudo apt upgrade -y
  fi
}

is_valid_distro() {
  local this_distro="$1"
  if [ -z "$this_distro" ]; then
    return 1
  fi
  for distro in "${valid_distro[@]}"; do
    if [[ "$this_distro" == "$distro" ]]; then
      return 0
    fi
  done
  return 1
}

if ! is_valid_distro "$distro"; then
  echo -e "$error_msg: Missing or invalid distro provided. Exiting."
  exit 1
fi

echo -e "$success_msg: Using distro $distro"

# Update and upgrade the system
echo -e "$info_msg: Updating package list."
echo -e "$warn_msg: You might have to enter your password to proceed."

if ! update_cmd; then
  echo -e "$error_msg: Update/Upgrade failed."
  exit 1
fi

# Packages Installer
source ./$CURRENT_DIR/scripts/packages.sh

# Stow
source ./$CURRENT_DIR/scripts/stow.sh

# Set zsh as default shell
echo -e "$info_msg: Changing default shell to zsh."

if ! chsh -s $(which zsh); then
  echo -e "$error_msg: Changing shell to zsh failed."
  exit 1
fi

# Wallpapers
# if "$include_wallpapers"; then
#   echo -e "$info_msg: Copying wallpapers"
#   if ! cp -pr "$SCRIPT_DIR/wallpapers" "$HOME/Pictures/"; then
#     echo -e "$error_msg: Copying wallpaper folder failed."
#     exit 1
#   fi
# fi 

echo -e "$info_msg: For all of your configuration to take effect you'll have to log out and log in again."

