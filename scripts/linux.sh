#!/usr/bin/env bash

distro=${1}

packages=(
  "stow"
  "git"
  "curl"
  "tree"
  "zsh"
  "ripgrep"
  "tmux"
  "wl-clipboard"
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

source ./packages_installer.sh "$distro"

install_packages packages

if [[ $distro == "arch" ]]; then
  echo -e "$info_msg: Installing arch specific packages."
  install_packages arch_specific_packages
fi

if [[ $distro == "fedora" ]]; then
  echo -e "$info_msg: Installing fedora specific packages."
  install_packages ubuntu_specific_packages
fi

if [[ $distro == "ubuntu" ]]; then
  echo -e "$info_msg: Installing ubuntu specific packages."
  install_packages ubuntu_specific_packages
fi
