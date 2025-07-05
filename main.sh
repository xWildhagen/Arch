#!/bin/bash

for file in "${HOME}/arch/scripts/"*.sh; do
    source "$file"
done

function main() {
    while true; do
        clear
        echo -en "${BLUE}"
        echo_dashes 40
        echo "              MAIN MENU              "
        echo_dashes 40
        echo "1) Start Archinstall setup"
        echo "2) Start yay and package installation"
        echo "3) Start dotfiles setup"
        echo "0) Quit"
        echo "-------------------------------------"
        echo -en "${PURPLE}"
        read -p "ENTER YOUR CHOICE: " OPTION
        echo -en "${BLUE}"
        echo "-------------------------------------"
        echo -en "${NC}"

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
            0|q|Q)
                echo_color "GREEN" "EXITING SCRIPT. GOODBYE!"
                echo -en "${BLUE}"
                echo "-------------------------------------"
                echo -en "${NC}"
                break
                ;;
            *)
                echo -en "${RED}"
                read -p "INVALID OPTION. PRESS ENTER TO CONTINUE..."
                echo -en "${BLUE}"
                echo "-------------------------------------"
                echo -en "${NC}"
                ;;
        esac
    done
}

main