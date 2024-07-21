import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
from scipy.stats import pearsonr

# Load the data
data = pd.read_csv("boot-time-bash-time.csv")

# Summary statistics
summary_stats = data[["real", "user", "sys"]].describe()
print("Summary Statistics:")
print(summary_stats)

# Correlation analysis
corr_real_user, _ = pearsonr(data["real"], data["user"])
corr_real_sys, _ = pearsonr(data["real"], data["sys"])
corr_user_sys, _ = pearsonr(data["user"], data["sys"])
print(f"\nCorrelation between real and user time: {corr_real_user}")
print(f"Correlation between real and sys time: {corr_real_sys}")
print(f"Correlation between user and sys time: {corr_user_sys}")

# Boxplot
plt.figure(figsize=(12, 6))
sns.boxplot(data=data[["real", "user", "sys"]])
plt.title("Boxplot of Real, User, and Sys Times")
plt.ylabel("Time (seconds)")
plt.xlabel("Measurement Type")
plt.xticks([0, 1, 2], ["Real", "User", "Sys"])
plt.show()

# Histograms
plt.figure(figsize=(12, 6))
sns.histplot(data["real"], kde=True, label="Real")
sns.histplot(data["user"], kde=True, color="orange", label="User")
sns.histplot(data["sys"], kde=True, color="green", label="Sys")
plt.title("Distribution of Real, User, and Sys Times")
plt.xlabel("Time (seconds)")
plt.ylabel("Frequency")
plt.legend()
plt.show()

# Efficiency analysis (user/real and sys/real ratios)
data["user_real_ratio"] = data["user"] / data["real"]
data["sys_real_ratio"] = data["sys"] / data["real"]

plt.figure(figsize=(12, 6))
sns.boxplot(data=data[["user_real_ratio", "sys_real_ratio"]])
plt.title("Boxplot of User/Real and Sys/Real Ratios")
plt.ylabel("Ratio")
plt.xlabel("Ratio Type")
plt.xticks([0, 1], ["User/Real", "Sys/Real"])
plt.show()

# Detailed stats for user/real and sys/real ratios
ratio_summary_stats = data[["user_real_ratio", "sys_real_ratio"]].describe()
print("Ratio Summary Statistics:")
print(ratio_summary_stats)
