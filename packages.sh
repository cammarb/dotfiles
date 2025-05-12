#!/bin/sh

echo -e "$info_msg: Installing packages."

install_cmd() {
  sudo apt install -y "$1"
}

packages=(
  "stow"
  "git"
  "curl"
  "tree"
  "ripgrep"
  "tmux"
  "xclip"
  "zip"
  "unzip"
  "zsh"
  "build-essential"
)

install_package() {
  echo -e "$info_msg: Installing $1."
  install_cmd "$1"
}

for package in "${packages[@]}"; do
  if ! install_package "$package"; then
    echo -e "$error_msg: Installation failed."
    exit 1
  fi
done

