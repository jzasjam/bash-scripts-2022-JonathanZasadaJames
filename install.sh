#!bin/bash/

# Set Text Colour
COLOR='\033[0;36m' # Cyan
#printf "${COLOR}"

# Get this file name to use in restart function and reference elsewhere
    thisFile="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"
    function RESTART(){
        clear
        bash $thisFile 
    }

# Create an array of install options
    i=0
    operations[$i]=" a  | apache     Install Apache"; ((i++))
    operations[$i]=" m  | mariadb    Install Maria DB"; ((i++))
    operations[$i]=" p  | php        Install PHP\n"; ((i++))

    operations[$i]=" wp | wordpress  Install Wordpress\n"; ((i++))

    operations[$i]=" all             Install All Above\n"; ((i++))

    operations[$i]=" x  | exit       Exit Install Menu"; ((i++))


task=$1
if test -z "$task" 
then
    echo "============================="
    echo "What Do You Want To Install?"
    echo "============================="
    
    echo -e "\n-------------------------------------"
    echo -e " Options(s)\tDescription"
    echo "-------------------------------------"
    # Loop through the array and print out the arguments and descriptions menu 
    for key in "${!operations[@]}"; do
        printf "${operations[${key}]} \n"
    done
    # Get User Input For Install
    echo -e "\n\n> Select What To Install..."
    read task   
    clear
else
    # If Command Line Argument Provided
    echo "> INSTALL SELECTED = $task"
fi

# Convert entered task to lower case
task=$(echo $task | tr '[:upper:]' '[:lower:]')

# Case Statement Menu Selecting Task  
    case $task in

        # Install MariaDB
        m | mariadb)

            # If command line argument not provided to start install, show details
            if [ -z "$1" ]
            then
                echo "=================================="
                echo "Install: MariaDB Server+Client & mysql_secure_installation"
                echo "=================================="
                echo -e "\n Current Version:"
                echo "----------------"
                if ! command -v mariadb &> /dev/null
                then
                    echo "MariaDB Not Installed"
                else
                    sudo mariadb -Version  
                fi
                echo "----------------"
                echo " Current Status:"
                echo "----------------"
                if ! command -v systemctl &> /dev/null
                then
                    sudo systemctl status mariadb
                else
                    # ON WSL: https://linuxhandbook.com/system-has-not-been-booted-with-systemd/#:~:text=Linode-,How%20to%20fix%20'System%20has%20not%20been%20booted%20with%20systemd,commands%20have%20somewhat%20similar%20syntax.
                    sudo service mysql status
                fi
                echo "----------------"
                echo " Install Maria DB? (y/n)"
                echo "----------------"
                read confirmation;
            else
                confirmation='y'
            fi

            # Once confirmed, install
            if [ "$confirmation" = "y" ]
            then
                clear
                echo "==================="
                echo " Installing MariaDB..."
                echo "==================="
                
                # Update
                sudo apt update

                # Install MariaDB    
                echo "y" | sudo apt install mariadb-server mariadb-client

                # After install start and enable
                if ! command -v systemctl &> /dev/null
                then
                    sudo systemctl start mariadb
                    sudo systemctl enable mariadb
                else
                    # ON WSL
                    sudo service mysql start
                fi

                # Secure Install
                clear
                echo -e "\n-------------------"
                echo " Running mysql_secure_installation"
                echo "-------------------"
                sudo mysql_secure_installation
                # After mysql_secure_installation install restart
                if ! command -v systemctl &> /dev/null
                then
                    sudo systemctl restart mariadb
                else
                    # ON WSL
                    sudo service mysql restart
                fi

                # Display confirmation and version/status
                clear
                echo "==================="
                echo " Maria DB Installed"
                echo "==================="
                echo -e "\n Current Version:"
                echo "----------------"
                sudo mariadb -Version  
                echo -e "\n----------------"
                echo " Current Status:"
                echo "----------------"
                if ! command -v systemctl &> /dev/null
                then
                    sudo systemctl status mariadb
                else
                    # ON WSL
                    sudo service mysql status
                fi
                echo "==================="
            else
                echo 'Install Cancelled'
            fi
        ;;

        # Install Apache
        a | apache)
            # If command line argument not provided to start install, show details
            if [ -z "$1" ]
            then
                clear
                echo "=================================="
                echo " Install: Apache & Lynx"
                echo "=================================="
                echo -e "\nCurrent Version:"
                echo "----------------"
                # if apache2 is installed
                if ! command -v apache2 &> /dev/null
                then
                    echo "Apache Not Installed"
                else
                    sudo apache2 -v 
                fi
                 
                echo -e "\n----------------"
                echo " Current Status:"
                echo "----------------"
                if ! command -v systemctl &> /dev/null
                then
                    sudo systemctl status apache2
                else
                    # ON WSL
                    sudo service apache2 status
                fi
                sudo apachectl status
                echo -e "\n----------------"
                echo " Install Apache? (y/n)"
                echo "----------------"
                read confirmation;
            else
                confirmation="y"
            fi

            # Once confirmed, install
            if [ "$confirmation" = "y" ]
            then
                clear
                echo "==================="
                echo " Installing Apache..."
                echo "==================="
                
                # Update
                sudo apt update
                    
                # Install Apache 
                echo "y" | sudo apt install apache2
                sudo apt install apache2 apache2-utils

                # Enable Apache To Run On Startup
                sudo systemctl enable apache2

                # Install Lynx  
                echo -e "\n-------------------"
                echo " Installing Lynx..."
                echo "-------------------"
                echo "y" | sudo apt install lynx

                # Display confirmation and version/status
                clear
                echo -e "\n==================="
                echo "Apache Installed"
                echo "==================="
                echo -e "\nCurrent Version:"
                echo "----------------"
                sudo apache2 -v  
                echo -e "\n----------------"
                echo "Current Status:"
                echo "----------------"

                # Restart Apache & get status
                if ! command -v systemctl &> /dev/null
                then
                    sudo systemctl restart apache2
                    sudo systemctl status apache2
                else
                    # ON WSL
                    sudo service apache2 restart
                    sudo service apache2 status
                fi
                sudo apachectl status
                echo "==================="

                # Create index.html if it doesn't exist
                if [ ! -f /var/www/html/index.html ]
                then
                    echo -e "\n-------------------"
                    echo " Creating index.html"
                    echo "-------------------"
                    # Create index.html
                    sudo touch /var/www/html/index.html
                    # Add content to index.html
                     # Template: html/default-index.html minified at https://www.willpeavy.com/tools/minifier/
                    html='<!DOCTYPE html><html> <head> <title>Home Page</title> <style>body, html{height: 100%; margin: 0;}body{word-break: break-word;}.bgimg{height: 100%; background-position: center; background-size: cover; position: relative; color: black; font-family: "Courier New", Courier, monospace; font-size: 25px;}.topleft{position: absolute; top: 0; left: 16px;}.bottomleft{position: absolute; bottom: 0; left: 16px;}.middle{position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); text-align: center;}i.main-icon{font-size: 5em;}hr{margin: auto; width: 40%;}</style> <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.2.0/css/all.min.css" integrity="sha512-xh6O/CkQoPOWDdYTDqeRdPCVd1SpvCA9XXcUnZS2FmJNp1coAFzvtCN9BmamE+4aHK8yyUHUSCcJHgXloTyT2A==" crossorigin="anonymous" referrerpolicy="no-referrer"/> <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.2.0/css/fontawesome.min.css" integrity="sha512-RvQxwf+3zJuNwl4e0sZjQeX7kUa3o82bDETpgVCH2RiwYSZVDdFJ7N/woNigN/ldyOOoKw8584jM4plQdt8bhA==" crossorigin="anonymous" referrerpolicy="no-referrer"/> </head><body><div class="bgimg"> <div class="topleft"> <p>Hooray...</p></div><div class="middle"> <h1><i class="main-icon fa-regular fa-face-laugh-beam"></i></h1> <h1><i class="fa-solid fa-check"></i> Your Server Is Active!</h1> <hr> <p id="demo" style="font-size:30px"></p></div><div class="bottomleft"> <p></p></div></div></body></html>'
                    sudo echo "$html" > /var/www/html/index.html
                fi
                
                # Offer to open index.html in browser
                echo -e "\n------------------------------"
                echo "> Want to view http://localhost? (y/n)"
                read confirmation;
                if [ "$confirmation" = "y" ]
                then
                    sudo bash load-www.sh http://localhost
                fi

                # Offer to create custom home page
                echo -e "\n------------------------------"
                echo "> Want to customise your homepage? (y/n)"
                read confirmation;

                if [ "$confirmation" = "y" ]
                then
                    sudo bash create-homepage.sh
                fi

            else
                echo 'Install Cancelled'
            fi

        ;;

        # Install PHP
        p | php)
                
                # If command line argument not provided to start install, show details
                if [ -z "$1" ]
                then
                    echo "=================================="
                    echo "Install: PHP & Recommended Modules"
                    echo "=================================="
                    echo -e "\n Current Version:"
                    echo "----------------"
                    if ! command -v php &> /dev/null
                    then
                        echo "PHP Not Installed"
                    else  
                        php -v
                    fi
                    echo -e "\n----------------"
                    echo " Install PHP? (y/n)"
                    echo "----------------"
                    read confirmation;
                else
                    confirmation="y"
                fi
    
                # Once confirmed, install
                if [ "$confirmation" = 'y' ]
                then
                    clear
                    echo -e "\n==================="
                    echo " Installing PHP..."
                    echo "==================="
                    
                    sudo apt update
                    
                    # Install PHP 
                    #echo "y" | sudo apt-get install php php-mysql php-fpm php-curl php-gd php-intl php-mbstring php-soap php-xml php-xmlrpc php-zip

                    echo "y" | sudo apt install ghostscript libapache2-mod-php php php-bcmath php-curl php-imagick php-intl php-json php-mbstring php-mysql php-xml php-zip
                    
                    # Restart Apache 
                    if ! command -v systemctl &> /dev/null
                    then
                        sudo systemctl restart apache2
                    else
                        # ON WSL
                        sudo service apache2 restart
                    fi

                    clear
                    echo -e "\n==================="
                    echo " PHP Installed"
                    echo "==================="
                    echo -e "\n Current Version:"
                    echo "----------------"
                    php -v  

                    # Create phpinfo.php
                    sudo echo "<?php phpinfo(); ?>" > /var/www/html/phpinfo.php
                    echo -e "\n------------------------------"
                    echo "> Want to view http://localhost/phpinfo.php? (y/n)"
                    read confirmation;
                    if [ "$confirmation" = "y" ]
                    then
                        sudo bash load-www.sh http://localhost/phpinfo.php
                    fi
                    
                else
                    echo 'Install Cancelled'
                fi
        ;;

        # Install WordPress
        wp | wordpress)

            # If command line argument not provided to start install, show details
            if [ -z "$1" ]
            then
                echo "=================================="
                echo " Install: Wordpress"
                echo "=================================="
                echo -e "\n------------------------------"
                echo " Install Latest Wordpress? (y/n)"
                echo "------------------------------"
                read confirmation;
            else
                confirmation="y"
            fi

            # Once confirmed, install
            if [ "$confirmation" = "y" ]
            then
                clear
                echo -e "\n==================="
                echo " Installing Wordpress..."
                echo "==================="

                # Download Latest Wordpress
                sudo wget -O /tmp/wordpress.tar.gz https://wordpress.org/latest.tar.gz
                wait

                # Extract Wordpress Download
                sudo tar -xzvf /tmp/wordpress.tar.gz -C /var/www/html
                wait

                # Remove Temporary Wordpress Download
                sudo rm /tmp/wordpress.tar.gz
                wait

                # Rename Wordpress Directory from /wordpress to /wp
                sudo mv /var/www/html/wordpress /var/www/html/wp
                wait

                # Change Wordpress Directory Permissions
                sudo chown -R www-data:www-data /var/www/html/wp
                sudo chmod -R 755 /var/www/html/wp

                clear
                echo "==================="
                echo " Wordpress Installed"
                echo "==================="

                echo -e "\n------------------------------"
                echo " Create Wordpress Database"
                echo "------------------------------"

                # Get User Values
                echo -e "\n> Enter New Wordpress Database Name: "
                read wp_dbname
                echo -e "\n> Enter New Wordpress Database User: "
                read wp_dbuser
                echo -e "\n> Enter New Wordpress Database Password: "
                read wp_dbpass

                # Confirm passwords are the same
                while [ true ] 
                do
                    echo -e "\n> Enter New Wordpress Database Password: "
                    read -s wp_dbpass
                    echo "> Repeat Password: "
                    read -s wp_dbpass2
                    if [ "$wp_dbpass" != "$wp_dbpass2" ]; 
                    then
                        clear
                        warning="Passwords do not match"
                        WARNING
                    else
                        break
                    fi  
                done  

                #Create Database
                sudo mysql -u root -e "CREATE DATABASE $wp_dbname;"
                sudo mysql -u root -e "CREATE USER '$wp_dbuser'@'localhost' IDENTIFIED BY '$wp_dbpass';"
                sudo mysql -u root -e "GRANT ALL PRIVILEGES ON $wp_dbname.* TO '$wp_dbuser'@'localhost';"
                sudo mysql -u root -e "FLUSH PRIVILEGES;"

                echo "-------------------"
                echo " Wordpress Database Created"
                echo "-------------------"
                sudo mysql -u root -e "SHOW DATABASES;"
                sudo mysql -u root -e "SHOW GRANTS FOR '$wp_dbuser'@'localhost';"

                echo -e "\n==================="
                echo " Create Wordpress Config File"
                echo "==================="
                # Create Wordpress Config File
                sudo cp /var/www/html/wp/wp-config-sample.php /var/www/html/wp/wp-config.php
                sudo sed -i "s/database_name_here/$wp_dbname/g" /var/www/html/wp/wp-config.php
                sudo sed -i "s/username_here/$wp_dbuser/g" /var/www/html/wp/wp-config.php
                sudo sed -i "s/password_here/$wp_dbpass/g" /var/www/html/wp/wp-config.php

                echo "-------------------"
                echo " Wordpress Config File Created"
                echo "-------------------"
                cat /var/www/html/wp/wp-config.php
                echo -e "\n==================="

                # Offer to view Wordpress Site
                echo "> Want to view http://localhost/wp? (y/n)"
                read confirmation;
                if [ "$confirmation" = "y" ]
                then
                    sudo bash load-www.sh http://localhost/wp
                fi

            else
                echo 'Install Cancelled'
            fi
        ;;

        # Install Apache, MariaDB, PHP, Wordpress
        all)
            bash $thisFile a
            bash $thisFile m
            bash $thisFile p
            bash $thisFile wp
        ;;

        # Exit
        x | exit)
            echo "======================"
            echo " Leaving Install Menu"
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