#!/bin/bash

# https://github.com/Jguer/yay
sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
yay -S visual-studio-code-bin
yay -S microsoft-edge-stable-bin