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

${LIGHT_RED}WARNING${ENDCOLOR}: You might have to enter your password to proceed.
EOF

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
  "zsh"
  "neovim"
  "tmux"
  "gh"
)

install_package(){
  echo -e "${BLUE}Installing $1...${ENDCOLOR}"
  sudo apt install -y $1
  check_exit_status "$1"
}

for package in "${packages[@]}"; do
  install_package "$package"
done

cat << EOF
${GREEN}
DONE:
Packages installed successfully.${ENDCOLOR}

EOF

echo "Installing External Packages and plugins..."

echo -e "${BLUE}Installing Oh-My-Zh..${ENDCOLOR}"
echo -e "${BLUE}Before installing Oh-My-Zsh, please press 'y' when prompted to set zsh as the default shell.${ENDCOLOR}"
echo -e "${BLUE}After installation, type 'exit' and press Enter to continue.${ENDCOLOR}"
read -p "Press Enter to continue..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

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
