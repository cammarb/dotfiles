#!/bin/bash

# =============================================================================
# Script Name: installer.sh
# Description: This script installs software and my dotfiles for the specified
#              environment. 
#              The script accepts predefined values: 'ubuntu', 'fedora', and 
#              'wsl2'. 
#              If no argument is provided or if the argument is invalid, it 
#              defaults to 'ubuntu'.
#
# Usage:
#   ./installer.sh [value]
#
# Arguments:
#   value   - A string representing the environment. Valid values are 
#             'ubuntu', 'fedora', and 'wsl2'.
#
# Example:
#   ./installer.sh fedora
# =============================================================================


# Console colors
RED="\e[31m"
LIGHT_RED="\e[91m"
GREEN="\e[32m"
BLUE="\e[34m"
MAGENTA="\e[35m"
YELLOW="\e[33m"
ENDCOLOR="\e[0m"

# Banner
echo -e "${RED}     _       _    __ _ _"
echo -e "${LIGHT_RED}  __| | ___ | |_ / _(_) | ___  ___"
echo -e "${YELLOW} / _\` |/ _ \\| __| |_| | |/ _ \\/ __|"
echo -e "${GREEN}| (_| | (_) | |_|  _| | |  __/\\__ \\"
echo -e "${BLUE} \\__,_|\\___/ \\__|_| |_|_|\\___||___/ ${ENDCOLOR}installer\n"
echo -e "@cammarb\n\n"

# Setup installer for a specific distro
DEFAULT_DISTRO="ubuntu"
VALID_VALUES=("ubuntu" "fedora" "wsl2")

is_valid_value() {
  local value="$1"
  for valid in "${VALID_VALUES[@]}"; do
    if [[ "$value" == "$valid" ]]; then
      return 0
    fi
  done
  return 1
}

DISTRO="${1:-$DEFAULT_VALUE}"

if ! is_valid_value "$DISTRO"; then
  echo -e "${RED}Invalid distro provided. Using default: $DEFAULT_VALUE${ENDCOLOR}"
  DISTRO="$DEFAULT_VALUE"
fi

echo -e "${GREEN}Using distro: $DISTRO${ENDCOLOR}"


check_exit_status(){
  if [ $? -ne 0 ]; then
        echo -e "${RED}Error: $1 failed to install.${ENDCOLOR}"
        exit 1
    fi
}

# Update and upgrade the system
cat << EOF
Updating package list...
EOF

echo -e "${LIGHT_RED}WARNING${ENDCOLOR}: You might have to enter your password to proceed."

if [[ "$DISTRO" == "ubuntu" || "$DISTRO" == "wsl2" ]]; then
  sudo apt update -y
  if [ $? -ne 0 ]; then
      echo -e "${RED}Error: apt update failed.${ENDCOLOR}"
      exit 1
  fi

  sudo apt upgrade -y
  if [ $? -ne 0 ]; then
      echo -e "${RED}Error: apt upgrade failed.${ENDCOLOR}"
      exit 1
  fi
elif [[ "$DISTRO" == "fedora" ]]; then
  sudo dnf update -y
  if [ $? -ne 0 ]; then
      echo -e "${RED}Error: dnf update failed.${ENDCOLOR}"
      exit 1
  fi

  sudo dnf upgrade -y
  if [ $? -ne 0 ]; then
      echo -e "${RED}Error: dnf upgrade failed.${ENDCOLOR}"
      exit 1
  fi
fi

echo ""
echo "Installing Packages..."

packages=(
  "stow"
  "git"
  "curl"
  "build-essential"
  "zsh"
  "neovim"
  "ripgrep"
  "tmux"
  "gh"
)

graphical_packages=(
  "alacritty"
  "sway"
  "tofi"
)

if [[ "$DISTRO" == "ubuntu" || "$DISTRO" == "fedora" ]]; then
  packages=("${packages[@]}" "${graphical_packages[@]}")
elif [[ "$DISTRO" == "wsl2" ]]; then
  packages=("${packages[@]}")
fi

install_package(){
  echo -e "${BLUE}Installing $1...${ENDCOLOR}"
  if [[ "$DISTRO" == "fedora" ]]; then
    sudo dnf install -y $1
  else
    sudo apt install -y $1
  fi
  if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Installation of $1 failed.${ENDCOLOR}"
    exit 1
  fi
}

for package in "${packages[@]}"; do
  install_package "$package"
done

echo -e "${GREEN}DONE: Packages installed successfully.${ENDCOLOR}\n"

echo "Installing External Packages and plugins..."

echo -e "${BLUE}Installing Oh-My-Zh..${ENDCOLOR}"
exit 0 | sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
echo -e "${BLUE}Removing default .zshrc file"
ZSHRC_FILE="$HOME/.zshrc"
if [ -f "$ZSHRC_FILE" ]; then
  rm "$ZSHRC_FILE"
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}.zshrc file has been successfully deleted.${ENDCOLOR}"
  else
    echo -e "${RED}Failed to delete .zshrc file.${ENDCOLOR}"
    exit 1
  fi
else
  echo -e "${BLUE}.zshrc file does not exist.${ENDCOLOR}"
fi

echo -e "${BLUE}Installing zsh-autosuggestions..."
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Installing zsh-autosuggestions failed.${ENDCOLOR}"
    exit 1
fi

echo -e "${BLUE}Installing nvm (Node Version Manager)...${ENDCOLOR}"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: nvm installation failed.${ENDCOLOR}"
    exit 1
fi

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Adding nvm to .zshrc failed.${ENDCOLOR}"
    exit 1
fi

echo -e "${BLUE}Installing LTS version of Node.JS...${ENDCOLOR}"
nvm install --lts
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Installing Node.JS failed.${ENDCOLOR}"
    exit 1
fi

echo -e "${BLUE}Changing default shell to zsh:${ENDCOLOR}"
echo -e "You might need to enter your password to make these changes."
read -p "Press Enter to continue..."
chsh -s $(which zsh)
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Changing shell to zsh failed.${ENDCOLOR}"
    exit 1
fi

echo -e "${GREEN}DONE${ENDCOLOR}: External packages installed successfully.\n"


stow_dirs=("git" "nvim" "tmux" "zsh")
graphical_stow_dirs=("alacritty" "sway" "tofi")

for dir in "${stow_dirs[@]}"; do
  if [ -d "$dir" ]; then
    echo -e "${BLUE}Running stow for directory: $dir${ENDCOLOR}"
    stow "$dir"
    if [ $? -ne 0 ]; then
      echo -e "${RED}Error: stow operation for $dir failed.${ENDCOLOR}"
      exit 1
    fi
  else
    echo -e "${RED}Directory $dir does not exist.${ENDCOLOR}"
  fi
done

# If the distro is Ubuntu or Fedora, apply stow for graphical directories
if [[ "$DISTRO" == "ubuntu" || "$DISTRO" == "fedora" ]]; then
  for dir in "${graphical_stow_dirs[@]}"; do
    if [ -d "$dir" ]; then
      echo -e "${BLUE}Running stow for graphical directory: $dir${ENDCOLOR}"
      stow "$dir"
      if [ $? -ne 0 ]; then
        echo -e "${RED}Error: stow operation for $dir failed.${ENDCOLOR}"
        exit 1
      fi
    else
      echo -e "${RED}Graphical directory $dir does not exist.${ENDCOLOR}"
    fi
  done
fi
echo -e "${GREEN}Stow initialization complete.${ENDCOLOR}"

echo -e "For all of your configuration to take effect you'll have to log out and log in again."
read -p "Press Enter to finish..."
