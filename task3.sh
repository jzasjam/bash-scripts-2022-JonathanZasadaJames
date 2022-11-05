#!/bin/bash

: '
- Automatic creation and rights management of a new user
- Application of firewall rules
- Extraction of monitoring information in a file
- Conduct system management activities on a regular basis

- Automated installation of a software
'

# Create an array of arguments/tasks to complete
declare -A argument
argument+=(["h | help"]="Get Some Help" )
argument+=(["u | update"]="Update and Upgrade The Operating System")
argument+=(["i | install"]="**Install Packages")
argument+=(["d | demo"]="See Bash Demo")
argument+=(["db | database"]="**Database Management")
argument+=(["us | user"]="**User Management")
argument+=(["c | cpu"]="**CPU Monitor to Log")
#argument+=(["r | restart"]="Restart")
argument+=(["w | www"]="**Open A Web Page")
argument+=(["x | exit"]="Quit / Exit")

declare -A installs
installs+=(["p | php"]="Install PHP")
installs+=(["mdb | mariadb"]="Install Maria DB" )
installs+=(["a | apache"]="Install Apache")
installs+=(["wp | wordpress"]="Install Wordpress")



# Get this file name to use in restart function and reference elsewhere
thisFile="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"
function RESTART(){
    #echo -e "\n\n"
    clear
    bash $thisFile 
}

# See If Command Line Argument Provided
    task=$1
    if test -z "$task" 
    then
        # If No Command Line Argument Provided
        echo "=================================================================="
        echo "   AVAILABLE TASKS"
        echo "=================================================================="
        echo "NOTE: Use 'bash $thisFile {argument}' to start automatically"

        echo "----------------------"
        echo -e "Argument(s) \t Description"
        echo "----------------------"

        # Loop through the array and print out the arguments and descriptions menu 
        for key in "${!argument[@]}"; do
            printf "${key} \t"
            printf "${argument[${key}]} \n"
        done

        # Get User Input For Task
        echo -e "\n\n> Select A Task (Enter An Argument)..."
        read task
        # Convert entered task to lower case
        task=$(echo $task | tr '[:upper:]' '[:lower:]')
        
        clear
    else
        # If Command Line Argument Provided
        echo "> TASK SELECTED = $task"
    fi


 # Case Statement Menu Selecting Task  
    case $task in
        h | help)
            bash help.sh
        ;;
        d | demo)
            bash bash.sh "bashbook.txt "
        ;;
        r | restart)
            echo "==================="
            echo "Restarting"
            echo "==================="
        ;;
        i | install)
            echo "==================="
            echo "What Do You Want To Install?"
            echo "==================="
             # Loop through the array and print out the arguments and descriptions menu 
            for key in "${!installs[@]}"; do
                printf "${key} \t"
                printf "${installs[${key}]} \n"
            done
            # Get User Input For Install
            echo -e "\n\n> Select What To Install..."
            read task
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
            echo "==================="
            echo "Visit A Web Page"
            echo "==================="
            # Check if command is available
            if ! command -v xdg-open &> /dev/null
            then
                # If not available, install it 
                echo "xdg-open could not be found"
                sudo apt install xdg-utils
                wait
            fi
            echo "Please Enter A URL >"
            read url
            xdg-open $url
            
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
    # Sleep for 2 secs then restart the menu/script
    #clear
    #echo "Restarting..."
    #sleep 1
    
    RESTART
fi