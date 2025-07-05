#!/bin/bash

ARCHINSTALL_CONFIG="${HOME}/arch/archinstall/user_configuration.json"
ARCHINSTALL_CREDS="${HOME}/arch/archinstall/user_credentials.json"

function install_archinstall_main() {
    clear
    echo "--- STARTING ARCHINSTALL SETUP ---"
    echo
    
    if ! archinstall_install; then
        failed
        return 1
    fi

    complete
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

    if archinstall --config "$ARCHINSTALL_CONFIG" --creds "$ARCHINSTALL_CREDS"; then
        clear
        return
    else
        return 1
    fi
}

function enter_to_continue() {
    echo
    read -p "PRESS ENTER TO CONTINUE..."
}

function complete {
    echo
    echo "--- ARCHINSTALL SETUP COMPLETE ---"
    enter_to_continue
}

function failed {
    echo
    echo "--- ARCHINSTALL SETUP FAILED ---"
    enter_to_continue
}