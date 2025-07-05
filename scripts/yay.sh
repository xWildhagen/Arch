#!/bin/bash

function yay_main() {
    clear
    echo "--- INSTALLING YAY (AUR HELPER) AND PACKAGES ---"
    echo

    yay_install
    yay_install_packages

    echo
    echo "--- YAY AND PACKAGE INSTALLATION COMPLETE ---"
    echo
    read -p "PRESS ENTER TO CONTINUE..."
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
    echo "INSTALLING PACKAGES WITH YAY..."
    if [ ${#yay_packages[@]} -eq 0 ]; then
        echo
        echo "No packages specified in yay_packages array."
        echo "Skipping package installation."
        echo
        read -p "PRESS ENTER TO CONTINUE..."
        return
    fi

    yay "${yay_packages[@]}" || { echo "FAILED TO INSTALL SOME PACKAGES"; }
}