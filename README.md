# NetTerraform

A Terraform module for provisioning and managing Azure infrastructure with version control. NetTerraform enables Infrastructure-as-Code (IaC) practices for the OmniCode project, automating the deployment of Azure App Services with support for both Node.js and Docker containerized applications.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

Before you begin, ensure you have the following tools installed:

**Terraform** (version >= 1.0)
```bash
# On macOS with Homebrew
brew install terraform

# On Linux (Ubuntu/Debian)
wget https://apt.releases.hashicorp.com/gpg
apt-key add gpg
apt-get update && apt-get install terraform

# Or download directly from https://www.terraform.io/downloads.html
```

**Azure CLI** (latest version)
```bash
# On macOS with Homebrew
brew install azure-cli

# On Linux (Ubuntu/Debian)
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Or follow instructions at https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
```

**Azure Subscription** with appropriate permissions to create resources in Azure.

### Installing

Follow these steps to set up your development environment:

**1. Clone the repository**
```bash
git clone https://github.com/N3TRS/NetTerraform.git
cd NetTerraform
```

**2. Authenticate with Azure**
```bash
az login
```
This will open a browser window to authenticate with your Azure account.

**3. Initialize Terraform**
```bash
terraform init
```
This command initializes the Terraform working directory and downloads the Azure provider plugin.

**4. Create a Terraform variables file**
```bash
cat > terraform.tfvars << EOF
project_name    = "omnicode"
location         = "East US"
sku_name         = "B1"
instance_count   = 1

apps_config = {
  "api" = {
    type    = "node"
    version = "18.x"
  }
  "web" = {
    type         = "docker"
    version      = "latest"
    docker_image = "myregistry/myapp"
  }
}
EOF
```

**5. Validate your configuration**
```bash
terraform validate
```

**6. Review the plan before applying**
```bash
terraform plan -out=tfplan
```

**7. Verify successful setup**
```bash
# Check that Terraform initialized correctly
ls -la .terraform/
```

## Usage

This Terraform module creates the following Azure resources:

- **Resource Group**: A logical container for your Azure resources
- **App Service Plan**: A managed hosting environment for your web applications
- **Linux Web Apps**: Individual application instances that can run Node.js or Docker containers

### Basic Example

```hcl
module "omnicode_infrastructure" {
  source = "./"

  project_name   = "omnicode"
  location       = "East US"
  sku_name       = "B1"
  instance_count = 2

  apps_config = {
    "api-server" = {
      type    = "node"
      version = "18.x"
    }
    "web-app" = {
      type         = "docker"
      version      = "v1.0"
      docker_image = "myregistry/web-app"
    }
  }
}
```

## Variables

The module accepts the following variables:

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `project_name` | string | "omnicode" | Name of the project (used in resource naming) |
| `location` | string | "East US" | Azure region for resource deployment |
| `sku_name` | string | "B1" | App Service Plan SKU (e.g., B1, B2, P1V2) |
| `instance_count` | number | 1 | Number of instances in the App Service Plan |
| `apps_config` | map(object) | - | Configuration for web applications |

### apps_config Structure

```hcl
apps_config = {
  "app-name" = {
    type         = "node" or "docker"  # Application type
    version      = "18.x" or "v1.0"    # Runtime/image version
    docker_image = "registry/image"    # Required only for Docker apps
  }
}
```

## Outputs

The module provides the following outputs:

| Output | Description |
|--------|-------------|
| `app_urls` | HTTPS URLs for deployed applications |
| `resource_group_name` | Name of the created Azure Resource Group |
| `service_plan_name` | Name of the App Service Plan |

Access outputs after deployment:
```bash
terraform output app_urls
terraform output resource_group_name
```

## Deployment

### Prerequisites for Deployment

Before deploying to a live system, ensure:

1. **Azure Storage Account** is configured for Terraform state backend
   - Resource Group: `rg-terraform-mgmt`
   - Storage Account: `spterraformomnicode`
   - Container: `tfstate`

2. **Azure credentials** are configured:
   ```bash
   az login
   ```

### Deploying to Production

**1. Create a production tfvars file**
```bash
cat > prod.tfvars << EOF
project_name    = "omnicode"
location         = "East US"
sku_name         = "P1V2"
instance_count   = 3

apps_config = {
  "api" = {
    type    = "node"
    version = "18.x"
  }
  "web" = {
    type         = "docker"
    version      = "v1.0.0"
    docker_image = "myregistry/web-app"
  }
}
EOF
```

**2. Plan the deployment**
```bash
terraform plan -var-file=prod.tfvars -out=prod.tfplan
```

**3. Apply the configuration**
```bash
terraform apply prod.tfplan
```

**4. Verify deployment**
```bash
terraform output app_urls
```

The URLs will show the HTTPS endpoints for your deployed applications.

### State Management

This module uses Azure Storage as a remote backend for Terraform state. The state is stored in:
- Resource Group: `rg-terraform-mgmt`
- Storage Account: `spterraformomnicode`
- Container: `tfstate`
- Key: `omnicode.prod.tfstate`

**Important**: Never commit `.tfstate` files to version control. They contain sensitive information.

## Built With

* [Terraform](https://www.terraform.io/) - Infrastructure as Code tool for provisioning cloud resources
* [Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs) - Official Terraform provider for Microsoft Azure
* [Microsoft Azure](https://azure.microsoft.com/) - Cloud platform providing computing, storage, and networking services
* [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/) - Command-line interface for managing Azure resources

## Authors

* **Tulio Riaño Sánchez** - [GitHub](https://github.com/tulio3101)
* **Juan Sebastián Puentes Julio** - [GitHub](https://github.com/sebaspuentes)
* **Julián Camilo López** - [GitHub](https://github.com/julianlopez11)
* **Alejandro Patacón Henao** - [GitHub](https://github.com/AlejandroHenao2572)

See also the list of [contributors](https://github.com/N3TRS/NetTerraform/contributors) on GitHub.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

Copyright (c) 2026 N3TRS

## Acknowledgments

* Inspired by Infrastructure-as-Code best practices and the Terraform community
* HashiCorp Terraform documentation and examples
* Azure documentation and guides
* The DevOps and cloud-native community for continuous learning and innovation
