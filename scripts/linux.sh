#!/usr/bin/env bash

packages=(
  "stow"
  "git"
  "curl"
  "tree"
  "zsh"
  "ripgrep"
  "tmux"
  "xclip"
  "zip"
  "unzip"
)

ubuntu_specific_packages=(
  "build-essential"
)

arch_specific_packages=(
  "base-devel"
  "ghostty"
)

fedora_specific_packages=(
  "@development-tools"
)

source ./scripts/packages_installer.sh

install_packages "${packages[@]}"

if [[ $OS == "arch" ]]; then
  echo -e "$INFO_MSG: Installing arch specific packages."
  install_packages "${arch_specific_packages[@]}"
fi

if [[ $OS == "fedora" ]]; then
  echo -e "$INFO_MSG: Installing fedora specific packages."
  install_packages "${fedora_specific_packages[@]}"
fi

if [[ $OS == "ubuntu" ]]; then
  echo -e "$INFO_MSG: Installing ubuntu specific packages."
  install_packages "${ubuntu_specific_packages[@]}"
fi
