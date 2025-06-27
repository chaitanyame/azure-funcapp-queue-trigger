# Terraform variables - customize these values as needed

# Resource naming (must be globally unique for storage account and function app)
resource_group_name   = "ces-af-terraform-rg-5733"
storage_account_name  = "cesfuncsa5733"
function_app_name     = "ces-funcapp-5733"

# Location
location = "West US 2"

# Environment and tags
environment = "dev"
owner       = "cloudengineerskills"

# Function runtime
python_version = "3.11"
