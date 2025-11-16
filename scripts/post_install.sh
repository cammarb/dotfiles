#!/usr/bin/env bash

# NodeJS
node_lts_installer(){
  echo -e "$info_msg: Installing LTS version of node.js."
  nvm install --lts
}
if ! node_lts_installer; then
  echo -e "$error_msg: Failed installing LTS version of node.js."
  exit 1
fi

# Java and Kotlin
java_installer(){
  sdk install java 21.0.2-temurin
}
if ! java_installer; then
  echo -e "$error_msg: Failed installing java sdks."
  exit 1
fi
kotlin_installer(){
  sdk install kotlin 2.1.0
}
if ! kotlin_installer; then
  echo -e "$error_msg: Failed installing kotlin."
  exit 1
fi