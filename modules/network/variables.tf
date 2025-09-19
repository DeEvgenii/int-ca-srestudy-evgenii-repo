variable "network_name" {
    description = "VPCネットワークの名前"
    type        = string
    default     = "service-vpc-dev"
}

variable "subnet_name" {
    description = "サブネットの名前"
    type        = string
    default     = "service-subnet-dev"
  
}

variable "region" {
    description = "GCPリージョン"
    type        = string 
}