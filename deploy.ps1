# Azure Decoupled Function App Deployment Script

Write-Host "Starting Azure Function App Deployment..." -ForegroundColor Green

# Check if Azure CLI is installed
try {
    az --version | Out-Null
    Write-Host "✓ Azure CLI is installed" -ForegroundColor Green
} catch {
    Write-Host "✗ Azure CLI is not installed. Please install it first." -ForegroundColor Red
    exit 1
}

# Check if Terraform is installed
try {
    terraform --version | Out-Null
    Write-Host "✓ Terraform is installed" -ForegroundColor Green
} catch {
    Write-Host "✗ Terraform is not installed. Please install it first." -ForegroundColor Red
    exit 1
}

# Check if logged into Azure
try {
    $account = az account show --query "name" -o tsv
    Write-Host "✓ Logged into Azure account: $account" -ForegroundColor Green
} catch {
    Write-Host "✗ Not logged into Azure. Please run 'az login' first." -ForegroundColor Red
    exit 1
}

Write-Host "`nDeploying infrastructure with Terraform..." -ForegroundColor Yellow

# Initialize Terraform
terraform init
if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Terraform init failed" -ForegroundColor Red
    exit 1
}

# Plan deployment
terraform plan
if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Terraform plan failed" -ForegroundColor Red
    exit 1
}

# Apply deployment
Write-Host "`nApplying Terraform configuration..." -ForegroundColor Yellow
terraform apply -auto-approve
if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Terraform apply failed" -ForegroundColor Red
    exit 1
}

Write-Host "`n✓ Infrastructure deployed successfully!" -ForegroundColor Green

# Install Node.js dependencies
Write-Host "`nInstalling Node.js dependencies..." -ForegroundColor Yellow
npm install
if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ npm install failed" -ForegroundColor Red
    exit 1
}

Write-Host "`n✓ Dependencies installed successfully!" -ForegroundColor Green

# Get function app name from Terraform output
$functionAppName = "cloudengineerskillstffuncapp"
Write-Host "`nFunction App Name: $functionAppName" -ForegroundColor Cyan

Write-Host "`nTo deploy the function code, run:" -ForegroundColor Yellow
Write-Host "func azure functionapp publish $functionAppName" -ForegroundColor Cyan

Write-Host "`nTo test the function:" -ForegroundColor Yellow
Write-Host "1. Upload a file to the 'helloworld' container in the storage account" -ForegroundColor Cyan
Write-Host "2. Add a message to the 'copyblobqueue' with the filename" -ForegroundColor Cyan
Write-Host "3. Check the container for the copied file with '-copy' suffix" -ForegroundColor Cyan

Write-Host "`n✓ Deployment completed successfully!" -ForegroundColor Green
