# Azure Decoupled Function App POC

This project demonstrates an Azure Function with Node.js using:
- Azure Storage Queue as the trigger
- Azure Blob Storage with input and output bindings
- Terraform for infrastructure provisioning

## Architecture

The function is triggered by messages in an Azure Storage Queue and:
1. Reads a blob from storage using input binding (path specified in queue message)
2. Copies the blob to a new location using output binding (appends '-copy' to filename)

## Prerequisites

- Azure CLI installed and configured
- Terraform installed
- Node.js 20+ installed

## Deployment

1. Initialize Terraform:
   ```powershell
   terraform init
   ```

2. Plan the deployment:
   ```powershell
   terraform plan
   ```

3. Apply the infrastructure:
   ```powershell
   terraform apply
   ```

4. Deploy the function code:
   ```powershell
   func azure functionapp publish <function-app-name>
   ```

## Testing

1. Upload a file to the 'helloworld' container
2. Add a message to the 'copyblobqueue' with the filename
3. The function will copy the file with '-copy' suffix

## Resources Created

- Resource Group
- Storage Account with Queue and Container
- Function App (Linux Consumption Plan)
- Application Insights
- Log Analytics Workspace
