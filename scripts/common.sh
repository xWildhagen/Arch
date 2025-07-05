#!/bin/bash

RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
NC="\033[0m"

function enter_to_continue() {
    echo
    read -p "PRESS ENTER TO CONTINUE..."
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