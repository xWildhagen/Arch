#!/bin/bash

RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
PURPLE="\033[0;35m"
NC="\033[0m"

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