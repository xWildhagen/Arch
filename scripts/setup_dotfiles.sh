#!/bin/bash

CONF_DIR="${HOME}/arch/scripts/conf"
source "${CONF_DIR}/colors.conf"
source "${CONF_DIR}/dotfiles_files.conf"
source "${CONF_DIR}/keep_folders.conf"
source "${CONF_DIR}/delete_folders.conf"
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
    echo_color "GREEN" "Home folder organized successfully."

    echo "Creating symbolic links..."
    for FILE in "${DOTFILES_FILES[@]}"; do
        echo "Processing ${FILE} file..."
        ln -sf "${DOTFILES_DIR}/${FILE}" "${HOME}/${FILE}" || echo_color "RED" "Error: Could not create symbolic link for ${FILE}."
    done
    echo_color "GREEN" "Symbolic links created successfully."
}

organize_home_directory() {
    cd "${HOME}" || { echo_color "RED" "Error: Could not find home directory."; return 1; }
    echo "Organizing home directory..."

    for FOLDER in "${KEEP_FOLDERS[@]}"; do
        IFS=':' read -r NEW_FOLDER OLD_FOLDER <<< "$FOLDER"
        echo "Processing ${NEW_FOLDER} folder..."
        if [ -d "$NEW_FOLDER" ]; then
            echo "$NEW_FOLDER folder already exists."
        elif [ -d "$OLD_FOLDER" ]; then
            echo_color "GREEN" "Renaming and moving $OLD_FOLDER to $NEW_FOLDER..."
            mv -n "$OLD_FOLDER" "$NEW_FOLDER" || { echo_color "RED" "Error: Could not rename/move $OLD_FOLDER."; return 1; }
        else
            echo_color "GREEN" "Creating $NEW_FOLDER folder..."
            mkdir -p "$NEW_FOLDER" || { echo_color "RED" "Error: Could not create $NEW_FOLDER folder."; return 1; }
        fi
    done
    
    for FOLDER in "${DELETE_FOLDERS[@]}"; do
        echo "Processing ${FOLDER} folder..."
        if [ -d "$FOLDER" ]; then
            echo_color "GREEN" "Deleting $FOLDER..."
            rm -r "$FOLDER" || { echo_color "RED" "Error: Could not delete $FOLDER."; return 1; }
        else
            echo "$FOLDER folder does not exist."
        fi
    done
}