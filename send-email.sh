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
        echo " Send An Email"
        echo "==================="
    fi

# Check if command is available
    if [ ! command -v sendmail &> /dev/null ]
    then
        # If not available, install it 
        warning="sendmail command could not be found"
        WARNING
        echo "--------------------------"
        echo "Install sendmail? (y/n)"
        read confirmation;
        if [ "$confirmation" = "y" ]
        then
            echo "y" | sudo apt-get install sendmail

            # UPDATE SMTP CONFIGURATION (/etc/ssmtp/ssmtp.conf)
            : '
            #
            # Config file for sSMTP sendmail
            #
            # The person who gets all mail for userids < 1000
            # Make this empty to disable rewriting.
            root=c1051167@my.shu.ac.uk

            # The place where the mail goes. The actual machine name is required no
            # MX records are consulted. Commonly mailhosts are named mail.domain.com
            mailhub=smtp.sendgrid.com:587

            AuthUser=apikey
            AuthPass={API-KEY-HERE}
            UseTLS=YES
            UseSTARTTLS=YES

            # Where will the mail seem to come from?
            rewriteDomain=my.shu.ac.uk

            # The full hostname
            hostname=c1051167@my.shu.ac.uk
            '

        else
            echo "Sending Email Cancelled"
            exit
        fi
    fi

# Send Email
    echo -e "\nSend Email"
    echo -e "----------------------"
    echo "Send To Email >"
    read email
    echo "Subject >"
    read subject
    echo "Message >"
    read message
    #echo $message | mail -s $subject $email
    echo -e "Subject: $subject \n\n $message" | sendmail $email
    