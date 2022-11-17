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
operations[$i]="h  | help       Get Some Help"; ((i++))
operations[$i]="d  | demo       See Bash Demo"; ((i++))
operations[$i]="w  | www        Open A Web Page\n"; ((i++))

# LAMP Stack Setup & Management
operations[$i]="u  | update     Update and Upgrade"; ((i++))
operations[$i]="s  | status     Service Status (Apache/MariaDB)"; ((i++))
operations[$i]="i  | install    Install Packages (Apache/MariaDB/PHP/Wordpress)\n"; ((i++))

operations[$i]="db | database   Database Management"; ((i++))
operations[$i]="hp | homepage   Create Homepage\n"; ((i++))

# OS Tasks
#operations[$i]="us | user       **User Management\n"; ((i++))
#operations[$i]="c  | cpu        **CPU Monitor to Log\n"; ((i++))

# Exit
operations[$i]="x  | exit       Quit / Exit"; ((i++))


# Get this file name to use in restart function and reference elsewhere
thisFile="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"
function RESTART(){
    #echo -e "\n\n"
    clear
    bash $thisFile 
}

# See If Command Line Argument Provided or Get User Input
# -----------------------------------------------------------
    task=$1
    if [ -z "$task" ]
    then
        # If No Command Line Argument Provided
        clear
        echo "=================================================================="
        echo "   AVAILABLE TASKS"
        echo "=================================================================="
        echo " NOTE: Use 'bash $thisFile {argument}' to start automatically"

        echo -e "\n-------------------------------------"
        echo -e " Options(s)\tDescription"
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
        # Creates a Custom index.html File
        hp | homepage)
            sudo bash create-homepage.sh
        ;;
        # Install Packages
        i | install)
            sudo bash install.sh $2
        ;;
        # Service Status
        s | status)
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