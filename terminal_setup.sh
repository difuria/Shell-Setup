#!/bin/zsh

if [[ `uname` == "Darwin" ]]; then
  echo "Running on MacOS"
  brew update
  brew upgrade

  brew install --cask iterm2
  if [[ `which starship` != "" ]]; then
    brew install starship
  else
    brew reinstall starship
  fi

  brew tap homebrew/cask-fonts

  # Check to see if font exists
  brew info font-hack-nerf-font
  if [[ $? -eq 0 ]]; then
    brew install font-hack-nerd-font
  else
    brew reinstall font-hack-nerd-font
  fi

  vscode_settings="$HOME/Library/Application\ Support/Code/User/settings.json"
  eval cat $vscode_settings
  jq '."terminal.external.osxExec"' /Users/difuria/Library/Application\ Support/Code/User/settings.json
elif [[ `uname` == "Linux" ]]; then
  echo "Running on Linux"
  curl -sS https://starship.rs/install.sh | sh -s -- -y

  if [[ `which yum` != "yum not found" ]]; then
    sudo yum install unzip -y 
    sudo yum update -y 
    sudo yum upgrade -y
  elif [[ `which apt-get` != "apt-get not found" ]]; then
    sudo apt-get install unzip -y
    sudo apt-get update -y
    sudo apt-get upgrade -y
  else
    echo "Unable to find package installer"
  fi

  if [[ -z "$SSH_CLIENT" ]] && [[ -z "$SSH_TTY" ]]; then
    echo "Installing Nerd Fonts"
    mkdir -p ~/downloads/nerd-fonts
    curl -LJO https://github.com/ryanoasis/nerd-fonts/archive/refs/heads/master.zip --output-dir ~/downloads/nerd-fonts
    unzip nerd-fonts-master.zip -d ~/downloads/nerd-fonts
    chmod +x ~/downloads/nerd-fonts/nerd-fonts-master/install.sh
    ~/downloads/nerd-fonts/nerd-fonts-master/install.sh
  fi

  # vscode_settings="$HOME/.config/Code/User/settings.json"
  # "terminal.external.osxExec": "iTerm.app",
  # "terminal.integrated.fontFamily": "Hack Nerd Font Mono",
else 
  echo "Unsupported OS `uname`"
  exit 1
fi

mkdir -p ~/.config
curl -s https://raw.githubusercontent.com/difuria/Shell-Setup/main/starship.toml --output ~/.config/starship.toml

if [[ `egrep "starship.*init.*zsh" ~/.zshrc` == "" ]]; then
  echo '\neval "$(starship init zsh)"' >> ~/.zshrc
fi

source ~/.zshrc

if [[ `uname` == "Linux" ]]; then
  reboot_system=""
  while [[ ${reboot_system:u} != "Y" && ${reboot_system:u} != "N" ]]; do
    echo "Do you want to reboot the system?"
    read reboot_system
    if [[ ${reboot_system:u} == "Y" ]]; then
      echo "Rebooting System"
      sleep 3
      sudo reboot
    elif [[ ${reboot_system:u} != "N" ]]; then
      echo "Invalid response: $reboot_system"
    fi
  done
fi
