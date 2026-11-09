# Terraform Docker IaC — Nginx Container Provisioning

> **DevOps Internship Task 3: Infrastructure as Code (IaC) using Terraform and Docker**

This project demonstrates the complete Infrastructure as Code (IaC) workflow by provisioning a local Docker container running `nginx:alpine` using Terraform.

---

## Table of Contents

- [Project Objective](#project-objective)
- [Tools Used](#tools-used)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Terraform Configuration](#terraform-configuration)
- [Provider and Resource Explanation](#provider-and-resource-explanation)
- [Workflow Commands](#workflow-commands)
- [Verification Results](#verification-results)
- [Screenshots Checklist](#screenshots-checklist)
- [Cleanup Instructions](#cleanup-instructions)

---

## Project Objective

Provision a local Docker container running the lightweight `nginx:alpine` image using Terraform, demonstrating the complete IaC lifecycle:

1. Define infrastructure declaratively in Terraform configuration files.
2. Use the official `kreuzwerker/docker` provider to interact with the local Docker daemon.
3. Pull the `nginx:alpine` image and create a container named `terraform-nginx`.
4. Map a host port to container port 80 for HTTP access.
5. Execute the full Terraform workflow: `init → fmt → validate → plan → apply`.
6. Verify the container is running, test HTTP connectivity, and inspect Terraform state.
7. Destroy the infrastructure and confirm cleanup.

---

## Tools Used

| Tool       | Version    | Purpose                                      |
|------------|------------|----------------------------------------------|
| Terraform  | v1.17.1    | Infrastructure as Code — declarative provisioning |
| Docker     | v28.1.1    | Container runtime for nginx:alpine image        |
| Docker Daemon | Running   | Local container engine                           |
| Git        | v2.25.1    | Version control and GitHub repository management |
| Provider   | kreuzwerker/docker ~> 3.0 | Terraform Docker provider             |

**Environment:** Windows 11 with WSL2 Ubuntu, Docker Desktop

---

## Prerequisites

1. **Docker Desktop** installed and running on Windows 11 with WSL2 Ubuntu.
2. **Terraform** installed (v1.0+ recommended).
3. **Git** installed and configured.
4. **GitHub repository** created and accessible.

Verify your environment:

```bash
terraform version
docker --version
docker info
git --version
```

---

## Project Structure

```
terraform-docker-iac/
├── .gitignore            # Excludes .terraform/, state files, secrets, logs
├── main.tf               # Main Terraform config: provider, image, container
├── variables.tf          # Input variable definitions
├── outputs.tf            # Output definitions for verification
├── execution-logs.txt    # Actual terminal command outputs from the workflow
├── README.md             # This documentation file
├── .terraform.lock.hcl   # (Auto-generated, provider lock file — safe to commit)
└── .terraform/           # (Auto-generated, gitignored — provider plugins)
```

---

## Terraform Configuration

### main.tf

Defines the core infrastructure:

- **Terraform block** — sets required Terraform version (>= 1.0) and declares the `kreuzwerker/docker` provider (version ~> 3.0).
- **Provider block** — configures the Docker provider to connect to the local Docker daemon via Unix socket (`unix:///var/run/docker.sock`).
- **docker_image resource** — pulls the `nginx:alpine` image from Docker Hub. The image name and keep-locally flag are parameterized via variables.
- **docker_container resource** — creates a container named `terraform-nginx` from the pulled image. Maps host port (8081) to container port (80). Sets restart policy to `unless-stopped`.

### variables.tf

Defines all configurable inputs:

| Variable          | Type   | Default          | Description                                   |
|-------------------|--------|------------------|-----------------------------------------------|
| `docker_image`    | string | `nginx:alpine`   | Docker image to pull from Docker Hub           |
| `keep_locally`    | bool   | `true`           | Keep image in local cache after destroy        |
| `container_name`  | string | `terraform-nginx`| Name assigned to the Docker container          |
| `host_port`       | number | `8081`           | Host port mapped to container's port 80        |
| `container_port`  | number | `80`             | Port nginx listens on inside the container     |

### outputs.tf

Exposes useful outputs after `terraform apply`:

| Output             | Description                                        |
|--------------------|----------------------------------------------------|
| `container_id`     | The ID of the created Docker container              |
| `container_name`   | The name of the created Docker container            |
| `container_status` | The status (running, exited, etc.)                 |
| `image_id`          | The ID of the Docker image used                     |
| `port_mapping`      | Host port and container port mapping                |
| `application_url`   | URL to access nginx from the host                   |

---

## Provider and Resource Explanation

### Provider: `kreuzwerker/docker`

The `kreuzwerker/docker` provider is the officially recommended Docker provider for Terraform (the original `hashicorp/docker` provider is deprecated). It allows Terraform to manage Docker images, containers, networks, and volumes on a Docker daemon.

**Configuration:**
```hcl
provider "docker" {
  host = "unix:///var/run/docker.sock"
}
```

This connects Terraform to the local Docker daemon running on the Unix socket — the default location for Docker Desktop and Docker Engine on Linux.

### Resource: `docker_image`

Pulls and manages a Docker image. In this project, it pulls `nginx:alpine` from Docker Hub.

```hcl
resource "docker_image" "nginx" {
  name         = var.docker_image
  keep_locally = var.keep_locally
}
```

- `name` — the image name and tag to pull (e.g., `nginx:alpine`).
- `keep_locally` — if `true`, the image remains in the local Docker cache even after `terraform destroy`.

### Resource: `docker_container`

Creates and manages a Docker container from an image.

```hcl
resource "docker_container" "nginx" {
  name  = var.container_name
  image = docker_image.nginx.image_id

  ports {
    internal = var.container_port
    external = var.host_port
  }

  restart = "unless-stopped"
}
```

- `name` — the container name (`terraform-nginx`).
- `image` — references the pulled image by its ID (creates a dependency so the image is pulled first).
- `ports` — maps container port 80 to host port 8081 for HTTP access.
- `restart` — `unless-stopped` ensures the container restarts automatically unless explicitly stopped.

---

## Workflow Commands

### 1. Initialize the working directory

Downloads the Docker provider plugin and initializes the Terraform backend.

```bash
terraform init
```

### 2. Format the configuration files

Automatically formats `.tf` files for consistent style.

```bash
terraform fmt
```

### 3. Validate the configuration

Checks the configuration files for syntax and internal consistency.

```bash
terraform validate
```

### 4. Preview the changes

Generates an execution plan showing what Terraform will create, modify, or destroy.

```bash
terraform plan
```

### 5. Apply the configuration

Provisions the infrastructure (pulls image, creates container). Requires approval unless `-auto-approve` is used.

```bash
terraform apply -auto-approve
```

**Note:** Port 8081 is used as the default host port. If port 8081 is already in use on your system, change the `host_port` variable in `variables.tf` to an available port.

### 6. Inspect the state

Lists all resources tracked by Terraform.

```bash
terraform state list
```

Shows detailed information about a specific resource.

```bash
terraform state show docker_container.nginx
```

### 7. View outputs

Displays all configured output values.

```bash
terraform output
```

### 8. Destroy the infrastructure

Removes all Terraform-managed resources (stops and removes the container).

```bash
terraform destroy -auto-approve
```

---

## Verification Results

> The following results are captured from actual execution. See `execution-logs.txt` for full terminal output.

### Container Verification

```bash
docker ps
```

Confirms the `terraform-nginx` container is running with port `8081:80` mapped.

Actual output:
```
CONTAINER ID   IMAGE          COMMAND                  CREATED          STATUS          PORTS                  NAMES
6e39b3cce9aa   7cac34a4d72b   "/docker-entrypoint..."   25 seconds ago   Up 24 seconds   0.0.0.0:8081->80/tcp   terraform-nginx
```

### HTTP Test

```bash
curl -s -o /dev/null -w "%{http_code}" http://localhost:8081
```

Returns `200` — confirming nginx is serving the default page.

Actual output:
```
HTTP Status Code: 200
```

The full curl response returns the nginx welcome page:
```html
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
...
<h1>Welcome to nginx!</h1>
<p>If you see this page, nginx is successfully installed and working.</p>
```

### State Inspection

```bash
terraform state list
```

Actual output:
```
docker_container.nginx
docker_image.nginx
```

```bash
terraform state show docker_container.nginx
```

Shows full container details: name, image, port mapping, network data, restart policy, and more.

Actual output (key fields):
```
resource "docker_container" "nginx" {
    name                                        = "terraform-nginx"
    image                                       = "sha256:7cac34a4d72be2539edd7d8732207e8ffc8268a0b6458e6491f9b7c3dc95a70d"
    restart                                     = "unless-stopped"
    network_mode                                = "bridge"
    ports {
        external = 8081
        internal = 80
        ip       = "0.0.0.0"
        protocol = "tcp"
    }
}
```

```bash
terraform output
```

Actual output:
```
application_url = "http://localhost:8081"
container_id = "6e39b3cce9aac91da9f48ef45a3184b98397f07988ff7ee094ef59a09f7b7759"
container_image = "sha256:7cac34a4d72be2539edd7d8732207e8ffc8268a0b6458e6491f9b7c3dc95a70d"
container_name = "terraform-nginx"
container_restart_policy = "unless-stopped"
image_id = "sha256:7cac34a4d72be2539edd7d8732207e8ffc8268a0b6458e6491f9b7c3dc95a70d"
port_mapping = {
  "container_port" = 80
  "host_port" = 8081
}
```

### Destroy Verification

After `terraform destroy`:
- `docker ps` — no `terraform-nginx` container (empty output)
- `docker ps -a` — not even in stopped containers (empty output)
- `terraform state list` — empty (no resources tracked)
- `curl http://localhost:8081` — returns `000` (connection refused, as expected)

Destroy output:
```
docker_container.nginx: Destroying... [id=6e39b3cce9aac91da9f48ef45a3184b98397f07988ff7ee094ef59a09f7b7759]
docker_container.nginx: Destruction complete after 1s
docker_image.nginx: Destroying... [id=sha256:7cac34a4d72be2539edd7d8732207e8ffc8268a0b6458e6491f9b7c3dc95a70dnginx:alpine]
docker_image.nginx: Destruction complete after 0s

Destroy complete! Resources: 2 destroyed.
```

---

## Screenshots Checklist

The following screenshots are recommended for the internship submission:

- [ ] Environment verification: `terraform version`, `docker --version`, `docker info`, `git --version`
- [ ] Project directory structure
- [ ] `terraform init` output
- [ ] `terraform fmt` output
- [ ] `terraform validate` output
- [ ] `terraform plan` output
- [ ] `terraform apply` output
- [ ] `docker ps` showing the running container
- [ ] `curl` HTTP test showing 200 response
- [ ] `terraform state list` output
- [ ] `terraform state show docker_container.nginx` output
- [ ] `terraform output` output
- [ ] `terraform destroy` output
- [ ] Post-destroy `docker ps` (container gone)
- [ ] Post-destroy `terraform state list` (empty)
- [ ] Browser access to `http://localhost:8081` (nginx welcome page)

---

## Cleanup Instructions

### Remove Terraform-managed resources

```bash
terraform destroy -auto-approve
```

### Verify cleanup

```bash
docker ps
terraform state list
```

### (Optional) Remove the Docker image

```bash
docker rmi nginx:alpine
```

### (Optional) Clean up the project directory

```bash
cd ~
rm -rf terraform-docker-iac
```

### (Optional) Remove Terraform-generated files

```bash
rm -rf .terraform .terraform.lock.hcl
rm -f terraform.tfstate terraform.tfstate.backup
```

---

## Notes

- This project uses **local state** (`terraform.tfstate`). For team or production use, consider remote state backends (S3, Terraform Cloud, etc.).
- The `.gitignore` file ensures Terraform state files, `.terraform/` directory, credentials, and `.tfvars` files are never committed to GitHub.
- The `kreuzwerker/docker` provider is used instead of the deprecated `hashicorp/docker` provider.
- The `nginx:alpine` image is chosen for its small size (~10 MB) and fast startup.
