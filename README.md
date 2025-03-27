# Dotfiles

This repository contains my configuration files for various tools and programs, managed using GNU Stow.
It also contains a script to install all the necessary tools and programs for development on a new Linux environment.

Currently the installer works for Arch, Fedora and Ubuntu.

## Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)

## Requirements

- git

  _if not installed, run:_

  ```shell
  sudo apt install git # Ubuntu

  sudo pacman -S git # Arch

  sudo dnf install git # Fedora usually comes with git pre-installed.
  ```

## Installation

1. **Clone the Repository**:

   ```shell
   git clone --recurse-submodules https://github.com/cammarb/dotfiles.git
   cd dotfiles
   ```

   `--recuse-submodules` will pull my [Neovim](https://github.com/cammarb/nvim) configuration.

2. **Run the installer script**:

   Example for ubuntu
   ```shell
   ./installer.sh ubuntu
   ```

   **_You might be prompted to enter your password a few times._**

3. **Close and Reopen your session.**

   *On a Desktop Environment you need to logout and login.*
