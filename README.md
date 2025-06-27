# Azure Function App with Queue Trigger

This project demonstrates an Azure Function App using Python with:
- Azure Storage Queue as the trigger
- Queue message processing and logging
- Terraform for complete infrastructure provisioning
- Robust error handling and message processing

## Architecture

The function is triggered by messages in an Azure Storage Queue and:
1. Receives messages from the `copyblobqueue` storage queue
2. Processes and logs the message content
3. Handles message encoding and decoding properly
4. Provides comprehensive logging for monitoring

## Features

- ✅ **Queue Trigger**: Automatically processes messages from Azure Storage Queue
- ✅ **Error Handling**: Robust exception handling to prevent message failures
- ✅ **Logging**: Comprehensive logging for Application Insights monitoring
- ✅ **No Retries**: Configured to process messages once without poison queue
- ✅ **Infrastructure as Code**: Complete Terraform setup for all Azure resources

## Prerequisites

- Azure CLI installed and configured
- Terraform installed
- Python 3.11+ (for local development)
- Azure subscription with appropriate permissions

## Deployment

1. **Initialize Terraform**:
   ```powershell
   terraform init
   ```

2. **Plan the deployment**:
   ```powershell
   terraform plan
   ```

3. **Apply the infrastructure**:
   ```powershell
   terraform apply
   ```

4. **Deploy the function code**:
   ```powershell
   # Create deployment package
   Compress-Archive -Path function_app.py, requirements.txt, host.json -DestinationPath function.zip -Force
   
   # Deploy to Azure
   az functionapp deployment source config-zip -g <resource-group> -n <function-app-name> --src function.zip
   
   # Restart function app
   az functionapp restart -g <resource-group> -n <function-app-name>
   ```

## Testing

1. **Send a test message to the queue**:
   ```powershell
   az storage message put --queue-name copyblobqueue --content "Test message" --account-name <storage-account> --account-key <key>
   ```

2. **Monitor the function logs**:
   ```powershell
   az webapp log tail -g <resource-group> -n <function-app-name>
   ```

3. **Verify message processing**:
   ```powershell
   # Check if queue is empty (message was processed)
   az storage message peek --queue-name copyblobqueue --account-name <storage-account> --account-key <key>
   ```

## Configuration

### Host.json Configuration
- `messageEncoding`: "none" - Handles messages as plain text
- `maxDequeueCount`: 999 - Prevents premature poison queue movement
- `maxPollingInterval`: 2 seconds - Fast message pickup
- `batchSize`: 1 - Process one message at a time

### Function Configuration
- **Trigger**: Azure Storage Queue (`copyblobqueue`)
- **Connection**: Uses `AzureWebJobsStorage` connection string
- **Error Handling**: Catches and logs exceptions without rethrowing

## Resources Created

- **Resource Group**: Container for all resources
- **Storage Account**: With queue and blob container
- **Function App**: Linux Consumption Plan with Python 3.11
- **Application Insights**: For monitoring and logging
- **Log Analytics Workspace**: For log aggregation

## Project Structure

```
├── function_app.py          # Main Azure Function code
├── host.json               # Function app configuration
├── requirements.txt        # Python dependencies
├── main.tf                # Terraform main configuration
├── variables.tf           # Terraform variables
├── outputs.tf             # Terraform outputs
├── terraform.tfvars       # Terraform variable values
└── README.md              # This file
```

## Troubleshooting

- **Function not triggering**: Check queue connection string and function app status
- **Message encoding errors**: Verify `messageEncoding` setting in host.json
- **Deployment issues**: Ensure all required files are included in deployment package
- **SSL errors during deployment**: Use Azure CLI with proper authentication

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request
