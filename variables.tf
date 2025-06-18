variable "aws_region" {
  description = "The AWS region to deploy the EKS cluster in."
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "The name of the EKS cluster."
  default     = "my-eks-cluster"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "The CIDR blocks for the public subnets."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "The CIDR blocks for the private subnets."
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "worker_node_instance_type" {
  description = "The instance type for the EKS worker nodes."
  default     = "t3.medium"
}

variable "worker_node_desired_size" {
  description = "The desired number of worker nodes."
  default     = 2
}

variable "worker_node_min_size" {
  description = "The minimum number of worker nodes."
  default     = 2
}

variable "worker_node_max_size" {
  description = "The maximum number of worker nodes."
  default     = 3
}