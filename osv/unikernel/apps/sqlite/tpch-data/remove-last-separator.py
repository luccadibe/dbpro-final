import os


def remove_trailing_pipe_from_tbl(file_path):
    try:
        # Read the file content
        with open(file_path, 'r') as file:
            lines = file.readlines()

        # Process each line to remove the trailing '|'
        processed_lines = [line.rstrip('\n').rstrip('|') + '\n' for line in lines]

        # Write the processed lines back to the file
        with open(file_path, 'w') as file:
            file.writelines(processed_lines)

        print(f"Processed {len(lines)} lines in the file {file_path}.")
    except FileNotFoundError:
        print(f"The file {file_path} does not exist.")
    except Exception as e:
        print(f"An error occurred: {e}")

script_dir = os.path.dirname(os.path.abspath(__file__))

file_path = os.path.join(script_dir, 'sqlite3_tpch_rootfs', 'customer.tbl')

remove_trailing_pipe_from_tbl(os.path.join(script_dir, 'customer.tbl'))
remove_trailing_pipe_from_tbl(os.path.join(script_dir, 'lineitem.tbl'))
remove_trailing_pipe_from_tbl(os.path.join(script_dir, 'nation.tbl'))
remove_trailing_pipe_from_tbl(os.path.join(script_dir, 'orders.tbl'))
remove_trailing_pipe_from_tbl(os.path.join(script_dir, 'part.tbl'))
remove_trailing_pipe_from_tbl(os.path.join(script_dir, 'partsupp.tbl'))
remove_trailing_pipe_from_tbl(os.path.join(script_dir, 'region.tbl'))
remove_trailing_pipe_from_tbl(os.path.join(script_dir, 'supplier.tbl'))