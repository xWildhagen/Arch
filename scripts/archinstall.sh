#!/bin/bash

ARCHINSTALL_CONFIG="${HOME}/arch/archinstall/user_configuration.json"
ARCHINSTALL_CREDS="${HOME}/arch/archinstall/user_credentials.json"

function archinstall_main() {
    clear
    echo "--- RUNNING ARCHINSTALL SETUP ---"
    echo

    archinstall_install
}

function archinstall_install() {
    if [ ! -f "${ARCHINSTALL_CONFIG}" ]; then
        echo "Error: Archinstall configuration file not found at ${ARCHINSTALL_CONFIG}"
        return 1
    fi
    if [ ! -f "${ARCHINSTALL_CREDS}" ]; then
        echo "Error: Archinstall credentials file not found at ${ARCHINSTALL_CREDS}"
        return 1
    fi

    archinstall --config "$ARCHINSTALL_CONFIG" --creds "$ARCHINSTALL_CREDS" || { echo "FAILED TO RUN ARCHINSTALL"; }
}

function archinstall_install() {
    # Check if the configuration file exists
    if [ ! -f "${ARCHINSTALL_CONFIG}" ]; then
        echo "Error: Archinstall configuration file not found at ${ARCHINSTALL_CONFIG}"
        return 1 # Indicate failure
    fi

    # Check if the credentials file exists
    if [ ! -f "${ARCHINSTALL_CREDS}" ]; then
        echo "Error: Archinstall credentials file not found at ${ARCHINSTALL_CREDS}"
        return 1 # Indicate failure
    fi

    if archinstall --config "$ARCHINSTALL_CONFIG" --creds "$ARCHINSTALL_CREDS"; then
        echo
        echo "--- ARCHINSTALL SETUP COMPLETE ---"
        echo
        read -p "PRESS ENTER TO CONTINUE..."
        return
    else
        echo
        echo "--- ARCHINSTALL SETUP FAILED ---"
        echo
        read -p "PRESS ENTER TO CONTINUE..."
        return 1
    fi
}