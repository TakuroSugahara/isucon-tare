#!/bin/bash

if ! type "git" > /dev/null 2>&1; then
  sudo apt-get update
  sudo apt-get install -y git
  git config --global TakuroSugahara
  git config --global k5690033@gmail.com
else
  echo "git is already installed"
fi
