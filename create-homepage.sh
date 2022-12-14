#!/bin/bash

# Start Apache
    sudo bash service-status.sh start apache
    clear

echo "=============================="
echo "Create Homepage"
echo "=============================="

# Offer to show current homepage
    echo -e "\n Current Homepage:"
    echo "------------------------------"
    echo "> Want to view http://localhost/? (y/n)"
    read confirmation;
    if [ "$confirmation" = "y" ]
    then
        bash load-www.sh http://localhost/
    fi

# Check if Apache is running
    pidofApache=$(pidof apache2)
    if [ "$pidofApache" = NULL ]
    then
        echo -e "\nPlease Install/Start Apache Before Editing Your Homepage"
        exit
    fi

# Offer To Restore Default Home page
    echo -e "\n Restore Default Homepage:"
    echo "------------------------------"
    echo "> Want to restore default homepage? (y/n)"
    read confirmation;
    if [ "$confirmation" = "y" ]
    then
    
        # Make a backup of home page
        sudo mv /var/www/html/index.html /var/www/html/index.html.bak
        # Copy default-index.html to index.html
        sudo cp html/default-index.html /var/www/html/index.html

    else

        # Get User Input For Homepage Title
            echo -e "\n------------------------------"
            echo "> What is your name or the name of your site?"
            read name

        #Parse Current Date (for time live js counter on homepage)
            Year=`date +%Y`
            Month=`date +%m`
            Day=`date +%d`
            Hour=`date +%H`
            Minute=`date +%M`
            Second=`date +%S`

        # Format Required: Jan 5, 2022 15:37:25
            date_string="$Month $Day, $Year $Hour:$Minute:$Second"


        # Create HTML File
            # HTML from template: https://www.w3schools.com/howto/howto_css_coming_soon.asp
            # Move current index.html
            sudo mv /var/www/html/index.html /var/www/html/index.html.bak
            # Copy template files to /var/www/html
            sudo cp html/index.html /var/www/html/index.html
            sudo cp html/forestbridge.jpg /var/www/html/forestbridge.jpg

            # Replace placeholder text with user input and date created
            sudo sed -i "s/user_name_here/$name/g" /var/www/html/index.html
            sudo sed -i "s/date_string_here/$date_string/g" /var/www/html/index.html

    fi

    # Offer to show new homepage
    echo -e "\n> Want to view http://localhost/? (y/n)"
    read confirmation;
    if [ "$confirmation" = "y" ]
    then
        bash load-www.sh http://localhost/
    fi