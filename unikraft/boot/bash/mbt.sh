#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <iterations> <output_file>"
    exit 1
fi

iterations=$1
output_file=$2

echo "iteration,real,user,sys" > "$output_file"


for (( i=1; i<=iterations; i++ ))
do
    # Use the time command to measure the execution time of `kraft run`
    { time_output=$( { time kraft run 2>&1 1>/dev/null; } 2>&1 ); } 2>/dev/null

    # Extract the real, user, and sys times
    real_time=$(echo "$time_output" | grep real | awk '{print $2}')
    user_time=$(echo "$time_output" | grep user | awk '{print $2}')
    sys_time=$(echo "$time_output" | grep sys | awk '{print $2}')

    # Convert the time format from m:ss.sss to seconds
    real_seconds=$(echo "$real_time" | awk -Fm '{ print ($1 * 60) + $2 }')
    user_seconds=$(echo "$user_time" | awk -Fm '{ print ($1 * 60) + $2 }')
    sys_seconds=$(echo "$sys_time" | awk -Fm '{ print ($1 * 60) + $2 }')

    # Write the results to the CSV file
    echo "$i,$real_seconds,$user_seconds,$sys_seconds" >> "$output_file"
done

echo "Benchmarking completed. Results are saved in $output_file"

