---
name: orchestrator
description: Coordinates all DNA extraction phases based on selected level
inputs:
  - name: repo_path
    type: directory
    description: Path to repository to analyze
  - name: level
    type: string
    description: Extraction level (snapshot, skeleton, standard, comprehensive)
  - name: output
    type: string
    description: Output file path (optional)
outputs:
  - name: claude_md
    type: markdown
    description: Generated CLAUDE.md content
  - name: dna_report
    type: json
    description: Full extraction report with confidence scores
---

# DNA Extractor Orchestrator

Coordinate multi-phase extraction based on the selected level.

## Inputs

- `{{repo_path}}` - Repository to analyze
- `{{level}}` - Extraction level: `snapshot`, `skeleton`, `standard`, `comprehensive`
- `{{output}}` - Output destination (optional)

## Level Configuration

### Level Mapping

| Level | Scouts | Specialists | Synthesis |
|-------|--------|-------------|-----------|
| `snapshot` | structure | none | minimal |
| `skeleton` | structure, config, entry_points | conventions | standard |
| `standard` | all | core (no security/infra) | full |
| `comprehensive` | all + extended | all | full + negative space |

### Level Details

#### `snapshot` (~2 minutes)
```yaml
phase1:
  - structure-scout
phase2: []
phase3:
  - dna-renderer (minimal mode)
```
**Output**: Languages, frameworks, basic structure

#### `skeleton` (~3-10 minutes)
```yaml
phase1:
  - structure-scout
  - config-scout
  - entry-point-scout
phase2:
  - convention-extractor
phase3:
  - conflict-resolver
  - dna-renderer
```
**Output**: + Entry points, dependencies, basic conventions

#### `standard` (~10-15 minutes) - Default
```yaml
phase1:
  - structure-scout
  - config-scout
  - entry-point-scout
  - schema-scout
phase2:
  - convention-extractor
  - domain-modeler
  - api-extractor
  - test-analyst
phase3:
  - conflict-resolver
  - confidence-scorer
  - dna-renderer
```
**Output**: Complete extraction for typical projects

#### `comprehensive` (~15+ minutes)
```yaml
phase1:
  - structure-scout (extended)
  - config-scout (extended)
  - entry-point-scout (extended)
  - schema-scout (extended)
phase2:
  - convention-extractor
  - domain-modeler
  - api-extractor
  - test-analyst
  - security-analyst
  - infrastructure-analyst
phase3:
  - conflict-resolver
  - confidence-scorer
  - negative-space-detector
  - dna-renderer (verbose)
```
**Output**: + Security, infrastructure, gaps, git history

## DNA Accumulator

Maintain state throughout extraction:

```json
{
  "meta": {
    "repo_path": "{{repo_path}}",
    "level": "{{level}}",
    "started_at": "<timestamp>",
    "status": "in_progress"
  },
  "phase1": {},
  "phase2": {},
  "phase3": {}
}
```

## Execution Flow

### Step 1: Parse Level

```python
LEVEL_CONFIG = {
    "snapshot": {
        "scouts": ["structure"],
        "specialists": [],
        "synthesis": ["dna-renderer"],
        "extended": False
    },
    "skeleton": {
        "scouts": ["structure", "config", "entry-points"],
        "specialists": ["conventions"],
        "synthesis": ["conflict-resolver", "dna-renderer"],
        "extended": False
    },
    "standard": {
        "scouts": ["structure", "config", "entry-points", "schema"],
        "specialists": ["conventions", "domain", "api", "tests"],
        "synthesis": ["conflict-resolver", "confidence-scorer", "dna-renderer"],
        "extended": False
    },
    "comprehensive": {
        "scouts": ["structure", "config", "entry-points", "schema"],
        "specialists": ["conventions", "domain", "api", "tests", "security", "infrastructure"],
        "synthesis": ["conflict-resolver", "confidence-scorer", "negative-space", "dna-renderer"],
        "extended": True
    }
}
```

### Step 2: Phase 1 - Scouts (Parallel)

Spawn all scouts for the level in parallel:

```
For each scout in config.scouts:
  spawn: prompts/phase1/{scout}-scout.md
    repo_path: {{repo_path}}
    extended: config.extended
```

Wait for all scouts to complete. Store results in `accumulator.phase1`.

### Step 3: Phase 2 - Specialists (Parallel)

Spawn specialists based on level and Phase 1 findings:

```
For each specialist in config.specialists:
  spawn: prompts/phase2/{specialist}.md
    repo_path: {{repo_path}}
    phase1: accumulator.phase1
```

Wait for all specialists to complete. Store results in `accumulator.phase2`.

### Step 4: Phase 3 - Synthesis (Sequential)

Run synthesis agents in order:

```
For each agent in config.synthesis:
  run: prompts/phase3/{agent}.md
    phase1: accumulator.phase1
    phase2: accumulator.phase2
    phase3: accumulator.phase3
  store result in accumulator.phase3.{agent}
```

### Step 5: Output

1. Extract final DNA from `accumulator.phase3.dna-renderer`
2. Write to `{{output}}` if specified, else stdout
3. Return full accumulator as report

## Error Handling

### Scout/Specialist Failures

If an agent fails:
1. Mark as `{"status": "error", "message": "..."}`
2. Continue with remaining agents
3. Note gap in final output

### Level Fallback

If level is unrecognized:
1. Log warning
2. Default to `standard`

### Timeout Handling

Estimated timeouts by level:
- `snapshot`: 5 minutes max
- `skeleton`: 20 minutes max
- `standard`: 1 hour max
- `comprehensive`: 4 hours max

If approaching timeout, skip remaining specialists and proceed to synthesis.

## Convergence Check

Before completing, verify:
- [ ] All configured scouts returned data or error
- [ ] All configured specialists completed
- [ ] Synthesis produced output

Report incomplete sections in final output.

## Output Format

Final output follows the DNA template structure:
- Identity section
- Stack section
- Conventions section
- Architecture section
- Capabilities section
- Operations section
- Uncertainties section

See `templates/dna-template.md` for full structure.
