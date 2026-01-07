# DNA Extractor Skill

Extract the "DNA" of any codebase - conventions, patterns, architecture, and tribal knowledge.

## Usage

```
/dna-extractor <path-or-url> [options]
```

## Arguments

- `path-or-url`: Either a local filesystem path OR a GitHub URL
  - Local: `/path/to/repo` or `.` or `~/projects/myapp`
  - GitHub: `https://github.com/owner/repo.git` or `https://github.com/owner/repo`

## Options

- `--level=<level>`: Extraction depth (default: standard)
  - `snapshot`: ~2 min - Languages, frameworks, structure only
  - `skeleton`: ~10 min - + Entry points, core entities
  - `standard`: ~30 min - Full extraction
  - `comprehensive`: ~2 hrs - + Negative space, git history
- `--output=<file>`: Output file path (default: DNA.md in target directory)

## Examples

```bash
# Extract from local directory
/dna-extractor .
/dna-extractor /path/to/my/project
/dna-extractor ~/code/myapp --level=skeleton

# Extract from GitHub URL
/dna-extractor https://github.com/owner/repo.git
/dna-extractor https://github.com/owner/repo --level=snapshot
/dna-extractor https://github.com/owner/repo.git --output=./docs/DNA.md
```

## Skill Implementation

When this skill is invoked, follow these steps:

### Step 1: Parse Arguments

```
Arguments: {{args}}
```

Parse the input to extract:
1. `target`: The path or URL (first non-flag argument, defaults to ".")
2. `level`: Extraction level from `--level=` flag (defaults to "standard")
3. `output`: Output path from `--output=` flag (defaults to "DNA.md" in target)

### Step 2: Determine Input Type

Check if `target` is a URL or local path:

**URL Detection:**
- Starts with `https://github.com/`
- Starts with `git@github.com:`
- Starts with `http://` or `https://` and contains `github`

**Local Path:**
- Everything else (relative or absolute filesystem path)

### Step 3: Handle GitHub URLs

If the target is a GitHub URL:

1. **Normalize the URL:**
   - Remove trailing `.git` if present for display
   - Ensure `.git` suffix for cloning
   - Extract repo name from URL (last path segment)

2. **Clone to temporary directory:**
   ```bash
   TEMP_DIR=$(mktemp -d)
   REPO_NAME=$(basename "$URL" .git)
   CLONE_PATH="$TEMP_DIR/$REPO_NAME"
   git clone --depth 1 "$URL" "$CLONE_PATH"
   ```

3. **Set working path:**
   - Use `$CLONE_PATH` as the extraction target
   - Remember to clean up `$TEMP_DIR` after extraction

4. **Error handling:**
   - If clone fails, report error with URL and git output
   - Check for common issues: invalid URL, private repo, network error

### Step 4: Handle Local Paths

If the target is a local path:

1. **Resolve the path:**
   - Expand `~` to home directory
   - Convert relative to absolute path
   - Verify directory exists

2. **Validate:**
   ```bash
   if [[ ! -d "$TARGET_PATH" ]]; then
     echo "Error: Directory not found: $TARGET_PATH"
     exit 1
   fi
   ```

3. **Set working path:**
   - Use the resolved path as extraction target

### Step 5: Run Extraction

Execute the DNA extraction process on the working path:

1. **Phase 1 - Reconnaissance (Scouts):**
   Run these scouts in parallel:
   - Structure Scout: Languages, frameworks, directory layout
   - Config Scout: Configuration files, environment variables
   - Entry Point Scout: Routes, CLI commands, background jobs
   - Schema Scout: Database schemas, API specs, message formats

2. **Phase 2 - Deep Analysis (Specialists):**
   Based on Phase 1 findings, run relevant specialists:
   - Domain Modeler: Entities, relationships, state machines
   - API Extractor: Endpoints, request/response schemas (if APIs found)
   - Test Analyst: Test coverage, behavioral specifications
   - Security Analyst: Auth mechanisms, trust boundaries
   - Convention Extractor: Naming patterns, code style
   - Infrastructure Analyst: Deployment, CI/CD, monitoring
   - Negative Space Detector: Expected-but-missing features (comprehensive only)

3. **Phase 3 - Synthesis:**
   - Conflict Resolver: Reconcile contradictory information
   - Confidence Scorer: Assign confidence levels
   - DNA Renderer: Generate final DNA.md

### Step 6: Write Output

1. **Determine output path:**
   - If `--output` specified: Use that path
   - If GitHub URL: Write to current directory as `{repo-name}-DNA.md`
   - If local path: Write to `DNA.md` in the target directory

2. **Write the file:**
   - Generate DNA.md using the DNA template
   - Include extraction metadata (timestamp, confidence, level)

### Step 7: Cleanup

If a temporary directory was created for a GitHub clone:

```bash
rm -rf "$TEMP_DIR"
```

Report completion with:
- Output file location
- Overall confidence score
- Extraction level used
- Time taken (if significant)

## Output Format

The extraction produces a DNA.md file following this structure:

```markdown
# {Project Name} DNA

> Extracted: {timestamp}
> Confidence: {overall_confidence}%
> Level: {extraction_level}

---

## Identity
- Name, description, purpose, primary language, project type

## Domain Model
- Entities, relationships, state machines, invariants

## Capabilities
- Features, API endpoints, CLI commands, events

## Architecture
- Directory structure, layers, patterns, data flow

## Stack
- Languages, frameworks, databases, dependencies

## Conventions
- Naming patterns, code style, documentation practices

## Constraints
- Security considerations, performance requirements

## Operations
- Build, test, deploy procedures

## Uncertainties
- Items with low confidence or requiring clarification
```

## Error Handling

| Error | Response |
|-------|----------|
| Invalid URL format | "Error: Invalid GitHub URL. Expected format: https://github.com/owner/repo" |
| Clone failed (404) | "Error: Repository not found. Check the URL or repository visibility." |
| Clone failed (auth) | "Error: Authentication required. For private repos, use local clone." |
| Clone failed (network) | "Error: Network error. Check your connection and try again." |
| Path not found | "Error: Directory not found: {path}" |
| Path not a directory | "Error: Path is not a directory: {path}" |
| Permission denied | "Error: Permission denied reading: {path}" |
| Empty repository | "Warning: Repository appears empty. Generating minimal DNA." |

## Level-Specific Behavior

### Snapshot (~2 min)
- Structure Scout only
- Languages, frameworks, basic structure
- No deep analysis phases

### Skeleton (~10 min)
- Phase 1 scouts (parallel)
- Entry points and core entities only from Phase 2
- Basic synthesis

### Standard (~30 min, default)
- Full Phase 1 and Phase 2
- Complete synthesis
- All sections populated

### Comprehensive (~2 hrs)
- Full extraction plus:
- Git history analysis (churn, ownership)
- Negative space detection
- Cross-reference validation
