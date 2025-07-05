#!/bin/bash

declare -a yay_packages=(
    "visual-studio-code-bin"
    "microsoft-edge-stable-bin"
)

function install_yay_main() {
    clear
    echo "--- STARTING YAY (AUR HELPER) AND PACKAGE INSTALLATION ---"
    echo

    if ! install_yay; then
        failed "--- YAY INSTALLATION"
        return 1
    fi
    if ! install_yay_packages; then
        failed "--- YAY PACKAGE INSTALLATION"
        return 1
    fi

    complete "--- YAY AND PACKAGE INSTALLATION"
}

# https://github.com/Jguer/yay
function install_yay() {
    echo "Checking for existing yay installation..."
    if command -v yay &> /dev/null; then
        echo
        echo "YAY IS ALREADY INSTALLED. SKIPPING INSTALLATION PROCESS."
        return 0
    fi

    echo "Yay not found. Proceeding with installation..."
    echo "Cloning and building yay..."
    cd ${HOME} || { echo -e "\nError: Could not find home directory."; return 1; }
    sudo pacman -S --needed git base-devel || { echo -e "\nError: Failed to install git and base-devel."; return 1; }
    if [ -d "yay" ]; then
        echo "yay directory already exists. Pulling latest changes..."
        (cd yay && git pull) || { echo -e "\nError: Failed to pull latest yay changes."; return 1; }
    else
        git clone https://aur.archlinux.org/yay.git || { echo -e "\nError: Failed to clone yay repository."; return 1; }
    fi

    cd yay || { echo -e "\nError: Could not find yay directory."; return 1; }
    makepkg -si || { echo -e "\nError: Failed to build and install yay."; return 1; }

    cd ${HOME} || { echo -e "\nError: Could not find home directory."; return 1; }
    sudo rm -r yay

    echo
    echo "YAY INSTALLED SUCCESSFULLY."
    return
}

function install_yay_packages() {
    echo
    echo "Installing packages with yay..."
    if [ ${#yay_packages[@]} -eq 0 ]; then
        echo "No packages specified in yay_packages array."
        echo
        echo "SKIPPING PACKAGE INSTALLATION."
        return
    fi

    if yay -S "${yay_packages[@]}"; then
        echo
        echo "ALL SPECIFIED PACKAGES INSTALLED SUCCESSFULLY."
        return 0
    else
        echo
        echo "FAILED TO INSTALL SOME PACKAGES."
        return 1
    fi
}