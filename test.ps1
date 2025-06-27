# Test script for Azure Function App

Write-Host "Azure Function Test Helper" -ForegroundColor Green

# Function to get terraform outputs
function Get-TerraformOutput {
    param (
        [string]$OutputName
    )
    
    try {
        $output = terraform output -raw $OutputName
        return $output
    } catch {
        Write-Host "✗ Could not get $OutputName from Terraform output" -ForegroundColor Red
        Write-Host "Make sure you have deployed the infrastructure first" -ForegroundColor Yellow
        exit 1
    }
}

# Function to upload test file
function New-TestFile {
    param (
        [string]$FileName,
        [string]$Content
    )
    
    $storageAccount = Get-TerraformOutput -OutputName "storage_account_name"
    $containerName = Get-TerraformOutput -OutputName "container_name"
    
    # Create a temporary file
    $tempFile = [System.IO.Path]::GetTempFileName()
    Set-Content -Path $tempFile -Value $Content
    
    try {
        az storage blob upload `
            --account-name $storageAccount `
            --container-name $containerName `
            --name $FileName `
            --file $tempFile `
            --overwrite
        
        Write-Host "✓ Uploaded test file: $FileName" -ForegroundColor Green
        Remove-Item $tempFile
    } catch {
        Write-Host "✗ Failed to upload test file" -ForegroundColor Red
        Remove-Item $tempFile
        exit 1
    }
}

# Function to add message to queue
function Add-QueueMessage {
    param (
        [string]$Message
    )
    
    $storageAccount = Get-TerraformOutput -OutputName "storage_account_name"
    $queueName = Get-TerraformOutput -OutputName "queue_name"
    
    try {
        az storage message put `
            --account-name $storageAccount `
            --queue-name $queueName `
            --content $Message
        
        Write-Host "✓ Added message to queue: $Message" -ForegroundColor Green
    } catch {
        Write-Host "✗ Failed to add message to queue" -ForegroundColor Red
        exit 1
    }
}

# Function to check for copied file
function Test-CopiedFile {
    param (
        [string]$OriginalFileName
    )
    
    $storageAccount = Get-TerraformOutput -OutputName "storage_account_name"
    $containerName = Get-TerraformOutput -OutputName "container_name"
    $copiedFileName = "$OriginalFileName-copy"
    
    Write-Host "Checking for copied file: $copiedFileName" -ForegroundColor Yellow
    
    for ($i = 1; $i -le 10; $i++) {
        try {
            $result = az storage blob exists `
                --account-name $storageAccount `
                --container-name $containerName `
                --name $copiedFileName `
                --query "exists" -o tsv
            
            if ($result -eq "true") {
                Write-Host "✓ Found copied file: $copiedFileName" -ForegroundColor Green
                return $true
            }
        } catch {
            # Continue checking
        }
        
        Write-Host "Attempt $i/10: File not found yet, waiting 5 seconds..." -ForegroundColor Yellow
        Start-Sleep -Seconds 5
    }
    
    Write-Host "✗ Copied file not found after 50 seconds" -ForegroundColor Red
    return $false
}

# Main test execution
Write-Host "`nRunning end-to-end test..." -ForegroundColor Cyan

# Check if Azure CLI is logged in
try {
    $account = az account show --query "name" -o tsv
    Write-Host "✓ Logged into Azure account: $account" -ForegroundColor Green
} catch {
    Write-Host "✗ Not logged into Azure. Please run 'az login' first." -ForegroundColor Red
    exit 1
}

# Test parameters
$testFileName = "test-file-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"
$testContent = "Hello, this is a test file created at $(Get-Date)"

Write-Host "`nTest Configuration:" -ForegroundColor Cyan
Write-Host "File Name: $testFileName" -ForegroundColor White
Write-Host "Content: $testContent" -ForegroundColor White

# Step 1: Upload test file
Write-Host "`nStep 1: Uploading test file..." -ForegroundColor Cyan
New-TestFile -FileName $testFileName -Content $testContent

# Step 2: Add message to queue
Write-Host "`nStep 2: Adding message to queue..." -ForegroundColor Cyan
Add-QueueMessage -Message $testFileName

# Step 3: Wait and check for copied file
Write-Host "`nStep 3: Waiting for function to process..." -ForegroundColor Cyan
$success = Test-CopiedFile -OriginalFileName $testFileName

if ($success) {
    Write-Host "`n✓ Test completed successfully! The function is working correctly." -ForegroundColor Green
} else {
    Write-Host "`n✗ Test failed. Check the function logs for details." -ForegroundColor Red
    Write-Host "You can view logs in the Azure portal or using:" -ForegroundColor Yellow
    $functionAppName = Get-TerraformOutput -OutputName "function_app_name"
    Write-Host "func azure functionapp logstream $functionAppName" -ForegroundColor Cyan
}
