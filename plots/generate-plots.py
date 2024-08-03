import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# change this according to your results files
# paths for each CSV file
paths = {
    "unikraft": "../unikraft/power/unikraft_0_7_15_iterations.csv",
    "nanos": "../nanos/power/nanos_0_7_15_iterations.csv",
    "osv": "../osv/power/osv_0_7_15_iterations.csv",
    "bare_metal": "../baremetal/power/baremetal_0_7_15_iterations.csv",
    "docker": "../docker/power/docker_0_7_15_iterations.csv",
}


def load_data(file_path):
    return pd.read_csv(file_path)


# Load data for all systems
data = {system: load_data(path) for system, path in paths.items()}

# Combine all data into a single dataframe
combined_data = pd.concat([data[system].assign(system=system) for system in data])


# Plotting functions
def plot_query_runtime_range(start, end, title, filename):
    plt.figure(figsize=(16, 8))
    sns.boxplot(
        data=combined_data[combined_data["query"].between(start, end)],
        x="query",
        y="time(s)",
        hue="system",
    )
    plt.title(title)
    plt.ylabel("Time (seconds)")
    plt.grid(True)
    plt.legend(title="System")
    plt.savefig(filename, dpi=300)
    plt.show()


def plot_single_queries(queries, title, filename):
    plt.figure(figsize=(16, 8))
    sns.boxplot(
        data=combined_data[combined_data["query"].isin(queries)],
        x="query",
        y="time(s)",
        hue="system",
    )
    plt.title(title)
    plt.ylabel("Time (seconds)")
    plt.grid(True)
    plt.legend(title="System")
    plt.savefig(filename, dpi=300)
    plt.show()


# side-by-side comparison of query run time from query 1 to 11
plot_query_runtime_range(
    1, 11, "Comparison of Query Run Time (Query 1 to 11)", "query_runtime_1_to_11.png"
)

# side-by-side comparison of query run time from query 12 to 22
plot_query_runtime_range(
    12,
    22,
    "Comparison of Query Run Time (Query 12 to 22)",
    "query_runtime_12_to_22.png",
)

# side-by-side comparison for specific queries (13, 17, 4, 12, 20)
# TODO: add any additional insights specific to these queries
# what the queries do, why they are important, etc.
plot_single_queries(
    [13, 17, 4, 12, 20],
    "Comparison of Specific Queries (13, 17, 4, 12, 20)",
    "specific_queries.png",
)

# compare mean query run times
mean_query_times = (
    combined_data.groupby(["system", "query"])["time(s)"].mean().unstack()
)
mean_query_times.plot(kind="bar", figsize=(16, 8))
plt.title("Mean Query Run Times for Each System")
plt.ylabel("Mean Time (seconds)")
plt.xlabel("Query")
plt.grid(True)
plt.legend(title="System")
plt.savefig("mean_query_run_times.png", dpi=300)
plt.show()

# overall mean time per system
# this is the average time for all queries for each system
# not exactly a useful metric, but it's interesting to see
overall_mean_time = combined_data.groupby("system")["time(s)"].mean().sort_values()
overall_mean_time.plot(kind="bar", figsize=(10, 6))
plt.title("Overall Mean Query Run Time per System")
plt.ylabel("Mean Time (seconds)")
plt.xlabel("System")
plt.grid(True)
plt.savefig("overall_mean_query_run_time.png", dpi=300)
plt.show()
