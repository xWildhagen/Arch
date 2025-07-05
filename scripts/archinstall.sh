#!/bin/bash

ARCHINSTALL_CONFIG="${HOME}/arch/archinstall/user_configuration.json"
ARCHINSTALL_CREDS="${HOME}/arch/archinstall/user_credentials.json"

function archinstall_main() {
    clear
    echo "--- RUNNING ARCHINSTALL SETUP ---"
    echo

    archinstall_install

    echo "--- ARCHINSTALL SETUP COMPLETE ---"
    echo
    read -p "PRESS ENTER TO CONTINUE..."
}

function archinstall_install() {
    if [ ! -f "${ARCHINSTALL_CONFIG}" ]; then
        echo "Error: Archinstall configuration file not found at ${ARCHINSTALL_CONFIG}"
        exit 1
    fi
    if [ ! -f "${ARCHINSTALL_CREDS}" ]; then
        echo "Error: Archinstall credentials file not found at ${ARCHINSTALL_CREDS}"
        exit 1
    fi
    
    archinstall --config "$ARCHINSTALL_CONFIG" --creds "$ARCHINSTALL_CREDS"
}