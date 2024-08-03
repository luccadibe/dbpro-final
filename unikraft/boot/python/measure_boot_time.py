import subprocess
import time
import csv
import sys

def kraft_run():
    start_time = time.time()
    result = subprocess.run(['kraft', 'run'], capture_output=True, text=True)
    end_time = time.time()
    execution_time = end_time - start_time
    output_lines = result.stdout.splitlines()
    return output_lines[-1], execution_time

if len(sys.argv) != 3:
    print("Usage: python measure_boot_time.py <number_of_iterations> <output_file>")
    sys.exit(1)

num_iterations = int(sys.argv[1])
output_file = sys.argv[2]

with open(output_file, mode='w', newline='') as file:
    writer = csv.writer(file)
    writer.writerow(["Iteration", "Start_Timestamp_Nanoseconds", "Measured_Timestamp", "Bootup_Time_Seconds", "Bootup_Time_Milliseconds", "Execution_Time_Seconds"])

    for i in range(1, num_iterations + 1):
        # Get the current timestamp (start time) in nanoseconds
        start_time_ns = time.time_ns()
        print(f"Start time (ns): {start_time_ns}")  # Debug print

        # Capture the timestamp from kraft run output and measure execution time
        measured_timestamp, execution_time = kraft_run()
        measured_timestamp = float(measured_timestamp.strip())
        print(f"Measured timestamp: {measured_timestamp}")  # Debug print

        # Calculate the boot-up time in nanoseconds and convert to seconds and milliseconds
        bootup_time_ns = time.time_ns() - start_time_ns
        bootup_time_seconds = bootup_time_ns / 1_000_000_000
        bootup_time_milliseconds = bootup_time_ns / 1_000_000
        print(f"Bootup time (seconds): {bootup_time_seconds}")  # Debug print
        print(f"Bootup time (milliseconds): {bootup_time_milliseconds:.2f}")  # Debug print
        print(f"Execution time (seconds): {execution_time:.2f}")  # Debug print

        # Write to CSV
        writer.writerow([i, start_time_ns, measured_timestamp, bootup_time_seconds, f"{bootup_time_milliseconds:.2f}", f"{execution_time:.2f}"])

        # Optionally add a delay between iterations
        time.sleep(1)

print(f"Boot-up time measurement completed. Results saved to {output_file}.")

