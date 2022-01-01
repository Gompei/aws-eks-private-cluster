variable "region" {
  description = "Region in which to build the resource."
  default     = "ap-northeast-1"
  type        = string
}

variable "vpc_cidr_block" {
  description = "The IP address range of the VPC in CIDR notation."
  default     = "10.0.0.0/16"
  type        = string
}

variable "eks_node_group_name" {
  description = "EKS Node Group Name."
  default     = "eks-node-group"
  type        = string
}
