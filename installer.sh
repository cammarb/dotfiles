#!/bin/bash

# =============================================================================
# Script Name: installer.sh
# Description: This script installs software and my dotfiles for the specified
#              environment. 
#              The script accepts predefined values: 'ubuntu', 'fedora', 'arch' 
#              If no argument is provided or if the argument is invalid, it 
#              defaults to 'ubuntu'.
#
# Usage:
#   ./installer.sh [value]
#
# Arguments:
#   value   - A string representing the environment. Valid values are 
#             'ubuntu', 'fedora', 'arch'.
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
VALID_DISTROS=(
  "ubuntu"
  "fedora"
  "arch"
)

is_valid_distro() {
  local value="$1"
  for valid in "${VALID_DISTROS[@]}"; do
    if [[ "$value" == "$valid" ]]; then
      return 0
    fi
  done
  return 1
}

DISTRO="${1:-$DEFAULT_DISTRO}"

if ! is_valid_distro "$DISTRO"; then
  echo -e "${RED}Invalid distro provided."
  exit 1
elif [[ -z "$1" ]]; then
  DISTRO=$DEFAULT_DISTRO
  echo -e "${YELLOW}No distro provided. Using default: $DEFAULT_DISTRO${ENDCOLOR}"
  echo "Log: No distro provided. Defaulting to $DEFAULT_DISTRO." >> script.log
fi

echo -e "${GREEN}Using distro: $DISTRO${ENDCOLOR}"

is_graphical() {
  local value="$1"
  if [[ "$value" == "true" || "$value" == "false" ]]; then
    return 0
  fi
  return 1
}

GRAPHICS="${GRAPHICS:-false}"

if ! is_graphical "$GRAPHICS"; then
  echo -e "${RED}Invalid graphics value provided.${ENDCOLOR}"
  exit 1
elif [[ -z "$2" ]]; then
  echo -e "${YELLOW}No graphics value provided. Using default: $GRAPHICS${ENDCOLOR}"
else
  $GRAPHICS=true
  echo -e "${YELLOW}No graphics value provided. Using default: $GRAPHICS${ENDCOLOR}"
fi

if ! is_valid_distro "$DISTRO"; then
  echo -e "${RED}Invalid distro provided."
  exit 1
elif [[ -z "$1" ]]; then
  DISTRO=$DEFAULT_DISTRO
  echo -e "${YELLOW}No distro provided. Using default: $DEFAULT_DISTRO${ENDCOLOR}"
  echo "Log: No distro provided. Defaulting to $DEFAULT_DISTRO." >> script.log
fi

echo -e "Install with graphical apps: ${YELLOW}$GRAPHICS${ENDCOLOR}"

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

if [[ $DISTRO == "ubuntu" ]]; then
  sudo apt-get update -y
  if [ $? -ne 0 ]; then
      echo -e "${RED}Error: apt-get update failed.${ENDCOLOR}"
      exit 1
  fi

  sudo apt-get upgrade -y
  if [ $? -ne 0 ]; then
      echo -e "${RED}Error: apt-get upgrade failed.${ENDCOLOR}"
      exit 1
  fi
elif [[ $DISTRO == "fedora" ]]; then
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
  "tree"
  "build-essential"
  "zsh"
  "neovim"
  "ripgrep"
  "tmux"
)

graphical_packages=(
  "alacritty"
  "sway"
  "wmenu"
  "wl-clipboard"
)

if [[ $GRAPHICS == true ]]; then
  packages=("${packages[@]}" "${graphical_packages[@]}")
fi

install_package(){
  echo -e "${BLUE}Installing $1...${ENDCOLOR}"
  if [[ "$DISTRO" == "fedora" ]]; then
    sudo dnf install -y $1
  elif [["$DISTRO" == "arch"]]; then  
    sudo pacman -S -y $1
  else
    sudo apt-get install -y $1
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

echo -e "Removing default config files\n"
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
echo -e "${BLUE}Removing default .ohmyzsh folder"
OHMYZSH_FILE="$HOME/.oh-my-zsh"
if [ -f "$OHMYZSH_FILE" ]; then
  rm "$OHMYZSH_FILE"
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}.oh-my-zsh folder has been successfully deleted.${ENDCOLOR}"
  else
    echo -e "${RED}Failed to delete .oh-my-zsh folder.${ENDCOLOR}"
    exit 1
  fi
else
  echo -e "${BLUE}.oh-my-zsh folder does not exist.${ENDCOLOR}"
fi

echo "Installing External Packages and plugins..."

echo -e "${BLUE}Installing Oh-My-Zh..${ENDCOLOR}"
exit 0 | sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

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

echo -e "${GREEN}DONE${ENDCOLOR}: External packages installed successfully.\n"

echo -e "Running stow\n"

# Copy wallpaper image to corresponding directory.
# This wallpaper is set in the sway configuration,
# so if this is missing, sway will throw an error.
if [[ $GRAPHICS == true ]]; then
  mkdir -p ~/Pictures/wallpapers
  cp wallpapers/penguin_smiling.jpg -r ~/Pictures/wallpapers/

stow_dirs=("git" "nvim" "tmux" "zsh")
graphical_stow_dirs=("alacritty" "sway")

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

# Stow for graphical directories
if [[ $GRAPHICS == true ]]; then
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

# Set zsh as default shell
echo -e "${BLUE}Changing default shell to zsh:${ENDCOLOR}"
echo -e "You might need to enter your password to make these changes."
chsh -s $(which zsh)
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Changing shell to zsh failed.${ENDCOLOR}"
    exit 1
fi

echo -e "For all of your configuration to take effect you'll have to log out and log in again.\n"
