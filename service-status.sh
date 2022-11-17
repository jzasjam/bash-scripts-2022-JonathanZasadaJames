#!bin/bash/

# SET THE COLORS
COLOR='\033[0m' # No Color
# COLOR ARRAY FOR STATUS TEXT
COL[0]='\033[1;31m' #Bold Red
COL[1]='\033[1;32m' #Bold Green

# Display message in colour depending on the status
function COLOR_TEXT(){
    printf "${COL[$status]}"
    printf " $message"
    printf "${COLOR}\n\n"    
}

# Get this file name to use in restart function and reference elsewhere
    thisFile="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"
    function RESTART(){
        clear
        bash $thisFile 
    }

# Check Apache Status
function APACHE_STATUS(){
    # if apache2 is installed
    echo "--- Apache Status ---"
    if [ ! command -v apache2 &> /dev/null ]
    then
        echo "Apache Is Not Installed"
    else
        status=0
        if ! command -v systemctl &> /dev/null
        then
            #sudo systemctl status apache2
            if sudo systemctl status apache2 | grep -q "is running"; 
            then
                status=1
            fi
        else
            # ON WSL
            #sudo service apache2 status
            if sudo service apache2 status | grep -q "is running"; 
            then
                status=1
            fi
        fi
        if [ $status -eq 1 ]
        then
            message="Apache Is Running"
            COLOR_TEXT
        else
            message="Apache Is Not Running"
            COLOR_TEXT
        fi
        #sudo apachectl status
    fi
}

# Check MariaDB Status
function MARIADB_STATUS(){
    # if mariadb is installed
    echo "--- MariaDB Status ---"
    if [ ! command -v mariadb &> /dev/null ]
    then
        echo "MariaDB Not Installed"
    else
        status=0
        if [ ! command -v systemctl &> /dev/null ] 
        then
            #sudo systemctl status mariadb
            if sudo systemctl status mariadb | grep -q "Uptime"; 
            then
                status=1
            fi
        else
            # ON WSL
            #sudo service mysql status
            if sudo service mysql status | grep -q "Uptime"; 
            then
                status=1
            fi
        fi
        if [ $status -eq 1 ]
        then
            message="MariaDB Is Running"
            COLOR_TEXT
        else
            message="MariaDB Is Not Running"
            COLOR_TEXT
        fi
    fi
}


#------------------------------------------------------------
# Output Starts Here

# Create an array of options
    i=0
    operations[$i]=" 1 | start      Start Services"; ((i++))
    operations[$i]=" 0 | stop       Stop Services"; ((i++))
    operations[$i]=" r | restart    Restart Services"; ((i++))
    operations[$i]=" s | status     Full Service Status\n"; ((i++))
    operations[$i]=" x | exit       Leave This Menu\n"; ((i++))

    echo "============================="
    echo "What Do You Want To Do?"
    echo -e "=============================\n"
    
    APACHE_STATUS
    MARIADB_STATUS

    echo -e "\n-------------------------------------"
    echo -e " Options(s)\tDescription"
    echo "-------------------------------------"
    # Loop through the array and print out the arguments and descriptions menu 
    for key in "${!operations[@]}"; do
        printf "${operations[${key}]} \n"
    done
    # Get User Input For Install
    echo -e "\n\n> Select What To Do..."
    read task   
    clear


#------------------------------------------------------------
# Chosen Task Starts Here
 
# Case Statement Menu Selecting Task  
    case $task in

        # Start Services
        1 | start)
            echo -e "\n Starting Services..."
            echo "=============================="
            echo -e "\n Starting Apache..."
            sudo service apache2 start
            echo -e "\n Starting MariaDB..."
            sudo service mysql start
        ;;

        # Stop Services
        0 | stop)
            echo -e "\n Stopping Services..."
            echo "=============================="

            echo -e "\n Stopping Apache..."
            sudo service apache2 stop
            echo -e "\n Stopping MariaDB..."
            sudo service mysql stop
        ;;

        # Restart Services
        r | restart)
            echo -e "\n Restarting Services..."
            echo "=============================="
            
            echo -e "\n Restarting Apache..."
            sudo service apache2 restart
            echo -e "\n Restarting MariaDB..."
            sudo service mysql restart
        ;;

        # Status
        s | status)
            
            # Check Apache Status
                # if apache2 is installed
                echo "=============================="
                echo " Apache Status"
                echo "=============================="
                if [ ! command -v apache2 &> /dev/null ]
                then
                    echo "Apache Not Installed"
                else
                    if ! command -v systemctl &> /dev/null
                    then
                        sudo systemctl status apache2
                    else
                        # ON WSL
                        sudo service apache2 status
                    fi
                    echo -e "\n-----------------------------"
                    sudo apachectl status
                fi

            # Check MariaDB Status
                # if mariadb is installed
                echo -e "\n=============================="
                echo " MariaDB Status"
                echo "=============================="
                if [ ! command -v mariadb &> /dev/null ]
                then
                    echo "MariaDB Not Installed"
                else
                    if [ ! command -v systemctl &> /dev/null ] 
                    then
                        sudo systemctl status mariadb
                    else
                        # ON WSL
                        sudo service mysql status 
                    fi
                fi
        ;;

        # Exit
        x | exit)
            echo "======================"
            echo " Leaving Status Menu"
            echo "======================"
            exit
        ;;
        *)
        echo "Sorry, That Option Is Not Available"
    esac


#------------------------------------------------------------
# Post Task Happens Here

    
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