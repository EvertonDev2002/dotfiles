# Docker — Instruções para o LLM

Contexto: Dockerfiles otimizados, multi-stage builds, segurança.

## Objetivo do assistant

- Gerar Dockerfiles multi-stage, seguros (non-root), com health checks.
- Minimizar tamanho de imagem final.

## Estrutura esperada

### Python/FastAPI Multi-stage

```dockerfile
# Builder stage
FROM python:3.12-slim AS builder

WORKDIR /app

# Install build dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      gcc \
      libpq-dev && \
    rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Runtime stage
FROM python:3.12-slim

WORKDIR /app

# Install runtime dependencies only
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      libpq5 \
      curl && \
    rm -rf /var/lib/apt/lists/*

# Copy installed packages from builder
COPY --from=builder /root/.local /root/.local

# Copy application code
COPY src/ ./src/

# Create non-root user
RUN useradd -m -u 1000 appuser && \
    chown -R appuser:appuser /app

# Update PATH for non-root user
ENV PATH=/root/.local/bin:$PATH

USER appuser

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1

CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Node.js/TypeScript Multi-stage

```dockerfile
# Build stage
FROM node:20-alpine AS builder

WORKDIR /app

# Install dependencies
COPY package.json pnpm-lock.yaml ./
RUN corepack enable pnpm && \
    pnpm install --frozen-lockfile

# Copy source and build
COPY tsconfig.json ./
COPY src/ ./src/
RUN pnpm build

# Production stage
FROM node:20-alpine

WORKDIR /app

# Install production dependencies only
COPY package.json pnpm-lock.yaml ./
RUN corepack enable pnpm && \
    pnpm install --frozen-lockfile --prod && \
    pnpm store prune

# Copy built application
COPY --from=builder /app/dist ./dist

# Create non-root user
RUN addgroup -g 1000 appuser && \
    adduser -D -u 1000 -G appuser appuser && \
    chown -R appuser:appuser /app

USER appuser

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

CMD ["node", "dist/main.js"]
```

### .dockerignore

```
# Version control
.git
.gitignore

# Dependencies
node_modules
__pycache__
*.pyc
.venv
venv

# IDE
.vscode
.idea
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Build outputs
dist
build
*.log

# Tests
tests
*.test.ts
*.test.js
coverage

# Documentation
README.md
docs
```

### Docker Compose (dev)

```yaml
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - '8000:8000'
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/mydb
      - LOG_LEVEL=debug
    volumes:
      - ./src:/app/src
    depends_on:
      db:
        condition: service_healthy

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
      POSTGRES_DB: mydb
    ports:
      - '5432:5432'
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ['CMD-SHELL', 'pg_isready -U user']
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  postgres_data:
```

## Restrições

- **Multi-stage**: SEMPRE use para separar build de runtime
- **Base images**: prefira `-alpine` ou `-slim`
- **Non-root**: NUNCA rode como root, use `USER`
- **HEALTHCHECK**: sempre defina para produção
- **.dockerignore**: crie para excluir desnecessários
- **Layer caching**: ordene comandos do menos mutável ao mais
- **apt cleanup**: sempre `rm -rf /var/lib/apt/lists/*`
- **pip cache**: use `--no-cache-dir`
- **npm/pnpm**: use `--frozen-lockfile` ou `ci`

## Comandos

```bash
# Build
docker build -t myapp:latest .

# Build com cache otimizado
docker build --target builder -t myapp:builder .
docker build -t myapp:latest .

# Run com health check
docker run --rm -p 8000:8000 --name myapp myapp:latest

# Check health
docker inspect --format='{{.State.Health.Status}}' myapp

# Compose
docker compose up -d
docker compose logs -f app
docker compose down -v
```

## Saída esperada

1. Dockerfile multi-stage com builder + runtime
2. .dockerignore com exclusões apropriadas
3. HEALTHCHECK definido
4. USER non-root configurado
5. Comandos de build e run
