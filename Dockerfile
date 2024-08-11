
FROM alpine:latest

RUN apk add --no-cache gcc musl-dev sqlite-dev

WORKDIR /usr/src/app

COPY TPC-H.db .
COPY ./tables ./tables
COPY ./queries ./queries
COPY ./docker ./docker

RUN gcc -o main docker/main.c -lsqlite3

#Default command to run the executable
CMD ["./main", "TPC-H.db", "15"]

