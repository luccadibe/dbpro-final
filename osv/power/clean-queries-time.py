import csv
import re
import os

def extract_run_times(file_path, iteration):
    run_times = []
    
    with open(file_path, 'r') as file:
        lines = file.readlines()
        
        current_query = 1
        run_time_sum = 0
        run_time_count = 0  # To track the number of times we've summed for query 15

        for line in lines:
            if "Run Time:" in line:
                # Extract the real time value using regex
                match = re.search(r"real\s+(\d+\.\d+)", line)
                if match:
                    real_time = float(match.group(1))
                    
                    if current_query == 15:
                        run_time_sum += real_time
                        run_time_count += 1
                        
                        # When we've summed three times, add the result and move to the next query
                        if run_time_count == 3:
                            run_times.append(run_time_sum)
                            current_query += 1
                            run_time_sum = 0
                            run_time_count = 0
                    else:
                        run_times.append(real_time)
                        current_query += 1
                    
                    # Stop if we've reached query 22
                    if current_query > 22:
                        break
    
    return run_times


def save_to_csv(output_file, iteration, run_times):
    # If iteration is 1, open the file in write mode to overwrite it
    mode = 'w' if iteration == 1 else 'a'
    write_header = iteration == 1

    with open(output_file, mode, newline='') as csvfile:
        writer = csv.writer(csvfile)
        
        if write_header:
            writer.writerow(['iteration', 'query', 'time(s)'])
        
        for query_num, time in enumerate(run_times, start=1):
            writer.writerow([iteration, query_num, time])

import sys

if __name__ == "__main__":
    script_dir = os.path.dirname(os.path.abspath(__file__))
    file_path = os.path.join(script_dir, 'temporary.txt')

    # Check if the iteration index is provided as an argument
    if len(sys.argv) != 3:
        print("Usage: python script.py <iteration_index>")
        sys.exit(1)
    
    iteration = int(sys.argv[1])
    output_file = sys.argv[2]

    # Extract the run times for the given iteration
    run_times = extract_run_times(file_path, iteration)

    # Save the results to the CSV file
    save_to_csv(output_file, iteration, run_times)

    print(f"Results of iteration {iteration} saved to {output_file}")
