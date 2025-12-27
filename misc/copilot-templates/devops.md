# Instruções - DevOps & Infraestrutura

Este arquivo foi reorganizado em templates menores, focados para uso por LLMs:

- `docker.md` — Dockerfile multi-stage, non-root, healthchecks.
- `kubernetes.md` — Manifests com probes, requests/limits e notas de segurança.
- `terraform.md` — Módulos, remote state e validação/format.
- `ansible.md` — Roles idempotentes e `ansible-lint`.

Para gerar instruções direcionadas, use:

```bash
./scripts/tools/generate.sh docker kubernetes terraform ansible
```

Os arquivos são curtos e contêm exemplos mínimos, restrições e saída esperada para o LLM.

### Linting de Infrastructure as Code

**SEMPRE use ferramentas de linting antes de aplicar mudanças em infraestrutura:**

**Terraform/OpenTofu:**

```bash
# 󰄬 TFLint - linting de Terraform
tflint --init
tflint --recursive

# 󰄬 Terraform validate
terraform validate

# 󰄬 Terraform fmt - formatação
terraform fmt -recursive

# 󰄬 Checkov - security scanning
checkov -d . --framework terraform

# 󰄬 tfsec - security scanner
tfsec .
```

**Ansible:**

```bash
# 󰄬 Ansible-lint - boas práticas
ansible-lint playbook.yml
ansible-lint roles/

# 󰄬 Ansible syntax check
ansible-playbook --syntax-check playbook.yml

# 󰄬 Dry run antes de aplicar
ansible-playbook --check playbook.yml
```

**Kubernetes:**

```bash
# 󰄬 kubeval - validação de manifests
kubeval deployment.yaml

# 󰄬 kube-linter - security e best practices
kube-linter lint deployment.yaml

# 󰄬 kubectl dry-run
kubectl apply --dry-run=client -f deployment.yaml
kubectl apply --dry-run=server -f deployment.yaml
```

**Docker:**

```bash
# 󰄬 Hadolint - Dockerfile linter
hadolint Dockerfile

# 󰄬 Dockerfile best practices
docker build --check .
```

**CI/CD Integration:**

```yaml
# .github/workflows/iac-lint.yml
name: IaC Linting

on: [push, pull_request]

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: 󰌢 TFLint
        uses: terraform-linters/setup-tflint@v4
      - run: tflint --init
      - run: tflint -f compact

      - name: 󰌢 Checkov
        uses: bridgecrewio/checkov-action@master
        with:
          directory: terraform/
          framework: terraform

  ansible:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: 󰌢 Ansible Lint
        uses: ansible/ansible-lint-action@main
```

**Padrão obrigatório:**

- 󰌢 Lint local antes de commit
- 󰌢 Lint no CI/CD (bloqueante)
- 󰄬 Fix automático quando possível (terraform fmt, ansible-lint --fix)
- 󰌢 Security scanning obrigatório para produção

### Kubernetes Manifests

```yaml
# 󰄬 Deployment com boas práticas
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
  labels:
    app: myapp
    version: v1.0.0
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
        version: v1.0.0
    spec:
      containers:
        - name: myapp
          image: myapp:v1.0.0
          ports:
            - containerPort: 8000

          # 󰄬 Resources SEMPRE definidos
          resources:
            requests:
              memory: '256Mi'
              cpu: '250m'
            limits:
              memory: '512Mi'
              cpu: '500m'

          # 󰄬 Probes configurados
          livenessProbe:
            httpGet:
              path: /health
              port: 8000
            initialDelaySeconds: 30
            periodSeconds: 10

          readinessProbe:
            httpGet:
              path: /ready
              port: 8000
            initialDelaySeconds: 5
            periodSeconds: 5

          # 󰄬 Config via ConfigMap/Secret
          envFrom:
            - configMapRef:
                name: myapp-config
            - secretRef:
                name: myapp-secrets

          # 󰌢 Security context
          securityContext:
            runAsNonRoot: true
            runAsUser: 1000
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: true
```

### Terraform Structure

```hcl
# 󰄬 Estrutura modular
# terraform/
# ├── modules/
# │   ├── networking/
# │   ├── compute/
# │   └── database/
# └── environments/
#     ├── dev/
#     ├── staging/
#     └── prod/

# main.tf
terraform {
  required_version = ">= 1.6"

  backend "s3" {
    bucket = "mycompany-terraform-state"
    key    = "prod/terraform.tfstate"
    region = "us-east-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# variables.tf
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

# outputs.tf
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}
```

### Ansible Playbooks

```yaml
# 󰄬 Playbook idempotente e organizado
---
- name: Configure web servers
  hosts: webservers
  become: true

  vars_files:
    - vars/{{ environment }}.yml

  roles:
    - common
    - nginx
    - monitoring

  tasks:
    - name: Ensure nginx is installed
      package:
        name: nginx
        state: present
      tags: [nginx, install]

    - name: Copy nginx config
      template:
        src: nginx.conf.j2
        dest: /etc/nginx/nginx.conf
        validate: nginx -t -c %s
        backup: true
      notify: restart nginx
      tags: [nginx, config]

  handlers:
    - name: restart nginx
      service:
        name: nginx
        state: restarted
```

### GitHub Actions Pipeline

```yaml
# .github/workflows/ci-cd.yml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: 󱘎 Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.12'
          cache: 'pip'

      - name: 󰋗 Install dependencies
        run: pip install -r requirements.txt

      - name: 󰙨 Run tests
        run: pytest --cov --cov-report=xml

      - name: 󰄬 Upload coverage
        uses: codecov/codecov-action@v4

  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: 󰡨 Build Docker image
        run: docker build -t myapp:${{ github.sha }} .

      - name: 󰌢 Scan image
        run: |
          docker run --rm \
            -v /var/run/docker.sock:/var/run/docker.sock \
            aquasec/trivy image --severity HIGH,CRITICAL myapp:${{ github.sha }}

      - name: 󰛳 Push to registry
        run: docker push myapp:${{ github.sha }}

  deploy:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - name: 󰒋 Deploy to Kubernetes
        run: |
          kubectl set image deployment/myapp \
            myapp=myapp:${{ github.sha }}
```

### Monitoring & Observability

**Prometheus Metrics:**

```python
from prometheus_client import Counter, Histogram, Gauge

# 󰋗 Counters para eventos
http_requests_total = Counter(
    'http_requests_total',
    'Total HTTP requests',
    ['method', 'endpoint', 'status']
)

# 󰋗 Histograms para latência
http_request_duration = Histogram(
    'http_request_duration_seconds',
    'HTTP request duration in seconds',
    ['method', 'endpoint']
)

# 󰋗 Gauges para valores atuais
active_connections = Gauge(
    'active_connections',
    'Number of active connections'
)

# Usage
http_requests_total.labels(method='GET', endpoint='/api/users', status=200).inc()
```

**Structured Logging:**

```python
import structlog

structlog.configure(
    processors=[
        structlog.contextvars.merge_contextvars,
        structlog.processors.add_log_level,
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.JSONRenderer()
    ]
)

log = structlog.get_logger()

# 󰄬 Log estruturado com contexto
log.info(
    "user_login",
    user_id=user.id,
    ip=request.remote_addr,
    duration_ms=duration
)
```

### Security Best Practices

**Secret Management:**

```bash
# 󰌢 Kubernetes Secrets (sealed)
kubeseal --format yaml < secret.yaml > sealed-secret.yaml

# 󰌢 HashiCorp Vault
vault kv put secret/myapp/prod \
  db_password=secret123 \
  api_key=key456

# 󰌢 AWS Secrets Manager
aws secretsmanager create-secret \
  --name myapp/prod/db \
  --secret-string '{"password":"secret123"}'
```

**Network Policies:**

```yaml
# 󰌢 Kubernetes NetworkPolicy
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-policy
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: frontend
      ports:
        - protocol: TCP
          port: 8000
  egress:
    - to:
        - podSelector:
            matchLabels:
              app: database
      ports:
        - protocol: TCP
          port: 5432
```

## 󰋗 Referências

- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Terraform Best Practices](https://developer.hashicorp.com/terraform/cloud-docs/recommended-practices)
- [The Twelve-Factor App](https://12factor.net/)
- [CNCF Landscape](https://landscape.cncf.io/)
