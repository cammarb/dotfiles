# Dotfiles

This repository contains my configuration files for various tools and programs, managed using GNU Stow.
It also contains a script to install all the necessary tools and programs for development on a new computer or VM running Linux.

## Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)

## Requirements

- git

  _if not installed, run:_

  ```bash
  sudo apt install git
  ```

## Installation

1. **Clone the Repository**:

   ```bash
   git clone --recurse-submodules https://github.com/cammarb/dotfiles.git
   cd dotfiles
   ```

   `--recuse-submodules` will pull my [Neovim](https://github.com/cammarb/nvim) configuration repo.

2. **Run the installer script**:

   ```
   ./installer.sh
   ```

   **_You might be prompted to enter your password a few times._**

3. **Close and Reopen your terminal**
