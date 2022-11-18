#!/bin/bash

# SET THE COLORS
COLOR='\033[0m' # No Color

# Display message in colour depending on the status
    function COLOR_TEXT(){
        # COLOR ARRAY FOR STATUS TEXT
        COL[0]='\033[1;31m' #Bold Red
        COL[1]='\033[1;32m' #Bold Green
        printf "${COL[$status]}"
        printf " $message"
        printf "${COLOR}\n\n"    
    }

echo "===================================="
echo " System Status"
echo "===================================="



echo -e "\n=============================="
echo " Service Status"
echo "=============================="

    # Get status of Apache and MariaDB/MySQL
    sudo bash service-status.sh quickstatus

echo -e "\n=============================="
echo " User Stats"
echo "=============================="

# Get current number of linux users
    currentUsers=$(cat /etc/passwd | wc -l)
    echo " $currentUsers Current Number of Users"

# Get current number of linux users with a home directory
    currentUsersWithHome=$(cat /etc/passwd | grep "/home" | wc -l)
    echo " $currentUsersWithHome Users With a Home Directory"

 # List all users with a home directory
    echo "---------------------"
    cat /etc/passwd | grep "/home" | cut -d: -f1


# Get and display stats about the computer usage
echo -e "\n==============================="
echo " Computer Usage Stats"
echo "==============================="

    echo " Processes:"
    echo "----------------------"

# Get the total number of processes
    totalProcesses=$(ps -A | wc -l)
    echo " - Total Processes:    |   $totalProcesses"

# Get the number of running processes
    runningProcesses=$(ps -A | grep -v "STAT" | wc -l)
    echo " - Running Processes:  |   $runningProcesses"

    echo -e "\n Memory:"
    echo "----------------------"

# Get the total amount of memory
    totalMemory=$(free -m | grep "Mem" | awk '{print $2}')
    echo " - Total Memory:       |   $totalMemory MB"

# Get the amount of used memory
    usedMemory=$(free -m | grep "Mem" | awk '{print $3}')
    echo " - Used Memory:        |   $usedMemory MB"

# Get the amount of free memory
    freeMemory=$(free -m | grep "Mem" | awk '{print $4}')
    echo " - Free Memory:        |   $freeMemory MB"

# Get the cpu usage
    echo "----------------------"
    cpuUsage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
    echo " CPU Usage:            |   $cpuUsage%"
    echo "----------------------"


    echo -e "\n=============================="
    echo " Databases"
    echo "=============================="

# Get the number of databases
    databases=$(sudo mysql -u root -e "SHOW DATABASES;" | grep -v "Database" | wc -l)
    echo "Number of Databases: $databases"

# Get the physical size of all the databases
    physicalSize=$(sudo mysql -u root -e "SELECT table_schema \"Database\", ROUND(SUM(data_length + index_length) / 1024 / 1024, 1) \"Size (MB)\" FROM information_schema.TABLES GROUP BY table_schema;" | grep -v "Database" | awk '{sum+=$2} END {print sum}')
    echo "Physical Size of Databases: $physicalSize MB"


# List the databases and sizes
    sudo mysql -u root -e "SELECT table_schema \"Database\", ROUND(SUM(data_length + index_length) / 1024 / 1024, 1) \"Size (MB)\" FROM information_schema.TABLES GROUP BY table_schema;"




