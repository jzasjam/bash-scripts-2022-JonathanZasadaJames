#!/bin/bash


# Create an array of arguments/tasks to complete
declare -A argument
argument+=(["u | update"]="Update and Upgarde The Operating System")
argument+=(["h | help"]="Get Some Help" )
argument+=(["p | prize"]="Win A Prize")
argument+=(["r | restart"]="Restart")
argument+=(["w | www"]="Open A Web Page")
argument+=(["x | exit"]="Quit / Exit")


# Get this filename to use in restart function and reference elsewhere
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
            echo "==================="
            echo "Help"
            echo "==================="
            echo "You Got First Prize"
        ;;
        p | prize)
            echo "==================="
            echo "Win A Prize"
            echo "==================="
            sudo bash bash.sh
        ;;
        r | restart)
            echo "==================="
            echo "Restarting"
            echo "==================="
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