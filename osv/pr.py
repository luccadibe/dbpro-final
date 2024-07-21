import csv


def process_time_file(input_file, output_file):
    with open(input_file, "r") as infile, open(output_file, "w", newline="") as outfile:
        csv_writer = csv.writer(outfile)
        csv_writer.writerow(["iteration", "time(s)"])

        for iteration, line in enumerate(infile, start=1):
            time_ms = float(line.strip())
            time_s = time_ms / 1000
            csv_writer.writerow([iteration, time_s])


if __name__ == "__main__":
    input_file = "bootup_time_clean.txt"  # Replace with your input file name
    output_file = "output.csv"  # Replace with your desired output file name
    process_time_file(input_file, output_file)
