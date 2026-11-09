###############################################################################
# main.tf
# -----------------------------------------------------------------------------
# Main Terraform configuration file for provisioning a Docker container
# running nginx:alpine using the kreuzwerker/docker provider.
#
# This is a beginner-friendly Infrastructure as Code (IaC) demonstration:
#   1. Declares Terraform version and Docker provider requirements.
#   2. Pulls the lightweight nginx:alpine image.
#   3. Creates a Docker container named "terraform-nginx".
#   4. Maps a configurable host port to container port 80.
#   5. Uses variables for all configurable values.
#   6. Exposes useful outputs for verification.
###############################################################################

#------------------------------------------------------------------------------
# Terraform Settings
#------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.0"

  required_providers {
    # Official Docker provider maintained by kreuzwerker.
    # Docs: https://registry.terraform.io/providers/kreuzwerker/docker/latest
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

#------------------------------------------------------------------------------
# Provider Configuration
#------------------------------------------------------------------------------
provider "docker" {
  # Connects to the local Docker daemon.
  # On most systems Docker Desktop / Docker Engine runs on a Unix socket.
  # No explicit host is needed when the daemon is on the default socket.
  host = "unix:///var/run/docker.sock"
}

#------------------------------------------------------------------------------
# Docker Image — nginx:alpine
#------------------------------------------------------------------------------
# Pulls the lightweight nginx:alpine image from Docker Hub.
resource "docker_image" "nginx" {
  name         = var.docker_image
  keep_locally = var.keep_locally
}

#------------------------------------------------------------------------------
# Docker Container — terraform-nginx
#------------------------------------------------------------------------------
# Creates and starts the container from the image above.
resource "docker_container" "nginx" {
  name  = var.container_name
  image = docker_image.nginx.image_id

  # Publish container port 80 to a configurable host port.
  ports {
    internal = var.container_port
    external = var.host_port
  }

  # Restart policy — keep the container running unless explicitly stopped.
  restart = "unless-stopped"

  # Ensure the image is pulled before the container is created.
  depends_on = [docker_image.nginx]
}
