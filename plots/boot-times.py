import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# Load the data from CSV files
osv_data = pd.read_csv("../osv/boot/osv_boot-time.csv")
nanos_data = pd.read_csv("../nanos/boot/nanos_boot-time.csv")
unikraft_data = pd.read_csv("../unikraft/boot/unikraft_boot-time.csv")


osv_boot_time = osv_data["time(s)"]
nanos_boot_time = nanos_data["time(s)"]
unikraft_boot_time = unikraft_data["time(s)"]

# Create a DataFrame for combined data
combined_data = pd.DataFrame(
    {"OSv": osv_boot_time, "Nanos": nanos_boot_time, "Unikraft": unikraft_boot_time}
)

# Plotting boxplots
plt.figure(figsize=(10, 6))
sns.boxplot(data=combined_data)
plt.title("Boxplot of Boot Up Times")
plt.ylabel("Time (seconds)")
plt.grid(True)
plt.savefig("boxplot_boot_times.png", dpi=200)
plt.show()

# Plotting CDFs
plt.figure(figsize=(14, 7))

# CDF for OSv
sns.ecdfplot(data=osv_boot_time, label="OSv", linestyle="-")
# CDF for Nanos
sns.ecdfplot(data=nanos_boot_time, label="Nanos", linestyle="--")
# CDF for Unikraft
sns.ecdfplot(data=unikraft_boot_time, label="Unikraft", linestyle="-.")

plt.title("CDF of Boot Up Times")
plt.xlabel("Time (seconds)")
plt.ylabel("CDF")
plt.legend()
plt.grid(True)
plt.savefig("cdf_boot_times.png", dpi=200)
plt.show()


# Print summary statistics
print("Summary Statistics for OSv Boot Times:\n", osv_boot_time.describe())
print("\nSummary Statistics for Nanos Boot Times:\n", nanos_boot_time.describe())
print("\nSummary Statistics for Unikraft Boot Times:\n", unikraft_boot_time.describe())
