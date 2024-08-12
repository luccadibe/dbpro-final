#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <memory>, <iterations>"
    exit 1
fi

MEMORY=$1
ITERATION=$2

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

TEMP_FILE="$SCRIPT_DIR/temporary.txt"

echo "OSv: Running boot up iterations..."

# Additional loop for 2 more iterations
for i in $(seq 1 2)
do  
    cd unikernel
    echo ".quit" | ./scripts/run.py -m ${MEMORY}G >> $TEMP_FILE
    cd ..
done

for i in $(seq 1 $ITERATION)
do
    cd unikernel
    echo ".quit" | ./scripts/run.py -m ${MEMORY}G >> $TEMP_FILE
    cd ..
done


echo "OSv: Generating boot up time file..."

python3 "${SCRIPT_DIR}/clean-boot-time.py" $TEMP_FILE

rm $TEMP_FILE

cp "${SCRIPT_DIR}/boot-times.csv" "${SCRIPT_DIR}/../osv_boot-time.csv"

echo "OSv: CSV file copied to: ${SCRIPT_DIR}/../osv_boot-time.csv"

echo "OSv: Boot up time measurement complete"
