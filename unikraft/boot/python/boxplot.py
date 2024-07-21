import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import sys

if len(sys.argv) != 2:
    print("Usage: python boxplot.py <input_csv_file>")
    sys.exit(1)

input_file = sys.argv[1]

# Read the data from the CSV file
data = pd.read_csv(input_file)
sns.set(font_scale=1.2)
# Create the boxplot
plt.figure(figsize=(12, 6), dpi=200)
sns.boxplot(data=data[["Bootup_Time_Seconds", "Execution_Time_Seconds"]])
plt.title("Boxplot of Bootup Time and Execution Time")
plt.ylabel("Time (seconds)")
plt.xlabel("Measurement Type")
plt.xticks([0, 1], ["Timestamp", "Execution Time"])
plt.show()

plt.savefig("BootUpTimeComparisonBoxplot.png")
