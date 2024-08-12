#!/bin/bash


if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
    echo "Usage: $0 <dbgen_size> <memory> <iterations>"
    exit 1
fi

DBGEN_SIZE=$1
MEMORY=$2
ITERATIONS=$3

echo "OSv: Starting to run the benchmark..."


# Get the directory where the script is located
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

# Define the output file relative to the script's directory
OUTPUT_FILE="$SCRIPT_DIR/power/temporary.txt"


# import the files and stuff
# Start the image and import the files

echo "OSv: Loading tables to the database..."

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

OUTPUT_CSV="$SCRIPT_DIR/power/osv_${FORMATTED_DBGEN_SIZE}_${ITERATIONS}_iterations.csv"

for i in $(seq 1 $ITERATIONS)
do
    cd unikernel
    ./scripts/run.py -m ${MEMORY}G <<EOF >> $OUTPUT_FILE
.timer on
$(for j in $(seq 1 22); do echo ".read query${j}.sql"; done)
.quit
EOF

    echo "OSv: Completed iteration $i."

    # Run the Python script after each iteration
    python3 $SCRIPT_DIR/power/clean-queries-time.py $i $OUTPUT_CSV

    rm "$SCRIPT_DIR/power/temporary.txt"

    cd ..
done


echo "OSv: Queries completed."

