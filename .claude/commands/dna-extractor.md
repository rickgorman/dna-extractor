---
description: Extract DNA (codebase structure/conventions) from a repository
allowed-tools: Read, Glob, Grep, Bash, Task
argument-hint: <repo-path> [--level=standard]
---

# DNA Extractor

Extract the "DNA" of a codebase - its structure, conventions, domain model, architecture, and operations.

## Arguments

- `$1`: Repository path (required)
- `--level=<level>`: Extraction depth (optional, default: standard)

Levels:
- `snapshot` (~2 min): Languages, frameworks, structure only
- `skeleton` (~10 min): + Entry points, core entities
- `standard` (~30 min): Full extraction (default)
- `comprehensive` (~2 hrs): + Negative space, git history

## Execution

Target repository: $ARGUMENTS

### Phase 1: Reconnaissance (Parallel)

Run these scouts in parallel to gather initial findings:

1. **Structure Scout**: Detect languages, frameworks, directory layout, monorepo signals
   - Reference: @prompts/phase1/structure-scout.md

2. **Config Scout**: Parse configuration files (package.json, pyproject.toml, etc.)

3. **Entry Point Scout**: Find main entry points, CLI commands, API endpoints

4. **Schema Scout**: Detect database schemas, migrations, data models

### Phase 2: Deep Analysis (Parallel)

Based on Phase 1 findings, run specialists:

1. **Domain Modeler**: Extract entities, relationships, state machines, invariants
   - Reference: @prompts/phase2/domain-modeler.md

2. **API Extractor**: Document API endpoints, request/response schemas

3. **Test Analyst**: Analyze test coverage, patterns, fixtures

4. **Security Analyst**: Identify auth patterns, security constraints

5. **Convention Extractor**: Detect coding conventions, naming patterns

6. **Infrastructure Analyst**: Parse IaC, deployment configs, observability
   - Reference: @prompts/phase2/infrastructure-analyst.md

### Phase 3: Synthesis (Sequential)

1. **Conflict Resolver**: Resolve conflicting findings between agents

2. **Confidence Scorer**: Annotate findings with certainty levels
   - Reference: @prompts/phase3/confidence-scorer.md

3. **DNA Renderer**: Generate final DNA document
   - Reference: @templates/dna-template.md

## Output Format

Generate structured YAML with these sections:

```yaml
dna:
  identity:
    name: <project-name>
    description: <what it does>
    primary_language: <language>
    project_type: <web-app|library|cli|api|etc>

  domain_model:
    entities: [...]
    relationships: [...]
    state_machines: [...]
    invariants: [...]

  capabilities:
    features: [...]
    endpoints: [...]
    commands: [...]

  architecture:
    directory_structure: {...}
    key_paths: {...}
    patterns: [...]

  stack:
    languages: [...]
    frameworks: [...]
    dependencies: [...]

  conventions:
    naming: {...}
    file_organization: {...}
    style: [...]

  constraints:
    security: [...]
    performance: [...]
    compatibility: {...}

  operations:
    build: [...]
    test: [...]
    deploy: [...]

  uncertainties:
    questions: [...]
    missing: [...]

  metadata:
    extraction_timestamp: <ISO-8601>
    overall_confidence: <0.0-1.0>
    extraction_level: <level>
```

## Help

If invoked with `--help`, display:

```
DNA Extractor - Extract codebase DNA

Usage: /dna-extractor <repo-path> [--level=standard]

Levels:
  snapshot       Quick scan (~2 min)
  skeleton       Basic structure (~10 min)
  standard       Full extraction (~30 min) [default]
  comprehensive  Deep analysis (~2 hrs)

Examples:
  /dna-extractor .
  /dna-extractor /path/to/repo --level=skeleton
  /dna-extractor ~/projects/myapp --level=comprehensive
```

## Begin Extraction

If `--help` was passed, show help and stop.

Otherwise, begin DNA extraction for: $ARGUMENTS
