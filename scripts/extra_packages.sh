#!/usr/bin/env bash

# Neovim (LINUX ONLY)
neovim_installer() {
  echo -e "$info_msg: Installing neovim."
  rm -rf nvim-linux-x86_64.tar.gz # Removing if the file exists already
  curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
  sudo rm -rf /opt/nvim
  sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz

  neovim_cleanup
}
neovim_cleanup(){
  rm -rf nvim-linux-x86_64.tar.gz
  echo -e "$warn_msg: Removing nvim configuration."
  nvim_configuration_folder="$HOME/.config/nvim"
  rm -rf "$nvim_configuration_folder"
}
if [[ $os != "macos" ]]; then
  if ! neovim_installer; then
    echo -e "$error_msg: Failed to install neovim"
    exit 1
  fi
  echo -e "$success_msg: neovim installation completed."
fi

# ohmyzsh
ohmyzsh_cleanup(){
  echo -e "$warn_msg: Cleaning up existing .oh-my-zsh folder."
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
}
ohmyzsh_installer() {
  ohmyzsh_cleanup
  echo -e "$info_msg: Installing ohmyzhs."
  echo "n" | sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}
if ! ohmyzsh_installer; then
  echo -e "$error_msg: Failed to install ohmyzsh."
  exit 1
fi
echo -e "$success_msg: ohmyzsh installation completed."
echo -e "$warn_msg: Removing default .zshrc file."

# zsh-autosuggestions
zshautosuggestions_installer() {
  echo -e "$info_msg: Installing zsh-autosuggestions."
  git clone https://github.com/zsh-users/zsh-autosuggestions "${zsh_custom:-$HOME/.oh-my-zsh/custom}"/plugins/zsh-autosuggestions
}
if ! zshautosuggestions_installer; then
  echo -e "$error_msg: Failed to install zsh-autosuggestions."
  exit 1
fi

# nvm
nvm_installer() {
  echo -e "$info_msg: Installing nvm (node version manager)."
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

# sdkman (java, kotlin)
sdkman_installer() {
  curl -s "https://get.sdkman.io" | bash
}
if ! sdkman_installer; then
  echo -e "$error_msg: Failed installing SDKMAN."
  exit 1
fi

remove_zshrc_file(){
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
}
if ! remove_zshrc_file; then
  echo -e "$error_msg: Failed to remove auto-created .zshrc file."
  exit 1
fi

echo -e "$success_msg: Extra packages installed successfully."
