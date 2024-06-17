#!/bin/bash

echo "Starting Programs Installer..."

echo "Updating and upgrading system and applications:"
sudo apt get update -y
sudo apt get upgrade -y

echo "Installing Programs:"

echo "ZSH"
sudo apt install zsh -y


