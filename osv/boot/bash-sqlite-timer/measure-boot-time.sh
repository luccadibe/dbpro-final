#!/bin/bash

# Check if the required arguments are provided
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <memory> <iterations>"
    exit 1
fi

# Assign input arguments to variables
MEMORY=$1
ITERATION=$2

# Get the directory where the script is located
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

# Define the temporary output file path
TEMP_FILE="$SCRIPT_DIR/temporary.txt"

echo "OSv: Running boot up iterations..."

# Initial boot up iterations (run twice as per the original script)
for i in $(seq 1 2)
do
    # Get the current time in milliseconds
    current_time=$(date +%s%3N)

    # Append the current time to the output file
    echo "Current Time (ms): $current_time" >> $TEMP_FILE

    cd unikernel
    ./scripts/run.py -m ${MEMORY}G <<EOF >> $TEMP_FILE
SELECT (strftime('%s','now') || substr(strftime('%f','now'),4)) AS current_time_ms;
.quit
EOF
    cd ..
done


# Main loop for the specified number of iterations
for i in $(seq 1 $ITERATION)
do
    # Get the current time in milliseconds
    current_time=$(date +%s%3N)

    # Append the current time to the output file
    echo "Current Time (ms): $current_time" >> $TEMP_FILE

    cd unikernel
    ./scripts/run.py -m ${MEMORY}G <<EOF >> $TEMP_FILE
SELECT (strftime('%s','now') || substr(strftime('%f','now'),4)) AS current_time_ms;
.quit
EOF
    cd ..

done

echo "OSv: Generating boot up time file..."

# Run the Python script to process the boot times
python3 "${SCRIPT_DIR}/clean-boot-time.py" $TEMP_FILE

# Remove the temporary file after processing
rm $TEMP_FILE

# Copy the final boot-times CSV to the parent directory with a new name
cp "${SCRIPT_DIR}/boot-times.csv" "${SCRIPT_DIR}/../osv_boot-time.csv"

echo "OSv: CSV file copied to: ${SCRIPT_DIR}/../osv_boot-time.csv"

echo "OSv: Boot up time measurement complete"
