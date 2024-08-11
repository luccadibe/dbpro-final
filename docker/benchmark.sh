#!/bin/bash


if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <itr>"
    exit 1
fi

ITR=$1

docker build -t main -f ../Dockerfile ../.
docker run -it --rm main ./main TPC-H.db $ITR > ./power/result.csv
