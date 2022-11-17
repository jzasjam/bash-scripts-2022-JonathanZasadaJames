#!/bin/bash

COLOR='\033[0m' # No Color

# Function to display a warning message 
    function WARNING(){
        RED='\033[0;31m'
        BRed='\033[1;31m' #Bold Red
        printf "${BRed}"
        printf "WARNING: $warning"
        printf "${COLOR}\n"   
    }

# If no URL is provided in command line argument, set up asking for user input
    if [ -z "$1" ]
    then
        echo "==================="
        echo "Visit A Web Page"
        echo "==================="
    fi

# Check if command is available
    if [ ! command -v xdg-open &> /dev/null ]
    then
        # If not available, install it 
        warning="xdg-open could not be found"
        WARNING
        echo "--------------------------"
        echo "Install xdg-open? (y/n)"
        read confirmation;
        if [ "$confirmation" = "y" ]
        then
            echo "y" | sudo apt install xdg-utils
        else
            echo "Page Load Cancelled"
            exit
        fi
    fi

# Get the URL from the command line argument or user input
    if [ -z "$1" ]
    then
        echo "Please Enter A URL >"
        read url
    else
        url=$1
    fi

# Open URL in default browser
    #xdg-open $url
    # Open quietly and in background
    bash -c "xdg-open $url" 2> /dev/null