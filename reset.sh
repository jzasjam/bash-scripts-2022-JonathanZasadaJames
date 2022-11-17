#!/bin/bash

echo "=============================="
echo "Remove Everything"
echo "=============================="

echo "Do You Really Want To Remove Everything (y/n)?"
read confirmation;
# Once confirmed, install
if [ "$confirmation" = "y" ]
then

    # Remove Apache
    ########################################
        echo "--------------------------"
        echo "Removing Apache"
        echo "--------------------------"
        if ! command -v systemctl &> /dev/null
        then
            sudo systemctl stop apache2
        else
            # ON WSL
            sudo service apache2 stop
        fi
        sudo apt remove apache2 -y
        sudo apt purge apache2 -y
        sudo apt remove apache2.* -y

    # Remove MariaDB/MySQL
    ########################################
        echo "--------------------------"
        echo "Removing MariaDB/MySQL"
        echo "--------------------------"
        if ! command -v systemctl &> /dev/null
        then
            sudo systemctl stop mariadb
        else
            # ON WSL
            sudo service mysql stop
        fi
        sudo /etc/init.d/mysql stop
        sudo apt-get purge mysql* mariadb*

    # Remove PHP
    ########################################
        # Get PHP Version (7.4, 8.0, etc)
        #phpVersion=$(php -r 'echo PHP_VERSION;')
        # Get PHP Major Version (eg 7, 8)
        phpVersion=$(php -r 'echo PHP_MAJOR_VERSION;')
        sudo apt-get purge php$phpVersion.* -y

    #Remove Wordpress
    ########################################
        echo "--------------------------"
        echo "Removing Wordpress"
        echo "--------------------------"
        sudo rm -rf /var/www/html/wp

    # Remove other HTML/PHP Files
    ########################################
        echo "--------------------------"
        echo "Removing HTML/PHP Files"
        echo "--------------------------"
        sudo rm -rf /var/www/html/
        wait
        sudo mkdir /var/www/html


fi