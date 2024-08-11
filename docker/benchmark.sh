#!/bin/bash

docker build -t main -f ../Dockerfile ../.
docker run main > ./power/result.csv
