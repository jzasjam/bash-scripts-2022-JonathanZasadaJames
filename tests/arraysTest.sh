#!/bin/bash

# Testing Arrays and Ordera
declare -A operations
operations+=(["c | create"]="Create Database")
operations+=(["ddb | dropdb"]="Drop Database")
operations+=(["du | dropuser"]="Drop User")
operations+=(["su | showusers"]="Show Users")

# Loop through the array and print out the operations menu 
for key in "${!operations[@]}"; do
    printf "${key} \t"
    printf "${operations[${key}]} \n"
done

echo -e "\n\n"

op[0]="c | create"
op[1]="ddb | dropdb"
op[2]="du | dropuser"
op[3]="su | showusers"

for i in "${op[@]}"; do
    echo $i
done

echo -e "\n\n"

op2=["c | create"]
op2=["ddb | dropdb"]
op2=["du | dropuser"]
op2=["su | showusers"]

for i in "${op2[@]}"; do
    echo $i
done

echo -e "\n\n"

i=0
op3[$i]="c | create"; ((i++))
op3[$i]="ddb | dropdb"; ((i++))
op3[$i]="du | dropuser"; ((i++))
op3[$i]="su | showusers"; ((i++))

for i in "${op3[@]}"; do
    echo $i
done
