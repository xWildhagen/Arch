#!/bin/bash

function setup_dotfiles_main() {
    clear
    echo "--- STARTING DOTFILES SETUP ---"
    echo

    if ! setup_dotfiles; then
        failed
        return 1
    fi

    complete
}

function setup_dotfiles() {

}