variable "vpc_id" {
    default = "vpc-036cd2fc7e7000ab6"
}

variable "username" {
    default = "root"
}
variable "rd_pwd_postgre" {
    default = "123456789"
}
variable "identifier_db" {
    default = "khainh_db"
}

variable "db_name" {
    default = "khainh_db"
}
variable "enginedb" {
    default = "postgres"
}
variable "engine_version" {
    default = "16"
}
variable "instance_class" {
    default = "db.t3.medium"
}

variable "db_port" {
    default     = 5432
}

