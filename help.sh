#!/bin/bash

# $1 = Main Menu Script

echo "==================="
echo "Help"
echo "==================="
echo "- Menu options are case insensitive"
echo "- Use 'bash $1' to start and select a task from the menu"
echo "- Use 'bash $1 {argument}' to start a task automatically from the command line"
echo "  - Use 'bash $1 {arg1} {arg2}' to start certain subtasks (install, load-www,) automatically (eg 'bash $1 install php' to install PHP)"
echo "- Use 'bash $1 help' to see this help menu"
echo "- Use 'bash $1 demo' to see a demo of bash scripting"
echo "! - CAUTION: Do Not Use 'reset' unless you know what you are doing (will purge all packages, databases, and files)"