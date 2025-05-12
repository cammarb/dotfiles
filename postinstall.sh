#!/bin/bash

echo -e "$info_msg: Post Install."

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" --no-use # This loads nvm, without auto-using the default version

echo -e "$info_msg: Installing LTS version of node.js."

if ! nvm install --lts; then
  echo -e "$error_msg: Failed installing LTS version of node.js."
  exit 1
fi
if ! npm -g install tree-sitter-cli; then # I need this for latex to work in neovim
  echo -e "$error_msg: Failed installing tree-sitter-cli."
  exit 1
fi

source "$HOME/.sdkman/bin/sdkman-init.sh"
if ! sdk install java 21.0.2-open; then
  echo -e "$error_msg: Failed installing java sdks."
  exit 1
fi

if ! sdk install kotlin 2.1.0; then
  echo -e "$error_msg: Failed installing kotlin."
  exit 1
fi

echo -e "$success_msg: External packages installed successfully."

