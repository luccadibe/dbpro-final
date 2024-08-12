#!/bin/bash

# Check if the required arguments are provided
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
    echo "Usage: $0 <dbgen_size> <memory> <iterations>"
    exit 1
fi

# Assign input arguments to variables
DBGEN_SIZE=$1
MEMORY=$2
ITERATIONS=$3

echo "OSv: Starting to run the benchmark..."

# Get the directory where the script is located
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

# Define the output file relative to the script's directory
OUTPUT_FILE="$SCRIPT_DIR/power/temporary.txt"


# Load the tables into the SQLite database inside the OSv unikernel
echo "OSv: Loading tables to the database..."

# Start the OSv image and execute SQLite commands to load data

cd unikernel

./scripts/run.py -m ${MEMORY}G <<EOF >> $OUTPUT_FILE
.read sqlite-ddl.sql
.import nation.tbl NATION
.import region.tbl REGION
.import part.tbl PART
.import supplier.tbl SUPPLIER
.import partsupp.tbl PARTSUPP
.import customer.tbl CUSTOMER
.import orders.tbl ORDERS
.import lineitem.tbl LINEITEM
.quit
EOF

cd ..

echo "OSv: Loading complete."

echo "OSv: Running the queries..."

# Format the DBGEN_SIZE for the filename (replace '.' with '_')
FORMATTED_DBGEN_SIZE=$(echo $DBGEN_SIZE | sed 's/\./_/')

# Define the output CSV file for query times
OUTPUT_CSV="$SCRIPT_DIR/power/osv_${FORMATTED_DBGEN_SIZE}_${ITERATIONS}_iterations.csv"

# Loop through the number of iterations specified
for i in $(seq 1 $ITERATIONS)
do
    cd unikernel
    ./scripts/run.py -m ${MEMORY}G <<EOF >> $OUTPUT_FILE
.timer on
$(for j in $(seq 1 22); do echo ".read query${j}.sql"; done)
.quit
EOF

    echo "OSv: Completed iteration $i."

    # Run the Python script to process the query execution times
    python3 $SCRIPT_DIR/power/clean-queries-time.py $i $OUTPUT_CSV

    # Clean up the temporary output file to prepare for the next iteration
    rm "$OUTPUT_FILE"

    cd ..
done

echo "OSv: Queries completed."

