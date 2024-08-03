#!/bin/bash


if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]  || [ -z "$4" ]; then
    echo "Usage: $0 <dbgen_size> <test: power,boot> <memoryGB> <iterations>"
    echo "Example: $0 1 power 1 10"
    exit 1
fi
# dbgen_size is the scale factor used for the generated database
# see https://www.tpc.org/TPC_Documents_Current_Versions/pdf/TPC-H_v3.0.1.pdf

DBGEN_SIZE=$1
TEST=$2
MEMORY=$3
ITERATIONS=$4
# check if directory TPCH-sqlite exists
# the generated db is stored in TPCH-sqlite and follows the naming convention TPC-H-<dbgen_size>.db
if [ ! -d "TPCH-sqlite" ]; then
    git clone --recursive https://github.com/lovasoa/TPCH-sqlite.git
    cd TPCH-sqlite
    SCALE_FACTOR=$DBGEN_SIZE make
    mv TPC-H.db TPC-H-$DBGEN_SIZE.db
    
    #check if there is already a generated db of the specified size
    elif [ ! -e "TPCH-sqlite/TPC-H-$DBGEN_SIZE.db" ]; then
    # remove all the tbl files in the TPCH-sqlite directory
    rm TPCH-sqlite/tpch-dbgen/*.tbl
    
    cd TPCH-sqlite
    
    SCALE_FACTOR=$DBGEN_SIZE make
    
    mv TPC-H.db TPC-H-$DBGEN_SIZE.db
fi


# build unikraft unikernel

cd unikraft

echo "Building unikraft unikernel..."
sh generate-kernel.sh $DBGEN_SIZE $TEST

cd ..

# TODO nanos, osv...

if [ "$TEST" == "power" ]; then
    
    # run the benchmark
    echo "Running the benchmark..."
    
    echo "Unikraft"
    cd unikraft
    
    python3 benchmark.py $DBGEN_SIZE ${MEMORY}Gi $ITERATIONS
    
    cd ..
    
    # TODO nanos, osv...
fi

if [ "$TEST" == "boot" ]; then
    
    # run the benchmark
    echo "Running the boot test..."
    
    echo "Unikraft"
    cd unikraft
    
    python3 boot/measure_boot_time.py $ITERATIONS boot/boot_time.csv
    
    cd ..
    
    # TODO nanos, osv...
fi