---
name: dna-extractor
description: Extract coding conventions, patterns, and architectural insights from a codebase to generate CLAUDE.md documentation. Use when analyzing a repository's structure, conventions, or when generating project documentation.
allowed-tools: Read, Glob, Grep, Bash(ls:*), Bash(git:*)
---

# DNA Extractor

Extract the "DNA" from a codebase - conventions, patterns, APIs, and architectural insights - to generate comprehensive CLAUDE.md documentation.

## Usage

```
/dna-extractor <path> [--level <level>] [--output <file>]
```

### Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `<path>` | Yes | Path to the repository or directory to analyze |
| `--level` | No | Analysis depth (see Levels below). Default: `standard` |
| `--output` | No | Output file path (default: stdout) |

## Levels

| Level | Time | What's Extracted |
|-------|------|------------------|
| `snapshot` | ~2 min | Languages, frameworks, directory structure |
| `skeleton` | ~10 min | + Entry points, core entities, basic config |
| `standard` | ~30 min | Full extraction - all conventions, APIs, tests (default) |
| `comprehensive` | ~2 hrs | + Negative space analysis, git history patterns |

### Level Details

#### `snapshot` (Quick Overview)
- **Phase 1**: Structure scout only
- **Phase 2**: None
- **Phase 3**: Minimal synthesis
- **Use when**: Quick orientation, initial triage

#### `skeleton` (Basic Analysis)
- **Phase 1**: Structure + Config + Entry point scouts
- **Phase 2**: Convention extractor only
- **Phase 3**: Standard synthesis
- **Use when**: Understanding project basics

#### `standard` (Full Extraction) - Default
- **Phase 1**: All scouts (structure, config, entry points, schemas)
- **Phase 2**: All core specialists (conventions, domain, API, tests)
- **Phase 3**: Full synthesis with conflict resolution
- **Use when**: Generating complete CLAUDE.md

#### `comprehensive` (Deep Dive)
- **Phase 1**: All scouts with extended analysis
- **Phase 2**: All specialists including security, infrastructure
- **Phase 3**: Full synthesis + negative space + git history
- **Use when**: Thorough audit, complex projects

## Examples

### Quick scan
```
/dna-extractor . --level=snapshot
```

### Standard analysis (default)
```
/dna-extractor /path/to/project
```

### Full analysis with output file
```
/dna-extractor /path/to/project --level=comprehensive --output=CLAUDE.md
```

## Workflow

This skill orchestrates a multi-phase extraction process:

### Phase 1: Scouts (Parallel)
Gather raw data from the codebase:
- **Structure scout**: Languages, frameworks, directory layout
- **Config scout**: Dependencies, CI/CD, deployment
- **Entry point scout**: Routes, CLI commands, jobs
- **Schema scout**: Database schemas, API specs

### Phase 2: Specialists (Conditional)
Analyze extracted data based on findings:
- **Convention extractor**: Naming, error handling, patterns
- **Domain modeler**: Entities, relationships, business logic
- **API extractor**: Endpoints, contracts, authentication
- **Test analyst**: Test patterns, coverage, frameworks
- **Security analyst**: Auth patterns, vulnerabilities
- **Infrastructure analyst**: Deployment, configuration

### Phase 3: Synthesis (Sequential)
Produce final output:
- **Conflict resolver**: Reconcile contradictions
- **Confidence scorer**: Rate finding certainty
- **Negative space detector**: Identify gaps
- **DNA renderer**: Generate CLAUDE.md

## Context

When invoked, this skill reads the orchestrator prompt and executes the extraction pipeline with the provided parameters.

See `prompts/orchestrator.md` for coordination logic.
