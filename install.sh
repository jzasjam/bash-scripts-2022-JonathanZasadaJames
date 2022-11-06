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
operations[$i]="ap  | apache    Install Apache"; ((i++))
operations[$i]="mdb | mariadb   Install Maria DB"; ((i++))
operations[$i]="p   | php       Install PHP\n"; ((i++))

operations[$i]="wp  | wordpress Install Wordpress\n"; ((i++))

operations[$i]="x   | exit      Exit Install Menu"; ((i++))


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
        mdb | mariadb)
            
            if [ -z "$1" ]
            then
                echo "Install: mariadb-server, mariadb-client & mysql_secure_installation"
                echo "=================================="
                echo "Current Version:"
                echo "----------------"
                sudo mariadb -Version  
                echo "----------------"
                echo "Current Status:"
                echo "----------------"
                sudo systemctl status mariadb
                # ON WSL
                sudo service mysql status
                echo "----------------"
                echo "Install Maria DB? (y/n)"
                echo "----------------"
                read confirmation;
            else
                confirmation='y'
            fi

            if [ $confirmation = 'y' ]
            then
                echo "y" | sudo apt install mariadb-server mariadb-client
                echo "==================="
                echo "Run mysql_secure_installation"
                echo "==================="
                sudo systemctl restart mariadb
                sudo systemctl enable mariadb
                # ON WSL:https://linuxhandbook.com/system-has-not-been-booted-with-systemd/#:~:text=Linode-,How%20to%20fix%20'System%20has%20not%20been%20booted%20with%20systemd,commands%20have%20somewhat%20similar%20syntax.
                sudo service mysql start

                sudo mysql_secure_installation

                echo "==================="
                echo "Maria DB Installed"
                echo "==================="
                echo "Check Status:"
                sudo systemctl status mariadb
                # ON WSL
                sudo service mysql status
                echo "==================="
            else
                echo 'Maria DB Not Installed'
            fi
        ;;
        ap | apache)
            # Install Apache 
            echo "y" | sudo apt install apache2
            sudo apt install apache2 apache2-utils

            # Enable Apache To Run On Startup
            sudo systemctl enable apache2
            # ON WSL
            sudo service apache2 enable

            # Install Lynx  
            echo "y" | sudo apt install lynx

            # Restart Apache 
            sudo systemctl restart apache2
            # ON WSL
            sudo service apache2 restart

            # Check Apache Status
            sudo systemctl status apache2
            sudo apachectl status
            # ON WSL
            sudo service apache2 status

        ;;
        x | exit)
            echo "==================="
            echo "Bye!"
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