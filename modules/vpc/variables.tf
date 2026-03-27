variable "vpc_cidr" {
    description = "cidr block for vpc"
    type = string
}

variable "availability_zones" {
    description = "Availability zones"
    type = list(string) 
}

variable "private_subnet_cidrs" {
    description = "cidr block for private subnet"
    type = list(string)
}

variable "public_subnet_cidrs" {
    description = "cidr block for public subnet"
    type = list(string)
}

variable "container_name" {
    description = "Name of ECS container"
    type = string
}