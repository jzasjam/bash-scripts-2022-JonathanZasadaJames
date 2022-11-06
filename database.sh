#!/bin/bash

# Set Text Colour
COLOR='\033[0;33m' #YELLOW
printf "${COLOR}"  

# Get this file name to use in restart function and reference elsewhere
thisFile="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"
function RESTART(){
    clear
    bash $thisFile 
}

# Intoduction Message
echo "=============================="
echo "Database Management"
echo "=============================="
echo "-------------------------------------"
printf "Argument(s)         Description\n"
echo "-------------------------------------"
# Create an array of database operations to complete
i=0
operations[$i]="s    | show         Show Databases"; ((i++))
operations[$i]="c    | create       Create Database"; ((i++))
operations[$i]="d    | drop         Drop/Delete Database\n"; ((i++))

operations[$i]="su   | showusers    Show Users"; ((i++))
operations[$i]="cu   | createuser   Create User"; ((i++))
operations[$i]="du   | dropuser     Drop/Delete User\n"; ((i++))

operations[$i]="dbu  | adduser      Add User to DB"; ((i++))
operations[$i]="dbru | removeuser   Remove User from DB\n"; ((i++))

#operations[$i]="t    | tables       Create Tables"; ((i++))
operations[$i]="x    | exit         Exit Database Menu"; ((i++))

# Display Menu
# Loop through the array and print out the operations menu 
for key in "${!operations[@]}"; do
    printf "${operations[${key}]} \n"
done

# Get User Input For Task
echo -e "\n\n> Select A Task (Enter An Argument)..."
read task

#If MariaDB is not installed, install it
if ! command -v mysql &> /dev/null
then
    echo "To continue, MariaDB must be installed"
    echo "-------------------------------------"
    echo 'Install Maria DB? (y/n)'
    read confirmation;

    # Install MariaDB
    sudo bash install.sh MariaDB
fi

function SHOW_USERS(){
    # Show Users
    echo "----------------------"
    echo "CURRENT USERS"
    echo "----------------------"
    sudo mysql -u root -e "SELECT user FROM mysql.user;"
    echo "----------------------"
}

function SHOW_DATABASES(){
    # Show Databases
    echo "----------------------"
    echo "CURRENT DATABASES"
    echo "----------------------"
    sudo mysql -u root -e "SHOW DATABASES;"
    echo "----------------------"
}

function CONFIRM(){
     
    echo "----------------------"
    echo "CONFIRMATION"
    echo "----------------------"
    echo "Are you sure you want to $str? (y/n)"
    read confirmation;

    if [ $confirmation != "y" ]
    then
        RESTART
    else
        clear
    fi
}

function WARNING(){
    RED='\033[0;31m'
    BRed='\033[1;31m' #Bold Red
    printf "${BRed}"
    printf "WARNING: $warning"
    printf "${COLOR}\n"   
}


# Case Statement Selecting Task  
    case $task in
        # Show The Existing Databases
        s | show)
            clear
            SHOW_DATABASES
        ;;
        # Create a Database
        c | create)
            clear
            echo "============================"
            echo "CREATE NEW DATABASE"
            echo "============================"
            SHOW_DATABASES
            echo "Enter New Database Name >"
            echo "----------------------"
            read db_name
            # Get confirmation (str is description of operation used in confirmation message) 
            str="create database $db_name"
            CONFIRM
            if [ "$db_name" != "" ]; then
                sudo mysql -u root -e "CREATE DATABASE $db_name;"
                clear
            else
                clear
                warning="Database name cannot be empty"
                WARNING
            fi
            SHOW_DATABASES
        ;;
        # Drop/Delete a Database
        ddb | dropdb)
            clear
            echo "============================"
            echo "DROP/DELETE A DATABASE"
            echo "============================"
            SHOW_DATABASES
            echo "Which Database To Drop? >"
            echo "----------------------"
            read db_name
            # Get confirmation (str is description of operation used in confirmation message) 
            str="drop/delete database $db_name"
            CONFIRM
            if [ "$db_name" != "" ]; 
            then
                sudo mysql -u root -e "DROP DATABASE $db_name;"
                clear
            else
                clear
                warning="Database name cannot be empty"
                WARNING
            fi
            SHOW_DATABASES
        ;;
        # Show The Existing Database Users
        su | showusers)
            clear
            SHOW_USERS
        ;;
        # Create A New Database User
        cu | user)
            clear
            echo "============================"
            echo "CREATE NEW USER"
            echo "============================"
            SHOW_USERS
            echo "Enter New User Name: >"
            echo "----------------------"
            read user_name
            echo "Enter New User Password: >"
            echo "----------------------"
            read user_password
            # Get confirmation (str is description of operation used in confirmation message) 
            str="create user $user_name"
            CONFIRM
            if [ "$user_name" != "" ] && [ "$user_password" != "" ]
            then
                # Create User
                sudo mysql -u root -e "CREATE USER '$user_name'@'localhost' IDENTIFIED BY '$user_password';"
            else
                clear
                warning="User name and password cannot be empty"
                WARNING
            fi
            SHOW_USERS
        ;;
        # Drop/Delete a Database User
        du | dropuser)
            clear
            echo "============================"
            echo "DROP/DELETE A DATABASE USER"
            echo "============================"
            SHOW_USERS
            echo "Which User To Drop: >"
            echo "----------------------"
            read user_name
            str="drop/delete user $user_name"
            CONFIRM
            if [ "$user_name" != "" ]; 
            then
                sudo mysql -u root -e "DROP USER $user_name@'localhost';"
                #clear
            else
                clear
                warning="User name cannot be empty"
                WARNING
            fi
            SHOW_USERS
        ;;
        # Add A User To A Database
        dbu | adduser)
            clear
            echo "============================"
            echo "ADD USER TO DATABASE"
            eecho "============================"
            SHOW_USERS
            echo "Which User To Add: >"
            echo "----------------------"
            read user_name
            clear
            sudo mysql -u root -e "SHOW GRANTS FOR $user_name@'localhost';"
            SHOW_DATABASES
            echo "Which Database To Add User: >"
            echo "----------------------"
            read db_name
            sudo mysql -u root -e "GRANT ALL PRIVILEGES ON $db_name.* TO '$user_name'@'localhost'; FLUSH PRIVILEGES;"
            clear
            echo "----------------------"
            echo "Updated Permissions: >"
            echo "----------------------"
            sudo mysql -u root -e "SHOW GRANTS FOR $user_name@'localhost';"
        ;;
        
        # Remove A User From A Database
        dbru | removeuser)
            clear
            echo "============================"
            echo "REMOVE USER FROM DATABASE"
            echo "============================"
            SHOW_USERS
            echo "Whch User To Remove: >"
            echo "----------------------"
            read user_name
            clear
            sudo mysql -u root -e "SHOW GRANTS FOR $user_name@'localhost';"
            SHOW_DATABASES
            echo "Which Database To Remove User:"
            read db_name
            sudo mysql -u root -e "REVOKE ALL PRIVILEGES ON $db_name.* FROM '$user_name'@'localhost'; FLUSH PRIVILEGES;"
            clear
            echo "----------------------"
            echo "Updated Permissions: >"
            echo "----------------------"
            sudo mysql -u root -e "SHOW GRANTS FOR $user_name@'localhost';"
        ;;
        x | exit)
            echo "==================="
            echo "Leaving Database Management!"
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