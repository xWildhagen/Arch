#!/bin/bash

function yay_main() {
    clear
    echo "--- Installing Yay (AUR helper) and packages ---"
    echo

    yay_install
    yay_install_packages

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

yay_packages = (
    "visual-studio-code-bin"
    "microsoft-edge-stable-bin"
)

function yay_install_packages() {
    echo "Installing packages with Yay..."
    if [ ${#yay_packages[@]} -eq 0 ]; then
        echo
        echo "No packages specified in yay_packages array."
        echo "Skipping package installation."
        echo
        read -p "Press Enter to continue..."
        return
    fi
    
    yay "${yay_packages[@]}" || { echo "Failed to install some packages"; }
}