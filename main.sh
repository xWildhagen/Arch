#!/bin/bash

# Sources
source ~/arch/scripts/archinstall.sh
source ~/arch/scripts/yay.sh

# Main loop
while true; do
    clear
    echo "-------------------------------------"
    echo "       Bash Script Main Menu         "
    echo "-------------------------------------"
    echo "1) Run Archinstall setup"
    echo "2) Install Yay and packages"
    echo "q) Quit"
    echo "-------------------------------------"
    read -p "Enter your choice: " OPTION

    case "$OPTION" in
        1)
            archinstall_main
            ;;
        2)
            yay_main
            ;;
        q|Q)
            echo
            echo "Exiting script. Goodbye!"
            break
            ;;
        *)
            echo
            read -p "Invalid option. Press Enter to continue..."
            ;;
    esac
done