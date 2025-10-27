#! /bin/bash

# Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# SDKMAN!
curl -s "https://get.sdkman.io" | bash

# Git Credential Manager
brew install --cask git-credential-manager
