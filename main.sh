#!/bin/bash

for file in "${HOME}/arch/scripts/"*.sh; do
    source "$file"
done

source "${HOME}/arch/scripts/install_archinstall.sh"
source "${HOME}/arch/scripts/install_yay.sh"
source "${HOME}/arch/scripts/setup_dotfiles.sh"

function main() {
    while true; do
        clear
        echo "-------------------------------------"
        echo "       BASH SCRIPT MAIN MENU         "
        echo "-------------------------------------"
        echo "1) Start Archinstall setup"
        echo "2) Start yay and package installation"
        echo "3) Start dotfiles setup"
        echo "q) Quit"
        echo "-------------------------------------"
        read -p "ENTER YOUR CHOICE: " OPTION

        case "$OPTION" in
            1)
                install_archinstall_main
                ;;
            2)
                install_yay_main
                ;;
            3)
                setup_dotfiles_main
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
}

main