#!/bin/bash

CONF_DIR="${HOME}/arch/scripts/conf"
source "${CONF_DIR}/colors.conf"

declare -a yay_packages=(
    "visual-studio-code-bin" 
    "microsoft-edge-stable-bin"
)

function install_yay_main() {
    starting "YAY (AUR HELPER) AND PACKAGE INSTALLATION"

    if ! install_yay; then
        failed "YAY INSTALLATION"
        return 1
    fi
    if ! install_yay_packages; then
        failed "YAY PACKAGE INSTALLATION"
        return 1
    fi

    complete "YAY AND PACKAGE INSTALLATION"
}

# https://github.com/Jguer/yay
function install_yay() {
    echo "Checking for existing yay installation..."
    if command -v yay &> /dev/null; then
        echo_color "GREEN" "yay is already installed. Skipping installation process."
        return 0
    fi

    echo "Yay not found. Proceeding with installation..."
    echo "Cloning and building yay..."
    cd ${HOME} || { echo_color "RED" "Error: Could not find home directory."; return 1; }
    sudo pacman -S --needed git base-devel || { echo_color "RED" "Error: Failed to install git and base-devel."; return 1; }
    if [ -d "yay" ]; then
        echo "yay directory already exists. Pulling latest changes..."
        (cd yay && git pull) || { echo_color "RED" "Error: Failed to pull latest yay changes."; return 1; }
    else
        git clone https://aur.archlinux.org/yay.git || { echo_color "RED" "Error: Failed to clone yay repository."; return 1; }
    fi

    cd yay || { echo_color "RED" "Error: Could not find yay directory."; return 1; }
    makepkg -si || { echo_color "RED" "Error: Failed to build and install yay."; return 1; }

    cd ${HOME} || { echo_color "RED" "Error: Could not find home directory."; return 1; }
    sudo rm -r yay

    echo_color "GREEN" "yay installed successfully."
    return
}

function install_yay_packages() {
    echo -e "Installing packages with yay..."
    if [ ${#yay_packages[@]} -eq 0 ]; then
        echo "No packages specified in yay_packages array."
        echo_color "YELLOW" "Skipping package installation."
        return
    fi

    if yay -S "${yay_packages[@]}"; then
        echo_color "GREEN" "All specified packages installed successfully."
        return 0
    else
        echo_color "RED" "Failed to install some packages."
        return 1
    fi
}