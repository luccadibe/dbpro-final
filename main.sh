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
    
    cp TPC-H.db ../TPC-H.db
    cp ./tpch-dbgen/*.tbl ../tables/
    
    mv TPC-H.db TPC-H-$DBGEN_SIZE.db
    cd ..
    #check if there is already a generated db of the specified size
    elif [ ! -e "TPCH-sqlite/TPC-H-$DBGEN_SIZE.db" ]; then
    # remove all the tbl files in the TPCH-sqlite directory
    rm TPCH-sqlite/tpch-dbgen/*.tbl
    
    cd TPCH-sqlite
    
    SCALE_FACTOR=$DBGEN_SIZE make
    
    mv TPC-H.db TPC-H-$DBGEN_SIZE.db
    cd ..
fi


# build unikraft unikernel

cd unikraft

echo "Building unikraft unikernel..."
sh generate-kernel.sh $DBGEN_SIZE $TEST

cd ..

cd osv

echo "OSv: Building unikernel image..."
bash ./generate-kernel.sh $DBGEN_SIZE $TEST

cd ..


if [ "$TEST" == "power" ]; then
    
    # run the benchmark
    echo "Running the benchmark..."
    
    echo "Unikraft"
    cd unikraft
    
    python3 benchmark.py $DBGEN_SIZE ${MEMORY}Gi $ITERATIONS
    
    cd ..
    
    # TODO osv..
    
    echo "Nanos"
    cd nanos
    
    bash benchmark.sh $ITERATIONS $MEMORY
    
    cd ..

    echo "OSv"
    cd osv
    bash ./benchmark.sh $DBGEN_SIZE $MEMORY $ITERATIONS

    cd ..

fi

if [ "$TEST" == "boot" ]; then
    
    # run the benchmark
    echo "Running the boot test..."
    
    echo "Unikraft"
    cd unikraft
    
    bash boot/bash/measure-boot-time.sh $ITERATIONS boot_time.csv
    
    cd ..
    
    echo "Nanos"
    
    cd nanos
    
    bash measure-boot-time.sh $ITERATIONS
    
    cd ..
    
    cd osv

    bash ./boot/built-in-timer/measure-boot-time.sh $MEMORY $ITERATIONS

    cd ..

fi
