#!/bin/bash

function yay_main() {
    #clear
    echo "--- Installing Yay (AUR helper) and packages ---"
    echo

    yay_install
    yay_install_packages

    #clear
    echo "--- Yay and package installation complete ---"
    echo
    read -p "Press Enter to continue..."
}

# https://github.com/Jguer/yay
function yay_install() {
    cd ~
    sudo pacman -S --needed git base-devel
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si
}

function yay_install_packages() {
    yay visual-studio-code-bin microsoft-edge-stable-bin
}