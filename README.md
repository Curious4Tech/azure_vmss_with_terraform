# Azure Virtual Machine Scale Set Terraform Configuration

This repository contains Terraform scripts to deploy an Azure Virtual Machine Scale Set (VMSS) with a load balancer for high availability and auto-scaling capabilities.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) (v1.0.0 or newer)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) installed and configured
- An active Azure subscription

## Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/Curious4Tech/azure_vmss_with_terraform.git
cd azure_vmss_with_terraform
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
terraform validate
```

![image](https://github.com/user-attachments/assets/c40d9e82-18ec-4f69-a086-d7f50bf56cf7)


### 4. Preview the Changes

```bash
terraform plan
```

![image](https://github.com/user-attachments/assets/632cd039-0e08-4b55-ae5f-26f667a7df11)


Review the planned changes to ensure they match your expectations.

### 5. Deploy the Infrastructure

```bash
terraform apply
```

![image](https://github.com/user-attachments/assets/e1b722c3-608e-4fc6-9394-644bfb8ebea2)

Type `yes` when prompted to confirm the deployment.

![image](https://github.com/user-attachments/assets/623466c6-327a-4354-baff-e9ad1b2eebdf)


### 6. Access Your Deployment

After deployment completes, Terraform will output:
- The VMSS resource ID
- The public IP address of the load balancer

![image](https://github.com/user-attachments/assets/64170015-bdd9-445d-aeaf-69581f704d1a)


You can access your applications via the load balancer's public IP.

## Infrastructure Components

This Terraform configuration creates:

- Resource Group
- Virtual Network and Subnet
- Public IP Address
- Load Balancer with HTTP rules (port 80)
- Linux Virtual Machine Scale Set (Ubuntu 18.04 LTS)
- Auto-scaling rules based on CPU usage

![image](https://github.com/user-attachments/assets/987573dd-74a5-46ed-93f9-c9f42db5a372)

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

![image](https://github.com/user-attachments/assets/4a72abc3-5ac7-41ef-bcbd-6b7898080ff6)


Type `yes` when prompted to confirm deletion of resources.

![image](https://github.com/user-attachments/assets/95f5edb4-af98-48d5-b116-bcce08cd1cd2)


## Security Notes

- Never commit `terraform.tfvars` or any files containing credentials to version control
- Consider using Azure Key Vault for storing secrets in production environments
- Review network security rules before deploying in production

## Troubleshooting

If you encounter issues:

1. Ensure you're logged into Azure CLI: `az login`

![image](https://github.com/user-attachments/assets/d74201a5-dc2c-4e42-abfc-fc8d621ad7d1)
 
2. Check that you have sufficient permissions in your Azure subscription
4. Verify that your password meets Azure's complexity requirements
5. Review the Terraform and Azure CLI logs for detailed error messages
