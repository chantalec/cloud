#!/bin/bash

# Check if benchmark_results.txt already exists
if [ -f "benchmark_results.txt" ]; then
    echo "Error: benchmark_results.txt already exists. Please remove or rename it."
    exit 1
fi

# Updates and installs sysbench
sudo apt-get update -y
sudo apt-get install sysbench -y

# File to store benchmark results
log_file="benchmark_results.txt"
border="--------------------------------------"

# Output benchmark results to log_file
{
    echo "Benchmark Results"
    echo $border
    echo
} > $log_file

# Start timer
start_time=$(date +%s)

# CPU Benchmark
echo "Running CPU Benchmark"
{
    echo "CPU Data:"
    sysbench cpu run
    echo
} >> $log_file

# Memory Benchmark
echo "Running Memory Benchmark"
{
    echo "Memory Data:"
    sysbench memory run
    echo
} >> $log_file

# FileIO Benchmark
echo "Running FileIO Benchmark"
{
    echo "FileIO Data:"
    sysbench fileio --file-test-mode=seqwr run
    echo
} >> $log_file

# Stop timer
end_time=$(date +%s)
total_execution_time=$((end_time - start_time))
current_date_time=$(date "+%Y-%m-%d %H:%M:%S")
echo
echo "All 3 benchmarks completed!"

# Record Execution time
{
    echo $border
    echo "Results:"
    echo "Benchmarks Completed at $current_date_time"
    echo "Total Execution Time: $total_execution_time seconds"
} >> $log_file

exit
