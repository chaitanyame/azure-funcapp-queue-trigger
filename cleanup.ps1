# Azure Decoupled Function App Cleanup Script

Write-Host "Starting cleanup of Azure resources..." -ForegroundColor Yellow

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

# Confirm deletion
$confirmation = Read-Host "Are you sure you want to destroy all Azure resources? This cannot be undone. (yes/no)"
if ($confirmation -ne "yes") {
    Write-Host "Cleanup cancelled." -ForegroundColor Yellow
    exit 0
}

Write-Host "`nDestroying infrastructure with Terraform..." -ForegroundColor Yellow

# Destroy resources
terraform destroy -auto-approve
if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Terraform destroy failed" -ForegroundColor Red
    exit 1
}

Write-Host "`n✓ All Azure resources have been destroyed!" -ForegroundColor Green
