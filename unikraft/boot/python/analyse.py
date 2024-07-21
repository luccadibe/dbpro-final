import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
from scipy.stats import ttest_rel
import sys

if len(sys.argv) != 2:
    print("Usage: python analyze_data.py <input_csv_file>")
    sys.exit(1)

input_file = sys.argv[1]

# Read the data from the CSV file
data = pd.read_csv(input_file)

# Summary statistics
summary_stats = data[["Bootup_Time_Seconds", "Execution_Time_Seconds"]].describe()
print("Summary Statistics:")
print(summary_stats)

# Paired t-test
t_stat, p_value = ttest_rel(data["Bootup_Time_Seconds"], data["Execution_Time_Seconds"])
print(f"\nPaired t-test results: t-statistic = {t_stat}, p-value = {p_value}")

# Boxplot
plt.figure(figsize=(12, 6))
sns.boxplot(data=data[["Bootup_Time_Seconds", "Execution_Time_Seconds"]])
plt.title("Boxplot of Bootup Time and Execution Time")
plt.ylabel("Time (seconds)")
plt.xlabel("Measurement Type")
plt.xticks([0, 1], ["Bootup Time", "Execution Time"])
plt.show()

# Histograms
plt.figure(figsize=(12, 6))
sns.histplot(data["Bootup_Time_Seconds"], kde=True, label="Bootup Time")
sns.histplot(
    data["Execution_Time_Seconds"], kde=True, color="orange", label="Execution Time"
)
plt.title("Distribution of Bootup Time and Execution Time")
plt.xlabel("Time (seconds)")
plt.ylabel("Frequency")
plt.legend()
plt.show()

# Outliers
plt.figure(figsize=(12, 6))
sns.boxplot(data=data[["Bootup_Time_Seconds", "Execution_Time_Seconds"]], whis=1.5)
plt.title("Boxplot with Outliers")
plt.ylabel("Time (seconds)")
plt.xlabel("Measurement Type")
plt.xticks([0, 1], ["Bootup Time", "Execution Time"])
plt.show()
