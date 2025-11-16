#!/usr/bin/env bash

os=${1}

install_command() {
  if [[ $os == "arch" ]]; then
    sudo pacman -S --noconfirm "$1"
  elif [[ $os == "fedora" ]]; then
    sudo dnf install -y "$1"
  elif [[ $os == "ubuntu" ]]; then
    sudo apt install -y "$1"
  elif [[ $os == "macos" ]]; then
    brew install "$1"
  fi
}

install_package() {
  echo -e "$info_msg: Installing $1."
  install_command "$1"
}

install_packages(){
  local packages_array="$1"
  local packages=("${!packages_array}")

  for package in "${packages[@]}"; do
    if ! install_package "$package"; then
      echo -e "$error_msg: Installation failed."
      exit 1
    fi
  done
}
