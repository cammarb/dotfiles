#!/bin/sh

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
ohmyzsh_installer() {
 sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
}
echo -e "$info_msg: Installing ohmyzhs."
if ! [ -d "$HOME/.oh-my-zsh" ]; then
  if ! ohmyzsh_installer; then
    echo -e "$error_msg: Failed to install ohmyzsh."
    exit 1
  else
    echo -e "$info_msg: ohmyzsh already installed, skipping."
  fi
fi

# zsh-autosuggestions
zshautosuggestions_installer() {
  git clone https://github.com/zsh-users/zsh-autosuggestions "${zsh_custom:-$HOME/.oh-my-zsh/custom}"/plugins/zsh-autosuggestions
}
echo -e "$info_msg: Installing zsh-autosuggestions."
if ! [ -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
  if ! zshautosuggestions_installer; then
    echo -e "$error_msg: Failed to install zsh-autosuggestions."
    exit 1
  else
    echo -e "$info_msg: Already installed, skipping."
  fi
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

# sdkman 
sdkman_installer() {
  curl -s "https://get.sdkman.io" | bash
  source "$HOME/.sdkman/bin/sdkman-init.sh"
}
if ! sdkman_installer; then
  echo -e "$error_msg: Failed installing SDKMAN."
  exit 1
fi

echo -e "$success_msg: External packages installed successfully."

