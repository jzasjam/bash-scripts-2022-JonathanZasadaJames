#!/bin/bash

# Set Text Colour
NC='\033[0m' # No Color
printf "${NC}"

: '
- Automatic creation and rights management of a new user
- Application of firewall rules
- Extraction of monitoring information in a file
- Conduct system management activities on a regular basis

- Automated installation of a software
'

# Create an array of arguments/tasks to complete
i=0
operations[$i]="h  | help       Get Some Help"; ((i++))
operations[$i]="d  | demo       See Bash Demo\n"; ((i++))

operations[$i]="u  | update     Update and Upgrade The Operating System"; ((i++))
operations[$i]="i  | install    **Install Packages"; ((i++))
operations[$i]="db | database   Database Management\n"; ((i++))

#operations[$i]="us | user       **User Management\n"; ((i++))

#operations[$i]="c  | cpu        **CPU Monitor to Log\n"; ((i++))


#operations[$i]="c  | cpu        **Design Your Index"; ((i++))
operations[$i]="w  | www        Open A Web Page\n"; ((i++))

operations[$i]="x  | exit       Quit / Exit"; ((i++))


# Get this file name to use in restart function and reference elsewhere
thisFile="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"
function RESTART(){
    #echo -e "\n\n"
    clear
    bash $thisFile 
}

# See If Command Line Argument Provided
    task=$1
    if [ -z "$task" ]
    then
        # If No Command Line Argument Provided
        clear
        echo "=================================================================="
        echo "   AVAILABLE TASKS"
        echo "=================================================================="
        echo "NOTE: Use 'bash $thisFile {argument}' to start automatically"

        echo "-------------------------------------"
        echo -e "Argument(s)\tDescription"
        echo "-------------------------------------"

        # Loop through the array and print out the arguments and descriptions menu 
        for key in "${!operations[@]}"; do
            printf "${operations[${key}]} \n"
        done

        # Get User Input For Task
        echo -e "\n\n> Select A Task (Enter An Argument)..."
        read task 
        clear
    else
        # If Command Line Argument Provided
        echo "> TASK SELECTED = $task"
    fi

# Convert entered task to lower case
    task=$(echo $task | tr '[:upper:]' '[:lower:]')

 # Case Statement Menu Selecting Task  
    case $task in
        h | help)
            bash help.sh $thisFile
        ;;
        d | demo)
            bash demo.sh "bashbook.txt "
        ;;
        db | database)
            sudo bash database.sh
        ;;
        i | install)
            sudo bash install.sh $2
        ;;
        u | update)
            echo "==================="
            echo "Updating"
            echo "==================="
            sudo apt update && sudo apt upgrade 
            echo "==================="
            echo "Updating Complete"
            echo "==================="
        ;;
        w | www)
            sudo bash load-www.sh $2
        ;;
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
if [ "$1" ] 
then
    echo "Task run in arguments complete - Bye!"
else
    echo -e "\n\n-----------------------"
    echo "Press Enter To Continue >>>"
    read x
    
    RESTART
fi