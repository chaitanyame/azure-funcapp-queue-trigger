# Create a zip file of the function code
data "archive_file" "function_zip" {
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/function-app.zip"
}
