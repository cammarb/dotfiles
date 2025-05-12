#!/bin/sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CONFIG_FOLDER="$HOME/.config/"

echo -e "$info_msg: Running Stow"

# Cleanup
echo -e "$warn_msg: Removing existing configurations."
for module in "$SCRIPT_DIR/config/*"; do
    module_name=$(basename "$module")
    target="$CONFIG_FOLDER/$module_name"

    if [ -e "$target" ] || [ -L "$target" ]; then
        echo "Removing existing: $target"
        rm -rf "$target"
    fi
done

echo -e "$info_msg: Running stow for .config"
if ! stow -d "$SCRIPT_DIR" config -t "$CONFIG_FOLDER"; then
  echo -e "$error_msg: Stow operation for .config failed."
  exit 1
fi

echo -e "$info_msg: Running stow for HOME"
if ! stow -d "$SCRIPT_DIR" home -t "$HOME"; then
  echo -e "$error_msg: Stow operation for HOME failed."
  exit 1
fi

