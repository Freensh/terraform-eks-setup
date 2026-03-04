
variable "cluster_name" {
    type = string
}
variable "vpc_name" {
    type = string
}
variable "igw_name" {
    type = string
}
variable "pub_sub_name" {
    type = string
}
variable "priv_sub_name" {
    type = string
}
variable "pub_rt_name" {
    type = string
}
variable "priv_rt_name" {
    type = string
}
variable "nat_gw_name" {
    type = string
}
variable "ngw_eip_name" {
    type = string
}
variable "cluster_sg_name" {
    type = string
}
variable "region" {
    type = string 
}

variable "env" {
    type = string
}

variable "cidr_block" {
    type = string
}

variable "az_list" {
    type = list(string)
}

variable "pub_subnet_count" {
    type = number
}

variable "pub_sub_cidr_block" {
    type = list(string)
}

variable "priv_subnet_count" {
    type = number
}

variable "priv_sub_cidr_block" {
    type = list(string)
}

variable "is_eks_role_enabled" {
    type = bool
}

variable "is_nodegroup_role_enabled" {
    type = bool
}

variable "is_eks_cluster_enabled" {
    type = bool
}

variable "cluster_version" {
    type = string
}
variable "endpoint_private_access" {
    type = string
}

variable "endpoint_public_access" {
    type = string
}

variable "addons" {
    type = list(object({
      name = string
      version = string
    }))
}

variable "ondemand-instance-types" {
    type = list(string)
}
variable "desired_capacity_ondemand" {
    type = number
}
variable "min_capacity_ondemand" {
    type = number
}
variable "max_capacity_ondemand" {
    type = number
}
variable "spot-instance-types" {
    type = list(string)
}
variable "desired_capacity_spot" {
    type = number
}
variable "min_capacity_spot" {
    type = number
}
variable "max_capacity_spot" {
    type = number
}
