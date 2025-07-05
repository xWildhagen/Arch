#!/bin/bash

# https://github.com/Jguer/yay
function install_yay() {
    clear
    echo "--- Installing Yay (AUR helper) ---"
    echo

    cd ~
    sudo pacman -S --needed git base-devel
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si
    yay -S visual-studio-code-bin
    yay -S microsoft-edge-stable-bin

    clear
    echo "--- Yay installation complete ---"
    echo
    read -p "Press Enter to continue..."
}