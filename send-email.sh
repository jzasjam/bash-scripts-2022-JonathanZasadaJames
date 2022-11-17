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

    # Get From Email value from root=value in conf file
    from_email="$(sudo cat /etc/ssmtp/ssmtp.conf | grep 'root=' | cut -d'=' -f2)"
    # echo $from_email

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
        echo "Configure sendmail? (y/n) (Use SendGrid single sender email)"
        read confirmation;
        if [ "$confirmation" = "y" ]
        then
            echo "y" | sudo apt-get install sendmail

            # UPDATE SMTP CONFIGURATION (/etc/ssmtp/ssmtp.conf)
            
            sudo cp ssmtp.conf.template /etc/ssmtp/ssmtp.conf
            
            # Ask for sending email address
            echo "--------------------------"
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

        else
            echo "Sending Email Cancelled"
            exit
        fi
    fi

# Send Email

    # Get From Email value from root=value in conf file
    from_email="$(sudo cat /etc/ssmtp/ssmtp.conf | grep 'root=' | cut -d'=' -f2)"
    # echo $from_email

    echo -e "\nSend Email"
    echo -e "----------------------"
    echo "Send To Email >"
    read email
    echo "Subject >"
    read subject
    echo "Message >"
    read message
    #echo $message | mail -s $subject $email
    echo -e "Subject: $subject \nFrom:$from_email \n\n $message" | sendmail $email

    echo -e "\n--------- Email Sent ----------"
    