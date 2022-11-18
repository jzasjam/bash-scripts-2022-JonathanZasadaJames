#!/bin/bash

COLOR='\033[0m' # No Color

# Get this file name to use in restart function and reference elsewhere
    thisFile="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"
    function RESTART(){
        clear
        bash $thisFile 
        exit
    }

# Function to display a warning message 
    function WARNING(){
        RED='\033[0;31m'
        BRed='\033[1;31m' #Bold Red
        printf "${BRed}"
        printf "WARNING: $warning"
        printf "${COLOR}\n"   
    }

# Display a message and get user confirmation
    function CONFIRM(){
        echo -e "\n----------------------"
        echo " CONFIRMATION"
        echo "----------------------"
        echo "> Are you sure you want to $str? (y/n)"
        read confirmation;

        # Convert input to lower case
        confirmation=$(echo $confirmation | tr '[:upper:]' '[:lower:]')

        if [ "$confirmation" == "y" ]
        then
            clear
        else
            if [ "$confirmation" == "n" ]
            then
                RESTART
            else
                echo "Invalid Input"
                CONFIRM
            fi
        fi
    }

# Function to configure the SMTP settings
    function CONFIGURE_SMTP(){

        # Get the SMTP settings from the user
        echo "=============================="
        echo " Current SMTP Settings:"
        echo "=============================="
        root="$(sudo cat /etc/ssmtp/ssmtp.conf | grep 'root=' | cut -d'=' -f2)"
        echo "Root Email: $root"
        mailhub="$(sudo cat /etc/ssmtp/ssmtp.conf | grep 'mailhub=' | cut -d'=' -f2)"
        echo "Mailhub: $mailhub"
        hostname="$(sudo cat /etc/ssmtp/ssmtp.conf | grep 'hostname=' | cut -d'=' -f2)"
        echo "Hostname: $hostname"
        rewritedomain="$(sudo cat /etc/ssmtp/ssmtp.conf | grep 'rewriteDomain=' | cut -d'=' -f2)"
        echo "RewriteDomain: $rewritedomain"
        authuser="$(sudo cat /etc/ssmtp/ssmtp.conf | grep 'AuthUser=' | cut -d'=' -f2)"
        echo "AuthUser: $authuser"
        echo "-----------------"

        str="Enter New Configuration Settings"
        CONFIRM

        echo "y" | sudo apt-get install sendmail

        # UPDATE SMTP CONFIGURATION (/etc/ssmtp/ssmtp.conf)
        
        sudo cp ssmtp.conf.template /etc/ssmtp/ssmtp.conf
        
        # Ask for sending email address
        echo -e "\n--------------------------"
        echo "> Enter your sending email address:"
        read email;
        sudo sed -i "s/{root}/$email/g" /etc/ssmtp/ssmtp.conf
        sudo sed -i "s/{hostname}/$email/g" /etc/ssmtp/ssmtp.conf
        # Gett the domain name from the email address
        domain="$(sudo cat /etc/ssmtp/ssmtp.conf | grep 'root=' | cut -d'@' -f2)"
        sudo sed -i "s/{rewritedomain}/$domain/g" /etc/ssmtp/ssmtp.conf

        # Ask for SMTP Credentials
        echo "--------------------------"
        echo "> Enter your SMTP mail server (with port): (e.g. smtp.sendgrid.com:587)"
        read mailhub;
        sudo sed -i "s/{mailhub}/$mailhub/g" /etc/ssmtp/ssmtp.conf
        
        echo "--------------------------"
        echo "> Enter your SMTP username: (eg. apikey)"
        read authuser;
        sudo sed -i "s/{authuser}/$authuser/g" /etc/ssmtp/ssmtp.conf

        echo "--------------------------"
        echo "> Enter your SMTP password/API Key:"
        read authpass;
        sudo sed -i "s/{authpass}/$authpass/g" /etc/ssmtp/ssmtp.conf

    }


# Create an array of install options
    i=0
    operations[$i]=" s  | send       Send An Email"; ((i++))
    operations[$i]=" c  | config     Configure SMTP\n"; ((i++))

    operations[$i]=" x  | exit       Exit Install Menu"; ((i++))

# If no URL is provided in command line argument, set up asking for user input
    if [ -z "$1" ]
    then
        echo "=============================="
        echo " Send Email"
        echo "=============================="
        echo -e "\n-------------------------------------"
        echo -e " Options(s)\tDescription"
        echo "-------------------------------------"
        # Loop through the array and print out the arguments and descriptions menu 
        for key in "${!operations[@]}"; do
            printf "${operations[${key}]} \n"
        done
        # Get User Input For Install
        echo -e "\n\n> Select What To do..."
        read task   
        clear
    else
        # If Command Line Argument Provided
        echo "> SELECTED = $task"
    fi

# Convert entered task to lower case
task=$(echo $task | tr '[:upper:]' '[:lower:]')

# Case Statement Menu Selecting Task  
    case $task in

        # Send Email
        s | send)
            
            # Start Apache
                sudo bash service-status.sh start apache
                clear

            # Get From Email value from root=value in conf file
                from_email="$(sudo cat /etc/ssmtp/ssmtp.conf | grep 'root=' | cut -d'=' -f2)"

            # Check if command is available
                if [ ! command -v sendmail &> /dev/null ] || [ "$from_email" == "postmaster" ] || [ "$from_email" == null ]
                then
                    warning="sendmail is not installed or root email is not set in ssmtp.conf"
                    WARNING
                    #exit
                
                    # If not available, install it 
                    #warning="sendmail command could not be found"
                    #WARNING
                    echo "--------------------------"
                    str="Configure sendmail (Use SendGrid single sender email)"
                    CONFIRM
                    if [ "$confirmation" = "y" ]
                    then
                        
                        CONFIGURE_SMTP

                    else
                        echo "Sending Email Cancelled"
                        exit
                    fi
                fi

            # Send Email

                # Get From Email value from root=value in conf file
                from_email="$(sudo cat /etc/ssmtp/ssmtp.conf | grep 'root=' | cut -d'=' -f2)"
                # echo $from_email

                echo "=============================="
                echo " Send An Email"
                echo "=============================="

                str="send an email"
                CONFIRM

                echo "=============================="
                echo " Email Details"
                echo "=============================="
                echo "> Enter Email To Send To:"
                read email
                echo -e "\n> Subject:"
                read subject
                echo -e "\n> Message:"
                read message
                #echo $message | mail -s $subject $email
                echo -e "Subject: $subject \nFrom:$from_email \n\n $message" | sendmail $email

                echo -e "\n--------- Email Sent ----------"
                
        ;;

        # Configure SMTP
        c | config)
            CONFIGURE_SMTP
        ;;

        # Exit
        x | exit)
            echo "======================"
            echo " Leaving Email Menu"
            echo "======================"
            exit
        ;;
        *)
        echo "Sorry, That Option Is Not Available"
        
    esac

# Restart with menu (on enter) or end program if called by arguments
if [ "$1" ] 
then
    echo "Task run in arguments complete - Bye!"
else
    echo -e "\n\n-----------------------"
    echo "Press Enter To Continue >>>"
    read x
    
    RESTART
fi
