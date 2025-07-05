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
    if ! organize_home_directory; then
        echo_color "RED" "Error: Failed to organize home directory."
        return 1
    fi
    echo_color "GREEN" "\nHome folder organized successfully."

    echo "Creating symbolic links..."
    ln -sf "${DOTFILES_DIR}/.gitconfig" "${HOME}/.gitconfig" || { echo_color "RED" "Error: Could not create symbolic link for .gitconfig."; return 1; }
}

function organize_home_directory() {
    cd ${HOME} || { echo_color "RED" "Error: Could not find home directory."; return 1; }
    echo "Organizing home directory..."

    if [ -d "documents" ]; then
        echo "documents folder already exists."
    elif [ -d "Documents" ]; then
        echo "Renaming Documents to documents..."
        mv -n "Documents" "documents" || { echo_color "RED" "Error: Could not rename Documents."; return 1; }
    else
        echo "Creating documents folder..."
        mkdir "documents" || { echo_color "RED" "Error: Could not create documents folder."; return 1; }
    fi

    if [ -d "downloads" ]; then
        echo "downloads folder already exists."
    elif [ -d "Downloads" ]; then
        echo "Renaming Downloads to downloads..."
        mv -n "Downloads" "downloads" || { echo_color "RED" "Error: Could not rename Downloads."; return 1; }
    else
        echo "Creating downloads folder..."
        mkdir "downloads" || { echo_color "RED" "Error: Could not create downloads folder."; return 1; }
    fi

    if [ -d "documents/desktop" ]; then
        echo "documents/desktop folder already exists."
    elif [ -d "Desktop" ]; then
        echo "Renaming and moving Desktop to documents/desktop..."
        mv -n "Desktop" "documents/desktop" || { echo_color "RED" "Error: Could not rename and move Desktop."; return 1; }
    else
        echo "Creating documents/desktop folder..."
        mkdir -p "documents/desktop" || { echo_color "RED" "Error: Could not create documents/desktop folder."; return 1; }
    fi

    if [ -d "documents/music" ]; then
        echo "documents/music folder already exists."
    elif [ -d "Music" ]; then
        echo "Renaming and moving Music to documents/music..."
        mv -n "Music" "documents/music" || { echo_color "RED" "Error: Could not rename and move Music."; return 1; }
    else
        echo "Creating documents/music folder..."
        mkdir -p "documents/music" || { echo_color "RED" "Error: Could not create documents/music folder."; return 1; }
    fi

    if [ -d "documents/pictures" ]; then
        echo "documents/pictures folder already exists."
    elif [ -d "Pictures" ]; then
        echo "Renaming and moving Pictures to documents/pictures..."
        mv -n "Pictures" "documents/pictures" || { echo_color "RED" "Error: Could not rename and move Pictures."; return 1; }
    else
        echo "Creating documents/pictures folder..."
        mkdir -p "documents/pictures" || { echo_color "RED" "Error: Could not create documents/pictures folder."; return 1; }
    fi

    if [ -d "documents/videos" ]; then
        echo "documents/videos folder already exists."
    elif [ -d "Videos" ]; then
        echo "Renaming and moving Videos to documents/videos..."
        mv -n "Videos" "documents/videos" || { echo_color "RED" "Error: Could not rename and move Videos."; return 1; }
    else
        echo "Creating documents/videos folder..."
        mkdir -p "documents/videos" || { echo_color "RED" "Error: Could not create documents/videos folder."; return 1; }
    fi

    if [ -d "Public" ]; then
        echo "Deleting Public..."
        rm -r "Public" || { echo_color "RED" "Error: Could not delete Public."; return 1; }
    else
        echo "Public folder does not exist."
    fi

    if [ -d "Templates" ]; then
        echo "Deleting Templates..."
        rm -r "Templates" || { echo_color "RED" "Error: Could not delete Templates."; return 1; }
    else
        echo "Templates folder does not exist."
    fi

    return
}