
#Reference var.VPC_ID
variable "VPC_ID" {
    description = "CIDR block for VPC Creation"
    default = "10.0.0.0/16"
}

#Reference var.subnet-a
variable "subnet-a" {
    description = "CIDR block for subnet Creation"
    default = "10.0.3.0/24"
}

#Reference var.private-ip
variable "private-ip" {
    description = "CIDR block for private-ip Creation"
    default = "10.0.3.50"
}

#Reference var.ami-id
variable "ami-id" {
    description = "Amazon Machine Image ID"
    default = "ami-038f1ca1bd58a5790"
}