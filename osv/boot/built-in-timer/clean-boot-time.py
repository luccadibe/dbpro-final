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

# Open the input file and output CSV file
with open(input_file_path, 'r') as input_file, open(output_file_path, 'w', newline='') as output_file:
    csv_writer = csv.writer(output_file)
    
    # Write the header to the CSV file
    csv_writer.writerow(["iteration", "time(s)"])
    
    # Process the input file line by line
    for line in input_file:
        # Look for lines containing "Booted up in"
        if "Booted up in" in line:
            iteration += 1
            
            # Extract the time in ms (e.g., "2054.86 ms")
            time_ms = float(line.split()[3])
            
            # Convert time from ms to seconds
            time_sec = time_ms / 1000.0
            
            if iteration in [1,2]:
                continue

            # Write the iteration and time in seconds to the CSV file
            csv_writer.writerow([iteration-2, round(time_sec, 3)])

print(f"OSv: CSV file created at: {output_file_path}")
