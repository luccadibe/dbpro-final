#!/bin/bash

gcc -o main main.c -lsqlite3

./main ../TPC-H.db 15 | tee ./power/result.csv
