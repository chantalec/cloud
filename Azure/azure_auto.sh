#!/bin/bash

# Initialize Terraform
terraform init -upgrade

# Check if Terraform initialization was successful
if [ $? -ne 0 ]; then
    echo "Terraform initialization failed. Exiting."
    exit 1
fi

# Create Terraform execution plan
terraform plan -out main.tfplan

# Apply Terraform execution plan
terraform apply main.tfplan

# Check if Terraform apply was successful
if [ $? -ne 0 ]; then
    echo "Terraform apply failed. Exiting."
    exit 1
fi

# Extract key_data to new file called key.pem
terraform output -raw key_data > key.pem

# Change permissions of key.pem
chmod 600 key.pem

# Extract public_ip_address to variable
ip_address=$(terraform output -raw public_ip_address)

# Check if public_ip_address is retrieved successfully
if [ -z "$ip_address" ]; then
    echo "Error: Failed to retrieve public IP address. Exiting."
    exit 1
fi

# Debugging output
echo "Public IP Address: $ip_address"

# SSH into Azure and run get_benchmarks.sh script
max_attempts=5
attempt=1

while [ $attempt -le $max_attempts ]; do
    echo "Attempting SSH connection to $ip_address (Attempt $attempt/$max_attempts)"
    if nc -z "$ip_address" 22 2>/dev/null; then
        echo "SSH port is open on $ip_address. Proceeding with SSH."
        ssh -o StrictHostKeyChecking=no -i key.pem azureadmin@$ip_address 'bash -s' < ./get_benchmarks.sh
        # Exit the loop if SSH command is successful
        if [ $? -eq 0 ]; then
            break
        fi
    else
        echo "Error: SSH port is not open on $ip_address. Retrying in 5 seconds..."
        sleep 5
        attempt=$((attempt + 1))
    fi
done

if [ $attempt -gt $max_attempts ]; then
    echo "Error: Max attempts reached. Could not establish SSH connection to $ip_address."
    # Clean up resources
    terraform plan -destroy -out main.destroy.tfplan
    terraform apply main.destroy.tfplan
    exit 1
fi

# Copy benchmark results from remote to local
scp -i key.pem azureadmin@$ip_address:/home/azureadmin/benchmark_results.txt .

# Check if SCP command was successful
if [ $? -ne 0 ]; then
    echo "Error: SCP command failed. Exiting."
    # Clean up resources
    terraform plan -destroy -out main.destroy.tfplan
    terraform apply main.destroy.tfplan
    exit 1
fi

echo "Benchmark results copied successfully."

# Clean up resources
terraform plan -destroy -out main.destroy.tfplan
terraform apply main.destroy.tfplan

exit 0
