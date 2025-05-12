#!/bin/sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "$info_msg: Running Stow"

# Cleanup
echo -e "$warn_msg: Removing existing configurations."

config_folder="$HOME/.config/"
stow_config_folder=$SCRIPT_DIR


echo -e "$info_msg: Running stow for .config"
if ! stow -d "$SCRIPT_DIR" config -t "$HOME/.config"; then
  echo -e "$error_msg: Stow operation for .config failed."
  exit 1
fi

echo -e "$info_msg: Running stow for HOME"
if ! stow -d "$SCRIPT_DIR" config -t "$HOME"; then
  echo -e "$error_msg: Stow operation for HOME failed."
  exit 1
fi
