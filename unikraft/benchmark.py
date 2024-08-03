import subprocess
import re
import csv
import sys


def run_benchmark(db_size, memory, iterations):
    # output file name
    output_file = f"power/unikraft_{db_size}_{iterations}_iterations.csv"

    #  headers
    headers = ["iteration", "query", "time(s)"]

    with open(output_file, "w", newline="") as file:
        writer = csv.writer(file)
        writer.writerow(headers)

        #  benchmark for the given number of iterations
        for iteration in range(1, iterations + 1):

            cmd = f"kraft run --memory {memory}"
            process = subprocess.Popen(
                cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE
            )
            stdout, stderr = process.communicate()

            # decode bytes to string
            output = stdout.decode()

            # Extract the run times using regex
            times = re.findall(
                r"Run Time: real ([0-9.]+) user [0-9.]+ sys [0-9.]+", output
            )

            # Convert times to float and handle the special case for query 15
            times = list(map(float, times))
            # Sum times for query 15
            times[14] = sum(
                times[14:17]
            )  # sum the times for the 15th query (indices 14, 15, 16)
            del times[15:17]  # remove the extra times for query 15

            # Write each query's time to the CSV file
            for query_number, time in enumerate(times, 1):
                writer.writerow([iteration, query_number, time])


# entry point
if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python3 benchmark.py <db_size> <memory> <iterations>")
        print("Example: python benchmark.py 0.7 2Gi 15")
    else:
        db_size = sys.argv[1]
        memory = sys.argv[2]
        iterations = int(sys.argv[3])
        run_benchmark(db_size, memory, iterations)
