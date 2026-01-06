# DNA Extractor Conventions

Project coding standards for contributors to dna-extractor.

## Directory Structure

```
dna-extractor/
├── skills/                    # Claude Code skill definitions
│   └── dna-extractor.md       # Main skill entry point
├── prompts/                   # Agent prompts
│   ├── orchestrator.md        # Main coordination prompt
│   ├── phase1/                # Scout prompts
│   │   ├── structure-scout.md
│   │   ├── config-scout.md
│   │   ├── entry-point-scout.md
│   │   └── schema-scout.md
│   ├── phase2/                # Specialist prompts
│   │   ├── domain-modeler.md
│   │   ├── api-extractor.md
│   │   ├── test-analyst.md
│   │   ├── security-analyst.md
│   │   ├── convention-extractor.md
│   │   ├── infrastructure-analyst.md
│   │   └── negative-space-detector.md
│   └── phase3/                # Synthesis prompts
│       ├── conflict-resolver.md
│       ├── confidence-scorer.md
│       └── dna-renderer.md
└── templates/                 # Output templates
    └── dna-template.md        # DNA output structure
```

## Prompt File Naming Conventions

### Format
- Use lowercase with hyphens: `<role>-<function>.md` or `<role>.md`
- File extension: `.md` (markdown)
- One prompt per file

### Naming Pattern
- **Scouts** (Phase 1): `<domain>-scout.md`
  - Examples: `structure-scout.md`, `config-scout.md`, `schema-scout.md`
- **Specialists** (Phase 2): `<domain>-<action>.md`
  - Actions: `extractor`, `analyst`, `modeler`, `detector`
  - Examples: `convention-extractor.md`, `test-analyst.md`, `domain-modeler.md`
- **Synthesis** (Phase 3): `<output>-<action>.md`
  - Examples: `conflict-resolver.md`, `confidence-scorer.md`, `dna-renderer.md`
- **Orchestrator**: `orchestrator.md` (root of prompts/)

### Phase Organization
- `prompts/phase1/` - Discovery/exploration agents (scouts)
- `prompts/phase2/` - Domain-specific analysis agents
- `prompts/phase3/` - Aggregation/synthesis agents

## YAML Output Format Conventions

All agent outputs use structured YAML for inter-agent communication.

### General Format
```yaml
# Agent identification
agent: structure-scout
phase: 1
timestamp: 2026-01-06T12:00:00Z

# Findings section
findings:
  languages:
    - name: python
      confidence: 0.98
      evidence:
        - "*.py files present"
        - "pyproject.toml found"
  frameworks:
    - name: fastapi
      confidence: 0.95
      evidence:
        - "fastapi in dependencies"
        - "app.py imports FastAPI"

# Confidence metadata
confidence:
  overall: 0.95
  sections:
    languages: 0.98
    frameworks: 0.95

# Uncertainties
uncertainties:
  - "Unable to determine if React is SSR or CSR"
  - "Multiple Python versions detected"
```

### Required Fields
- `agent`: Name of the agent producing output
- `phase`: Phase number (1, 2, or 3)
- `timestamp`: ISO 8601 timestamp
- `findings`: Structured data organized by category
- `confidence`: Overall and per-section confidence scores (0.0-1.0)
- `uncertainties`: List of unresolved questions or ambiguities

### Confidence Scores
- 0.95-1.0: High confidence, strong evidence
- 0.85-0.94: Good confidence, reasonable evidence
- 0.70-0.84: Moderate confidence, some evidence
- Below 0.70: Low confidence, flag for review

### DNA Ontology Sections
Final DNA output includes these sections:
- **Identity**: Project name, purpose, maturity
- **Domain Model**: Core entities and relationships
- **Capabilities**: What the system does
- **Architecture**: System structure and patterns
- **Stack**: Languages, frameworks, dependencies
- **Conventions**: Coding standards and patterns
- **Constraints**: Limitations and requirements
- **Operations**: Build, test, deploy procedures
- **Uncertainties**: Unresolved questions

## Agent Communication Patterns

### Phase Flow
```
Phase 1 (Parallel)     Phase 2 (Parallel)     Phase 3 (Sequential)
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ structure-scout │    │ domain-modeler  │    │conflict-resolver│
│ config-scout    │───►│ api-extractor   │───►│confidence-scorer│
│ entry-pt-scout  │    │ test-analyst    │    │ dna-renderer    │
│ schema-scout    │    │ security-analyst│    └─────────────────┘
└─────────────────┘    │ convention-ext  │
                       │ infra-analyst   │
                       │ negative-space  │
                       └─────────────────┘
```

### Orchestrator Responsibilities
1. Spawn Phase 1 scouts in parallel
2. Wait for Phase 1 completion, accumulate findings
3. Spawn Phase 2 specialists based on Phase 1 findings
4. Wait for Phase 2 completion, accumulate findings
5. Spawn Phase 3 agents sequentially
6. Track convergence (all sections populated or N/A)
7. Return final DNA output

### Accumulator Pattern
- Orchestrator maintains a DNA accumulator object
- Each agent reads current accumulator state
- Each agent writes structured findings to accumulator
- Conflicts are flagged for Phase 3 resolution

### Agent Independence
- Agents should be stateless between invocations
- All context comes from input parameters
- Agents must not assume previous agent execution order
- Each agent outputs complete, self-contained YAML

## Extraction Levels

| Level | Time | Scope |
|-------|------|-------|
| `snapshot` | ~2 min | Languages, frameworks, structure only |
| `skeleton` | ~10 min | + Entry points, core entities |
| `standard` | ~30 min | Full extraction (default) |
| `comprehensive` | ~2 hrs | + Negative space, git history |

### Level Selection
- Passed via `--level` flag: `/dna-extractor /path/to/repo --level=skeleton`
- Orchestrator adjusts which agents to spawn based on level
- Higher levels include all lower level work

## Contribution Workflow

### Issue Tracking
Use `bd` (beads) for issue management:
```bash
bd ready                        # Find available work
bd show <id>                    # View issue details
bd update <id> --status=in_progress  # Claim work
bd close <id>                   # Complete work
```

### Issue Naming Convention
- Format: `DNA-<number>: <brief description>`
- Examples: `DNA-6: Structure scout`, `DNA-14: Convention extractor`

### Definition of Done Template
Each issue should include:
```markdown
## Definition of Done
- [ ] Primary functionality implemented
- [ ] Outputs structured YAML
- [ ] Confidence thresholds met (specify %)
- [ ] Edge cases handled (specify which)
```

### Git Workflow
1. Create branch from issue: `polecat/<issue-slug>`
2. Implement with tests if applicable
3. Update beads: `bd close <id>`
4. Sync and commit: `bd sync && git commit`
5. Submit for merge: `gt done`

### Pull Request Format
```markdown
## Summary
Brief description of changes

## Testing
How the changes were verified

## Definition of Done
- [x] All checklist items from issue completed
```

## Prompt Authoring Guidelines

### Structure
```markdown
# <Agent Name>

## Role
One-sentence description of what this agent does.

## Inputs
- What context/data this agent receives
- Expected format of inputs

## Process
1. Step-by-step instructions
2. What to look for
3. How to handle edge cases

## Output
Expected YAML structure with examples.

## Confidence Guidelines
When to report high/medium/low confidence.
```

### Best Practices
- Be explicit about evidence requirements
- Include examples of expected output
- Document edge cases and how to handle them
- Specify confidence thresholds
- Keep prompts focused on single responsibility
