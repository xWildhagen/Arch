#!/bin/bash

# Sources
source ./scripts/install_archinstall.sh
source ./scripts/install_yay.sh

# Main loop
while true; do
    clear
    echo "-------------------------------------"
    echo "       Bash Script Main Menu         "
    echo "-------------------------------------"
    echo "1) Run Archinstall setup"
    echo "2) Install Yay"
    echo "q) Quit"
    echo "-------------------------------------"
    read -p "Enter your choice: " OPTION

    case "$OPTION" in
        1)
            install_archinstall
            ;;
        2)
            install_yay
            ;;
        q|Q)
            echo "Exiting script. Goodbye!"
            break # Exit the while loop
            ;;
        *)
            echo "Invalid option. Please enter 1, 2, or q."
            ;;
    esac
done