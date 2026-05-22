# 🏗️ NetTerraform — Infraestructura Azure como Código para OmniCode

<div align="center">

### 🛠️ Stack Tecnológico

![Terraform](https://img.shields.io/badge/Terraform-≥_1.0-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![Azure](https://img.shields.io/badge/Azure_Provider-~>_4.0-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)
![HCL](https://img.shields.io/badge/HCL-Declarative-7B42BC?style=for-the-badge)

### ☁️ Recursos Provisionados

![Resource Group](https://img.shields.io/badge/Resource_Group-Azure-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)
![App Service Plan](https://img.shields.io/badge/App_Service_Plan-Linux-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)
![Web Apps](https://img.shields.io/badge/Linux_Web_Apps-Node.js_+_Docker-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)

### 🏛️ Arquitectura

![IaC](https://img.shields.io/badge/Pattern-Infrastructure_as_Code-blueviolet?style=for-the-badge)
![Remote State](https://img.shields.io/badge/State-Azure_Storage-0078D4?style=for-the-badge)
![Modular](https://img.shields.io/badge/Design-Variable--Driven-009688?style=for-the-badge)

</div>

---

## 📑 Tabla de Contenidos

1. [👤 Integrantes](#1--integrantes)
2. [🎯 Objetivo del Proyecto](#2--objetivo-del-proyecto)
3. [⚡ Recursos Provisionados](#3--recursos-provisionados)
4. [📋 Estrategia de Versionamiento](#4--estrategia-de-versionamiento)
5. [⚙️ Variables y Configuración](#5-️-variables-y-configuración)
6. [📤 Outputs](#6--outputs)
7. [🏛️ Arquitectura de la Infraestructura](#7-️-arquitectura-de-la-infraestructura)
8. [🗂️ Organización del Código](#8-️-organización-del-código)
9. [🔗 Estado Remoto (Azure Storage)](#9--estado-remoto-azure-storage)
10. [🚀 Uso del Módulo](#10--uso-del-módulo)
11. [🤝 Integrantes y Contribuciones](#11--integrantes-y-contribuciones)

---

## 1. 👤 Integrantes

- Tulio Riaño Sánchez
- Julian Camilo Lopez Barrero
- Juan Sebastián Puentes Julio
- David Alejandro Patacon Henao

---

## 2. 🎯 Objetivo del Proyecto

**NetTerraform** automatiza el aprovisionamiento de toda la infraestructura Azure de **OmniCode** mediante código HCL versionado en git. Crea Resource Groups, App Service Plans y Linux Web Apps con soporte para runtimes Node.js o contenedores Docker, con estado remoto centralizado en Azure Storage para colaboración en equipo y pipelines CI/CD.

---

## 3. ⚡ Recursos Provisionados

| Recurso Azure | Nombre | Descripción |
|---|---|---|
| `azurerm_resource_group` | `rg-{project_name}-prod` | Contenedor lógico de todos los recursos |
| `azurerm_service_plan` | `asp-{project_name}` | Plan de hosting Linux con SKU y instancias configurables |
| `azurerm_linux_web_app` | `{project_name}-{app_name}` | Web App por cada entrada en `apps_config` |

### Runtimes Soportados

| Tipo | Configuración | Ejemplo |
|---|---|---|
| **Node.js** | `type = "node"`, `version = "20.x"` | `{ type = "node", version = "20.x" }` |
| **Docker** | `type = "docker"`, `version = "v1.0"`, `docker_image = "registry/image"` | `{ type = "docker", version = "latest", docker_image = "acr.io/app" }` |

---

## 4. 📋 Estrategia de Versionamiento

### Convenciones para commits

```
feat: agregar web app para omnicode-api-sessions
fix: corregir SKU en app service plan para producción
chore: actualizar azurerm provider a 4.x
docs: agregar ejemplo de configuración Docker en README
```

### Archivos NO versionados (`.gitignore`)

```
.terraform/          # Plugins del proveedor (binarios)
*.tfstate            # Estado local Terraform
*.tfstate.backup     # Backup de estado
terraform.tfvars     # Variables con valores reales (secretos)
.terraform.lock.hcl  # Sí se versiona — pin de versiones de providers
```

---

## 5. ⚙️ Variables y Configuración

| Variable | Tipo | Default | Descripción |
|---|---|---|---|
| `project_name` | string | `"omnicode"` | Prefijo para todos los nombres de recursos |
| `location` | string | `"East US"` | Región Azure de despliegue |
| `sku_name` | string | `"B1"` | SKU del App Service Plan (B1, B2, P1V2, S1, etc.) |
| `instance_count` | number | `1` | Número de instancias/workers del plan |
| `apps_config` | map(object) | — | Mapa de aplicaciones a desplegar |

### Estructura de `apps_config`

```hcl
apps_config = {
  "api-auth" = {
    type    = "node"
    version = "20.x"
  }
  "api-sessions" = {
    type         = "docker"
    version      = "latest"
    docker_image = "acromnicodeprod.azurecr.io/net-sessions"
  }
}
```

### Ejemplo completo (`terraform.tfvars`)

```hcl
project_name   = "omnicode"
location       = "Canada Central"
sku_name       = "B1"
instance_count = 1

apps_config = {
  "api-authentication" = { type = "node", version = "20.x" }
  "api-calls"          = { type = "node", version = "20.x" }
  "api-real-time"      = { type = "docker", version = "latest", docker_image = "acromnicodeprod.azurecr.io/net-sessions" }
  "api-python"         = { type = "node", version = "20.x" }
}
```

---

## 6. 📤 Outputs

| Output | Tipo | Descripción |
|---|---|---|
| `app_urls` | `map(string)` | URLs HTTPS de cada app: `https://{name}.azurewebsites.net` |
| `resource_group_name` | `string` | Nombre del Resource Group creado |
| `service_plan_name` | `string` | Nombre del App Service Plan |

```bash
# Ver URLs de todas las apps
terraform output app_urls

# Ver nombre del resource group
terraform output resource_group_name
```

---

## 7. 🏛️ Arquitectura de la Infraestructura

```
Azure Subscription
└── Resource Group: rg-omnicode-prod
    │
    ├── App Service Plan: asp-omnicode (Linux, B1)
    │   │
    │   ├── omnicode-api-authentication  (Node.js 20.x)
    │   ├── omnicode-api-calls           (Node.js 20.x)
    │   ├── omnicode-api-real-time       (Docker: acr.io/net-sessions:latest)
    │   └── omnicode-api-python          (Node.js 20.x)
    │
    └── [Azure Container Registry: acromnicodeprod]  (externo a este módulo)
```

### Convención de nombres

| Recurso | Patrón | Ejemplo |
|---|---|---|
| Resource Group | `rg-{project_name}-prod` | `rg-omnicode-prod` |
| App Service Plan | `asp-{project_name}` | `asp-omnicode` |
| Web App | `{project_name}-{app_name}` | `omnicode-api-calls` |

---

## 8. 🗂️ Organización del Código

```
NetTerraform/
│
├── main.tf              # Recursos: azurerm_resource_group, azurerm_service_plan, azurerm_linux_web_app (for_each)
├── variables.tf         # Definición de todas las variables de entrada
├── outputs.tf           # Outputs: app_urls, resource_group_name, service_plan_name
├── versions.tf          # Versiones requeridas de Terraform y Azure Provider + backend config
│
├── .terraform.lock.hcl  # Lock de versiones de providers (versionado en git)
├── .gitignore           # Excluye .terraform/, *.tfstate, terraform.tfvars
├── LICENSE              # MIT
└── README.md
```

---

## 9. 🔗 Estado Remoto (Azure Storage)

El estado Terraform se almacena en Azure Storage para colaboración segura:

```hcl
# versions.tf
backend "azurerm" {
  resource_group_name  = "rg-terraform-mgmt"
  storage_account_name = "spterraformomnicode"
  container_name       = "tfstate"
  key                  = "omnicode.prod.tfstate"
}
```

| Propiedad | Valor |
|---|---|
| **Resource Group** | `rg-terraform-mgmt` |
| **Storage Account** | `spterraformomnicode` |
| **Container** | `tfstate` |
| **Blob key** | `omnicode.prod.tfstate` |

> **Importante:** Nunca incluir archivos `.tfstate` en git. Contienen valores sensibles de la infraestructura.

---

## 10. 🚀 Uso del Módulo

### 📋 Prerrequisitos

- **Terraform >= 1.0**
- **Azure CLI** y suscripción con permisos de creación de recursos

### 🛠️ Despliegue

```bash
# 1. Clonar y entrar al directorio
git clone <repo-url>
cd NetTerraform

# 2. Autenticar con Azure
az login

# 3. Inicializar Terraform (descarga providers, configura backend)
terraform init

# 4. Crear archivo de variables
cat > terraform.tfvars << EOF
project_name   = "omnicode"
location       = "East US"
sku_name       = "B1"
instance_count = 1
apps_config = {
  "api-auth" = { type = "node", version = "20.x" }
}
EOF

# 5. Validar configuración
terraform validate

# 6. Ver plan antes de aplicar
terraform plan -out=tfplan

# 7. Aplicar la infraestructura
terraform apply tfplan

# 8. Ver URLs resultantes
terraform output app_urls
```

### 🔄 Actualizar Infraestructura

```bash
# Modificar variables o main.tf, luego:
terraform plan -out=update.tfplan
terraform apply update.tfplan
```

### 🗑️ Destruir Infraestructura

```bash
# ⚠️ Esto elimina TODOS los recursos del plan
terraform destroy
```

### Autenticación en CI/CD (Service Principal)

```bash
# Variables de entorno para pipelines automatizados:
export ARM_CLIENT_ID="<service-principal-client-id>"
export ARM_CLIENT_SECRET="<service-principal-secret>"
export ARM_SUBSCRIPTION_ID="<azure-subscription-id>"
export ARM_TENANT_ID="<azure-tenant-id>"
```

Los pipelines GitHub Actions de OmniCode usan los secrets:
- `AZUREAPPSERVICE_CLIENTID`
- `AZUREAPPSERVICE_TENANTID`
- `AZUREAPPSERVICE_SUBSCRIPTIONID`

---

## 11. 🤝 Integrantes y Contribuciones

<div align="center">

![Course](https://img.shields.io/badge/Course-ARSW-orange?style=for-the-badge)
![Year](https://img.shields.io/badge/Year-2026--1-blue?style=for-the-badge)

| 👤 Integrante | 🎓 Rol |
|:---|:---|
| Tulio Riaño Sánchez | Desarrollo y arquitectura |
| Julian Camilo Lopez Barrero | Desarrollo y arquitectura |
| Juan Sebastián Puentes Julio | Desarrollo y arquitectura |
| David Alejandro Patacon Henao | Desarrollo y arquitectura |

> 💡 **NetTerraform** provisiona toda la infraestructura Azure de OmniCode como código versionado en git — desde el Resource Group hasta cada Web App individual — garantizando entornos reproducibles y despliegues consistentes.

**🎓 Escuela Colombiana de Ingeniería Julio Garavito**

</div>
