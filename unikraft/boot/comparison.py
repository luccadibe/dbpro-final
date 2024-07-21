import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from scipy.stats import ttest_rel

# Load the data from CSV files
bash_data = pd.read_csv("bash/boot-time-bash-time.csv")
python_data = pd.read_csv("python/boot-time-python-timestamp.csv")

# Extract the relevant columns
bash_real_time = bash_data["real"]
python_bootup_time = python_data["Bootup_Time_Seconds"]
python_execution_time = python_data["Execution_Time_Seconds"]

# Create a DataFrame for combined data
combined_data = pd.DataFrame(
    {
        "Bash Real Time": bash_real_time,
        "Python Bootup Time": python_bootup_time,
        "Python Execution Time": python_execution_time,
    }
)

# Summary statistics
summary = combined_data.describe()
print("Summary Statistics:\n", summary)

# Perform t-tests
t_test_bootup = ttest_rel(bash_real_time, python_bootup_time)
t_test_execution = ttest_rel(bash_real_time, python_execution_time)
print("\nT-Test Results:")
print(
    f"Bash Real Time vs Python Bootup Time: t-statistic={t_test_bootup.statistic}, p-value={t_test_bootup.pvalue}"
)
print(
    f"Bash Real Time vs Python Execution Time: t-statistic={t_test_execution.statistic}, p-value={t_test_execution.pvalue}"
)

# Plotting CDFs
plt.figure(figsize=(14, 7))

# CDF for Bash Real Time
sns.ecdfplot(data=bash_real_time, label="Bash Real Time", linestyle="-")

# CDF for Python Bootup Time
sns.ecdfplot(data=python_bootup_time, label="Python Timestamp", linestyle="--")

# CDF for Python Execution Time
sns.ecdfplot(data=python_execution_time, label="Python Real Time", linestyle="-.")

plt.title("CDF of Boot Up Times")
plt.xlabel("Time (seconds)")
plt.ylabel("CDF")
plt.legend()
plt.grid(True)
plt.show()

# Plotting boxplots
plt.figure(figsize=(10, 6))
sns.boxplot(data=combined_data)
plt.title("Boxplot of Boot Up Times")
plt.ylabel("Time (seconds)")
plt.grid(True)
plt.show()


# Print the summary statistics
print("Summary Statistics:\n", summary)
