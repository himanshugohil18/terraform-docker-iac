###############################################################################
# variables.tf
# -----------------------------------------------------------------------------
# Input variable definitions for the Terraform Docker nginx project.
# All configurable values are declared here so the configuration is reusable.
###############################################################################

#------------------------------------------------------------------------------
# Docker Image Name
#------------------------------------------------------------------------------
variable "docker_image" {
  description = "Docker image to pull from Docker Hub."
  type        = string
  default     = "nginx:alpine"
}

#------------------------------------------------------------------------------
# Keep Image Locally
#------------------------------------------------------------------------------
variable "keep_locally" {
  description = "If true, the image is kept in the local Docker cache after destroy."
  type        = bool
  default     = true
}

#------------------------------------------------------------------------------
# Container Name
#------------------------------------------------------------------------------
variable "container_name" {
  description = "Name assigned to the Docker container."
  type        = string
  default     = "terraform-nginx"
}

#------------------------------------------------------------------------------
# Host Port (the port you access from the host machine)
#------------------------------------------------------------------------------
variable "host_port" {
  description = "Host port to map to the container's exposed port."
  type        = number
  default     = 8081
}

#------------------------------------------------------------------------------
# Container Port (the port nginx listens on inside the container)
#------------------------------------------------------------------------------
variable "container_port" {
  description = "Port the nginx container listens on internally."
  type        = number
  default     = 80
}
