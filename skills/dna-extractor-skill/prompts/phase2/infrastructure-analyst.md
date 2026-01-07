# Infrastructure Analyst

## Role

Analyze infrastructure-as-code, deployment configurations, CI/CD pipelines, and observability setup to document operational patterns.

## Inputs

- **Repository path**: Root directory of the codebase
- **Accumulator state**: Phase 1 findings (languages, frameworks, directory structure)
- **Extraction level**: One of `snapshot`, `skeleton`, `standard`, `comprehensive`

## Process

### 1. Container Configuration

#### Dockerfile Analysis

Locate and parse Dockerfiles:
```
Dockerfile
Dockerfile.*
docker/Dockerfile*
.docker/Dockerfile*
*/Dockerfile
```

**Extract from Dockerfile:**
```dockerfile
FROM node:18-alpine AS builder    # Base image, build stages
WORKDIR /app                       # Working directory
COPY package*.json ./              # Dependency files
RUN npm ci                         # Build commands
COPY . .                           # Source copying
RUN npm run build                  # Build step
EXPOSE 3000                        # Exposed ports
CMD ["npm", "start"]               # Entry command
HEALTHCHECK --interval=30s CMD curl -f http://localhost:3000/health
```

**Output structure:**
```yaml
containers:
  - file: Dockerfile
    base_image: node:18-alpine
    multi_stage: true
    stages:
      - name: builder
        base: node:18-alpine
      - name: production
        base: node:18-alpine
    exposed_ports: [3000]
    entry_command: ["npm", "start"]
    healthcheck:
      interval: 30s
      command: "curl -f http://localhost:3000/health"
    environment_vars:
      - NODE_ENV
      - DATABASE_URL
    confidence: 0.98
```

#### Docker Compose Analysis

Locate compose files:
```
docker-compose.yml
docker-compose.yaml
docker-compose.*.yml
compose.yml
compose.yaml
```

**Extract from docker-compose:**
```yaml
services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - DATABASE_URL=postgres://...
    depends_on:
      - db
      - redis
  db:
    image: postgres:15
    volumes:
      - pgdata:/var/lib/postgresql/data
  redis:
    image: redis:7-alpine
```

**Output structure:**
```yaml
compose:
  file: docker-compose.yml
  services:
    - name: app
      build: true
      ports: ["3000:3000"]
      dependencies: [db, redis]
    - name: db
      image: postgres:15
      volumes: [pgdata]
    - name: redis
      image: redis:7-alpine
  networks: [default]
  volumes: [pgdata]
  confidence: 0.98
```

### 2. Infrastructure as Code

#### Terraform

Locate Terraform files:
```
*.tf
terraform/*.tf
infrastructure/*.tf
infra/*.tf
deploy/terraform/*.tf
```

**Extract from Terraform:**
```hcl
provider "aws" {
  region = var.region
}

resource "aws_ecs_cluster" "main" {
  name = "production"
}

resource "aws_rds_instance" "db" {
  engine         = "postgres"
  instance_class = "db.t3.medium"
}
```

**Output structure:**
```yaml
terraform:
  providers:
    - name: aws
      version: "~> 5.0"
      region: var.region
    - name: kubernetes
      version: "~> 2.0"
  resources:
    - type: aws_ecs_cluster
      name: main
      purpose: container_orchestration
    - type: aws_rds_instance
      name: db
      engine: postgres
      purpose: database
    - type: aws_s3_bucket
      name: assets
      purpose: storage
  modules:
    - name: vpc
      source: terraform-aws-modules/vpc/aws
  state_backend: s3
  confidence: 0.95
```

#### CloudFormation

Locate CloudFormation templates:
```
*.yaml (with AWSTemplateFormatVersion)
*.yml (with AWSTemplateFormatVersion)
*.json (with AWSTemplateFormatVersion)
cloudformation/*.yaml
cfn/*.yaml
```

**Extract key resources:**
- EC2 instances, ECS services, Lambda functions
- RDS, DynamoDB, S3
- API Gateway, Load Balancers
- IAM roles and policies

#### Pulumi

Locate Pulumi files:
```
Pulumi.yaml
Pulumi.*.yaml
__main__.py (with pulumi imports)
index.ts (with @pulumi imports)
```

#### Other IaC

| Tool | Files | Indicators |
|------|-------|------------|
| Ansible | `playbook.yml`, `ansible.cfg` | `hosts:`, `tasks:` |
| Chef | `cookbooks/`, `recipes/` | `cookbook_name` |
| Puppet | `manifests/*.pp` | `class`, `node` |
| Kubernetes | `*.yaml` with `apiVersion:` | `kind:`, `metadata:` |
| Helm | `Chart.yaml`, `values.yaml` | `appVersion` |
| CDK | `cdk.json`, `lib/*.ts` | `@aws-cdk` imports |

### 3. Deployment Target Identification

#### Cloud Providers

**AWS Indicators:**
| Signal | Confidence |
|--------|------------|
| `aws` provider in Terraform | 0.98 |
| `AWSTemplateFormatVersion` in YAML | 0.98 |
| `serverless.yml` with `provider: aws` | 0.95 |
| `.aws/` directory | 0.90 |
| `AWS_` environment variables | 0.85 |
| `s3://` URLs in configs | 0.80 |

**GCP Indicators:**
| Signal | Confidence |
|--------|------------|
| `google` provider in Terraform | 0.98 |
| `app.yaml` (App Engine) | 0.95 |
| `cloudbuild.yaml` | 0.95 |
| `GOOGLE_` environment variables | 0.85 |
| `gs://` URLs | 0.80 |

**Azure Indicators:**
| Signal | Confidence |
|--------|------------|
| `azurerm` provider in Terraform | 0.98 |
| `azure-pipelines.yml` | 0.95 |
| `AZURE_` environment variables | 0.85 |

#### Platform-as-a-Service

| Platform | Indicators | Confidence |
|----------|------------|------------|
| Heroku | `Procfile`, `app.json`, `heroku.yml` | 0.98 |
| Railway | `railway.json`, `railway.toml` | 0.98 |
| Render | `render.yaml` | 0.98 |
| Fly.io | `fly.toml` | 0.98 |
| Vercel | `vercel.json`, `.vercel/` | 0.98 |
| Netlify | `netlify.toml`, `_redirects` | 0.98 |
| DigitalOcean | `do.yaml`, `.do/` | 0.95 |

#### Container Orchestration

| Platform | Indicators | Confidence |
|----------|------------|------------|
| Kubernetes | `deployment.yaml`, `service.yaml` | 0.98 |
| ECS | `ecs-task-definition.json` | 0.98 |
| Docker Swarm | `docker-stack.yml` | 0.95 |
| Nomad | `*.nomad`, `job.hcl` | 0.95 |

### 4. CI/CD Pipeline Analysis

#### GitHub Actions

Location: `.github/workflows/*.yml`

**Extract:**
```yaml
ci_cd:
  platform: github_actions
  workflows:
    - name: CI
      file: .github/workflows/ci.yml
      triggers: [push, pull_request]
      jobs:
        - name: test
          runs_on: ubuntu-latest
          steps: [checkout, setup-node, install, test]
        - name: build
          runs_on: ubuntu-latest
          needs: [test]
    - name: Deploy
      file: .github/workflows/deploy.yml
      triggers: [push to main]
      jobs:
        - name: deploy
          environment: production
```

#### GitLab CI

Location: `.gitlab-ci.yml`

#### Other CI/CD

| Platform | Config File | Confidence |
|----------|-------------|------------|
| CircleCI | `.circleci/config.yml` | 0.98 |
| Travis CI | `.travis.yml` | 0.98 |
| Jenkins | `Jenkinsfile` | 0.98 |
| Azure Pipelines | `azure-pipelines.yml` | 0.98 |
| Buildkite | `.buildkite/pipeline.yml` | 0.98 |
| Drone | `.drone.yml` | 0.98 |
| TeamCity | `.teamcity/` | 0.95 |

### 5. Observability Setup

#### Logging

| Tool | Indicators | Confidence |
|------|------------|------------|
| Winston | `winston` in deps, `logger.js` | 0.95 |
| Pino | `pino` in deps | 0.95 |
| Log4j | `log4j.xml`, `log4j2.xml` | 0.95 |
| Logback | `logback.xml` | 0.95 |
| Python logging | `logging.config` | 0.90 |
| Serilog | `Serilog` in deps | 0.95 |
| Fluentd | `fluent.conf`, `fluentd` | 0.95 |
| Logstash | `logstash.conf` | 0.95 |

**Log aggregation services:**
| Service | Indicators |
|---------|------------|
| Datadog | `DD_` env vars, `datadog.yaml` |
| Splunk | `splunk` configs |
| ELK Stack | `elasticsearch`, `kibana` configs |
| Papertrail | `papertrail` in configs |
| Loggly | `loggly` in configs |
| CloudWatch | AWS logging configs |

#### Metrics

| Tool | Indicators | Confidence |
|------|------------|------------|
| Prometheus | `prometheus.yml`, `/metrics` endpoint | 0.95 |
| Grafana | `grafana/`, dashboards | 0.95 |
| StatsD | `statsd` in deps | 0.90 |
| Datadog | `dd-trace`, `datadog` deps | 0.95 |
| New Relic | `newrelic.js`, `NEW_RELIC_` vars | 0.95 |
| Dynatrace | `oneagent` configs | 0.95 |

#### Tracing

| Tool | Indicators | Confidence |
|------|------------|------------|
| OpenTelemetry | `@opentelemetry` deps, `otel` configs | 0.95 |
| Jaeger | `jaeger` configs | 0.95 |
| Zipkin | `zipkin` configs | 0.95 |
| X-Ray | AWS X-Ray configs | 0.95 |
| Datadog APM | `dd-trace` | 0.95 |

#### Health Checks

Look for:
- `/health`, `/healthz`, `/ready` endpoints
- Kubernetes liveness/readiness probes
- Load balancer health check configs

### 6. Build and Deploy Commands

#### Package Manager Scripts

**npm/yarn/pnpm (package.json):**
```json
{
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "test": "jest",
    "lint": "eslint .",
    "deploy": "vercel --prod"
  }
}
```

**Python (pyproject.toml, setup.py):**
```toml
[tool.poetry.scripts]
serve = "myapp.main:run"
migrate = "myapp.db:migrate"
```

**Go (Makefile):**
```makefile
build:
	go build -o bin/app ./cmd/app

test:
	go test ./...

deploy:
	kubectl apply -f k8s/
```

**Output structure:**
```yaml
commands:
  build:
    - command: "npm run build"
      description: "Build production assets"
      confidence: 0.98
    - command: "docker build -t app ."
      description: "Build Docker image"
      confidence: 0.95
  test:
    - command: "npm test"
      description: "Run test suite"
      confidence: 0.98
  deploy:
    - command: "kubectl apply -f k8s/"
      description: "Deploy to Kubernetes"
      confidence: 0.90
    - command: "vercel --prod"
      description: "Deploy to Vercel"
      confidence: 0.85
  dev:
    - command: "npm run dev"
      description: "Start development server"
      confidence: 0.98
```

### 7. Edge Cases

**Multi-environment setups:**
- Detect `staging`, `production`, `development` configs
- Map environment-specific variables

**Monorepo deployments:**
- Identify per-package deployment configs
- Map shared infrastructure

**Serverless:**
- Parse `serverless.yml`, `sam.yaml`
- Identify function definitions

**Hybrid deployments:**
- Some services on containers, others serverless
- Mixed cloud providers

## Output

```yaml
agent: infrastructure-analyst
phase: 2
timestamp: "{{timestamp}}"

findings:
  containers:
    - type: dockerfile
      file: Dockerfile
      base_image: node:18-alpine
      multi_stage: true
      exposed_ports: [3000]
      entry_command: ["npm", "start"]
      healthcheck: true
      confidence: 0.98
    - type: compose
      file: docker-compose.yml
      services:
        - name: app
          build: true
          ports: ["3000:3000"]
        - name: db
          image: postgres:15
        - name: redis
          image: redis:7-alpine
      confidence: 0.98

  infrastructure_as_code:
    tool: terraform
    version: "~> 1.5"
    providers:
      - name: aws
        region: us-east-1
    resources:
      - type: aws_ecs_cluster
        purpose: container_orchestration
      - type: aws_rds_instance
        engine: postgres
        purpose: database
      - type: aws_elasticache_cluster
        engine: redis
        purpose: caching
    state_backend: s3
    confidence: 0.95

  deployment_targets:
    primary:
      platform: aws
      services:
        - ECS (containers)
        - RDS (database)
        - ElastiCache (caching)
        - S3 (storage)
        - CloudFront (CDN)
      confidence: 0.98
    secondary:
      - platform: vercel
        purpose: frontend_hosting
        confidence: 0.90

  ci_cd:
    platform: github_actions
    workflows:
      - name: CI
        file: .github/workflows/ci.yml
        triggers: [push, pull_request]
        stages: [lint, test, build]
      - name: Deploy
        file: .github/workflows/deploy.yml
        triggers: [push to main]
        stages: [build, push, deploy]
        environments: [staging, production]
    confidence: 0.98

  observability:
    logging:
      library: winston
      aggregation: datadog
      structured: true
      confidence: 0.95
    metrics:
      collector: prometheus
      visualization: grafana
      custom_metrics: true
      confidence: 0.90
    tracing:
      library: opentelemetry
      backend: jaeger
      confidence: 0.85
    health_checks:
      - endpoint: /health
        type: liveness
      - endpoint: /ready
        type: readiness
      confidence: 0.95

  commands:
    build:
      - command: "npm run build"
        source: package.json
        confidence: 0.98
      - command: "docker build -t app ."
        source: Makefile
        confidence: 0.95
    test:
      - command: "npm test"
        source: package.json
        confidence: 0.98
    deploy:
      - command: "terraform apply"
        source: Makefile
        confidence: 0.90
      - command: "kubectl apply -f k8s/"
        source: Makefile
        confidence: 0.90
    dev:
      - command: "docker-compose up"
        source: README.md
        confidence: 0.85

  environments:
    - name: development
      config_files: [.env.development, docker-compose.yml]
    - name: staging
      config_files: [.env.staging, terraform/staging.tfvars]
    - name: production
      config_files: [.env.production, terraform/production.tfvars]

confidence:
  overall: 0.93
  sections:
    containers: 0.98
    infrastructure_as_code: 0.95
    deployment_targets: 0.95
    ci_cd: 0.98
    observability: 0.90
    commands: 0.92

uncertainties:
  - "Some deploy commands inferred from README examples"
  - "Tracing configuration may be incomplete"
  - "Environment-specific configs not fully parsed"
  - "Secrets management approach unclear"
```

## Confidence Guidelines

### Deployment Target (target: ≥95%)
- **High (≥0.95)**: Explicit IaC with provider declarations
- **Good (0.85-0.94)**: Platform config files present
- **Moderate (0.70-0.84)**: Inferred from environment variables
- **Low (<0.70)**: Only circumstantial evidence

### Build Commands (target: ≥90%)
- **High (≥0.95)**: Explicit scripts in package.json/Makefile
- **Good (0.85-0.94)**: Commands in CI/CD config
- **Moderate (0.70-0.84)**: Commands in README
- **Low (<0.70)**: Inferred from project structure

### Observability Tools (target: ≥85%)
- **High (≥0.95)**: Explicit config files present
- **Good (0.85-0.94)**: Dependencies declared
- **Moderate (0.70-0.84)**: Environment variables suggest tool
- **Low (<0.70)**: Only partial indicators

## Error Handling

- **No infrastructure files**: Return minimal findings with deployment target as "unknown"
- **Conflicting configurations**: Flag conflicts in uncertainties
- **Incomplete IaC**: Note partial infrastructure in findings
- **Missing CI/CD**: Report manual deployment suspected
