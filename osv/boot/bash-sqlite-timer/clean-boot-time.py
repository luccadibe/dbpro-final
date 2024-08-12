import os
import sys
import csv

# Check if the input file path is provided
if len(sys.argv) < 2:
    print("Usage: python script.py <path_to_txt_file>")
    sys.exit(1)

# Get the input file path from the command line arguments
input_file_path = sys.argv[1]

# Define the output CSV file path in the same directory as the input file
output_file_path = os.path.join(os.path.dirname(input_file_path), "boot-times.csv")

# Initialize the iteration counter
iteration = 0
current_time_list = []
sqlite_time_list = []

# Open the input file and output CSV file
with open(input_file_path, 'r') as input_file, open(output_file_path, 'w', newline='') as output_file:
    csv_writer = csv.writer(output_file)
    
    # Write the header to the CSV file
    csv_writer.writerow(["iteration", "time(s)"])
    
    # Process the input file line by line
    for line in input_file:
        # Look for lines containing "Current Time (ms):"
        if "Current Time (ms):" in line:
            iteration += 1
            # Extract the current time in ms by splitting and selecting the right part
            current_time_ms = int(line.split(':')[1].strip())
            current_time_list.append(current_time_ms)

        # Look for lines containing SQLite timestamp
        elif line.strip().startswith('sqlite>') and len(line.strip().split()) == 2:
            sqlite_time_ms = int(line.strip().split()[1])
            sqlite_time_list.append(sqlite_time_ms)
            # Calculate the difference and write to CSV starting from the third iteration
            if iteration >= 3:
                time_diff_ms = sqlite_time_list[-1] - current_time_list[-1]
                time_diff_sec = time_diff_ms / 1000.0
                csv_writer.writerow([iteration - 2, round(time_diff_sec, 3)])

print(f"OSv: CSV file created at: {output_file_path}")
