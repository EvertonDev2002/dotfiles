# Kubernetes — Instruções para o LLM

Contexto: manifests K8s, deploy seguro, observabilidade.

## Objetivo do assistant

- Gerar manifests completos (Deployment, Service, ConfigMap, Secret).
- Configurar probes, resources, labels e security contexts.

## Estrutura esperada

### Deployment com probes e resources

```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
  namespace: production
  labels:
    app: myapp
    version: v1.0.0
    component: backend
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
        version: v1.0.0
      annotations:
        prometheus.io/scrape: 'true'
        prometheus.io/port: '8000'
        prometheus.io/path: '/metrics'
    spec:
      serviceAccountName: myapp
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        fsGroup: 1000
      containers:
        - name: app
          image: myapp:v1.0.0
          imagePullPolicy: IfNotPresent
          ports:
            - name: http
              containerPort: 8000
              protocol: TCP
          env:
            - name: LOG_LEVEL
              value: 'info'
            - name: DATABASE_URL
              valueFrom:
                secretKeyRef:
                  name: myapp-secrets
                  key: database-url
            - name: REDIS_HOST
              valueFrom:
                configMapKeyRef:
                  name: myapp-config
                  key: redis-host
          resources:
            requests:
              cpu: 100m
              memory: 128Mi
            limits:
              cpu: 500m
              memory: 512Mi
          livenessProbe:
            httpGet:
              path: /health
              port: http
            initialDelaySeconds: 30
            periodSeconds: 10
            timeoutSeconds: 3
            failureThreshold: 3
          readinessProbe:
            httpGet:
              path: /ready
              port: http
            initialDelaySeconds: 10
            periodSeconds: 5
            timeoutSeconds: 2
            successThreshold: 1
            failureThreshold: 3
          securityContext:
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: true
            capabilities:
              drop:
                - ALL
          volumeMounts:
            - name: tmp
              mountPath: /tmp
      volumes:
        - name: tmp
          emptyDir: {}
```

### Service (ClusterIP)

```yaml
# service.yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp
  namespace: production
  labels:
    app: myapp
spec:
  type: ClusterIP
  selector:
    app: myapp
  ports:
    - name: http
      protocol: TCP
      port: 80
      targetPort: http
  sessionAffinity: None
```

### ConfigMap

```yaml
# configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: myapp-config
  namespace: production
data:
  redis-host: 'redis.production.svc.cluster.local'
  redis-port: '6379'
  app.conf: |
    server {
      listen 8000;
      client_max_body_size 10M;
    }
```

### Secret (base64 encoded)

```yaml
# secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: myapp-secrets
  namespace: production
type: Opaque
data:
  # echo -n "postgresql://user:pass@db:5432/mydb" | base64
  database-url: cG9zdGdyZXNxbDovL3VzZXI6cGFzc0BkYjo1NDMyL215ZGI=
  # echo -n "supersecretkey" | base64
  jwt-secret: c3VwZXJzZWNyZXRrZXk=
```

### Ingress (NGINX)

```yaml
# ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myapp
  namespace: production
  annotations:
    cert-manager.io/cluster-issuer: 'letsencrypt-prod'
    nginx.ingress.kubernetes.io/ssl-redirect: 'true'
    nginx.ingress.kubernetes.io/rate-limit: '100'
spec:
  ingressClassName: nginx
  tls:
    - hosts:
        - api.example.com
      secretName: myapp-tls
  rules:
    - host: api.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: myapp
                port:
                  name: http
```

### HorizontalPodAutoscaler

```yaml
# hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: myapp
  namespace: production
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: myapp
  minReplicas: 3
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 80
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
        - type: Percent
          value: 50
          periodSeconds: 60
```

### Kustomization

```yaml
# kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: production

resources:
  - deployment.yaml
  - service.yaml
  - configmap.yaml
  - secret.yaml
  - ingress.yaml
  - hpa.yaml

commonLabels:
  app: myapp
  managed-by: kustomize

images:
  - name: myapp
    newTag: v1.0.0
```

## Restrições

- **Resources**: SEMPRE defina requests e limits
- **Probes**: liveness e readiness obrigatórios
- **Security**: runAsNonRoot, readOnlyRootFilesystem, drop capabilities
- **Labels**: padronize (app, version, component)
- **Namespaces**: sempre especifique
- **RollingUpdate**: maxUnavailable: 0 para zero downtime
- **Secrets**: use base64, nunca plain text
- **Service Account**: crie específico, não use default

## Comandos

```bash
# Apply manifests
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

# Apply with kustomize
kubectl apply -k .

# Check deployment
kubectl get deploy -n production
kubectl describe deploy myapp -n production

# Check pods
kubectl get pods -n production -l app=myapp
kubectl logs -n production -l app=myapp --tail=50 -f

# Check resources
kubectl top pods -n production -l app=myapp

# Port-forward for debug
kubectl port-forward -n production svc/myapp 8000:80

# Rollout management
kubectl rollout status deployment/myapp -n production
kubectl rollout history deployment/myapp -n production
kubectl rollout undo deployment/myapp -n production
```

## Saída esperada

1. Deployment com probes, resources e security context
2. Service (ClusterIP ou LoadBalancer)
3. ConfigMap e Secret
4. HPA para autoscaling
5. Kustomization para gerenciamento
6. Comandos de deploy e verificação
