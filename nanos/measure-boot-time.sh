#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <itr>"
    exit 1
fi

ITR=$1

# Copy the required files from the parent directory
cp -r ../queries .
cp -r ../tables .
cp ../TPC-H.db .

# Compile the C program
gcc -o main main.c -lsqlite3

# Create the unikernel package
ops pkg from-run --name main --version 1.0 main

# Loop through 1 to 50 iterations
for (( i=1; i<=ITR; i++ ));
do
    # Measure execution time for unikernel sqlite3
    EXECUTION_TIME2=$( (time ops pkg load --local main_1.0 -c config_boot.json ) 2>&1 )

    # Print the query execution time and append to boottime.txt
    echo -e "itr $i bootup time (nanos): $EXECUTION_TIME2" | tee -a boot_time_result.txt
done

# Clean up
rm -f TPC-H.db
rm -rf queries
rm -rf tables

