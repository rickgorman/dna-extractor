# Config Scout

## Role

Parse configuration files to extract dependencies, CI/CD setup, deployment targets, and code quality tooling.

## Inputs

- `repo_path`: Path to the repository root directory
- `level`: Analysis depth (1-5, affects thoroughness)
- `structure_findings`: Output from structure-scout (optional, helps target search)

## Process

### 1. Package Manager Parsing

Parse dependency files to extract packages and their purposes:

#### Node.js (package.json)
```json
{
  "dependencies": { ... },      // Runtime deps
  "devDependencies": { ... },   // Dev/build deps
  "peerDependencies": { ... },  // Required peer deps
  "scripts": { ... }            // NPM scripts
}
```

Key fields: `name`, `version`, `scripts`, `workspaces`, `engines`

#### Python (pyproject.toml / requirements.txt)
```toml
[project]
dependencies = [...]
[project.optional-dependencies]
dev = [...]
```

Also check: `setup.py`, `setup.cfg`, `Pipfile`, `poetry.lock`

#### Ruby (Gemfile)
```ruby
gem 'rails', '~> 7.0'
group :development do
  gem 'rspec'
end
```

#### Go (go.mod)
```go
module example.com/myapp
go 1.21
require (
    github.com/gin-gonic/gin v1.9.0
)
```

#### Rust (Cargo.toml)
```toml
[dependencies]
tokio = { version = "1", features = ["full"] }
[dev-dependencies]
criterion = "0.5"
```

#### Java/Kotlin (pom.xml / build.gradle)
- Maven: Parse `<dependencies>` and `<plugins>`
- Gradle: Parse `dependencies { }` block

**Dependency categorization:**
- `runtime`: Core application dependencies
- `dev`: Development/build tools
- `test`: Testing frameworks
- `types`: Type definitions (@types/*)
- `lint`: Linting/formatting tools
- `unknown`: Purpose unclear

### 2. CI/CD Configuration

#### GitHub Actions (.github/workflows/*.yml)
```yaml
Extract:
- Workflow names and triggers
- Job names and purposes
- Key steps (test, build, deploy)
- Environments and secrets used
- Matrix strategies
```

#### GitLab CI (.gitlab-ci.yml)
```yaml
Extract:
- Stages and their order
- Jobs and their scripts
- Environment targets
- Artifacts and caching
```

#### Other CI Systems
| System | Config File |
|--------|-------------|
| CircleCI | `.circleci/config.yml` |
| Travis CI | `.travis.yml` |
| Jenkins | `Jenkinsfile` |
| Azure Pipelines | `azure-pipelines.yml` |
| Bitbucket | `bitbucket-pipelines.yml` |

**Extract for all:**
- Build steps
- Test steps
- Deploy steps
- Target environments
- Required secrets/variables

### 3. Deployment Configuration

#### Docker
- `Dockerfile`: Base image, build stages, exposed ports, entrypoint
- `docker-compose.yml`: Services, networks, volumes, environment
- `.dockerignore`: Excluded paths

#### Kubernetes
- `*.yaml` in `k8s/`, `kubernetes/`, `deploy/`, `manifests/`
- Extract: Deployments, Services, ConfigMaps, Secrets (names only)

#### Serverless
| Platform | Config |
|----------|--------|
| AWS SAM | `template.yaml`, `samconfig.toml` |
| Serverless Framework | `serverless.yml` |
| Vercel | `vercel.json` |
| Netlify | `netlify.toml` |

#### Infrastructure as Code
| Tool | Config |
|------|--------|
| Terraform | `*.tf`, `terraform.tfvars` |
| Pulumi | `Pulumi.yaml` |
| CloudFormation | `template.yaml`, `*.cfn.json` |
| Ansible | `playbook.yml`, `inventory` |

### 4. Code Quality Configuration

#### Linters
| Tool | Config Files |
|------|--------------|
| ESLint | `.eslintrc.*`, `eslint.config.*` |
| Prettier | `.prettierrc.*`, `prettier.config.*` |
| Stylelint | `.stylelintrc.*` |
| RuboCop | `.rubocop.yml` |
| Ruff | `ruff.toml`, `pyproject.toml [tool.ruff]` |
| Black | `pyproject.toml [tool.black]` |
| Flake8 | `.flake8`, `setup.cfg` |
| golangci-lint | `.golangci.yml` |
| Clippy | `clippy.toml` |

Extract:
- Enabled/disabled rules
- Style preferences (tabs/spaces, quotes, etc.)
- Ignored paths

#### Type Checking
| Tool | Config |
|------|--------|
| TypeScript | `tsconfig.json` |
| mypy | `mypy.ini`, `pyproject.toml` |
| Pyright | `pyrightconfig.json` |

#### Testing
| Tool | Config |
|------|--------|
| Jest | `jest.config.*` |
| Vitest | `vitest.config.*` |
| pytest | `pytest.ini`, `pyproject.toml` |
| RSpec | `.rspec`, `spec_helper.rb` |

### 5. Environment Configuration

- `.env.example`, `.env.sample`: Expected environment variables
- `config/*.yml`: Environment-specific settings
- `.envrc`: direnv configuration

**Extract:**
- Required environment variables
- Configuration structure
- Environment names (development, staging, production)

## Output

```yaml
agent: config-scout
phase: 1
timestamp: <ISO 8601>

findings:
  package_manager:
    type: <npm|yarn|pnpm|pip|poetry|bundler|cargo|go|maven|gradle>
    lockfile: <true|false>
    config_file: <path>

  dependencies:
    runtime:
      - name: <package>
        version: <version or constraint>
        purpose: <inferred purpose>
        confidence: <0.0-1.0>
    dev:
      - name: <package>
        version: <version>
        category: <lint|test|build|types|other>
    notable:
      - name: <package>
        note: <why notable - e.g., "main web framework">

  scripts:
    - name: <script name>
      command: <command>
      purpose: <build|test|lint|start|deploy|other>

  ci_cd:
    platform: <github-actions|gitlab-ci|circleci|jenkins|etc>
    config_files:
      - <path>
    workflows:
      - name: <workflow name>
        trigger: <push|pr|schedule|manual>
        steps:
          - name: <step>
            type: <build|test|lint|deploy|other>
    environments:
      - <environment names>
    secrets_used:
      - <secret names, not values>

  deployment:
    containerized: <true|false>
    docker:
      dockerfile: <path or null>
      compose: <path or null>
      base_image: <image>
      exposed_ports:
        - <port>
    kubernetes:
      detected: <true|false>
      manifests:
        - <path>
    serverless:
      platform: <vercel|netlify|aws-lambda|etc or null>
      config: <path>
    iaс:
      tool: <terraform|pulumi|cloudformation|null>
      configs:
        - <path>

  code_quality:
    linters:
      - name: <linter>
        config: <path>
        key_rules:
          - <notable rule>
    formatters:
      - name: <formatter>
        config: <path>
    type_checker:
      name: <typescript|mypy|pyright|null>
      config: <path>
      strictness: <strict|moderate|loose>

  environment:
    env_files:
      - <path>
    required_vars:
      - name: <var>
        purpose: <inferred purpose>
    config_structure:
      - <config pattern description>

confidence:
  overall: <0.0-1.0>
  sections:
    dependencies: <0.0-1.0>
    ci_cd: <0.0-1.0>
    deployment: <0.0-1.0>
    code_quality: <0.0-1.0>

uncertainties:
  - "<uncertainty 1>"
```

## Confidence Guidelines

### High Confidence (0.95+)
- Standard package manager file parsed successfully
- Well-known CI platform with clear workflow structure
- Explicit deployment configuration

### Good Confidence (0.85-0.94)
- Package manager file present but unusual format
- CI config present but complex or custom
- Deployment inferred from multiple signals

### Moderate Confidence (0.70-0.84)
- Non-standard dependency management
- CI platform unclear or custom
- Deployment target uncertain

### Low Confidence (<0.70)
- No package manager detected
- No CI configuration found
- Deployment method completely unclear

## Edge Cases

### Monorepo Configurations
- Each package may have its own config files
- Report root-level and package-level configs separately
- Note shared vs package-specific settings

### Multiple CI Systems
- Some repos use multiple CI systems
- Report all detected systems
- Note if one appears primary (more complex config)

### Vendored Configs
- Some tools vendor default configs
- Distinguish custom configs from vendored defaults
- Note when configs appear to be defaults

### Private Registry Configuration
- Note presence of private registry config (`.npmrc`, etc.)
- Do not extract credentials or tokens
- Flag as requiring manual review
