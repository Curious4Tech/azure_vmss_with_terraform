# Azure Virtual Machine Scale Set Terraform Configuration

This repository contains Terraform scripts to deploy an Azure Virtual Machine Scale Set (VMSS) with a load balancer for high availability and auto-scaling capabilities.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) (v1.0.0 or newer)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) installed and configured
- An active Azure subscription

## Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/azure-vmss-terraform.git
cd azure-vmss-terraform
```

### 2. Configure Credentials

Create a file named `terraform.tfvars` to store your credentials:

```bash
# Create the file (this file should NOT be committed to Git)
touch terraform.tfvars
```

Edit the `terraform.tfvars` file and add the following content:

```hcl
admin_username = "yourpreferredusername"
admin_password = "YourSecurePassword123!"
resource_group_location = "East US"  # Change this if needed
instance_count = 2  # Number of initial VM instances
```

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Preview the Changes

```bash
terraform plan
```

Review the planned changes to ensure they match your expectations.

### 5. Deploy the Infrastructure

```bash
terraform apply
```

Type `yes` when prompted to confirm the deployment.

### 6. Access Your Deployment

After deployment completes, Terraform will output:
- The VMSS resource ID
- The public IP address of the load balancer

You can access your applications via the load balancer's public IP.

## Infrastructure Components

This Terraform configuration creates:

- Resource Group
- Virtual Network and Subnet
- Public IP Address
- Load Balancer with HTTP rules (port 80)
- Linux Virtual Machine Scale Set (Ubuntu 18.04 LTS)
- Auto-scaling rules based on CPU usage

## Customization

You can modify the following variables in `terraform.tfvars`:

- `admin_username`: VM administrator username
- `admin_password`: VM administrator password
- `resource_group_location`: Azure region for deployment
- `instance_count`: Initial number of VM instances

## Cleaning Up

To destroy all resources when they're no longer needed:

```bash
terraform destroy
```

Type `yes` when prompted to confirm deletion of resources.

## Security Notes

- Never commit `terraform.tfvars` or any files containing credentials to version control
- Consider using Azure Key Vault for storing secrets in production environments
- Review network security rules before deploying in production

## Troubleshooting

If you encounter issues:

1. Ensure you're logged into Azure CLI: `az login`
2. Check that you have sufficient permissions in your Azure subscription
3. Verify that your password meets Azure's complexity requirements
4. Review the Terraform and Azure CLI logs for detailed error messages
