variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "ces-af-terraform-rg"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "West US 2"
}

variable "storage_account_name" {
  description = "Name of the storage account (must be globally unique)"
  type        = string
  default     = "cloudengineerskillstfsa"
}

variable "function_app_name" {
  description = "Name of the function app (must be globally unique)"
  type        = string
  default     = "cloudengineerskillstffuncapp"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "Owner tag for resources"
  type        = string
  default     = "cloudengineerskills"
}

variable "python_version" {
  description = "Python version for the function app"
  type        = string
  default     = "3.11"
}
