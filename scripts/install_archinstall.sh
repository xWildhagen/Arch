#!/bin/bash

CONF_DIR="${HOME}/arch/scripts/conf"
source "${CONF_DIR}/colors.conf"
ARCHINSTALL_CONFIG="${HOME}/arch/archinstall/user_configuration.json"
ARCHINSTALL_CREDS="${HOME}/arch/archinstall/user_credentials.json"

function install_archinstall_main() {
    starting "ARCHINSTALL SETUP"

    if ! install_archinstall; then
        failed "ARCHINSTALL SETUP"
        return 1
    fi

    complete "ARCHINSTALL SETUP"
}

function install_archinstall() {
    if [ ! -f "${ARCHINSTALL_CONFIG}" ]; then
        echo_color "RED" "Error: Archinstall configuration file not found at ${ARCHINSTALL_CONFIG}"
        return 1
    fi

    if [ ! -f "${ARCHINSTALL_CREDS}" ]; then
        echo_color "RED" "Error: Archinstall credentials file not found at ${ARCHINSTALL_CREDS}"
        return 1
    fi

    if archinstall --config "$ARCHINSTALL_CONFIG" --creds "$ARCHINSTALL_CREDS"; then
        clear
        return
    else
        return 1
    fi
}