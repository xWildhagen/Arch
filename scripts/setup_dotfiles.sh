#!/bin/bash

function setup_dotfiles_main() {
    clear
    echo "--- STARTING DOTFILES SETUP ---"
    echo

    if ! setup_dotfiles; then
        failed "--- DOTFILES SETUP "
        return 1
    fi

    complete "--- DOTFILES SETUP "
}

function setup_dotfiles() {

}