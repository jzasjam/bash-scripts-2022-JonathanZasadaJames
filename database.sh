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


# Perform a SQL Query
function SQLQUERY(){
    # Run SQL Query
    sudo mysql -u root -e "$query"
}

# Show Database Users
function SHOW_USERS(){
    # Show Users
    echo -e "\n----------------------"
    echo " CURRENT USERS"
    echo "----------------------"
    query="SELECT user FROM mysql.user;"
    SQLQUERY
    echo "----------------------"
}

# Display a users database permissions
function SHOW_USER_PERMISSIONS(){
    # Show User Permissions
    echo -e "\n----------------------"
    echo " CURRENT PERMISSIONS"
    echo "----------------------"
    query="SHOW GRANTS FOR $user_name@'localhost';"
    SQLQUERY
    echo "----------------------"
}

# Display the existing databases
function SHOW_DATABASES(){
    # Show Databases
    echo -e "\n----------------------"
    echo " CURRENT DATABASES"
    echo "----------------------"
    query="SHOW DATABASES;"
    SQLQUERY
    echo "----------------------"
}
# Display the existing databases
function SHOW_TABLES(){
    # Show Tables
    echo -e "\n----------------------"
    echo " CURRENT TABLES"
    echo "----------------------"
    query="USE $db_name;"
    query+="SHOW TABLES;"
    SQLQUERY
    echo "----------------------"
}
# Display database table columns
function SHOW_COLUMNS(){
    # Show Columns
    echo -e "\n----------------------"
    echo " CURRENT COLUMNS"
    echo "----------------------"
    query="USE $db_name;"
    query+="SHOW COLUMNS FROM $table_name;"
    SQLQUERY
    echo "----------------------"
}

# Display a message and get user confirmation
function CONFIRM(){
    echo -e "\n----------------------"
    echo " CONFIRMATION"
    echo "----------------------"
    echo "> Are you sure you want to $str? (y/n)"
    read confirmation;

    if [ "$confirmation" != "y" ]
    then
        RESTART
    else
        clear
    fi
}

# Display a warning message 
function WARNING(){
    RED='\033[0;31m'
    BRed='\033[1;31m' #Bold Red
    printf "${BRed}"
    printf "WARNING: $warning"
    printf "${COLOR}\n"   
}


# Intoduction Message
echo "=================================================================="
echo " Database Management"
echo "=================================================================="
echo "-------------------------------------"
printf "Argument(s)         Description\n"
echo "-------------------------------------"
# Create an array of database operations to complete
i=0
operations[$i]=" s    | show         Show Databases"; ((i++))
operations[$i]=" c    | create       Create Database"; ((i++))
operations[$i]=" d    | drop         Drop/Delete Database\n"; ((i++))

operations[$i]=" su   | showusers    Show Users"; ((i++))
operations[$i]=" cu   | createuser   Create User"; ((i++))
operations[$i]=" du   | dropuser     Drop/Delete User\n"; ((i++))

operations[$i]=" st   | showtables   Show Tables for a Database"; ((i++))
operations[$i]=" ct   | createtable  Create Table"; ((i++))
operations[$i]=" dt   | droptable    Drop/Delete Table\n"; ((i++))

operations[$i]=" col  | columns      Show Table Columns"; ((i++))
operations[$i]=" sel  | select       Select/Show Table Contents\n"; ((i++))

operations[$i]=" dbu  | adduser      Add User to a Database"; ((i++))
operations[$i]=" dbru | removeuser   Remove User from a Database\n"; ((i++))

#operations[$i]=" t    | tables       Create Tables"; ((i++))
operations[$i]=" x    | exit         Exit Database Menu"; ((i++))

# Display Menu
# Loop through the array and print out the operations menu 
for key in "${!operations[@]}"; do
    printf "${operations[${key}]} \n"
done


task=$1
if test -z "$task" 
then
    # Get User Input For Task
    echo -e "\n\n> Select A Task (Enter An Argument)..."
    read task
    clear
else
    # If Command Line Argument Provided
    echo "> DB OPERATION SELECTED = $task"
fi

# If not exiting
if [ "$task" != "x" ]
then

    #If MariaDB is not installed, install it
    if [ ! command -v mysql &> /dev/null ] 
    then
        echo -e "\n-------------------------------------"
        echo " To continue, MariaDB must be installed"
        echo "-------------------------------------"
        str="Install Maria DB"
        CONFIRM
        read confirmation;

        # Install MariaDB
        sudo bash install.sh MariaDB
    else
        # If MariaDB is installed, start service
        if ! command -v systemctl &> /dev/null
        then
            sudo systemctl start mariadb
        else
            # ON WSL
            sudo service mysql start
        fi
    fi

fi

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
            echo "=================================="
            echo " CREATE NEW DATABASE"
            echo "=================================="
            SHOW_DATABASES
            echo -e "\n> Enter New Database Name..."
            echo "----------------------"
            read db_name
            # Get confirmation (str is description of operation used in confirmation message) 
            str="create database $db_name"
            CONFIRM
            if [ "$db_name" != "" ]; then
                query="CREATE DATABASE $db_name;"
                SQLQUERY
                clear
            else
                clear
                warning="Database name cannot be empty"
                WARNING
            fi
            SHOW_DATABASES
        ;;
        # Drop/Delete a Database
        d | drop)
            clear
            echo "=================================="
            echo " DROP/DELETE A DATABASE"
            echo "=================================="
            SHOW_DATABASES
            echo -e "\n> Which Database To Drop?"
            echo "----------------------"
            read db_name
            # Get confirmation (str is description of operation used in confirmation message) 
            str="drop/delete database $db_name"
            CONFIRM
            if [ "$db_name" != "" ]; 
            then
                query="DROP DATABASE $db_name;"
                SQLQUERY
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
            echo "=================================="
            echo " CREATE NEW USER"
            echo "=================================="
            SHOW_USERS
            echo -e "\n> Enter New User Name?"
            echo "----------------------"
            read user_name
            
            # Confirm passwords are the same
            while [ true ] 
            do
                echo -e "\n----------------------"
                echo "> Enter New User Password?"
                echo "----------------------"
                read -s user_password
                echo
                echo "> Repeat Password?"
                read -s user_password2
                echo
                if [ "$user_password" != "$user_password2" ]; 
                then
                    clear
                    warning="Passwords do not match"
                    WARNING
                else
                    break
                fi  
            done

            # Get confirmation (str is description of operation used in confirmation message) 
            str="create user $user_name"
            CONFIRM
            if [ "$user_name" != "" ] && [ "$user_password" != "" ]
            then
                # Create User
                query="CREATE USER '$user_name'@'localhost' IDENTIFIED BY '$user_password';"
                SQLQUERY
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
            echo "=================================="
            echo " DROP/DELETE A DATABASE USER"
            echo "=================================="
            SHOW_USERS
            echo -e "\n> Which User To Drop?"
            echo "----------------------"
            read user_name
            str="drop/delete user $user_name"
            CONFIRM
            if [ "$user_name" != "" ]; 
            then
                query="DROP USER $user_name@'localhost';"
                #clear
                SQLQUERY
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
            echo "=================================="
            echo " ADD USER TO DATABASE"
            echo "=================================="
            SHOW_USERS
            
            echo -e "\n> Which User To Add?"
            echo "----------------------"
            read user_name
            clear
            SHOW_USER_PERMISSIONS
            SHOW_DATABASES

            echo -e "\n----------------------"
            echo "> Which Database To Add User?"
            echo "----------------------"
            read db_name

            # Get confirmation
            str="add user $user_name to database $db_name"
            CONFIRM

            query="GRANT ALL PRIVILEGES ON $db_name.* TO '$user_name'@'localhost'; FLUSH PRIVILEGES;"
            SQLQUERY
            clear

            echo "----------------------"
            echo "Updated Permissions: >"
            echo "----------------------"
            SHOW_USER_PERMISSIONS
        ;;
        
        # Remove A User From A Database
        dbru | removeuser)
            clear
            echo "=================================="
            echo " REMOVE USER FROM DATABASE"
            echo "=================================="
            SHOW_USERS

            echo -e "\n> Which User To Remove?"
            echo "----------------------"
            read user_name
            clear
            SHOW_USER_PERMISSIONS
            SHOW_DATABASES

            echo -e "\n----------------------"
            echo "> Which Database To Remove User?"
            read db_name

            # Get confirmation
            str="remove user $user_name from database $db_name"
            CONFIRM

            query="REVOKE ALL PRIVILEGES ON $db_name.* FROM '$user_name'@'localhost'; FLUSH PRIVILEGES;"
            SQLQUERY
            clear

            echo "----------------------"
            echo "Updated Permissions: >"
            echo "----------------------"
            SHOW_USER_PERMISSIONS
        ;;
        # Show The Existing Database Tables
        st | showtables)
            clear
            SHOW_DATABASES
            echo -e "\n----------------------"
            echo "> Which Database To Show Tables?"
            read db_name
            SHOW_TABLES
        ;;
        
        # Create A New Database Table
        ct | createtable)
            clear
            echo "=================================="
            echo " CREATE NEW TABLE"
            echo "=================================="
            SHOW_DATABASES
            echo -e "\n----------------------"
            echo "> Which Database To Create Table?"
            read db_name
            SHOW_TABLES
            echo -e "\n----------------------"
            echo "> Enter New Table Name"
            read table_name
            # Get confirmation (str is description of operation used in confirmation message) 
            str="create table $table_name"
            CONFIRM
            if [ "$table_name" != "" ]; 
            then
                query="CREATE TABLE $db_name.$table_name (id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY, name VARCHAR(30) NOT NULL, email VARCHAR(50), reg_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP);"
                SQLQUERY
            else
                clear
                warning="Table name cannot be empty"
                WARNING
            fi
            SHOW_TABLES
        ;;

        # Drop/Delete a Database Table
        dt | droptable)
            clear
            echo "=================================="
            echo " DROP/DELETE A DATABASE TABLE"
            echo "=================================="
            SHOW_DATABASES
            echo -e "\n----------------------"
            echo "> Which Database To Drop Table?"
            read db_name
            SHOW_TABLES
            echo -e "\n----------------------"
            echo "> Which Table To Drop?"
            read table_name
            # Get confirmation (str is description of operation used in confirmation message) 
            str="drop/delete table $table_name"
            CONFIRM
            if [ "$table_name" != "" ]; 
            then
                query="DROP TABLE $db_name.$table_name;"
                SQLQUERY
            else
                clear
                warning="Table name cannot be empty"
                WARNING
            fi
            SHOW_TABLES
        ;;

        # Show The Existing Database Table Columns
        col | columns)
            clear
            echo "=================================="
            echo " SHOW DATABASE TABLE COLUMNS"
            echo "=================================="
            SHOW_DATABASES
            echo -e "\n----------------------"
            echo "> Which Database To Show Table Columns?"
            read db_name
            SHOW_TABLES
            echo -e "\n----------------------"
            echo "> Which Table To Show Columns?"
            read table_name
            SHOW_COLUMNS
        ;;
        
        # Select Data From A Database Table
        sel | select)
            clear
            echo "=================================="
            echo " SELECT DATA FROM DATABASE TABLE"
            echo "=================================="
            SHOW_DATABASES
            echo -e "\n----------------------"
            echo "> Which Database To Select Data From?"
            read db_name
            SHOW_TABLES
            echo -e "\n----------------------"
            echo "> Which Table To Select Data From?"
            read table_name
            SHOW_COLUMNS
            echo -e "\n----------------------"
            echo "> Which Columns To Select Data From (use comma between multiple or use * for all)?"
            read column_name
            query="USE $db_name;"
            query+="SELECT $column_name FROM $table_name;"
            SQLQUERY
        ;;

        x | exit)
            echo "=============================="
            echo " Leaving Database Management!"
            echo "=============================="
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