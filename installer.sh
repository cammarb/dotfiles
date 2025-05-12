#!/bin/bash

# =============================================================================
# Script Name: installer.sh
# Description: This script installs software and my dotfiles for the specified
#              environment.
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

update_cmd() {
  sudo apt update -y && sudo apt upgrade -y
}

# Update and upgrade the system
echo -e "$info_msg: Updating packages."
echo -e "$warn_msg: You might have to enter your password to proceed."

if ! update_cmd; then
  echo -e "$error_msg: Update/Upgrade failed."
  exit 1
fi

# Packages Installers
source ./$CURRENT_DIR/packages.sh
source ./$CURRENT_DIR/external-packages.sh

# Stow
source ./$CURRENT_DIR/stow.sh

# Set zsh as default shell
echo -e "$info_msg: Changing default shell to zsh."

if ! chsh -s $(which zsh); then
  echo -e "$error_msg: Changing shell to zsh failed."
  exit 1
fi

zsh

echo -e "$info_msg: For all of your configuration to take effect you'll have to log out and log in again."

