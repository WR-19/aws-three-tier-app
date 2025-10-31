variable "name_prefix" {
  description = "Name prefix for resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "database_name" {
  description = "Database name"
  type        = string
  default     = "appdb"
}

variable "database_user" {
  description = "Database username"
  type        = string
  default     = "appuser"
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
