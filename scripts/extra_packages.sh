#!/usr/bin/env bash

# Neovim (LINUX ONLY)
neovim_installer() {
  echo -e "$INFO_MSG: Installing neovim."
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
    echo -e "$ERROR_MSG: Failed to install neovim"
    exit 1
  fi
  echo -e "$SUCCESS_MSG: neovim installation completed."
fi

# ohmyzsh
ohmyzsh_cleanup(){
  echo -e "$WARN_MSG: Cleaning up existing .oh-my-zsh folder."
  ohmyzsh_folder="$HOME/.oh-my-zsh"
  if [ -d "$ohmyzsh_folder" ]; then
    if ! rm -rf "$ohmyzsh_folder"; then
      echo -e "$ERROR_MSG: Failed to delete .oh-my-zsh folder."
      exit 1
    else
      echo -e "$SUCCESS_MSG: .oh-my-zsh folder deleted."
    fi
  else
    echo -e ".oh-my-zsh folder does not exist. Continue."
  fi
}
ohmyzsh_installer() {
  ohmyzsh_cleanup
  echo -e "$INFO_MSG: Installing ohmyzhs."
  echo "n" | sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}
if ! ohmyzsh_installer; then
  echo -e "$ERROR_MSG: Failed to install ohmyzsh."
  exit 1
fi
echo -e "$SUCCESS_MSG: ohmyzsh installation completed."
echo -e "$WARN_MSG: Removing default .zshrc file."

# zsh-autosuggestions
zshautosuggestions_installer() {
  echo -e "$INFO_MSG: Installing zsh-autosuggestions."
  git clone https://github.com/zsh-users/zsh-autosuggestions "${zsh_custom:-$HOME/.oh-my-zsh/custom}"/plugins/zsh-autosuggestions
}
if ! zshautosuggestions_installer; then
  echo -e "$ERROR_MSG: Failed to install zsh-autosuggestions."
  exit 1
fi

# nvm
nvm_installer() {
  echo -e "$INFO_MSG: Installing nvm (node version manager)."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
}
if ! nvm_installer; then
  echo -e "$ERROR_MSG: Failed to install nvm."
  exit 1
fi

# sdkman (java, kotlin)
sdkman_installer() {
  curl -s "https://get.sdkman.io" | bash
}
if ! sdkman_installer; then
  echo -e "$ERROR_MSG: Failed installing SDKMAN."
  exit 1
fi

remove_zshrc_file(){
  zshrc_file="$HOME/.zshrc"
  if [ -f "$zshrc_file" ]; then
    if rm "$zshrc_file"; then
      echo -e "$SUCCESS_MSG: .zshrc file has been successfully deleted."
    else
      echo -e "$ERROR_MSG: Failed to delete .zshrc file."
      exit 1
    fi
  else
    echo -e ".zshrc file does not exist. Skipping."
  fi
}
if ! remove_zshrc_file; then
  echo -e "$ERROR_MSG: Failed to remove auto-created .zshrc file."
  exit 1
fi

echo -e "$SUCCESS_MSG: Extra packages installed successfully."
