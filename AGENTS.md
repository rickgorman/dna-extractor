# DNA Extractor

Work style: telegraph; noun-phrases ok; drop grammar; min tokens

## Quick Start

```bash
bd ready                    # available work
bd show <id>                # issue details
bd update <id> --status in_progress  # claim
bd close <id>               # complete
```

## Structure

```
skills/dna-extractor.md     # skill entry
prompts/
  orchestrator.md           # coordination
  phase1/                   # scouts (parallel)
    structure-scout.md
    config-scout.md
    entry-point-scout.md
    schema-scout.md
  phase2/                   # specialists (parallel)
    domain-modeler.md
    api-extractor.md
    test-analyst.md
    security-analyst.md
    convention-extractor.md
    infrastructure-analyst.md
    negative-space-detector.md
  phase3/                   # synthesis (sequential)
    conflict-resolver.md
    confidence-scorer.md
    dna-renderer.md
templates/dna-template.md   # output structure
```

## Naming

- Prompts: `<role>-<function>.md` lowercase hyphenated
- Scouts: `<domain>-scout.md`
- Specialists: `<domain>-<action>.md` (actions: extractor|analyst|modeler|detector)
- Synthesis: `<output>-<action>.md`

## Agent Output Format

YAML structured; required fields:

```yaml
agent: structure-scout
phase: 1
timestamp: 2026-01-06T12:00:00Z
findings:
  languages:
    - name: python
      confidence: 0.98
      evidence: ["*.py present", "pyproject.toml"]
confidence:
  overall: 0.95
  sections: {languages: 0.98}
uncertainties: ["SSR vs CSR unclear"]
```

## Confidence Scores

- 0.95-1.0: high; strong evidence
- 0.85-0.94: good; reasonable evidence
- 0.70-0.84: moderate; some evidence
- <0.70: low; flag for review

## DNA Ontology

9 sections: Identity, Domain Model, Capabilities, Architecture, Stack, Conventions, Constraints, Operations, Uncertainties

## Phase Flow

```
Phase 1 (parallel)  =>  Phase 2 (parallel)  =>  Phase 3 (sequential)
scouts                  specialists             synthesis
```

Orchestrator: spawn P1 => accumulate => spawn P2 => accumulate => run P3 sequential => output DNA

## Extraction Levels

| Level | Time | Scope |
|-------|------|-------|
| snapshot | ~2m | lang/framework/structure |
| skeleton | ~10m | +entry points, core entities |
| standard | ~30m | full (default) |
| comprehensive | ~2h | +negative space, git history |

Usage: `/dna-extractor /path --level=skeleton`

## Prompt Structure

```markdown
# Agent Name

## Role
One sentence.

## Inputs
- context/data received
- expected format

## Process
1. steps
2. what to look for
3. edge cases

## Output
YAML structure + examples

## Confidence Guidelines
high/medium/low criteria
```

## Session Completion

MANDATORY before done:

1. File remaining work => `bd create`
2. Quality gates (if code) => tests/lint/build
3. Update issues => `bd close`
4. Push:
   ```bash
   git pull --rebase && bd sync && git push
   git status  # must show "up to date"
   ```
5. Handoff context

Rules:
- NOT done until `git push` succeeds
- Never stop before pushing
- If push fails => resolve + retry

## Issue Format

- Naming: `DNA-<n>: <description>`
- DoD required: functionality, YAML output, confidence thresholds, edge cases

## Git Workflow

1. Branch: `polecat/<issue-slug>`
2. Implement
3. `bd close <id>`
4. `bd sync && git commit`
5. `gt done`
