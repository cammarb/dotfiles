#!/bin/bash

# npm
npm i -g \
	typescript typescript-language-server \
	pyright \
        gh-actions-language-server \
        bash-language-server \
        @microsoft/compose-language-service

# homebrew
# https://brew.sh/
brew install lua-language-server \
  yaml-language-server \

# go
go install github.com/docker/docker-language-server/cmd/docker-language-server@latest

# Custom
DOWNLOADS=$HOME/Downloads
# kotlin-lsp
# Check https://github.com/Kotlin/kotlin-lsp/releases for the latest version
KOTLIN_LSP_DIR=/opt/kotlin-lsp
curl -LO --output-dir "$DOWNLOADS" https://download-cdn.jetbrains.com/kotlin-lsp/262.4739.0/kotlin-server-262.4739.0.tar.gz
sudo tar -C "$KOTLIN_LSP_DIR" -xzf "$DOWNLOADS/kotlin-server-262.4739.0.tar.gz"
chmod +x "$KOTLIN_LSP_DIR/bin/kotlin-lsp.sh"
sudo ln -s "$KOTLIN_LSP_DIR/bin/kotlin-lsp.sh" "$HOME/.local/bin/kotlin-lsp"

