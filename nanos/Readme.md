
# Nanos Benchmarking and Bootup Time Measurement

## Prerequisites
Before running the scripts, ensure that you have the following installed:

- `gcc`: C compiler
- `ops`: A tool for creating and running nanos unikernal images: https://github.com/nanovms/ops
- `sqlite3`: database to be benchmarked

## Overview
This folder contains scripts to run benchmarks on a SQLite database using nanos.
- `main.c`: C program that interacts with SQlite database, runs all 22 TPC-H queries and logs metrices
- `benchmark.sh`: This script sets up the necessary environment, compiles the C program, creates a nanos image using the compiled ELF, runs the benchmarking on unikernal and logs the metrices to `result.csv` file.
- `measure-boot-time.sh`: This script is used to measures the bootup time of the unikernal.

## Running the Scripts

### `benchmark.sh`

The `benchmark.sh` script is responsible for the following tasks:

```bash
Usage: ./benchmark.sh <itr> <memory_size>
```

2. **Environment Setup**: The script copies necessary folders (`queries`, `tables`) and files (`TPC-H.db`) from the parent directory to the current working directory.

3. **Compilation**: The C program (`main.c`) is compiled into an executable called `main`.

4. **Creating Unikernal Image**: The compiled executable is packaged into a unikernel using `ops pkg`.

5. **Configuration File Generation**: A configuration file (`nano_config.json`) is generated with the specified memory size and the number of iterations. This configuration is used to run the unikernel.

6. **Execution and Logging**: The unikernel is executed, and the results are logged into a CSV file (`./power/result.csv`).

7. **Cleanup**: After execution, the script cleans up by removing the copied files and directories.


