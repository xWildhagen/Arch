#!/bin/bash

function archinstall_main() {
    #clear
    echo "--- Running Archinstall setup ---"
    echo

    archinstall_install

    #clear
    echo "--- Archinstall setup complete ---"
    echo
    read -p "Press Enter to continue..."
}

function archinstall_install() {
    archinstall --config ~/arch/archinstall/user_configuration.json --creds ~/arch/archinstall/user_credentials.json
}