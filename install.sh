#!bin/bash/

# Set Text Colour
COLOR='\033[0;36m' # Cyan
printf "${COLOR}"

# Create an array of install options
i=0
operations[$i]="p   | php       Install PHP"; ((i++))
operations[$i]="mdb | mariadb   Install Maria DB"; ((i++))
operations[$i]="ap  | apache    Install Apache"; ((i++))
operations[$i]="wp  | wordpress Install Wordpress"; ((i++))
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
            if [ "$1" = NULL ]
            then
                echo 'Install Maria DB? (y/n)'
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
                sudo mysql_secure_installation
                sudo systemctl restart mariadb
                sudo systemctl enable mariadb
                # ON WSL:https://linuxhandbook.com/system-has-not-been-booted-with-systemd/#:~:text=Linode-,How%20to%20fix%20'System%20has%20not%20been%20booted%20with%20systemd,commands%20have%20somewhat%20similar%20syntax.
                sudo service mariadb start
                echo "==================="
                echo "Maria DB Installed"
                echo "==================="
                echo "Check Status:"
                sudo systemctl status mariadb
                # ON WSL
                sudo service mariadb status
                echo "==================="
            else
                echo 'Maria DB Not Installed'
            fi
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
