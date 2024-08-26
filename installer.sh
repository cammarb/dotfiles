#!/bin/bash

# Console colors
RED="\e[31m"
LIGHT_RED="\e[91m"
GREEN="\e[32m"
BLUE="\e[34m"
MAGENTA="\e[35m"
YELLOW="\e[33m"
ENDCOLOR="\e[0m"

check_exit_status(){
  if [ $? -ne 0 ]; then
        echo -e "${RED}Error: $1 failed to install.${ENDCOLOR}"
        exit 1
    fi
}

echo -e "${YELLOW}Starting Programs Installer...${ENDCOLOR}"

# Update and upgrade the system
cat << EOF
Updating package list...

EOF

echo -e "${LIGHT_RED}WARNING${ENDCOLOR}: You might have to enter your password to proceed."
echo ""
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

echo ""
echo "Installing Packages..."

packages=(
  "build-essential"
  "git"
  "curl"
  "stow"
  "zsh"
  "neovim"
  "tmux"
  "gh"
  "sway"
  "tofi"
)

install_package(){
  echo -e "${BLUE}Installing $1...${ENDCOLOR}"
  sudo apt install -y $1
  check_exit_status "$1"
}

for package in "${packages[@]}"; do
  install_package "$package"
done

echo -e "${GREEN}DONE: Packages installed successfully.${ENDCOLOR}"
echo -e ""

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

echo -e "${BLUE}Changing default shell to zsh...${ENDCOLOR}"
echo -e "You might need to enter your password to make these changes."
read -p "Press Enter to continue..."
chsh -s $(which zsh)
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Changing shell to zsh failed.${ENDCOLOR}"
    exit 1
fi

echo -e "${GREEN}DONE:External packages installed successfully.${ENDCOLOR}"
echo ""

echo -e "${BLUE}Initializing stow for every folder in the current directory...${ENDCOLOR}"
for dir in */ ; do
  if [ -d "$dir" ]; then
    dir=${dir%/}
    echo -e "${BLUE}Running stow for directory: $dir${ENDCOLOR}"
    stow "$dir"
  fi
done
echo -e "${GREEN}Stow initialization complete for all directories.${ENDCOLOR}"

echo -e "For all of your configuration to take effect you'll have to log out and log in again."
read -p "Press Enter to finish..."
