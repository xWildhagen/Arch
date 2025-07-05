#!/bin/bash

declare -a yay_packages = (
    "visual-studio-code-bin"
    "microsoft-edge-stable-bin"
)

function yay_main() {
    clear
    echo "--- STARTING YAY (AUR HELPER) AND PACKAGE INSTALLATION ---"
    echo
    enter_to_continue
    if ! yay_install; then
        failed "--- YAY INSTALLATION"
        return 1
    fi

    if ! yay_install_packages; then
        failed "--- YAY PACKAGE INSTALLATION"
        return 1
    fi

    complete "--- YAY AND PACKAGE INSTALLATION"
}

# https://github.com/Jguer/yay
function yay_install() {
    echo "Checking for existing yay installation..."
    if command -v yay &> /dev/null; then
        echo
        echo "YAY IS ALREADY INSTALLED. SKIPPING INSTALLATION PROCESS."
        echo
        return 0
    fi
    echo "Yay not found. Proceeding with installation..."
    echo "Cloning and building yay..."
    cd ~ || { echo -e "\nError: Could not change to home directory."; return 1; }
    sudo pacman -S --needed git base-devel || { echo -e "\nError: Failed to install git and base-devel."; return 1; }
    if [ -d "yay" ]; then
        echo "yay directory already exists. Pulling latest changes..."
        (cd yay && git pull) || { echo -e "\nError: Failed to pull latest yay changes."; return 1; }
    else
        git clone https://aur.archlinux.org/yay.git || { echo -e "\nError: Failed to clone yay repository."; return 1; }
    fi
    cd yay || { echo -e "\nError: Could not change to yay directory."; return 1; }
    makepkg -si || { echo -e "\nError: Failed to build and install yay."; return 1; }
    echo
    echo "YAY INSTALLED SUCCESSFULLY."
    echo
    return
}

function yay_install_packages() {
    echo "INSTALLING PACKAGES WITH YAY..."
    if [ ${#yay_packages[@]} -eq 0 ]; then
        echo
        echo "No packages specified in yay_packages array."
        echo "Skipping package installation."
        enter_to_continue
        return
    fi

    yay "${yay_packages[@]}" || { echo "FAILED TO INSTALL SOME PACKAGES"; }
}

function enter_to_continue() {
    echo
    read -p "PRESS ENTER TO CONTINUE..."
}

function complete {
    echo
    echo "$1 COMPLETE ---"
    enter_to_continue
}

function failed {
    echo
    echo "$1 FAILED ---"
    enter_to_continue
}