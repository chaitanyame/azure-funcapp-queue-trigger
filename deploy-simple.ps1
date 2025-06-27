# Simple Azure Function Deployment with Terraform

Write-Host "Azure Function Deployment with Terraform" -ForegroundColor Green

# Check prerequisites
Write-Host "`nChecking prerequisites..." -ForegroundColor Yellow

# Check Azure CLI
try {
    $account = az account show --query "name" -o tsv
    Write-Host "✓ Azure CLI - Logged in as: $account" -ForegroundColor Green
} catch {
    Write-Host "✗ Azure CLI not logged in. Run: az login" -ForegroundColor Red
    exit 1
}

# Check Terraform
try {
    terraform --version | Out-Null
    Write-Host "✓ Terraform is available" -ForegroundColor Green
} catch {
    Write-Host "✗ Terraform not found. Please install Terraform" -ForegroundColor Red
    exit 1
}

# Deploy with Terraform
Write-Host "`nDeploying with Terraform..." -ForegroundColor Yellow

terraform init
if ($LASTEXITCODE -ne 0) { exit 1 }

terraform plan
if ($LASTEXITCODE -ne 0) { exit 1 }

terraform apply -auto-approve
if ($LASTEXITCODE -ne 0) { exit 1 }

Write-Host "`n✓ Deployment completed!" -ForegroundColor Green

# Show outputs
Write-Host "`nDeployment Information:" -ForegroundColor Cyan
terraform output

Write-Host "`nTo test the function:" -ForegroundColor Yellow
Write-Host "1. Upload a file to the storage container" -ForegroundColor White
Write-Host "2. Add the filename to the queue" -ForegroundColor White
Write-Host "3. Check for the copied file with '-copy' suffix" -ForegroundColor White

Write-Host "`nFunction App URL:" -ForegroundColor Cyan
terraform output -raw function_app_url
