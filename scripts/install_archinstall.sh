#!/bin/bash

function install_archinstall() {
    clear
    echo "--- Running Archinstall setup ---"
    echo

    archinstall --config ./archinstall/user_configuration.json --creds ./archinstall/user_credentials.json

    clear
    echo "--- Archinstall setup complete ---"
    echo
    read -p "Press Enter to continue..."
}