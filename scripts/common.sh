#!/bin/bash

CONF_DIR="${HOME}/arch/scripts/conf"
source "${CONF_DIR}/colors.conf"
source "${CONF_DIR}/yay_packages.conf"

function enter_to_continue() {
    echo -en "${PURPLE}"
    read -p "PRESS ENTER TO CONTINUE..."
    echo -en "${BLUE}"
    echo_dashes 50
    echo -en "${NC}"
}

function starting() {
    clear
    echo -en "${BLUE}"
    echo_dashes 50
    echo -e "STARTING $1"
    echo_dashes 50
    echo -en "${NC}"
}

function complete() {
    echo -en "${BLUE}"
    echo_dashes 50
    echo -en "${GREEN}"
    echo -e "$1 COMPLETE"
    echo -en "${BLUE}"
    echo_dashes 50
    echo -en "${NC}"
    enter_to_continue
}

function failed() {
    echo -en "${BLUE}"
    echo_dashes 50
    echo -en "${RED}"
    echo -e "$1 FAILED"
    echo -en "${BLUE}"
    echo_dashes 50
    echo -en "${NC}"
    enter_to_continue
}

function echo_color() {
    case "${!1}" in
        "$RED"|"$GREEN"|"$YELLOW"|"$BLUE"|"$PURPLE") COLOR="${!1}" ;;
        *) COLOR="$NC" ;;
    esac
    echo -en "${COLOR}${2}${NC}\n"
}

echo_dashes() {
    echo "$(printf '%*s' "$1" | tr ' ' '-')"
}