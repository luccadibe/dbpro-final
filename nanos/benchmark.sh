#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <itr> <memory_size>"
    exit 1
fi

ITR=$1
MEMORY_SIZE=$2


# Copy the necessary folders and file from the parent directory to the current directory.
cp -r ../queries .
cp -r ../tables .
cp ../TPC-H.db .

# Compile the C program into ELF 'main'
gcc -o main main.c -lsqlite3

# Create a unikernel package from the compiled executable 'main'.
ops pkg from-run --name main --version 1.0 main

echo "generating config file"
# Create the config.json file with the specified JSON content
cat <<EOF > nano_config.json
{
    "Files": ["TPC-H.db"], 
    "Args": ["TPC-H.db", "$ITR"],
    "Dirs": ["queries", "tables"],
    "BaseVolumeSz": "${MEMORY_SIZE}g", 
    "RunConfig": {
        "Accel": true
    }
}
EOF

echo "Config File has been generated.."


# Load the unikernel package 'main_1.0' with configuration from 'nano_config.json'.
ops pkg load --local main_1.0 -c nano_config.json | tee ./power/result.csv

# Clean up
rm -f TPC-H.db
rm -r queries
rm -r tables

