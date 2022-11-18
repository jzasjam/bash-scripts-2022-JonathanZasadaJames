#!/bin/bash

# Set Text Colour
NC='\033[0m' # No Color
printf "${NC}"

: ' SUGGESTIONS: 
- Automatic creation and rights management of a new user
- Application of firewall rules
- Extraction of monitoring information in a file
- Conduct system management activities on a regular basis
- Automated installation of a software
'

# Create an array of arguments/tasks to complete
# -----------------------------------------------------------
i=0
# Basic tasks
operations[$i]="h   | help       Get Some Help\n"; ((i++))
#operations[$i]="d  | demo       See Bash Demo"; ((i++))
operations[$i]="w   | www        Open A Web Page"; ((i++))
operations[$i]="e   | email      Send An Email (and configure SMTP)\n"; ((i++))

# LAMP Stack Setup & Management
operations[$i]="s   | status     System Status Overview (Services/Users/CPU/MEM)"; ((i++))
operations[$i]="sv  | service    Service Status & Management (Apache/MariaDB)"; ((i++))
operations[$i]="u   | update     Update and Upgrade"; ((i++))
operations[$i]="i   | install    Install Packages (Apache/MariaDB/PHP/Wordpress)\n"; ((i++))

operations[$i]="db  | database   Database Management"; ((i++))
operations[$i]="hp  | homepage   Create Homepage\n"; ((i++))

# OS Tasks
#operations[$i]="us | user       **User Management\n"; ((i++))
#operations[$i]="c  | cpu        **CPU Monitor to Log\n"; ((i++))

# Exit
operations[$i]="x   | exit       Quit / Exit"; ((i++))


# Get this file name to use in restart function and reference elsewhere
thisFile="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"
function RESTART(){
    #echo -e "\n\n"
    clear
    bash $thisFile 
    exit
}

# See If Command Line Argument Provided or Get User Input
# -----------------------------------------------------------
    task=$1
    if [ -z "$task" ]
    then
        # If No Command Line Argument Provided
        clear
        echo "=================================================================="
        echo "      WELCOME TO THE LAMP SERVER SETUP & MANAGEMENT SCRIPT"
        echo "=================================================================="
        echo " NOTE: Use commands like 'bash $thisFile {argument}' to start them automatically"

        echo -e "\n-------------------------------------"
        echo -e " Options(s) \t Description"
        echo "-------------------------------------"

        # Loop through the array and print out the arguments and descriptions menu 
        for key in "${!operations[@]}"; do
            printf " ${operations[${key}]} \n"
        done

        # Get User Input For Task
        echo -e "\n\n-------------------------------------"
        echo "> Select A Task (Enter An Argument)..."
        read task 
        clear
    else
        # If Command Line Argument Provided
        echo "> TASK SELECTED = $task"
    fi

# Convert entered task to lower case
    task=$(echo $task | tr '[:upper:]' '[:lower:]')

 # Case Statement Menu Performing Selected Task  
 # ----------------------------------------------------------- 
    case $task in
        # Help and Descriptions
        h | help)
            bash help.sh $thisFile
        ;;
        # Demo Script
        d | demo)
            bash demo.sh "bashbook.txt"
        ;;
        # Database Management
        db | database)
            sudo bash database.sh $2
        ;;
        # Send Email
        e | email)
            bash send-email.sh
        ;;
        # Creates a Custom index.html File
        hp | homepage)
            bash create-homepage.sh
        ;;
        # Install Packages
        i | install)
            sudo bash install.sh $2
        ;;
        # System Status
        s | status)
            bash system-status.sh $2
        ;;
        # Service Status
        sv | service)
            bash service-status.sh $2
        ;;
        # Updates and Upgrades
        u | update)
            echo "==================="
            echo "Updating"
            echo "==================="
            sudo apt update && sudo apt upgrade -y
            echo "==================="
            echo "Updating Complete"
            echo "==================="
        ;;
        # Load a URL in the default browser
        w | www)
            bash load-www.sh $2
        ;;
        # CAUTION: Removes all packages, databases + installs
        reset)
            sudo bash reset.sh
        ;;
        # Exit
        x | exit)
            echo "==================="
            echo "Bye!"
            echo "==================="
            exit
        ;;
        *)
        echo "Sorry, That Option Is Not Available"
        
    esac

# Restart with menu or end program if called by arguments
# -----------------------------------------------------------
if [ "$1" ] 
then
    #echo "Task run in arguments complete - Bye!"
    exit
else
    echo -e "\n\n-----------------------"
    echo "Press Enter To Continue >>>"
    read x
    
    RESTART
fi