#!/bin/sh

echo -e "$info_msg: Post Install."

echo -e "$info_msg: Installing LTS version of node.js."

if ! nvm install --lts; then
  echo -e "$error_msg: Failed installing LTS version of node.js."
  exit 1
fi
if ! npm -g install tree-sitter-cli; then # I need this for latex to work in neovim
  echo -e "$error_msg: Failed installing tree-sitter-cli."
  exit 1
fi

if ! sdk install java 21.0.2-open; then
  echo -e "$error_msg: Failed installing java sdks."
  exit 1
fi

if ! sdk install kotlin 2.1.0; then
  echo -e "$error_msg: Failed installing kotlin."
  exit 1
fi

echo -e "$success_msg: External packages installed successfully."
