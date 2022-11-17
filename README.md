# bash

##### By Jonathan Zasada-James [31051167]
-----------------------------------

## Setup:
Place the downloaded directory on your machine in an easy to access directory

## Usage:
1. In terminal, cd to the directory you downloaded or moved it
> *eg:* `cd Downloads/bash-scripts-2022-JonathanZasadaJames`

2. Run the main script
> `bash task3.sh`

### Additonal Information
---------------------
- Menu options are case insensitive
- Use `bash task3.sh` to start and select a task from the menu
- Use `bash task3.sh {argument}` to start a task automatically from the command line
    - Use `'bash task3.sh {arg1} {arg2}` to start certain subtasks (eg: install, database) automatically (eg `bash task3.sh install php` to install PHP)
- Use `bash task3.sh help` to see the help menu
- Use `bash task3.sh demo` to see a demo of bash scripting
- (!) CAUTION: Do Not Use 'reset' unless you know what you are doing (will purge all installed packages, databases, and files)

### Files Description
- The .sh files can be executed independently...
> eg: `bash install.sh` or `bash install.sh php` to install immediately
+ **/html**                   - Directory containing template html for custom index.html
+ **/tests**                  - Directory containing some test files used with *demo.sh*
+ **create-homepage.sh**      - Script to take user input and create a custom index.html in /var/www/html
+ **database.sh**             - MariaDB Datanase management tool (Show, Drow & Create; Databases, Tables & Users)
+ **demo.sh**                 - Examples of some BASH functionality
+ **help.sh**                 - Help file with instructions for user
+ **install.sh**              - LAMP Install helper tool for Apache, MariaDB, PHP and WP
+ **load-www.sh**             - Load a webpage in the browser
+ **reset.sh**                - Removes all LAMP(+Wordpress) packages, files and databases.
+ **send-email.sh**           - Send an email to a chosen address (via SMTP connection)
+ **service-status.sh**       - Get the latest status, start, stop and restart for Apache and MariaDB
+ **task3.sh**                - Main menu script to guide user