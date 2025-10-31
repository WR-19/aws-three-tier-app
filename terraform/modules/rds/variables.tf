variable "name_prefix" {
  description = "Name prefix for resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "allowed_security_groups" {
  description = "List of security group IDs allowed to access RDS"
  type        = list(string)
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
