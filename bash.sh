#!/bin/bash

echo "==================="
echo "Demo Bash Script"
echo "==================="
echo "EXAMPLES TAKEN AND ADAPTED FROM: https://linuxhint.com/30_bash_script_examples/"
# EXAMPLES TAKEN AND ADAPTED FROM: https://linuxhint.com/30_bash_script_examples/

#Comment

#Echo
    echo "Yo"

#Add 2 numbers
    echo -e "\nAdd 2 numbers"
    echo -e "----------------------"
    ((sum=25+25))
    #Echo answer
    echo $sum

#Multi Line Comment
    : '
    Multi Line
    Comment
    '

#While Loop
    echo -e "\nWhile Loop"
    echo -e "----------------------"
    valid=true
    count=1
    while [ $valid ] 
    do
        echo $count
        if [ $count -eq 5 ];
            then
            break
        fi
        ((count++))
    done

#For Loop
    echo -e "\nFor Loop"
    echo -e "----------------------"
    for (( counter=10; counter>0; counter-- ))
    do  
        echo -n "$counter "
    done
    printf "\n"

#Get User Input
    echo -e "\nGet User Input"
    echo -e "----------------------"
    echo "Enter Your Name"
    read name
    echo "Welcome $name to Bash Scripting"

#If Statement
    echo -e "\nIf Statement"
    echo -e "----------------------"
    n=10
    if [ $n -lt 10 ];
    then
        echo "It is a one digit number"
    else
        echo "It is a two digit number"
    fi

 #Case Statement
    echo -e "\nCase Statement"
    echo -e "----------------------"
    echo "Enter You Lucky Number"
    read n
    case $n in
        101)
            echo "You Got First Prize";;
        510)
            echo "You Got 2nd Prize";;
        999)
            echo "You Got Third Prize";;
        *)
        echo "Sorry Try Again Soon";;
    esac

 #Get Command Line Arguments
    echo -e "\nGet Command Line Arguments"
    echo -e "----------------------"
    echo "Total Arguments : $#"
    echo "1st Argument = $1"
    echo "2nd Argument = $2"   


 #Get Command Line Arguments with Names
    echo -e "\nGet Command Line Arguments with Names"
    echo -e "----------------------"
    for arg in "$@"
    do  
        #No Spaces around '=' eg: id=val
        index=$(echo $arg | cut -f1 -d=)
        val=$(echo $arg | cut -f2 -d=)
        case $index in 
            X) x=$val;;
            Y) y=$val;;
            *)
        esac
        done
        ((result=x+y))
        echo "X+Y=$result"

#Combine String Variables
    echo -e "\nCombine String Variables"
    echo -e "----------------------"
    string1="Software Architecture"
    string2="Desgin Principles"

    string3="$string1 & $string2"
    echo "$string3"

    string3+=" Is A Great Module"
    echo $string3

#Get Substring of String
    echo -e "\nGet Substring of String"
    echo -e "----------------------"
    str="Learn Linux with SADP"
    #String:Start Index:Num Chars
    subStr=${str:0:11}
    echo $subStr
    #echo: Learn Linux
    subStr=${str:17:4}
    echo $subStr
    #echo: SADP

#Add 2 Numbers
    echo -e "\nAdd 2 Numbers"
    echo -e "----------------------"
    echo "Enter First Number"
    read x
    echo "Enter Second Number"
    read y
    ((sum=x+y))
    echo "Result = $sum"

#Create A Function
    echo -e "\nCreate A Function"
    echo -e "----------------------"
    function F1()
    {
        echo "I Like SADP"
    }
    #Call the function
    F1

#Function With Parameters
    echo -e "\nFunction With Parameters"
    echo -e "----------------------"
    Rectangle_Area(){
        area=$(($1*$2))
        echo "Area is : $area"
    }
    #Call the function
    Rectangle_Area 10 5

#Pass Return Value From Function
    echo -e "\nPass Return Value From Function"
    echo -e "----------------------"
    function greeting(){
        str="Hello $name"
        echo $str
    }
    echo "Enter Your Name"
    read name

    val=$(greeting)
    echo "Return Value Of The Function Is: $val"

#Make Directory
    echo -e "\nMake Directory"
    echo -e "----------------------"
    echo "Enter Directory Name"
    read newdir
    mkdir $newdir

#Make Directory By Checking Existence
    echo -e "\nMake Directory By Checking Existence"
    echo -e "----------------------"
    echo "Enter Directory Name"
    read ndir
    if [ -d "$ndir" ] 
    then
        echo "Directory Exists"
    else
        `mkdir $ndir`
        echo "Direcotry Created"
    fi

#Check If File Exists
    echo -e "\nCheck If File Exists"
    echo -e "----------------------"
    filename=$1
    if [ -f "$filename" ]
    then
        echo "File Exists"
    else
        `touch $filename`
        echo "Created $filename"
    fi

#Read A File
    echo -e "\nRead A File"
    echo -e "----------------------"
    echo "Read A File $1"
    file="book.txt"
    #Will not read last line (leave blank)
    while read line; do
        echo $line
    done < $file

#Append To A File
    echo -e "\nAppend To A File"
    echo -e "----------------------"
    echo "Before Appending The File"
    cat book.txt
    echo "Dr Seuss">> book.txt
    echo "After Appending The File"
    cat book.txt

#Remove A File
    echo -e "\nRemove A File"
    echo -e "----------------------"
    echo "Enter Filename To Remove"
    read fn
    rm $fn 
    # -i adds user confirmation
    #rm -i $fn 

#Send Email
    echo -e "\nSend Email"
    echo -e "----------------------"
    echo "Your Email >"
    read email
    echo "Subject >"
    read subject
    echo "Message >"
    read message
    echo $message | mail -s $subject $email
#https://linuxhint.com/bash_script_send_email/
#https://superuser.com/questions/1492929/how-to-use-mail-command-from-within-windows-linux-subsystem
#https://askubuntu.com/questions/14685/what-does-package-package-has-no-installation-candidate-mean
    #Recipient="jonathan.zasada-james@student.shu.ac.uk"
    #Subject="Hello from Bash"
    #Message="You have succeeded in sending an email"
    #`mail -s $Subject $Recipient <<< $Message`
    #echo "Sent Mail To $Recipient"

