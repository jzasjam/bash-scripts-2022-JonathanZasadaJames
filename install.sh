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
operations[$i]="a  | apache    Install Apache"; ((i++))
operations[$i]="m  | mariadb   Install Maria DB"; ((i++))
operations[$i]="p  | php       Install PHP\n"; ((i++))

operations[$i]="wp | wordpress Install Wordpress\n"; ((i++))

operations[$i]="x  | exit      Exit Install Menu"; ((i++))


task=$1
if test -z "$task" 
then
    echo "============================="
    echo "What Do You Want To Install?"
    echo "============================="
    echo -e "Argument(s)\tDescription"
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
        m | mariadb)

            # If command line argument not provided to start install, show details
            if [ -z "$1" ]
            then
                echo "=================================="
                echo "Install: mariadb-server, mariadb-client & mysql_secure_installation"
                echo "=================================="
                echo "Current Version:"
                echo "----------------"
                if ! command -v mariadb &> /dev/null
                then
                    echo "MariaDB Not Installed"
                else
                    sudo mariadb -Version  
                fi
                echo "----------------"
                echo "Current Status:"
                echo "----------------"
                if ! command -v systemctl &> /dev/null
                then
                    sudo systemctl status mariadb
                else
                    # ON WSL
                    sudo service mysql status
                fi
                echo "----------------"
                echo "Install Maria DB? (y/n)"
                echo "----------------"
                read confirmation;
            else
                confirmation='y'
            fi

            # Once confirmed, install
            if [ $confirmation = 'y' ]
            then
                echo "==================="
                echo "Starting Install"
                echo "==================="
                
                sudo apt update
                    
                echo "y" | sudo apt install mariadb-server mariadb-client
                # After install start and enable
                if ! command -v systemctl &> /dev/null
                then
                    sudo systemctl start mariadb
                    sudo systemctl enable mariadb
                else
                    # ON WSL:https://linuxhandbook.com/system-has-not-been-booted-with-systemd/#:~:text=Linode-,How%20to%20fix%20'System%20has%20not%20been%20booted%20with%20systemd,commands%20have%20somewhat%20similar%20syntax.
                    sudo service mysql start
                fi
                echo "-------------------"
                echo "Running mysql_secure_installation"
                echo "-------------------"
                sudo mysql_secure_installation
                # After mysql_secure_installation install restart
                if ! command -v systemctl &> /dev/null
                then
                    sudo systemctl restart mariadb
                else
                    # ON WSL:https://linuxhandbook.com/system-has-not-been-booted-with-systemd/#:~:text=Linode-,How%20to%20fix%20'System%20has%20not%20been%20booted%20with%20systemd,commands%20have%20somewhat%20similar%20syntax.
                    sudo service mysql restart
                fi

                echo "==================="
                echo "Maria DB Installed"
                echo "==================="
                echo "Current Version:"
                echo "----------------"
                sudo mariadb -Version  
                echo "----------------"
                echo "Current Status:"
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
        a | apache)

            # If command line argument not provided to start install, show details
            if [ -z "$1" ]
            then
                echo "=================================="
                echo "Install: apache2 & lynx"
                echo "=================================="
                echo "Current Version:"
                echo "----------------"
                if ! command -v apache2 &> /dev/null
                then
                    echo "Apache Not Installed"
                else
                    sudo apache2 -v 
                fi
                 
                echo "----------------"
                echo "Current Status:"
                echo "----------------"
                if ! command -v systemctl &> /dev/null
                then
                    sudo systemctl status apache2
                else
                    # ON WSL
                    sudo service apache2 status
                fi
                sudo apachectl status
                echo "----------------"
                echo "Install Apache? (y/n)"
                echo "----------------"
                read confirmation;
            else
                confirmation="y"
            fi

            # Once confirmed, install
            if [ $confirmation = 'y' ]
            then
                echo "==================="
                echo "Starting Install"
                echo "==================="
                
                sudo apt update
                    
                # Install Apache 
                echo "y" | sudo apt install apache2
                sudo apt install apache2 apache2-utils

                # Enable Apache To Run On Startup
                sudo systemctl enable apache2

                echo "-------------------"
                echo "Installing Lynx"
                echo "-------------------"
                # Install Lynx  
                echo "y" | sudo apt install lynx

                
                echo "==================="
                echo "Apache Installed"
                echo "==================="
                echo "Current Version:"
                echo "----------------"
                sudo apache2 -v  
                echo "----------------"
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

                echo "Want to view http://localhost? (y/n)"
                read confirmation;

                if [ "$confirmation" = "y" ]
                then
                    sudo bash load-www.sh http://localhost
                fi

            else
                echo 'Install Cancelled'
            fi

        ;;
        p | php)
                
                # If command line argument not provided to start install, show details
                if [ -z "$1" ]
                then
                    echo "=================================="
                    echo "Install: PHP & Recommended Modules"
                    echo "=================================="
                    echo "Current Version:"
                    echo "----------------"
                    if ! command -v php &> /dev/null
                    then
                        echo "PHP Not Installed"
                    else  
                        php -v
                    fi
                    echo "----------------"
                    echo "Install PHP? (y/n)"
                    echo "----------------"
                    read confirmation;
                else
                    confirmation="y"
                fi
    
                # Once confirmed, install
                if [ "$confirmation" = 'y' ]
                then
                    echo "==================="
                    echo "Starting Install"
                    echo "==================="
                    
                    sudo apt update
                    
                    # Install PHP 
                    #echo "y" | sudo apt-get install php php-mysql php-fpm php-curl php-gd php-intl php-mbstring php-soap php-xml php-xmlrpc php-zip

                    echo "y" | sudo apt install ghostscript libapache2-mod-php php php-bcmath php-curl php-imagick php-intl php-json php-mbstring php-mysql php-xml php-zip
                    
                    # Restart Apache & get status
                    if ! command -v systemctl &> /dev/null
                    then
                        sudo systemctl restart apache2
                    else
                        # ON WSL
                        sudo service apache2 restart
                    fi

                    echo "==================="
                    echo "PHP Installed"
                    echo "==================="
                    echo "Current Version:"
                    echo "----------------"
                    php -v  
                else
                    echo 'Install Cancelled'
                fi
        ;;
        wp | wordpress)

            # If command line argument not provided to start install, show details
            if [ -z "$1" ]
            then
                echo "=================================="
                echo "Install: Wordpress"
                echo "=================================="
                echo "----------------"
                echo "Install Latest Wordpress? (y/n)"
                echo "----------------"
                read confirmation;
            else
                confirmation="y"
            fi

            # Once confirmed, install
            if [ "$confirmation" = "y" ]
            then
                echo "==================="
                echo "Starting Install"
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

                # Rename Wordpress Directory
                sudo mv /var/www/html/wordpress /var/www/html/wp
                wait

                # Change Wordpress Directory Permissions
                sudo chown -R www-data:www-data /var/www/html/wp
                sudo chmod -R 755 /var/www/html/wp

                echo "==================="
                echo "Wordpress Installed"
                echo "==================="

                echo "==================="
                echo "Wordpress Site Files"
                echo "==================="
                sudo cd /var/www/html/wp
                echo "List of /var/www/html/wp:"
                echo "-------------------------"
                sudo ls -la
                echo "==================="

                echo "==================="
                echo "Create Wordpress Database"
                echo "==================="

                read -p "Enter Wordpress Database Name: " wp_dbname
                read -p "Enter Wordpress Database User: " wp_dbuser
                # Confirm passwords are the same
                while [ true ] 
                do
                    read -s -p "Enter Database Password: " wp_dbpass
                    echo
                    read -s -p "Repeat Password: >" wp_dbpass2
                    echo
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
                echo "Wordpress Database Created"
                echo "-------------------"
                sudo mysql -u root -e "SHOW DATABASES;"
                sudo mysql -u root -e "SHOW GRANTS FOR '$wp_dbuser'@'localhost';"

                echo "==================="
                echo "Create Wordpress Config File"
                echo "==================="
                # Create Wordpress Config File
                sudo cp /var/www/html/wp/wp-config-sample.php /var/www/html/wp/wp-config.php
                sudo sed -i "s/database_name_here/$wp_dbname/g" /var/www/html/wp/wp-config.php
                sudo sed -i "s/username_here/$wp_dbuser/g" /var/www/html/wp/wp-config.php
                sudo sed -i "s/password_here/$wp_dbpass/g" /var/www/html/wp/wp-config.php

                echo "-------------------"
                echo "Wordpress Config File Created"
                echo "-------------------"
                cat wp-config.php
                echo "==================="


                echo "Want to view http://localhost/wp? (y/n)"
                read confirmation;

                if [ "$confirmation" = "y" ]
                then
                    sudo bash load-www.sh http://localhost/wp
                fi

            else
                echo 'Install Cancelled'
            fi
        ;;
        x | exit)
            echo "==================="
            echo "Leaving Install Menu!"
            echo "==================="
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