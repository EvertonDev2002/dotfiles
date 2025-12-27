# Terraform — Instruções para o LLM

Contexto: Infrastructure as Code (IaC) com Terraform/OpenTofu.

## Objetivo do assistant

- Gerar módulos reutilizáveis, configurar remote state, outputs.
- Seguir convenções (resources, variables, outputs).

## Estrutura esperada

### Módulo VPC (AWS)

```hcl
# modules/vpc/variables.tf
variable "vpc_name" {
  description = "Nome da VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block para VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "CIDR block inválido"
  }
}

variable "availability_zones" {
  description = "Lista de AZs para subnets"
  type        = list(string)
}

variable "private_subnets" {
  description = "CIDR blocks para subnets privadas"
  type        = list(string)
}

variable "public_subnets" {
  description = "CIDR blocks para subnets públicas"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Habilitar NAT Gateway"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags comuns para todos os recursos"
  type        = map(string)
  default     = {}
}
```

```hcl
# modules/vpc/main.tf
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    var.tags,
    {
      Name = var.vpc_name
    }
  )
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-private-${count.index + 1}"
      Tier = "private"
    }
  )
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-public-${count.index + 1}"
      Tier = "public"
    }
  )
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-igw"
    }
  )
}

resource "aws_eip" "nat" {
  count  = var.enable_nat_gateway ? length(var.public_subnets) : 0
  domain = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-nat-eip-${count.index + 1}"
    }
  )
}

resource "aws_nat_gateway" "main" {
  count         = var.enable_nat_gateway ? length(var.public_subnets) : 0
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-nat-${count.index + 1}"
    }
  )

  depends_on = [aws_internet_gateway.main]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-public-rt"
    }
  )
}

resource "aws_route_table" "private" {
  count  = length(var.private_subnets)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = var.enable_nat_gateway ? aws_nat_gateway.main[count.index].id : null
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-private-rt-${count.index + 1}"
    }
  )
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
```

```hcl
# modules/vpc/outputs.tf
output "vpc_id" {
  description = "ID da VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block da VPC"
  value       = aws_vpc.main.cidr_block
}

output "private_subnet_ids" {
  description = "IDs das subnets privadas"
  value       = aws_subnet.private[*].id
}

output "public_subnet_ids" {
  description = "IDs das subnets públicas"
  value       = aws_subnet.public[*].id
}

output "nat_gateway_ips" {
  description = "IPs públicos dos NAT Gateways"
  value       = aws_eip.nat[*].public_ip
}
```

### Root main.tf

```hcl
# main.tf
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "production/vpc/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Project     = var.project_name
    }
  }
}

module "vpc" {
  source = "./modules/vpc"

  vpc_name           = "${var.project_name}-${var.environment}"
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  enable_nat_gateway = true

  tags = {
    Tier = "network"
  }
}
```

```hcl
# variables.tf
variable "aws_region" {
  description = "AWS region para recursos"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Ambiente (dev, staging, production)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment deve ser dev, staging ou production"
  }
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
}
```

```hcl
# outputs.tf
output "vpc_id" {
  description = "ID da VPC criada"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "IDs das subnets privadas"
  value       = module.vpc.private_subnet_ids
}

output "public_subnets" {
  description = "IDs das subnets públicas"
  value       = module.vpc.public_subnet_ids
}
```

### terraform.tfvars (gitignored)

```hcl
# terraform.tfvars
aws_region   = "us-east-1"
environment  = "production"
project_name = "myapp"
```

### .tflint.hcl

```hcl
plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

plugin "aws" {
  enabled = true
  version = "0.29.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

rule "terraform_naming_convention" {
  enabled = true
}

rule "terraform_deprecated_syntax" {
  enabled = true
}

rule "terraform_unused_declarations" {
  enabled = true
}
```

## Restrições

- **Remote State**: SEMPRE use S3 + DynamoDB lock ou Terraform Cloud
- **Versions**: Pin provider versions (~> 5.0)
- **Variables**: Valide inputs críticos
- **Secrets**: use AWS Secrets Manager, nunca hardcode
- **Modules**: prefira módulos para recursos repetitivos
- **Outputs**: documente com `description`
- **Tags**: use `default_tags` no provider
- **Format**: execute `terraform fmt` sempre
- **Naming**: `resource_type.descriptive_name`

## Comandos

```bash
# Initialize
terraform init

# Validate
terraform validate
tflint

# Format
terraform fmt -recursive

# Plan
terraform plan -out=tfplan

# Apply
terraform apply tfplan

# Outputs
terraform output

# Destroy
terraform destroy

# State management
terraform state list
terraform state show aws_vpc.main
terraform state rm aws_instance.old
```

## Saída esperada

1. Módulo com variables.tf, main.tf, outputs.tf
2. Root com backend S3, provider config
3. Variables com validation
4. .tflint.hcl configurado
5. Comandos de init/plan/apply
