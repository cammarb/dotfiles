#!/usr/bin/env bash

os=${1}

# Package Manager - Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew_packages=(
	"--cask git-credential-manager"
	"neovim"
	"stow"
	"ripgrep"
	"tmux"
	"zip"
	"unzip"
)

source ./packages_installer.sh

install_packages brew_packages

# Node Version Manager (nvm)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

# SDKMAN!
curl -s "https://get.sdkman.io" | bash

