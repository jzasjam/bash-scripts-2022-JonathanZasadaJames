#!/bin/bash

# Set Text Colour
COLOR='\033[0;33m' #YELLOW
printf "${COLOR}"  

# Get this file name to use in restart function and reference elsewhere
thisFile="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"
function RESTART(){
    clear
    bash $thisFile 
    exit
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

    if [ "$confirmation" == "y" ]
    then
        clear
    else
        if [ "$confirmation" == "n" ]
        then
            RESTART
        else
            echo "Invalid Input"
            CONFIRM
        fi
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
        str="Install Maria DB" # Set Confirmation Message
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
            
            while [ "$db_name" == "" ]
            do
                SHOW_DATABASES
                echo -e "\n> Enter New Database Name... (Can cancel/confirm at next step)"
                echo "----------------------"
                read db_name
                if [ "$db_name" != "" ]; 
                then
                    query="CREATE DATABASE $db_name;"
                    # Get confirmation (str is description of operation used in confirmation message) 
                    str="create database $db_name"
                    CONFIRM
                    SQLQUERY
                    clear
                    break
                else
                    clear
                    warning="Database name cannot be empty"
                    WARNING
                fi
            done
            SHOW_DATABASES
        ;;
        # Drop/Delete a Database
        d | drop)
            clear
            echo "=================================="
            echo " DROP/DELETE A DATABASE"
            echo "=================================="
            while [ "$db_name" == "" ]
            do
                SHOW_DATABASES
                echo -e "\n> Which Database To Drop? (Can cancel/confirm at next step)"
                echo "----------------------"
                read db_name
                if [ "$db_name" != "" ]; then
                    query="DROP DATABASE $db_name;"
                    # Get confirmation (str is description of operation used in confirmation message) 
                    str="drop/delete database $db_name"
                    CONFIRM
                    SQLQUERY
                    clear
                    break
                else
                    clear
                    warning="Database name cannot be empty"
                    WARNING
                fi
            done
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

            while [ "$user_name" == "" ]
            do
                SHOW_USERS
                echo -e "\n> Enter New User Name... (Can cancel/confirm at next step)"
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

                # Check Username
                if [ "$user_name" != "" ]; then
                    query="CREATE USER '$user_name'@'localhost' IDENTIFIED BY '$user_password';"
                    # Get confirmation (str is description of operation used in confirmation message) 
                    str="create user $user_name"
                    CONFIRM
                    SQLQUERY
                    clear
                    break
                else
                    clear
                    warning="User name cannot be empty"
                    WARNING
                fi
            done
            SHOW_USERS
        ;;
        # Drop/Delete a Database User
        du | dropuser)
            clear
            echo "=================================="
            echo " DROP/DELETE A DATABASE USER"
            echo "=================================="
           
            while [ "$user_name" == "" ]
            do
                SHOW_USERS
                echo -e "\n> Which User To Drop? (Can cancel/confirm at next step)"
                echo "----------------------"
                read user_name
                if [ "$user_name" != "" ]; then
                    query="DROP USER '$user_name'@'localhost';"
                    # Get confirmation 
                    str="drop/delete user $user_name"
                    CONFIRM
                    SQLQUERY
                    clear
                    break
                else
                    clear
                    warning="User name cannot be empty"
                    WARNING
                fi
            done
            SHOW_USERS
        ;;
        # Add A User To A Database
        dbu | adduser)
            clear
            echo "=================================="
            echo " ADD USER TO DATABASE"
            echo "=================================="
            
            while [ "$user_name" == "" ]
            do
                SHOW_USERS
                echo -e "\n> Which User To Add?"
                echo "----------------------"
                read user_name
                if [ "$user_name" != "" ]; then
                    clear
                    break
                else
                    clear
                    warning="User name cannot be empty"
                    WARNING
                fi
            done
            while [ "$db_name" == "" ]
            do
                SHOW_DATABASES
                SHOW_USER_PERMISSIONS
                echo -e "\n> Which Database To Add User To?"
                echo "----------------------"
                read db_name
                if [ "$db_name" != "" ]; then
                    break
                else
                    clear
                    warning="Database name cannot be empty"
                    WARNING
                fi
            done
                
            if [ "$user_name" != "" ] && [ "$db_name" != "" ]; then
                query="GRANT ALL PRIVILEGES ON $db_name.* TO '$user_name'@'localhost';"
                # Get confirmation
                str="add user $user_name to database $db_name"
                CONFIRM
                SQLQUERY
                clear
                break
            else
                clear
                warning="User name and database name cannot be empty"
                WARNING
            fi
                
            

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
           
            while [ "$user_name" == "" ] || [ "$db_name" == "" ]
            do 
                SHOW_USERS

                echo -e "\n> Which User To Remove?"
                echo "----------------------"
                read user_name
                clear
                SHOW_DATABASES
                SHOW_USER_PERMISSIONS

                echo -e "\n----------------------"
                echo "> Which Database To Remove User? (Can cancel/confirm at next step)"
                read db_name

                if [ "$user_name" != "" ] && [ "$db_name" != "" ]; then
                    query="REVOKE ALL PRIVILEGES ON $db_name.* FROM '$user_name'@'localhost';"
                    # Get confirmation
                    str="remove user $user_name from database $db_name"
                    CONFIRM
                    SQLQUERY
                    clear
                    break
                else
                    clear
                    warning="User name and database name cannot be empty"
                    WARNING
                fi
            done
            SHOW_USER_PERMISSIONS
        ;;
        # Show The Existing Database Tables
        st | showtables)
            clear
            while [ "$db_name" == "" ]
            do
                SHOW_DATABASES
                echo -e "\n> Which Database To Show Tables?"
                echo "----------------------"
                read db_name
                if [ "$db_name" != "" ]; 
                then
                    clear
                    SHOW_TABLES
                    break
                else
                    clear
                    warning="Database name cannot be empty"
                    WARNING
                fi
            done
        ;;
        
        # Create A New Database Table
        ct | createtable)
            clear
            echo "=================================="
            echo " CREATE NEW TABLE"
            echo "=================================="

            while [ "$db_name" == "" ]
            do
                SHOW_DATABASES
                echo -e "\n----------------------"
                echo "> Which Database To Create Table?"
                read db_name
                if [ "$db_name" != "" ]; 
                then
                    clear
                    break
                else
                    clear
                    warning="Database name cannot be empty"
                    WARNING
                fi
            done
            while [ "$table_name" == "" ]
            do
                SHOW_TABLES
                echo -e "\n----------------------"
                echo "> Enter New Table Name... (Can cancel/confirm at next step)"
                read table_name
                if [ "$table_name" != "" ]; 
                then
                    # Get confirmation (str is description of operation used in confirmation message) 
                    str="create table $table_name"
                    CONFIRM
                    clear
                    break
                else
                    clear
                    warning="Table name cannot be empty"
                    WARNING
                fi
            done
            
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

            while [ "$db_name" == "" ]
            do
                SHOW_DATABASES
                echo -e "\n----------------------"
                echo "> Which Database To Drop Table?"
                read db_name
                if [ "$db_name" != "" ]; 
                then
                    clear
                    break
                else
                    clear
                    warning="Database name cannot be empty"
                    WARNING
                fi
            done

            while [ "$table_name" == "" ]
            do
                SHOW_TABLES
                echo -e "\n----------------------"
                echo "> Which Table To Drop? (Can cancel/confirm at next step)"
                read table_name

                if [ "$table_name" != "" ]; 
                then
                    query="DROP TABLE $db_name.$table_name;"
                    # Get confirmation
                    str="drop table $table_name in database $db_name"
                    CONFIRM
                    SQLQUERY
                    clear
                    break
                else
                    clear
                    warning="Table name cannot be empty"
                    WARNING
                fi
            done
            SHOW_TABLES
        ;;

        # Show The Existing Database Table Columns
        col | columns)
            clear
            echo "=================================="
            echo " SHOW DATABASE TABLE COLUMNS"
            echo "=================================="
            while [ "$db_name" == "" ]
            do
                SHOW_DATABASES
                echo -e "\n----------------------"
                echo "> Which Database To Show Columns?"
                read db_name
                if [ "$db_name" != "" ]; 
                then
                    clear
                    break
                else
                    clear
                    warning="Database name cannot be empty"
                    WARNING
                fi
            done
            while [ "$table_name" == "" ]
            do
                SHOW_TABLES
                echo -e "\n----------------------"
                echo "> Which Table To Show Columns?"
                read table_name
                if [ "$table_name" != "" ]; 
                then
                    clear
                    break
                else
                    clear
                    warning="Table name cannot be empty"
                    WARNING
                fi
            done
            SHOW_COLUMNS
        ;;
        
        # Select Data From A Database Table
        sel | select)
            clear
            echo "=================================="
            echo " SELECT DATA FROM DATABASE TABLE"
            echo "=================================="
            while [ "$db_name" == "" ]
            do
                SHOW_DATABASES
                echo -e "\n----------------------"
                echo "> Which Database To Select Data From?"
                read db_name
                if [ "$db_name" != "" ]; 
                then
                    clear
                    break
                else
                    clear
                    warning="Database name cannot be empty"
                    WARNING
                fi
            done
            while [ "$table_name" == "" ]
            do
                SHOW_TABLES
                echo -e "\n----------------------"
                echo "> Which Table To Select Data From?"
                read table_name
                if [ "$table_name" != "" ]; 
                then
                    clear
                    break
                else
                    clear
                    warning="Table name cannot be empty"
                    WARNING
                fi
            done
            while [ "$column_name" == "" ]  
            do
                SHOW_COLUMNS
                echo -e "\n----------------------"
                echo "> Which Column To Select Data From?"
                read column_name
                if [ "$column_name" != "" ]; 
                then
                    clear
                    query="USE $db_name;"
                    query+="SELECT $column_name FROM $table_name;"
                    SQLQUERY
                    break
                else
                    clear
                    warning="Column name cannot be empty"
                    WARNING
                fi
            done
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