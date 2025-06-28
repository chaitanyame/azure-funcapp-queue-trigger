# Create a zip file of the function code
data "archive_file" "function_zip" {
  type        = "zip"
  source_dir  = "${path.module}"
  output_path = "${path.module}/function-app.zip"
  excludes    = ["*.tf", "*.tfvars", "terraform.tfstate*", ".terraform*", "*.ps1", "*.bat", "*.json", "*.txt", "*.md", ".git*", "*.zip"]
}
