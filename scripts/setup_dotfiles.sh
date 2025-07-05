#!/bin/bash

function setup_dotfiles_main() {
    clear
    echo "--- STARTING DOTFILES SETUP ---"
    echo

    if ! temp; then
        failed 
        return 1
    fi

    complete
}

function enter_to_continue() {
    echo
    read -p "PRESS ENTER TO CONTINUE..."
}

function complete {
    echo
    echo "--- DOTFILES SETUP COMPLETE ---"
    enter_to_continue
}

function failed {
    echo
    echo "--- DOTFILES SETUP FAILED ---"
    enter_to_continue
}