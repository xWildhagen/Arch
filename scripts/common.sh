#!/bin/bash

function enter_to_continue() {
    echo
    read -p "PRESS ENTER TO CONTINUE..."
}

function complete {
    echo
    echo "$1 COMPLETE ---"
    enter_to_continue
}

function failed {
    echo
    echo "$1 FAILED ---"
    enter_to_continue
}