# Use Alpine Linux as the base image
FROM alpine:latest

# Install build tools, libraries, and SQLite
RUN apk add --no-cache gcc musl-dev sqlite-dev

# Set the working directory
WORKDIR /usr/src/app

# Copy everything from the root directory to the container's working directory
COPY TPC-H.db .
COPY ./tables ./tables
COPY ./queries ./queries
COPY ./docker ./docker

# Compile the C program
RUN gcc -o main docker/main.c -lsqlite3

# Command to run the executable
CMD ./main TPC-H.db 15

