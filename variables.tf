#--------------------------------------------------------------
# AWS settings
#--------------------------------------------------------------
variable "access_key" {
    description = "Please enter your AWS access key"
}

variable "secret_key" {
    description = "Please enter your AWS secret key"
}

# Note: Terraform hasn't support passphrased-protected private key yet
variable "key_path" {
    description = "Your private key's path here"
}
