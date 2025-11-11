#! /bin/bash

# Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# SDKMAN!
curl -s "https://get.sdkman.io" | bash

# Git Credential Manager
brew install --cask git-credential-manager

# Neovim
brew install neovim

# Node Version Manager (nvm)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

# Stow
brew install stow
