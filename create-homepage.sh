#!/bin/bash

echo "=============================="
echo "Create Homepage"
echo "=============================="

if ! command -v apache2 &> /dev/null
then
echo "Please Install Apache First"
    exit
fi
# Get User Input
    echo "Enter Your Name"
    read name

#Parse Current Date
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
    sudo mv /var/www/html/index.html /var/www/html/index.html.bak
    sudo cp html/index.html /var/www/html/index.html
    sudo cp html/forestbridge.jpg /var/www/html/forestbridge.jpg

    sudo sed -i "s/user_name_here/$name/g" /var/www/html/index.html
    sudo sed -i "s/date_string_here/$date_string/g" /var/www/html/index.html
    echo "Want to view http://localhost/? (y/n)"
    read confirmation;

    if [ "$confirmation" = "y" ]
    then
        sudo bash load-www.sh http://localhost/
    fi