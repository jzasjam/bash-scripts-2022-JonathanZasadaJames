#!/bin/bash

# Watch CPU change

    seconds=10
    while [ $seconds -gt 0 ]  
    do  
        clear
        echo "=================================================="
        echo " CPU Usage Live Monitor for $seconds seconds"
        echo "=================================================="  
        echo " Press Ctrl+C to exit..."

        # Get the cpu usage
        cpuUsage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
        echo -e "\n ----------------------"
        echo " CPU Usage:      |   $cpuUsage%"
        echo "----------------------"
        
        sleep 1
        #remove 1 second from seconds
        ((seconds--))
    done