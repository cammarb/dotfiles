#!/bin/sh

echo -e "$info_msg: Installing packages."

packages=(
  "stow"
  "git"
  "curl"
  "tree"
  "ripgrep"
  "tmux"
  "xclip"
  "wl-clipboard"
  "zip"
  "unzip"
  "zsh"
)

ubuntu_specific=(
  "build-essential"
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
 sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
}
if ! ohmyzsh_installer; then
  echo -e "$error_msg: Failed to install ohmyzsh."
  exit 1
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
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
  # Load nvm immediately so the script can use it
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
}
if ! nvm_installer; then
  echo -e "$error_msg: Failed to install nvm."
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
  source "$HOME/.sdkman/bin/sdkman-init.sh"
}
if ! sdkman_installer; then
  echo -e "$error_msg: Failed installing SDKMAN."
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

echo -e "$success_msg: External packages installed successfully."