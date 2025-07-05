#!/bin/bash

# Sources
source ~/arch/scripts/archinstall.sh
source ~/arch/scripts/yay.sh

# Main loop
while true; do
    clear
    echo "-------------------------------------"
    echo "       BASH SCRIPT MAIN MENU         "
    echo "-------------------------------------"
    echo "1) Run Archinstall setup"
    echo "2) Install Yay and packages"
    echo "q) Quit"
    echo "-------------------------------------"
    read -p "ENTER YOUR CHOICE: " OPTION

    case "$OPTION" in
        1)
            archinstall_main
            ;;
        2)
            yay_main
            ;;
        q|Q)
            echo
            echo "EXITING SCRIPT. GOODBYE!"
            break
            ;;
        *)
            echo
            read -p "INVALID OPTION. PRESS ENTER TO CONTINUE..."
            ;;
    esac
done