#!/bin/bash

# Sources
source ./scripts/archinstall.sh
source ./scripts/yay.sh

# Main loop
while true; do
    #clear
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
            echo "Exiting script. Goodbye!"
            break # Exit the while loop
            ;;
        *)
            echo "Invalid option. Please enter 1, 2, or q."
            ;;
    esac
done