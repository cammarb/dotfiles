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
  "zip"
  "unzip"
)

ubuntu_specific=(
  "git-credential-oauth"
  "build-essential"
  "libsecret-1-0"
  "libsecret-1-dev"
)

arch_specific=(
  "base-devel"
  "ghostty"
)

install_package() {
  echo -e "$info_msg: Installing $1."
  install_cmd "$1"
}

yay_installer(){
  git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si
  yay -Y --gendb
  yay -Syu --devel
  yay -Y --devel --save
}

git-credential-libsecret_setup(){
  sudo make /usr/share/doc/git/contrib/credential/libsecret/git-credential-libsecret
}

for package in "${packages[@]}"; do
  if ! install_package "$package"; then
    echo -e "$error_msg: Installation failed."
    exit 1
  fi
done

if [[ $distro == "ubuntu" ]]; then
  echo -e "$info_msg: Installing ubuntu specific packages."
  for package in "${ubuntu_specific[@]}"; do
    if ! install_cmd "$package"; then
      echo -e "$error_msg: Specific packages installation failed."
      exit 1
    fi
  done
  if ! git-credential-libsecret_setup; then
    echo -e "$error_msg: git-credential-libsecret setup failed."
    exit 1
  fi
fi

if [[ $distro == "arch" ]]; then
  echo -e "$info_msg: Installing arch specific packages."
  for package in "${arch_specific[@]}"; do
    if ! install_cmd "$package"; then
      echo -e "$error_msg: Specific packages installation failed."
      exit 1
    fi
  done
  echo -e "$info_msg: Installing yay."
  if ! yay_installer; then
      echo -e "$error_msg: yay installation failed."
      exit 1
  fi
fi

echo -e "$success_msg: Packages installed successfully."

echo -e "$info_msg: Installing external packages and plugins."

# neovim
echo -e "$info_msg: Installing neovim."

neovim_installer() {
  rm -rf nvim-linux-x86_64.tar.gz # Removing if the file exists already
  curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz

  if ! sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz; then
    echo -e "$error_msg: Failed to extract neovim"
    exit 1
  fi

  # Cleanup
  echo -e "$warn_msg: Removing nvim configuration."
  nvim_configuration_folder="$HOME/.config/nvim"
  if ! rm -rf nvim-linux-x86_64.tar.gz && rm -rf "$nvim_configuration_folder"; then
    echo -e "$error_msg: Failed removing nvim configuration."
    exit 1
  fi

  echo -e "$success_msg: neovim installation completed."
}

if ! [ -d /opt/nvim-linux-x86_64/ ]; then
  if ! neovim_installer; then
    echo -e "$error_msg: Failed to download neovim"
    exit 1
  fi
else 
  echo -e "info_msg: Neovim is already installed, skipping."
fi


# ohmyzsh
echo -e "$info_msg: Installing ohmyzhs."
echo -e "$warn_msg: Removing default .oh-my-zsh folder."

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

ohmyzsh_installer() {
 sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
}
if ! ohmyzsh_installer; then
  echo -e "$error_msg: Failed to install ohmyzsh."
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

# zsh-autosuggestions
echo -e "$info_msg: Installing zsh-autosuggestions."

zshautosuggestions_installer() {
  git clone https://github.com/zsh-users/zsh-autosuggestions "${zsh_custom:-$HOME/.oh-my-zsh/custom}"/plugins/zsh-autosuggestions
}
if ! zshautosuggestions_installer; then
  echo -e "$error_msg: Failed to install zsh-autosuggestions."
  exit 1
fi

# nvm
echo -e "$info_msg: Installing nvm (node version manager)."

nvm_installer() {
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
}
if ! nvm_installer; then
  echo -e "$error_msg: Failed to install nvm."
  exit 1
fi

nvm_init_cmd() {
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
}
if ! nvm_init_cmd; then
  echo -e "$error_msg: Failed to initialize nvm."
  exit 1
fi

echo -e "$info_msg: Installing LTS version of node.js."

if ! nvm install --lts; then
  echo -e "$error_msg: Failed installing LTS version of node.js."
  exit 1
fi
if ! npm -g install tree-sitter-cli; then # I need this for latex to work in neovim
  echo -e "$error_msg: Failed installing tree-sitter-cli."
  exit 1
fi

# sdkman (java, kotlin)
sdkman_installer() {
  curl -s "https://get.sdkman.io" | bash
}
if ! sdkman_installer; then
  echo -e "$error_msg: Failed installing SDKMAN."
  exit 1
fi

sdkman_init_cmd() {
  source "$HOME/.sdkman/bin/sdkman-init.sh"
}
if ! sdkman_init_cmd; then
  echo -e "$error_msg: Failed initializing SDKMAN."
  exit 1
fi

if ! sdk install java 21.0.2-open; then
  echo -e "$error_msg: Failed installing java sdks."
  exit 1
fi

if ! sdk install kotlin 2.1.0; then
  echo -e "$error_msg: Failed installing kotlin."
  exit 1
fi

if ! rm -f ~/.zshrc; then
  echo -e "$error_msg: Failed to remove auto-created .zshrc file."
  exit 1
fi

echo -e "$success_msg: External packages installed successfully."

echo -e "$info_msg: Running stow"

stow_dirs=(git nvim zsh oh-my-zsh)

for dir in "${stow_dirs[@]}"; do
  echo -e "$info_msg: Running stow for directory $dir"
  if ! stow -d "$SCRIPT_DIR" "$dir"; then
    echo -e "$error_msg: Stow operation for $dir failed."
    exit 1
  fi
done

# Set zsh as default shell
echo -e "$info_msg: Changing default shell to zsh."

if ! chsh -s $(which zsh); then
  echo -e "$error_msg: Changing shell to zsh failed."
  exit 1
fi

# Wallpapers
echo -e "$info_msg: Copying wallpapers"
if ! cp -pr "$SCRIPT_DIR/wallpapers" "$HOME/Pictures/"; then
  echo -e "$error_msg: Copying wallpaper folder failed."
  exit 1
fi

echo -e "$info_msg: For all of your configuration to take effect you'll have to log out and log in again."

