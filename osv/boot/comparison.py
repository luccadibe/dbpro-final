import pandas as pd
import matplotlib.pyplot as plt
import os

# Get the directory where the script is located
script_dir = os.path.dirname(os.path.abspath(__file__))
output_dir = os.path.join(script_dir, 'plots')

csv_file_1 = os.path.join(script_dir, 'bash-sqlite-timer/boot-times.csv')
csv_file_2 = os.path.join(script_dir, 'built-in-timer/boot-times.csv')

df1 = pd.read_csv(csv_file_1)
df2 = pd.read_csv(csv_file_2)

df1['Dataset'] = 'Bash-sqlite timer'
df2['Dataset'] = 'Built-in timer'

# Combine the two datasets for plotting
combined_df = pd.concat([df1[['time(s)', 'Dataset']], df2[['time(s)', 'Dataset']]])

# Create the boxplot
plt.figure(figsize=(10, 6))
combined_df.boxplot(by='Dataset', column=['time(s)'], grid=False)

plt.xlabel('Measurement approach')
plt.ylabel('Time (seconds)')
plt.title('Comparison of Bootup Time Measurement Approaches for OSv')
plt.suptitle('')  

#plt.show()

# Define the output directory relative to the script's location
output_dir = os.path.join(script_dir, 'plots')
output_file = os.path.join(output_dir, 'comparison_plot.png')
os.makedirs(output_dir, exist_ok=True)
plt.savefig(output_file)
