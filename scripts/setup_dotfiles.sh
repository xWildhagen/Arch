#!/bin/bash

DOTFILES_DIR="${HOME}/arch/dotfiles"

function setup_dotfiles_main() {
    starting "DOTFILES SETUP"

    if ! setup_dotfiles; then
        failed "DOTFILES SETUP"
        return 1
    fi

    complete "DOTFILES SETUP"
}

function setup_dotfiles() {
    organize_home_directory
    echo "Creating symbolic links..."
    ln -sf "${DOTFILES_DIR}/.gitconfig" "${HOME}/.gitconfig" || { echo_color "RED" "\nError: Could not create symbolic link for .gitconfig."; return 1; }
}

function organize_home_directory() {
    cd ${HOME} || { echo_color "RED" "\nError: Could not find home directory."; return 1; }
    echo "Organizing home directory..."

    echo "Renaming Documents to documents..."
    mv -n "Documents" "documents" || { echo_color "RED" "\nError: Could not rename Documents."; return 1; }
    echo "Renaming Downloads to downloads..."
    mv -n "Downloads" "downloads" || { echo_color "RED" "\nError: Could not rename Downloads."; return 1; }

    echo "Renaming and moving Desktop to documents/desktop..."
    mv -n "Desktop" "documents/desktop" || { echo_color "RED" "\nError: Could not rename and move Desktop."; return 1; }
    echo "Renaming and moving Music to documents/music..."
    mv -n "Music" "documents/music" || { echo_color "RED" "\nError: Could not rename and move Music."; return 1; }
    echo "Renaming and moving Pictures to documents/pictures..."
    mv -n "Pictures" "documents/pictures" || { echo_color "RED" "\nError: Could not rename and move Pictures."; return 1; }
    echo "Renaming and moving Videos to documents/videos..."
    mv -n "Videos" "documents/videos" || { echo_color "RED" "\nError: Could not rename and move Videos."; return 1; }

    echo "Deleting Public..."
    rm -r "Public" || { echo_color "RED" "\nError: Could not delete Public."; return 1; }
    echo "Deleting Templates..."
    rm -r "Templates" || { echo_color "RED" "\nError: Could not delete Templates."; return 1; }

    echo
    echo_color "GREEN" "HOME FOLDER ORGANIZED SUCCESSFULLY."
    return
}