#!/bin/bash

function setup_dotfiles_main() {
    clear
    echo "--- STARTING DOTFILES SETUP ---"
    echo

    if ! setup_dotfiles; then
        failed "--- DOTFILES SETUP"
        return 1
    fi

    complete "--- DOTFILES SETUP"
}

function setup_dotfiles() {
    organize_home_directory
}

function organize_home_directory() {
    cd ${HOME} || { echo -e "\nError: Could not find home directory."; return 1; }
    echo "Organizing home directory..."

    echo "Renaming Documents to documents..."
    mv -n "Documents" "documents" || { echo -e "\nError: Could not rename Documents."; return 1; }
    echo "Renaming Downloads to downloads..."
    mv -n "Downloads" "downloads" || { echo -e "\nError: Could not rename Downloads."; return 1; }

    echo "Renaming and moving Desktop to documents/desktop..."
    mv -n "Desktop" "documents/desktop" || { echo -e "\nError: Could not rename and move Desktop."; return 1; }
    echo "Renaming and moving Music to documents/music..."
    mv -n "Music" "documents/music" || { echo -e "\nError: Could not rename and move Music."; return 1; }
    echo "Renaming and moving Pictures to documents/pictures..."
    mv -n "Pictures" "documents/pictures" || { echo -e "\nError: Could not rename and move Pictures."; return 1; }
    echo "Renaming and moving Videos to documents/videos..."
    mv -n "Videos" "documents/videos" || { echo -e "\nError: Could not rename and move Videos."; return 1; }

    echo "Deleting Public..."
    rm -r "Public" || { echo -e "\nError: Could not delete Public."; return 1; }
    echo "Deleting Templates..."
    rm -r "Templates" || { echo -e "\nError: Could not delete Templates."; return 1; }

    echo
    echo "HOME FOLDER ORGANIZED SUCCESSFULLY."
    return
}