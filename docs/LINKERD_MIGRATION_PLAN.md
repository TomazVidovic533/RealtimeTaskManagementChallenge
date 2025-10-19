# Linkerd Service Mesh Migration Plan

**Goal:** Replace nginx-based frontend proxy with Linkerd + Ingress Controller for enterprise-grade traffic management

**Timeline:** 2-3 hours
**Status:** 📋 Planning Phase

---

## Current Architecture (Before)

```
┌─────────────────────────────────────────────────────────────┐
│  User Request (localhost:3001)                              │
└────────────────────┬────────────────────────────────────────┘
                     ↓
        ┌────────────────────────┐
        │  k3d Port Mapping      │
        │  3001 → NodePort 30081 │
        └────────────┬───────────┘
                     ↓
        ┌────────────────────────────────────┐
        │  Frontend Pod (nginx)              │
        │  - Serves React static files       │
        │  - Proxies /api → rtmc-api:8080   │
        │  ❌ DNS timing issues               │
        │  ❌ Crashes on startup              │
        └────────────┬───────────────────────┘
                     ↓
        ┌────────────────────────┐
        │  API Pod               │
        │  .NET 9 Web API        │
        └────────────────────────┘
```

**Problems:**
- ❌ nginx crashes if API DNS not ready (2-3 restarts)
- ❌ Frontend coupled to API at infrastructure level
- ❌ No mTLS between services
- ❌ No advanced traffic control
- ❌ Limited observability

---

## Target Architecture (After)

```
┌─────────────────────────────────────────────────────────────┐
│  User Request (localhost:80 or 443)                         │
└────────────────────┬────────────────────────────────────────┘
                     ↓
        ┌────────────────────────────────────┐
        │  Ingress Controller (nginx-ingress)│
        │  - Path-based routing              │
        │  - TLS termination                 │
        │  - Rate limiting                   │
        └────────┬───────────┬───────────────┘
                 ↓           ↓
    ┌────────────────┐  ┌─────────────────┐
    │ Frontend       │  │ API             │
    │ Service        │  │ Service         │
    └───┬────────────┘  └────┬────────────┘
        ↓                    ↓
    ┌────────────────┐  ┌─────────────────┐
    │ Frontend Pod   │  │ API Pod         │
    │ ┌────────────┐ │  │ ┌─────────────┐ │
    │ │ linkerd-   │ │  │ │ linkerd-    │ │
    │ │ proxy      │ │  │ │ proxy       │ │
    │ │ (sidecar)  │ │  │ │ (sidecar)   │ │
    │ └────────────┘ │  │ └─────────────┘ │
    │ ┌────────────┐ │  │ ┌─────────────┐ │
    │ │ Static     │ │  │ │ .NET API    │ │
    │ │ File Server│ │  │ │             │ │
    │ └────────────┘ │  │ └─────────────┘ │
    └────────────────┘  └─────────────────┘
```

**Benefits:**
- ✅ Frontend starts instantly (no DNS dependency)
- ✅ Automatic mTLS between all services
- ✅ Traffic splitting (canary, blue-green)
- ✅ Circuit breaking & retries
- ✅ Beautiful Grafana dashboards
- ✅ Production-grade observability
- ✅ Industry-standard architecture

---

## Phase 1: Replace nginx with Static File Server

### 1.1 Update Frontend Dockerfile

**Current (nginx-based):**
```dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM nginx:1.27-alpine
ENV API_HOST=api
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf.template /etc/nginx/templates/default.conf.template
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

**New (static file server):**
```dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:20-alpine
WORKDIR /app
RUN npm install -g serve
COPY --from=builder /app/dist ./dist
EXPOSE 3000
CMD ["serve", "-s", "dist", "-l", "3000"]
```

**Alternative (even lighter with Caddy):**
```dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM caddy:2-alpine
COPY --from=builder /app/dist /srv
COPY Caddyfile /etc/caddy/Caddyfile
EXPOSE 80
CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile"]
```

**Caddyfile (optional):**
```
:80 {
    root * /srv
    file_server
    try_files {path} /index.html
}
```

### 1.2 Update Frontend Service Port

**Update `values.yaml`:**
```yaml
frontend:
  service:
    port: 3000  # Changed from 80
```

### 1.3 Remove nginx Configuration Files

```bash
rm frontend/nginx.conf.template
rm frontend/nginx.conf  # if exists
```

**Estimated Time:** 15 minutes

---

## Phase 2: Install Linkerd

### 2.1 Install Linkerd CLI

```bash
# macOS
curl -sL https://run.linkerd.io/install | sh
export PATH=$PATH:$HOME/.linkerd2/bin

# Linux
curl -sL https://run.linkerd.io/install | sh

# Verify
linkerd version
```

### 2.2 Pre-flight Check

```bash
linkerd check --pre
```

**Expected output:**
```
✔ can initialize the client
✔ can query the Kubernetes API
✔ kubectl is configured correctly
...
Status check results are √
```

### 2.3 Install Linkerd Control Plane

```bash
# Install CRDs
linkerd install --crds | kubectl apply -f -

# Install control plane
linkerd install | kubectl apply -f -

# Verify installation
linkerd check
```

### 2.4 Install Linkerd Viz (Observability)

```bash
linkerd viz install | kubectl apply -f -
linkerd viz check
```

**Estimated Time:** 10 minutes

---

## Phase 3: Install Ingress Controller

### Option A: nginx-ingress (Most Popular)

**3.1 Install nginx-ingress via Helm:**
```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install nginx-ingress ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.service.type=LoadBalancer
```

**3.2 Verify Installation:**
```bash
kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx
```

### Option B: Traefik (Lighter, k3d default)

**3.1 Enable Traefik in k3d:**
```bash
# Traefik comes pre-installed with k3d
kubectl get pods -n kube-system | grep traefik
```

**If not installed:**
```bash
helm repo add traefik https://traefik.github.io/charts
helm install traefik traefik/traefik \
  --namespace kube-system \
  --set service.type=LoadBalancer
```

**Recommendation:** Use nginx-ingress (more industry-standard, better for portfolio)

**Estimated Time:** 10 minutes

---

## Phase 4: Create Ingress Resources

### 4.1 Create Helm Template: `infrastructure/helm/rtmc/templates/ingress.yaml`

```yaml
{{- if .Values.ingress.enabled }}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ include "rtmc.fullname" . }}
  labels:
    {{- include "rtmc.labels" . | nindent 4 }}
  annotations:
    {{- if eq .Values.ingress.className "nginx" }}
    nginx.ingress.kubernetes.io/rewrite-target: /$2
    nginx.ingress.kubernetes.io/use-regex: "true"
    {{- end }}
    {{- with .Values.ingress.annotations }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
spec:
  ingressClassName: {{ .Values.ingress.className }}
  {{- if .Values.ingress.tls }}
  tls:
    {{- range .Values.ingress.tls }}
    - hosts:
        {{- range .hosts }}
        - {{ . | quote }}
        {{- end }}
      secretName: {{ .secretName }}
    {{- end }}
  {{- end }}
  rules:
  - http:
      paths:
      # Frontend (serves all non-API routes)
      - path: /
        pathType: Prefix
        backend:
          service:
            name: {{ include "rtmc.fullname" . }}-frontend
            port:
              number: {{ .Values.frontend.service.port }}
      # API routes
      - path: /api(/|$)(.*)
        pathType: ImplementationSpecific
        backend:
          service:
            name: {{ include "rtmc.fullname" . }}-api
            port:
              number: {{ .Values.api.service.port }}
{{- end }}
```

### 4.2 Update `values.yaml`

```yaml
ingress:
  enabled: true
  className: nginx
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"  # Optional for TLS
  hosts:
    - host: rtmc.local
      paths:
        - path: /
          pathType: Prefix
  tls: []
  # tls:
  #   - secretName: rtmc-tls
  #     hosts:
  #       - rtmc.local
```

### 4.3 Update k3d Port Mapping

**Update `infrastructure/scripts/k8s/create.py`:**
```python
result = subprocess.run([
    "k3d", "cluster", "create", "rtmc",
    "--registry-create", "rtmc-registry:0.0.0.0:35000",
    "--port", "80:80@loadbalancer",      # HTTP via Ingress
    "--port", "443:443@loadbalancer",    # HTTPS via Ingress
    "--port", "8080:8080@loadbalancer",  # Keep for direct API access (optional)
    "--port", "5432:5432@loadbalancer",
    "--port", "6379:6379@loadbalancer",
    "--port", "9092:9092@loadbalancer",
    "--port", "5672:5672@loadbalancer",
    "--port", "15672:15672@loadbalancer"
])
```

**Estimated Time:** 20 minutes

---

## Phase 5: Inject Linkerd into Services

### 5.1 Annotate Deployments for Auto-Injection

**Update Helm deployment templates:**

**`templates/api/deployment.yaml`:**
```yaml
{{- if .Values.api.enabled }}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "rtmc.fullname" . }}-api
  labels:
    {{- include "rtmc.labels" . | nindent 4 }}
    app.kubernetes.io/component: api
spec:
  replicas: {{ .Values.api.replicas }}
  selector:
    matchLabels:
      {{- include "rtmc.selectorLabels" . | nindent 6 }}
      app.kubernetes.io/component: api
  template:
    metadata:
      annotations:
        {{- if .Values.linkerd.enabled }}
        linkerd.io/inject: enabled
        {{- end }}
      labels:
        {{- include "rtmc.selectorLabels" . | nindent 8 }}
        app.kubernetes.io/component: api
    spec:
      # ... rest of deployment
{{- end }}
```

**Repeat for:**
- `templates/frontend/deployment.yaml`
- `templates/postgres/deployment.yaml`
- `templates/redis/deployment.yaml`
- `templates/kafka/deployment.yaml`
- `templates/rabbitmq/deployment.yaml`
- `templates/elasticsearch/deployment.yaml`
- `templates/grafana/deployment.yaml`

### 5.2 Add Linkerd Configuration to `values.yaml`

```yaml
global:
  environment: development
  namespace: rtmc

linkerd:
  enabled: true
  inject: enabled
```

### 5.3 Manual Injection (Alternative Method)

```bash
# Inject Linkerd into existing deployments
kubectl get deploy -o yaml | linkerd inject - | kubectl apply -f -

# Or per deployment
kubectl get deploy rtmc-api -o yaml | linkerd inject - | kubectl apply -f -
```

**Estimated Time:** 15 minutes

---

## Phase 6: Update Makefile Workflows

### 6.1 Add Linkerd Commands to Makefile

**Add to `.PHONY`:**
```makefile
.PHONY: ... linkerd-install linkerd-check linkerd-dashboard linkerd-inject linkerd-uninject linkerd-viz
```

**Add commands:**
```makefile
# Linkerd commands
linkerd-install:
	@echo "$(YELLOW)Installing Linkerd...$(RESET)"
	@linkerd check --pre || (echo "$(RED)Pre-check failed$(RESET)" && exit 1)
	@echo "$(YELLOW)Installing Linkerd CRDs...$(RESET)"
	@linkerd install --crds | kubectl apply -f -
	@echo "$(YELLOW)Installing Linkerd control plane...$(RESET)"
	@linkerd install | kubectl apply -f -
	@echo "$(YELLOW)Installing Linkerd Viz...$(RESET)"
	@linkerd viz install | kubectl apply -f -
	@echo "$(GREEN)Linkerd installed successfully!$(RESET)"
	@echo ""
	@echo "$(CYAN)Verify installation:$(RESET)"
	@echo "  make linkerd-check"

linkerd-check:
	@echo "$(YELLOW)Checking Linkerd installation...$(RESET)"
	@linkerd check
	@linkerd viz check

linkerd-dashboard:
	@echo "$(YELLOW)Opening Linkerd dashboard...$(RESET)"
	@linkerd viz dashboard

linkerd-inject:
	@echo "$(YELLOW)Injecting Linkerd into all deployments...$(RESET)"
	@kubectl get deploy -o yaml | linkerd inject - | kubectl apply -f -
	@echo "$(GREEN)All deployments now have Linkerd sidecars!$(RESET)"

linkerd-uninject:
	@echo "$(YELLOW)Removing Linkerd from all deployments...$(RESET)"
	@kubectl get deploy -o yaml | linkerd uninject - | kubectl apply -f -
	@echo "$(GREEN)Linkerd sidecars removed!$(RESET)"

linkerd-viz:
	@echo "$(YELLOW)Installing Linkerd Viz...$(RESET)"
	@linkerd viz install | kubectl apply -f -
	@linkerd viz check
	@echo "$(GREEN)Linkerd Viz installed!$(RESET)"

linkerd-tap:
	@echo "$(YELLOW)Live traffic tap (Ctrl+C to stop):$(RESET)"
	@linkerd viz tap deploy

linkerd-stat:
	@echo "$(YELLOW)Deployment statistics:$(RESET)"
	@linkerd viz stat deploy

linkerd-routes:
	@echo "$(YELLOW)Service routes:$(RESET)"
	@linkerd viz routes deploy
```

### 6.2 Add Ingress Commands

```makefile
# Ingress commands
ingress-install:
	@echo "$(YELLOW)Installing nginx-ingress controller...$(RESET)"
	@helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
	@helm repo update
	@helm install nginx-ingress ingress-nginx/ingress-nginx \
		--namespace ingress-nginx \
		--create-namespace \
		--set controller.service.type=LoadBalancer
	@echo "$(GREEN)nginx-ingress installed!$(RESET)"

ingress-status:
	@echo "$(CYAN)=== Ingress Controller Status ===$(RESET)"
	@kubectl get pods -n ingress-nginx
	@echo ""
	@kubectl get svc -n ingress-nginx

ingress-logs:
	@kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx -f
```

### 6.3 Update k3d-start Workflow

```makefile
k3d-start:
	@echo "$(YELLOW)Starting k3d cluster...$(RESET)"
	@uv run infrastructure/scripts/k8s/create.py
	@echo "$(YELLOW)Installing Linkerd...$(RESET)"
	@make linkerd-install
	@echo "$(YELLOW)Installing Ingress Controller...$(RESET)"
	@make ingress-install
	@echo "$(YELLOW)Deploying services to k3d...$(RESET)"
	@uv run infrastructure/scripts/helm/install.py
	@echo "$(GREEN)k3d cluster started with Linkerd + Ingress!$(RESET)"
	@echo ""
	@echo "$(CYAN)Access points:$(RESET)"
	@echo "  $(YELLOW)App:$(RESET)         http://localhost"
	@echo "  $(YELLOW)API Direct:$(RESET)  http://localhost:8080"
	@echo "  $(YELLOW)Swagger:$(RESET)     http://localhost:8080/swagger"
	@echo ""
	@echo "$(CYAN)Linkerd Dashboard:$(RESET)"
	@echo "  make linkerd-dashboard"
```

### 6.4 Update Help Command

```makefile
help:
	@echo "$(CYAN)=== Real-Time Task Management ===$(RESET)"
	@echo ""
	@echo "$(YELLOW)Development (Local):$(RESET)"
	@echo "  make backend-build    - Build backend"
	@echo "  make backend-run      - Run backend API locally"
	@echo "  make backend-test     - Run tests"
	@echo "  make frontend-install - Install frontend dependencies"
	@echo "  make frontend-dev     - Run frontend dev server"
	@echo ""
	@echo "$(YELLOW)Docker:$(RESET)"
	@echo "  make docker-build     - Build all Docker images (backend + frontend)"
	@echo "  make docker-start     - Start all services with Docker Compose"
	@echo "  make docker-stop      - Stop Docker services"
	@echo "  make docker-logs      - View Docker logs"
	@echo "  make docker-clean     - Remove all containers and volumes"
	@echo ""
	@echo "$(YELLOW)Kubernetes (k3d):$(RESET)"
	@echo "  make k3d-start        - Create cluster with Linkerd + Ingress (first time)"
	@echo "  make k3d-update       - Rebuild images and upgrade deployment"
	@echo "  make k3d-status       - View k3d cluster status"
	@echo "  make k3d-stop         - Stop and remove k3d cluster"
	@echo "  make k3d-clean        - Full k3d cleanup"
	@echo ""
	@echo "$(YELLOW)Linkerd Service Mesh:$(RESET)"
	@echo "  make linkerd-check    - Verify Linkerd health"
	@echo "  make linkerd-dashboard- Open Linkerd web dashboard"
	@echo "  make linkerd-stat     - Show deployment statistics"
	@echo "  make linkerd-tap      - Live traffic tap (real-time)"
	@echo "  make linkerd-routes   - Show service routes"
	@echo ""
	@echo "$(YELLOW)Ingress:$(RESET)"
	@echo "  make ingress-status   - View ingress controller status"
	@echo "  make ingress-logs     - View ingress logs"
	@echo ""
	@echo "$(YELLOW)Observability:$(RESET)"
	@echo "  make status           - Check all services (auto-detects environment)"
	@echo "  make k3d-logs         - View all pod logs"
	@echo "  make k3d-logs-<svc>   - View specific service logs"
```

**Estimated Time:** 30 minutes

---

## Phase 7: Update React App Configuration

### 7.1 Update API Base URL in React

**Option A: Use Relative URLs (Recommended)**

`frontend/src/config/api.ts`:
```typescript
// Before (absolute URL)
export const API_BASE_URL = 'http://localhost:8080/api';

// After (relative URL - uses Ingress routing)
export const API_BASE_URL = '/api';
```

**Option B: Environment-based Configuration**

`frontend/.env.development`:
```
VITE_API_BASE_URL=/api
```

`frontend/.env.production`:
```
VITE_API_BASE_URL=/api
```

`frontend/src/config/api.ts`:
```typescript
export const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || '/api';
```

### 7.2 Update Axios/Fetch Calls

```typescript
// Use relative URLs
const response = await fetch('/api/users');

// Or with axios
import axios from 'axios';
const api = axios.create({
  baseURL: '/api'
});
```

**Estimated Time:** 10 minutes

---

## Phase 8: Traffic Management Examples

### 8.1 Canary Deployment (Traffic Splitting)

**Create canary deployment:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rtmc-api-canary
spec:
  replicas: 1
  selector:
    matchLabels:
      app: rtmc-api
      version: canary
  template:
    metadata:
      annotations:
        linkerd.io/inject: enabled
      labels:
        app: rtmc-api
        version: canary
    spec:
      # ... new version of API
```

**Traffic split (90/10):**
```yaml
apiVersion: split.smi-spec.io/v1alpha1
kind: TrafficSplit
metadata:
  name: api-split
spec:
  service: rtmc-api
  backends:
  - service: rtmc-api-stable
    weight: 900
  - service: rtmc-api-canary
    weight: 100
```

### 8.2 Circuit Breaking

```yaml
apiVersion: policy.linkerd.io/v1alpha1
kind: HTTPRoute
metadata:
  name: api-route
spec:
  parentRefs:
  - name: rtmc-api
    kind: Service
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: "/api"
    backendRefs:
    - name: rtmc-api
      port: 8080
    timeouts:
      request: 10s
    retries:
      maxRetries: 3
      retryOn: 5xx
```

### 8.3 Rate Limiting

```yaml
apiVersion: policy.linkerd.io/v1alpha1
kind: RateLimitPolicy
metadata:
  name: api-ratelimit
spec:
  targetRef:
    group: ""
    kind: Service
    name: rtmc-api
  limits:
  - limit: 100
    period: 1m
```

**Estimated Time:** 20 minutes (optional, for advanced demos)

---

## Phase 9: Testing & Validation

### 9.1 Test Checklist

```bash
# 1. Linkerd health check
make linkerd-check

# 2. Ingress status
make ingress-status

# 3. Service mesh injection
kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[*].name}{"\n"}{end}'
# Should see: pod-name    linkerd-proxy    app-container

# 4. mTLS verification
linkerd viz tap deploy/rtmc-api | grep "tls=true"

# 5. Test frontend
curl http://localhost/

# 6. Test API via Ingress
curl http://localhost/api/weatherforecast

# 7. Test direct API access (optional)
curl http://localhost:8080/weatherforecast

# 8. View traffic in dashboard
make linkerd-dashboard

# 9. Live traffic tap
make linkerd-tap

# 10. Check metrics
make linkerd-stat
```

### 9.2 Performance Benchmarks

```bash
# Before Linkerd
ab -n 1000 -c 10 http://localhost:8080/api/weatherforecast

# After Linkerd
ab -n 1000 -c 10 http://localhost/api/weatherforecast

# Expected: < 1ms latency increase
```

**Estimated Time:** 20 minutes

---

## Phase 10: Documentation Updates

### 10.1 Update README.md

**Add Linkerd section:**
```markdown
## Service Mesh (Linkerd)

This project uses Linkerd for:
- 🔐 Automatic mTLS between all services
- 📊 Real-time observability with Grafana
- ⚡ Sub-millisecond latency overhead
- 🔄 Traffic splitting for canary deployments
- 🛡️ Circuit breaking and retries

### Access Linkerd Dashboard
```bash
make linkerd-dashboard
```

### View Live Traffic
```bash
make linkerd-tap
```
```

### 10.2 Create Architecture Diagram

**Create `docs/architecture.md`:**
```markdown
# System Architecture

## Request Flow

1. User → `http://localhost/` → Ingress Controller
2. Ingress → Routes based on path:
   - `/` → Frontend Service → Static Files
   - `/api/*` → API Service → .NET Backend
3. All pod-to-pod communication encrypted with mTLS
4. Linkerd provides observability and resilience
```

### 10.3 Update Service Endpoints Table

```markdown
| Service | URL | Note |
|---------|-----|------|
| Application | http://localhost | Via Ingress |
| API (Direct) | http://localhost:8080 | Optional direct access |
| Swagger | http://localhost:8080/swagger | API documentation |
| Linkerd Dashboard | `make linkerd-dashboard` | Service mesh UI |
| Grafana (Linkerd) | Via Linkerd dashboard | Metrics & graphs |
```

**Estimated Time:** 15 minutes

---

## Total Time Estimate: **2-3 hours**

---

## Rollback Plan

If something goes wrong:

```bash
# 1. Remove Linkerd
linkerd viz uninstall | kubectl delete -f -
linkerd uninstall | kubectl delete -f -

# 2. Remove Ingress
helm uninstall nginx-ingress -n ingress-nginx
kubectl delete namespace ingress-nginx

# 3. Revert to old frontend
git checkout HEAD~1 frontend/Dockerfile

# 4. Rebuild and redeploy
make k3d-update

# 5. Restore old port mappings
# Edit infrastructure/scripts/k8s/create.py
# make k3d-clean && make k3d-start
```

---

## Success Criteria

- ✅ Frontend starts in < 5 seconds (no restarts)
- ✅ All services show `linkerd-proxy` sidecar
- ✅ `linkerd check` passes all checks
- ✅ `curl http://localhost/` returns React app
- ✅ `curl http://localhost/api/weatherforecast` returns JSON
- ✅ Linkerd dashboard shows traffic with mTLS
- ✅ `linkerd viz tap` shows encrypted connections
- ✅ Latency increase < 1ms (p99)

---

## Next Steps After Migration

1. **Add monitoring alerts** (Prometheus + Alertmanager)
2. **Implement canary deployments** (gradual rollouts)
3. **Add distributed tracing** (Jaeger integration)
4. **Set up CI/CD** with automatic traffic shifting
5. **Document in portfolio** with screenshots of Linkerd dashboard

---

## Questions for Consideration

1. **TLS/HTTPS**: Do you want HTTPS on localhost? (cert-manager + self-signed certs)
2. **Multi-environment**: Dev, staging, prod configurations?
3. **Custom domain**: Use `rtmc.local` instead of `localhost`?
4. **Monitoring**: Keep or remove Grafana/Elasticsearch from infrastructure?

---

## References

- [Linkerd Documentation](https://linkerd.io/docs/)
- [Linkerd Best Practices](https://linkerd.io/2/tasks/books/)
- [nginx-ingress Documentation](https://kubernetes.github.io/ingress-nginx/)
- [Service Mesh Patterns](https://www.oreilly.com/library/view/service-mesh-patterns/9781492086444/)

---

**Status Legend:**
- 📋 Planning
- 🚧 In Progress
- ✅ Complete
- ⚠️ Needs Attention
- ❌ Blocked