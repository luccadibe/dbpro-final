# OSv Benchmarking and Bootup Time Measurement

This folder contains all the necessary code to execute the 22 queries of the TPC-H benchmark and measure the bootup times of the OSv unikernel.

> **Note:** This folder is a subset of OSv's [official repo](https://github.com/cloudius-systems/osv.git). If you intend to run the OSv SQLite unikernel using the original repository, ensure you:
> - Modify the `apps/sqlite/GET` file to fetch the latest version of SQLite and disable fortified source by adding `-D_FORTIFY_SOURCE=0` to the compilation flags.
> - Update the `apps/sqlite/usr.manifest` file to load data into the unikernel's filesystem.

## Structure

```sh
osv/
├── boot/
│   ├── bash-sqlite-timer/   # Measures bootup time by executing a SQLite command that captures current timestamp right after boot
│   ├── built-in-timer/      # Measures bootup time using OSv's built-in functionality
│   ├── plots/               # Contains a boxplot comparing the two bootup timing methods
│   └── comparison.py        # Generates the boxplot in plots/
├── osv_boot-time.csv        # Stores the latest bootup time data from either method
├── power/                   # Contains results of benchmark.sh that runs the 22 TPC-H queries
├── unikernel/               # Core OSv unikernel code
├── benchmark.sh             # Runs the 22 TPC-H queries
├── generate-kernel.sh       # Sets up dependencies and builds the OSv image
└── README.md
```

## About `main.sh`

In relation to OSv, the main script executes one of the two benchmarking aspects:

 - Bootup time
 - Query execution time

and accepts 4 arguments:
1.  `dbgen_size`: The scale factor used for generating the database (e.g., 0.1 for 1GB).
2. `test`: The type of test to run, either `power` (to run the TPC-H benchmark queries) or `boot` (to measure bootup time).
3. `memory`: The amount of memory (in GB) allocated to the unikernel.
4. `iterations`: The number of times the test should be repeated.

with an example usage:

```sh
bash main.sh 0.1 boot 4 5
```

### What it does in terms of OSv:

1. Checks if a pre-generated SQLite database exists for the specified `dbgen_size` (scale factor). If not, it generates the database and ensures that the necessary data files are available.
2. Navigates to the `osv` directory and runs the `generate-kernel.sh` script. This step is responsible for setting up dependencies and compiling the OSv unikernel image, configured for the specified test (`power` or `boot`).
3. Running TPC-H benchmark (`power` test):
    - If the `test` parameter is set to `power`, the script runs the TPC-H benchmark on OSv by calling the `benchmark.sh` script.
    - It runs the benchmark with the specified database size, memory allocation, and number of iterations, measuring the performance of OSv.
4. Measuring bootup time (`boot` test):
    - If the `test` parameter is set to `boot`, the script measures the bootup time of the OSv unikernel using the `measure-boot-time.sh` script located in the `osv/boot/built-in-timer/` directory.
        > **Note:** Since the built-in-timer method is used, this bootup measurement excludes the time spent on starting QEMU.
    - The script captures how long OSv takes to boot, using the specified memory size and iterating the process the given number of times.

## How to run things in this folder?
### Bootup times
```
bash ./boot/bash-sqlite-timer/measure-boot-time.sh
```
The script captures the current system time in milliseconds and logs it to a temporary file. It then runs the OSv unikernel, where it executes a SQL command to retrieve the time in milliseconds from within the unikernel environment, logging this time to the same file. A separate script `clean-boot-time.py` then calculates the difference between these two recorded times, effectively measuring the time taken from when the script starts until the unikernel is fully booted and the SQL command is executed. 

```
bash ./boot/built-in-timer/measure-boot-time.sh
```
Functions the same as the previous, but directly uses the built-in boot up measurements which are logged into a temporary file that is later processed by `clean-boot-time.py`.

### Query execution times
```
bash ./benchmark.sh
```
You will need to build the unikernel image manually before running this, as the script imports `.tbl` files directly into the SQLite database. If the image isn't built anew, the import statements won't work properly. You can build the image with:
```
cd unikernel
./scripts/run.py
cd ..
```
> **Note:** If you want to build the image with a database of relatively large size, increase the size of the image with `fs_size_mb=6000` or a size you deem necessary. If the image size isn't large enough, the build process will fail.