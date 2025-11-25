#!/usr/bin/env bash

if [[ $OS == "arch" ]]; then
  INSTALL_CMD=(sudo pacman -S --noconfirm)
elif [[ $OS == "fedora" ]]; then
  INSTALL_CMD=(sudo dnf install -y)
elif [[ $OS == "ubuntu" ]]; then
  INSTALL_CMD=(sudo apt install -y)
elif [[ $OS == "macos" ]]; then
  INSTALL_CMD=(brew install)
fi

install_package() {
  echo -e "$INFO_MSG: Installing $1."
  "${INSTALL_CMD[@]}" "$1"
}

install_packages(){
  local packages=("$@")

  for package in "${packages[@]}"; do
    if ! install_package "$package"; then
      echo -e "$ERROR_MSG: Installation failed."
      exit 1
    fi
  done
}
