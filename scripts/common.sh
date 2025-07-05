#!/bin/bash

RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
PURPLE="\033[0;35m"
NC="\033[0m"

function enter_to_continue() {
    echo -e "${YELLOW}"
    read -p "PRESS ENTER TO CONTINUE..."
    echo -e "${NC}"
}

function starting {
    clear
    echo -e "${BLUE}--- STARTING $1${NC}"
    echo
}

function complete {
    echo
    echo -e "${GREEN}$1 COMPLETE ---${NC}"
    enter_to_continue
}

function failed {
    echo
    echo -e "${RED}$1 FAILED ---${NC}"
    enter_to_continue
}

function echo_color {
    case "${!1}" in
        "$RED"|"$GREEN"|"$YELLOW"|"$BLUE"|"$PURPLE") COLOR="${!1}" ;;
        *) COLOR="$NC" ;;
    esac
    echo -e "${COLOR}${2}${NC}"
}