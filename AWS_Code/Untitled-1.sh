
# Initialize Terraform in the directory containing main.tf
terraform init

# Plan the terraform configuration
terraform plan
# Apply the Terraform configuration
terraform apply -auto-approve

# Run sysbench tests
sudo apt-get update
sudo apt-get install sysbench

sysbench --test=cpu run
sysbench --test=memory run
sysbench --test=fileio --file-test-mode=seqwr run

