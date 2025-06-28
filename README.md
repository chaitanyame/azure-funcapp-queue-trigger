# Azure Function App with Queue Processing System

This project demonstrates an Azure Function App using Python with:
- Two separate queue processing functions
- JSON message processing and blob storage
- Azure Storage Queue triggers
- Terraform for complete infrastructure provisioning
- Robust error handling and message processing

## Architecture

### Function 1: Queue Logger (`copyblobqueue`)
- Receives messages from the `copyblobqueue` storage queue
- Logs message content for monitoring
- Simple message processing and logging

### Function 2: JSON Processor (`jsonprocessqueue`)
- Receives JSON messages from the `jsonprocessqueue` storage queue
- Directly copies JSON messages to blob storage
- Saves files as `json-messages/message-{guid}.json`

## Features

- ✅ **Dual Queue Processing**: Two functions handling different queues
- ✅ **JSON to Blob**: Direct JSON message copying to blob storage
- ✅ **Queue Triggers**: Automatically processes messages from Azure Storage Queues
- ✅ **JSON Sender Script**: Python script to send JSON messages to queue
- ✅ **Error Handling**: Robust exception handling to prevent message failures
- ✅ **Logging**: Comprehensive logging for Application Insights monitoring
- ✅ **No Retries**: Configured to process messages once without poison queue
- ✅ **Infrastructure as Code**: Complete Terraform setup for all Azure resources

## Quick Start - JSON Processing

### 1. Set Environment Variable
```powershell
$env:AZURE_STORAGE_CONNECTION_STRING = "your_connection_string_from_terraform"
```

### 2. Send JSON Messages to Queue

**Option 1: Send Random JSON (Easy Testing)**
```powershell
# Send 1 random JSON message
.\run-json-sender.ps1

# Send 5 random JSON messages
.\run-json-sender.ps1 -Count 5
```

**Option 2: Send Specific JSON File**
```powershell
# Send sample1.json
.\run-json-sender.ps1 -JsonFile "sample1.json"

# Send sample2.json
.\run-json-sender.ps1 -JsonFile "sample2.json"
```

**Option 3: Direct Python Command**
```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r script-requirements.txt

# Send random JSON
python send_json_to_queue.py

# Send specific file
python send_json_to_queue.py --file sample1.json

# Send multiple random messages
python send_json_to_queue.py --count 3
```

### 3. Monitor Results
- **Function Logs**: Check Azure Portal → Function App → Monitor
- **Blob Storage**: Check `json-messages/` container for processed JSON files
- **File Format**: `message-{random-guid}.json`

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
├── send_json_to_queue.py   # JSON sender script
├── run-json-sender.ps1     # PowerShell helper script
├── script-requirements.txt # Script dependencies
├── sample1.json            # Test JSON file
├── sample2.json            # Test JSON file
├── requirements.txt        # Function app dependencies
├── host.json               # Function app configuration
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
