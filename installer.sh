#!/bin/bash

# =============================================================================
# Script Name: installer.sh
# Description: This script installs software and my dotfiles for the specified
#              environment.
#              The script accepts predefined values: 'ubuntu', 'arch'
#              If no argument is provided or if the argument is invalid, it
#              the script won't run.
#
# Usage:
#   ./installer.sh [value]
#
# Arguments:
#   value   - A string representing the environment. Valid values are
#             'ubuntu', 'arch'.
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

# Setup installer for a specific distro
valid_distro=(
  "ubuntu"
  "arch"
)

distro=${1}

is_valid_distro() {
  local value="$1"
  if [ -z "$value" ]; then
    return 1
  fi
  for valid in "${valid_distro[@]}"; do
    if [[ "$value" == "$valid" ]]; then
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

check_exit_status() {
  if [ $? -ne 0 ]; then
    echo -e "$error_msg: $1 Failed to install."
    exit 1
  fi
}

# Update and upgrade the system
echo -e "$info_msg: Updating package list."
echo -e "$warn_msg: You might have to enter your password to proceed."

if [[ $distro == "ubuntu" ]]; then
  if ! sudo apt update -y && sudo apt upgrade; then
    echo -e "$error_msg: apt-get update failed."
    exit 1
  fi
elif [[ $distro == "arch" ]]; then
  if ! sudo pacman -Syyu -y; then
    echo -e "$error_msg: pacman update/upgrade failed."
    exit 1
  fi
fi

echo -e "$info_msg: Installing packages."

packages=(
  "stow"
  "git"
  "curl"
  "tree"
  "zsh"
  "ripgrep"
  "tmux"
  "xclip"
  "wl-clipboard"
)

ubuntu_specific=(
  "build-essential"
)

arch_specific=(
  "base-devel"
  "neovim"
  "ghostty"
)

install_package() {
  echo -e "$info_msg: Installing $1."
  if [[ $distro == "arch" ]]; then
    sudo pacman -S -y "$1"
  else
    sudo apt install -y "$1"
  fi
}

for package in "${packages[@]}"; do
  if ! install_package "$package"; then
    echo -e "$error_msg: Installation failed."
    exit 1
  fi
done

echo -e "$info_msg: Installing ubuntu specific packages."
if [[ $distro == "ubuntu" ]]; then
  for package in "${ubuntu_specific[@]}"; do
    if ! sudo apt install -y "$package"; then
      echo -e "$error_msg: Specific packages installation failed."
      exit 1
    fi
  done
fi

echo -e "$info_msg: Installing arch specific packages."
if [[ $distro == "arch" ]]; then
  for package in "${arch_specific[@]}"; do
    if ! sudo pacman -s -y "$package"; then
      echo -e "$error_msg: Specific packages installation failed."
      exit 1
    fi
  done
fi

echo -e "$success_msg: Packages installed successfully."

echo -e "$warn_msg: Removing existing config files."

echo -e "$info_msg: Removing default .oh-my-zsh folder"
ohmyzsh_folder="$HOME/.oh-my-zsh"
if [ -d "$ohmyzsh_folder" ]; then
  if ! rm -rf "$ohmyzsh_folder"; then
    echo -e "$error_msg: Failed to delete .oh-my-zsh folder."
    exit 1
  else
    echo -e "$success_msg: .oh-my-zsh folder deleted."
  fi
else
  echo -e ".oh-my-zsh folder does not exist. Continue."
fi

echo -e "$info_msg: Installing external packages and plugins."

if [[ $distro == "ubuntu" ]]; then
  echo -e "$info_msg: Installing neovim."
  neovim_installer(){
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
  }
  if ! neovim_installer; then
    echo -e "$error_msg: Failed to download neovim"
    exit 1
  fi

  sudo rm -rf /opt/nvim

  if ! sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz; then
    echo -e "$error_msg: Failed to extract neovim"
    exit 1
  fi
  rm -rf nvim-linux-x86_64.tar.gz

  echo -e "$success_msg: neovim installation completed."
fi

echo -e "$info_msg: Installing ohmyzhs."
ohmyzsh_installer(){
  echo "n" | sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}
if ! ohmyzsh_installer; then
  echo -e "$error_msg: Failed to download ohmyzsh."
  exit 1
fi

echo -e "$info_msg: Installing zsh-autosuggestions."
zshautosuggestions_installer(){
  git clone https://github.com/zsh-users/zsh-autosuggestions "${zsh_custom:-$HOME/.oh-my-zsh/custom}"/plugins/zsh-autosuggestions
}
if ! zshautosuggestions_installer; then
  echo -e "$error_msg: Failed to install zsh-autosuggestions."
  exit 1
fi

echo -e "$info_msg: Installing nvm (node version manager)."
nvm_installer(){
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
}
if ! nvm_installer; then
  echo -e "$error_msg: Failed to install nvm."
  exit 1
fi

nvm_init_cmd=$(
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
)

if ! "$nvm_init_cmd"; then
  echo -e "$error_msg: Failed to initialize nvm."
  exit 1
fi

echo -e "$info_msg: Installing LTS version of node.js."

if ! nvm install --lts; then
  echo -e "$error_msg: Failed installing LTS version of node.js."
  exit 1
fi

echo -e "$success_msg: External packages installed successfully."

echo -e "$info_msg: Running stow"

stow_dirs=("nvim" "tmux" "zsh")

echo -e "$warn_msg: Removing nvim configuration."
nvim_configuration_folder="$HOME/.config/nvim"
if ! rm -rf "$nvim_configuration_folder"; then
  echo -e "$error_msg: Failed removing nvim configuration."
  exit 1
fi

echo -e "$warn_msg: Removing default .zshrc file."
zshrc_file="$HOME/.zshrc"
if [ -f "$zshrc_file" ]; then
  if rm "$zshrc_file"; then
    echo -e "$success_msg: .zshrc file has been successfully deleted."
  else
    echo -e "$error_msg: Failed to delete .zshrc file."
    exit 1
  fi
else
  echo -e ".zshrc file does not exist. Skipping."
fi

for dir in "${stow_dirs[@]}"; do
  if [ -d "$dir" ]; then
    echo -e "$info_msg: Running stow for directory $dir."
    stow "$dir"
    if [ $? -ne 0 ]; then
      echo -e "$error_msg: Stow operation for $dir failed."
      exit 1
    fi
  else
    echo -e "$error_msg: Directory $dir does not exist."
  fi
done

# Set zsh as default shell
echo -e "$info_msg: Changing default shell to zsh."
echo -e "$warn_msg: You might need to enter your password to make these changes."

if ! chsh -s "$(which zsh)"; then
  echo -e "$error_msg: Changing shell to zsh failed."
  exit 1
fi

echo -e "For all of your configuration to take effect you'll have to log out and log in again.\n"
