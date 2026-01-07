---
description: Extract DNA (codebase structure/conventions) from a repository
allowed-tools: Read, Write, Glob, Grep, Bash, Task, TaskOutput
argument-hint: <repo-path> [--level=standard]
version: "0.1"
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

## Execution Strategy

**CRITICAL: Maximize parallelization. Minimize main context usage.**

Use the Task tool to spawn subtasks that run in parallel. Keep analysis work in subtasks until results are ready to synthesize. Only return to main context for final assembly.

Target repository: $ARGUMENTS

---

## Phase 1: Reconnaissance (PARALLEL)

**Launch ALL scouts simultaneously using Task tool with `run_in_background: true`:**

```
Task 1: Structure Scout
- Detect languages from file extensions
- Identify frameworks (package.json, requirements.txt, Cargo.toml, etc.)
- Map directory layout
- Check for monorepo signals
- Reference: @prompts/phase1/structure-scout.md

Task 2: Config Scout
- Parse package.json, pyproject.toml, Cargo.toml, go.mod
- Extract dependencies, scripts, metadata
- Identify build tools, test frameworks

Task 3: Entry Point Scout
- Find main/index files
- Detect CLI entry points (bin/, scripts)
- Identify API entry points (routes, controllers)
- Find test entry points

Task 4: Schema Scout
- Detect database schemas (migrations, schema.rb, prisma)
- Find ORM models
- Identify data structures
```

**Spawn all 4 scouts in a SINGLE message with multiple Task tool calls.**

Wait for all scouts to complete using TaskOutput before proceeding.

---

## Phase 2: Deep Analysis (PARALLEL)

**Based on Phase 1 findings, launch specialists in parallel:**

```
Task 5: Domain Modeler (if models detected)
- Extract entities, attributes, types
- Map relationships (has_many, belongs_to, foreign keys)
- Detect state machines
- Identify invariants/validations
- Reference: @prompts/phase2/domain-modeler.md

Task 6: API Extractor (if API detected)
- Document endpoints (routes, methods)
- Extract request/response schemas
- Identify authentication patterns

Task 7: Test Analyst (if tests detected)
- Analyze test structure and patterns
- Identify fixtures, factories
- Note coverage patterns

Task 8: Security Analyst
- Identify auth mechanisms
- Find security middleware
- Note encryption/secrets handling

Task 9: Convention Extractor
- Detect naming conventions
- Identify code style patterns
- Note documentation patterns

Task 10: Infrastructure Analyst (if IaC detected)
- Parse Dockerfile, docker-compose
- Analyze Terraform/CloudFormation
- Identify CI/CD patterns
- Reference: @prompts/phase2/infrastructure-analyst.md
```

**Spawn ALL applicable specialists in a SINGLE message.**

Use `run_in_background: true` for each. Collect results with TaskOutput.

---

## Phase 3: Synthesis (SEQUENTIAL)

Only after Phase 2 completes, run synthesis in main context:

1. **Conflict Resolution**: Merge findings, resolve contradictions
2. **Confidence Scoring**: Rate each finding (certain/inferred/speculated)
   - Reference: @prompts/phase3/confidence-scorer.md
3. **DNA Rendering**: Generate final output using template
   - Reference: @templates/dna-template.md

---

## Parallelization Rules

1. **Always batch Task calls**: Send multiple Task tool calls in ONE message
2. **Use background mode**: Set `run_in_background: true` for all scouts/specialists
3. **Defer to subtasks**: Push ALL analysis work into subtasks
4. **Main context = assembly only**: Only use main context for:
   - Launching tasks
   - Collecting results (TaskOutput)
   - Final synthesis
5. **No redundant reads**: Subtasks read files, main context just assembles

---

## Output Format

Generate structured YAML:

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

---

## Help

If invoked with `--help`, display:

```
DNA Extractor v0.1 - Extract codebase DNA

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

---

## Output File Naming

**CRITICAL: Never clobber existing DNA files.**

1. Extract project name from repo path:
   - `/path/to/bar-project` → `bar-project`
   - `https://github.com/foo/bar-project.git` → `bar-project`
   - Use basename, strip `.git` suffix if present

2. Convert to safe filename:
   - Uppercase all letters
   - Replace non-word chars (except underscores) with underscores
   - Remove consecutive underscores
   - Example: `bar-project` → `BAR_PROJECT`

3. Append `_DNA.md`:
   - Base: `BAR_PROJECT_DNA.md`

4. Check for existing files and increment if needed:
   - If `BAR_PROJECT_DNA.md` exists → `BAR_PROJECT_DNA_002.md`
   - If `BAR_PROJECT_DNA_002.md` exists → `BAR_PROJECT_DNA_003.md`
   - Continue incrementing until unique filename found

5. Write file to **current working directory** (where command was invoked)

6. After writing, display:
   ```
   DNA extraction complete!

   Output saved to: /full/path/to/BAR_PROJECT_DNA.md
   ```

---

## Begin Extraction

If `--help` was passed, show help and stop.

Otherwise:

### Step 0: Fast Intro (IMMEDIATE - no delay)

**Display intro within 1 second of start:**

1. **Get project name (fast check only):**
   ```bash
   # Try README H1 first (grep first # heading)
   head -20 README.md 2>/dev/null | grep -m1 '^# ' | sed 's/^# //'

   # Fallback: use folder/repo name
   basename "$(pwd)" | sed 's/\.git$//'
   ```

2. **Display intro immediately:**
   ```
   DNA Extractor v0.1
   ==================
   Scanning: {project_name}

   Phases:
     1. Scout     - structure, config, entry points, schemas
     2. Analyze   - domain, APIs, tests, security, conventions
     3. Synthesize - resolve conflicts, score confidence, render

   Starting Phase 1...
   ```

3. **NO prompts, NO delays** - print intro and immediately begin Phase 1

**Example for local path:**
```
$ /dna-extractor /path/to/myproject --level=standard

DNA Extractor v0.1
==================
Scanning: myproject

Phases:
  1. Scout     - structure, config, entry points, schemas
  2. Analyze   - domain, APIs, tests, security, conventions
  3. Synthesize - resolve conflicts, score confidence, render

Starting Phase 1...
```

**Example for GitHub URL:**
```
$ /dna-extractor https://github.com/foo/bar.git

DNA Extractor v0.1
==================
Cloning: bar (from github.com/foo)

Phases:
  1. Scout     - structure, config, entry points, schemas
  2. Analyze   - domain, APIs, tests, security, conventions
  3. Synthesize - resolve conflicts, score confidence, render

Cloning repository...
Starting Phase 1...
```

### Steps 1-9: Main Extraction

1. Parse arguments from: $ARGUMENTS
2. **Display fast intro (Step 0 above)**
3. Determine output filename (see Output File Naming above)
4. Launch Phase 1 scouts (4 parallel background tasks)
5. Collect Phase 1 results
6. Launch Phase 2 specialists (up to 6 parallel background tasks based on findings)
7. Collect Phase 2 results
8. Run Phase 3 synthesis in main context
9. Write DNA to output file (never clobber existing)
10. Display full path to created file
