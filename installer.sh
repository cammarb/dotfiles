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
yellow="\e[33m"
endcolor="\e[0m"

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
    echo -e "$error_msg: $1 failed to install."
    exit 1
  fi
}

# Update and upgrade the system
cat <<EOF
Updating package list...
EOF

echo -e "${light_red}WARNING${endcolor}: You might have to enter your password to proceed."

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

echo ""
echo "Installing Packages..."

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
  echo -e "${blue}Installing $1...${endcolor}"
  if [[ $distro == "arch" ]]; then
    sudo pacman -S -y "$1"
  else
    sudo apt install -y "$1"
  fi
}

for package in "${packages[@]}"; do
  if ! install_package "$package"; then
    echo -e "$error_msg: installation failed."
    exit 1
  fi
done

echo -e "installing ubuntu specific packages"
if [[ $distro == "ubuntu" ]]; then
  for package in "${ubuntu_specific[@]}"; do
    if ! sudo apt install -y "$package"; then
      echo -e "$error_msg: specific packages installation failed."
      exit 1
    fi
  done
fi

echo -e "installing arch specific packages"
if [[ $distro == "arch" ]]; then
  for package in "${arch_specific[@]}"; do
    if ! sudo pacman -s -y "$package"; then
      echo -e "$error_msg: specific packages installation failed."
      exit 1
    fi
  done
fi

echo -e "$success_msg: packages installed successfully.\n"

echo -e "removing default config files\n"

echo -e "${blue}removing default .oh-my-zsh folder"
ohmyzsh_folder="$home/.oh-my-zsh"
if [ -d "$ohmyzsh_folder" ]; then
  if ! rm -rf "$ohmyzsh_folder"; then
    echo -e "$error_msg: failed to delete .oh-my-zsh folder."
    exit 1
  else
    echo -e "$success_msg: .oh-my-zsh folder has been deleted successfully."
  fi
else
  echo -e ".oh-my-zsh folder does not exist."
  echo -e "continue"
fi

echo "installing external packages and plugins..."

if [[ $distro == "ubuntu" ]]; then
  echo -e "${blue}installing neovim...${endcolor}"
  if ! curl -lo https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz; then
    echo -e "$error_msg: failed to download neovim"
  fi

  sudo rm -rf /opt/nvim

  if ! sudo tar -c /opt -xzf nvim-linux64.tar.gz; then
    echo -e "$error_msg: failed to extract neovim"
  fi
  rm -rf nvim-linux64.tar.gz

  echo -e "$success_msg: neovim installation completed."
fi

echo -e "${blue}installing oh-my-zh..${endcolor}"
exit 0 | sh -c "$(curl -fssl https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo -e "${blue}installing zsh-autosuggestions..."
if ! git clone https://github.com/zsh-users/zsh-autosuggestions "${zsh_custom:-~/.oh-my-zsh/custom}"/plugins/zsh-autosuggestions; then
  echo -e "$error_msg: installing zsh-autosuggestions failed."
  exit 1
fi

echo -e "${blue}installing nvm (node version manager)...${endcolor}"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
if [ $? -ne 0 ]; then
  echo -e "$error_msg: nvm installation failed."
  exit 1
fi

nvm_init_cmd=$(
  cat <<eof
export nvm_dir="$([ -z "${xdg_config_home-}" ] && printf %s "${home}/.nvm" || printf %s "${xdg_config_home}/nvm")"
[ -s "$nvm_dir/nvm.sh" ] && \. "$nvm_dir/nvm.sh" # this loads nvm
eof
)

if ! nvm_init_cmd; then
  echo -e "$error_msg: adding nvm to .zshrc failed."
  exit 1
fi

echo -e "${blue}installing lts version of node.js...${endcolor}"

if ! nvm install --lts; then
  echo -e "$error_msg: installing node.js failed."
  exit 1
fi

echo -e "$success_msg: external packages installed successfully.\n"

echo -e "running stow\n"

stow_dirs=("nvim" "tmux" "zsh")

echo "remove nvim configuration"
rm -rf "$home"/.config/nvim

echo -e "${blue}removing default .zshrc file"
ZSHRC_FILE="$home/.zshrc"
if [ -f "$ZSHRC_FILE" ]; then
  if rm "$ZSHRC_FILE"; then
    echo -e "$success_msg: .zshrc file has been successfully deleted."
  else
    echo -e "$error_msg: failed to delete .zshrc file."
    exit 1
  fi
else
  echo -e ".zshrc file does not exist. Skipping."
fi

for dir in "${stow_dirs[@]}"; do
  if [ -d "$dir" ]; then
    echo -e "${blue}Running stow for directory: $dir${endcolor}"
    stow "$dir"
    if [ $? -ne 0 ]; then
      echo -e "$error_msg: stow operation for $dir failed."
      exit 1
    fi
  else
    echo -e "$error_msg: directory $dir does not exist."
  fi
done

# Set zsh as default shell
echo -e "${blue}Changing default shell to zsh:${endcolor}"
echo -e "You might need to enter your password to make these changes."

if chsh -s "$(which zsh)"; then
  echo -e "$error_msg: Changing shell to zsh failed."
  exit 1
fi

echo -e "For all of your configuration to take effect you'll have to log out and log in again.\n"
