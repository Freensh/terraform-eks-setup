
variable "project_name" {
    type = string
    default = "my project"
    description = "The name of the project"
}
variable "region" {
    type = string
    default = "ca-central"
  
}

variable "env" {
    type = string
    default = "Dev"
    description = "working enironment"
}

variable "cidr_block" {
    type = string
    description = "vpc cidr block"
    default = "10.0.0.0/16" 
}

variable "az_list" {
    type = list(string)
    description = "list of availability zones"
    default = [ "ca-central-1", "ca-central-2" ]
  
}

variable "pub_subnet_count" {
    description = "Number of public subnets needed"
    type = number
    default = 2
}

variable "pub_sub_cidr_block" {
    description = "list of public subnet cidr blocks"
    type = list(string)
    default = ["10.0.0.0/16", "10.0.0.0/16"]
}

variable "priv_subnet_count" {
    description = "Number of private subnets needed"
    type = number
    default = 2
}

variable "priv_sub_cidr_block" {
    description = "list of private subnet cidr blocks"
    type = list(string)
    default = ["10.0.0.0/16", "10.0.0.0/16"]
}

variable "is_eks_role_enabled" {
    description = "Indicate if there is a need to create iam role for eks"
    type = bool
    default = true
}

variable "is_nodegroup_role_enabled" {
    type = bool
    default = true
}

variable "is_eks_cluster_enabled" {
    type = bool
    default = true
}

variable "cluster_version" {
    type = string
    default = "1.2"
}
variable "endpoint_private_access" {
    type = string
    default = "1.2"
}

variable "endpoint_public_access" {
    type = string
    default = "1.2"
}