###############################################################################
# outputs.tf
# -----------------------------------------------------------------------------
# Output definitions for the Terraform Docker nginx project.
# These expose useful information after apply and can be read with
# `terraform output`.
###############################################################################

#------------------------------------------------------------------------------
# Container ID
#------------------------------------------------------------------------------
output "container_id" {
  description = "The ID of the created Docker container."
  value       = docker_container.nginx.id
}

#------------------------------------------------------------------------------
# Container Name
#------------------------------------------------------------------------------
output "container_name" {
  description = "The name of the created Docker container."
  value       = docker_container.nginx.name
}

#------------------------------------------------------------------------------
# Container Image Name (for reference)
#------------------------------------------------------------------------------
output "container_image" {
  description = "The image used to create the Docker container."
  value       = docker_container.nginx.image
}

#------------------------------------------------------------------------------
# Container Restart Policy
#------------------------------------------------------------------------------
output "container_restart_policy" {
  description = "The restart policy of the Docker container."
  value       = docker_container.nginx.restart
}

#------------------------------------------------------------------------------
# Image ID
#------------------------------------------------------------------------------
output "image_id" {
  description = "The ID of the Docker image used."
  value       = docker_image.nginx.image_id
}

#------------------------------------------------------------------------------
# Port Mapping
#------------------------------------------------------------------------------
output "port_mapping" {
  description = "The host port mapped to the container port."
  value = {
    host_port      = var.host_port
    container_port = var.container_port
  }
}

#------------------------------------------------------------------------------
# Application URL
#------------------------------------------------------------------------------
output "application_url" {
  description = "URL to access the nginx application from the host."
  value       = "http://localhost:${var.host_port}"
}
