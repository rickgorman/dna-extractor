# Confidence Scorer

## Role

Annotate all DNA findings with certainty levels, count corroboration across sources, calculate confidence scores, and document provenance for each finding.

## Inputs

- **Accumulated findings**: All Phase 1 and Phase 2 agent outputs
- **Resolved conflicts**: Output from conflict-resolver agent
- **Repository path**: For provenance verification

## Process

### 1. Certainty Classification

Assign one of four certainty classes to each finding:

| Class | Definition | Criteria | Score Range |
|-------|------------|----------|-------------|
| `certain` | Definitive evidence | Explicit declaration, multiple corroborating sources | 0.95-1.00 |
| `inferred` | Strong evidence | Derived from patterns, single authoritative source | 0.80-0.94 |
| `speculated` | Weak evidence | Based on conventions, naming patterns, or defaults | 0.60-0.79 |
| `unknown` | Insufficient evidence | No clear evidence, requires manual verification | 0.00-0.59 |

#### Certainty Rules by Finding Type

**Language Detection:**
```yaml
certain:
  - File extension matches language (*.py → Python)
  - Language-specific config present (tsconfig.json → TypeScript)
  - Multiple corroborating signals

inferred:
  - Single file type detected
  - Language in comments/shebang

speculated:
  - File extension ambiguous (*.h could be C or C++)
  - Mixed signals
```

**Framework Detection:**
```yaml
certain:
  - Framework config file present (next.config.js)
  - Framework in dependencies with version
  - Framework-specific directory structure

inferred:
  - Framework in dependencies without config
  - Import statements reference framework

speculated:
  - Naming patterns suggest framework
  - Partial directory structure match
```

**Entity/Model Detection:**
```yaml
certain:
  - Explicit model class definition
  - Schema file with table definition
  - Migration files present

inferred:
  - Class inherits from base model
  - Attributes declared but no schema

speculated:
  - PORO with database-like attributes
  - Referenced in relationships but not defined
```

**Relationship Detection:**
```yaml
certain:
  - Explicit association declaration (has_many, belongs_to)
  - Foreign key in schema
  - Join table present

inferred:
  - Column naming follows FK conventions (*_id)
  - Query patterns suggest relationship

speculated:
  - Variable naming suggests relationship
  - No explicit declaration found
```

### 2. Corroboration Counting

Track how many independent sources support each finding:

**Source Types:**
| Source | Weight | Examples |
|--------|--------|----------|
| Config file | 1.0 | package.json, tsconfig.json |
| Schema/Migration | 1.0 | schema.rb, migrations/*.py |
| Source code | 0.8 | Model definitions, imports |
| Documentation | 0.5 | README, inline comments |
| Naming convention | 0.3 | File/folder names |
| Default assumption | 0.1 | Framework conventions |

**Corroboration Score:**
```
corroboration_score = sum(source_weights) / max_possible_score

where max_possible_score varies by finding type:
- Language: 3.0 (config + source + naming)
- Framework: 4.0 (config + deps + source + structure)
- Entity: 3.0 (model + schema + migration)
- Relationship: 2.5 (declaration + schema + code)
```

**Output format:**
```yaml
finding:
  type: framework
  value: next.js
  certainty: certain
  corroboration:
    score: 0.95
    sources:
      - type: config_file
        file: next.config.js
        line: 1
        weight: 1.0
      - type: dependencies
        file: package.json
        line: 15
        weight: 1.0
        evidence: '"next": "14.0.0"'
      - type: directory_structure
        path: pages/
        weight: 0.8
      - type: source_code
        file: pages/_app.tsx
        line: 1
        weight: 0.8
        evidence: "import { AppProps } from 'next/app'"
```

### 3. Per-Section Confidence Calculation

Calculate confidence for each DNA section:

**Section Confidence Formula:**
```
section_confidence = (
  sum(finding_certainty * finding_corroboration) /
  count(findings)
) * coverage_factor

where:
  coverage_factor = min(1.0, findings_found / expected_findings)
```

**Expected Findings by Section:**

| Section | Expected Findings | Minimum for Full Coverage |
|---------|-------------------|---------------------------|
| Identity | 5 | name, description, language, type, license |
| Domain Model | varies | At least 1 entity or "no domain model" |
| Capabilities | varies | At least 1 feature/endpoint |
| Architecture | 4 | structure, entry_points, layers, patterns |
| Stack | 3 | language, framework, dependencies |
| Conventions | 3 | naming, file_org, style |
| Constraints | 2 | security, compatibility |
| Operations | 4 | build, test, deploy, dev |
| Uncertainties | n/a | Always 1.0 (meta-section) |

**Section Scoring Example:**
```yaml
section: domain_model
findings:
  - type: entity
    value: User
    certainty_score: 0.98
    corroboration_score: 0.95
    weighted_score: 0.931  # 0.98 * 0.95

  - type: entity
    value: Post
    certainty_score: 0.95
    corroboration_score: 0.90
    weighted_score: 0.855

  - type: relationship
    value: User has_many Posts
    certainty_score: 0.92
    corroboration_score: 0.85
    weighted_score: 0.782

average_weighted: 0.856  # (0.931 + 0.855 + 0.782) / 3
coverage_factor: 1.0     # Meets minimum expected
section_confidence: 0.856
```

### 4. Overall DNA Confidence Score

Calculate the final DNA confidence:

**Weighted Section Importance:**
| Section | Weight | Rationale |
|---------|--------|-----------|
| Identity | 0.15 | Foundational but often incomplete |
| Stack | 0.20 | Critical for understanding codebase |
| Architecture | 0.15 | Important structural information |
| Domain Model | 0.15 | Core business logic |
| Capabilities | 0.10 | Feature inventory |
| Conventions | 0.10 | Development patterns |
| Operations | 0.10 | Deployment information |
| Constraints | 0.05 | Often implicit |

**Overall Formula:**
```
overall_confidence = sum(section_confidence * section_weight)

Adjustments:
- If any critical section < 0.5: overall *= 0.9
- If uncertainty_count > 10: overall *= 0.95
- If conflict_count > 5: overall *= 0.9
```

**Confidence Grade:**
| Score | Grade | Interpretation |
|-------|-------|----------------|
| 0.90-1.00 | A | High quality extraction |
| 0.80-0.89 | B | Good extraction, minor gaps |
| 0.70-0.79 | C | Adequate, some uncertainties |
| 0.60-0.69 | D | Significant gaps |
| < 0.60 | F | Poor extraction, needs review |

### 5. Provenance Documentation

Record the source location for every finding:

**Provenance Format:**
```yaml
provenance:
  file: src/models/user.rb
  line: 15
  column: 3
  snippet: "has_many :posts"
  extracted_by: domain-modeler
  extraction_timestamp: "2026-01-06T12:00:00Z"
```

**Multi-Source Provenance:**
```yaml
provenance:
  primary:
    file: app/models/user.rb
    line: 1
    snippet: "class User < ApplicationRecord"
  supporting:
    - file: db/schema.rb
      line: 45
      snippet: 'create_table "users"'
    - file: spec/models/user_spec.rb
      line: 3
      snippet: "RSpec.describe User"
```

**Provenance Verification:**
- Verify file exists at stated path
- Verify line contains expected content
- Flag stale provenance if content has changed

### 6. Quality Metrics

Track extraction quality indicators:

```yaml
quality_metrics:
  total_findings: 47
  certain_count: 28
  inferred_count: 15
  speculated_count: 3
  unknown_count: 1

  certainty_distribution:
    certain: 0.60
    inferred: 0.32
    speculated: 0.06
    unknown: 0.02

  average_corroboration: 0.82

  coverage:
    sections_complete: 8
    sections_partial: 1
    sections_empty: 0

  provenance:
    verified: 45
    unverified: 2
    stale: 0
```

### 7. Edge Cases

**Sparse Codebases:**
- Lower coverage expectations
- Weight corroboration higher
- Flag as "minimal codebase"

**Generated Code:**
- Lower confidence for generated sections
- Note generation source in provenance

**Conflicting Evidence:**
- Use conflict-resolver output
- Note resolution in provenance
- Lower confidence if unresolved

**Missing Sections:**
- Don't penalize for legitimately absent sections
- Mark as "N/A" with explanation
- Full confidence for documented absence

## Output

```yaml
agent: confidence-scorer
phase: 3
timestamp: "{{timestamp}}"

findings:
  sections:
    identity:
      confidence: 0.95
      grade: A
      findings:
        - type: project_name
          value: "my-app"
          certainty: certain
          certainty_score: 0.98
          corroboration:
            score: 0.95
            count: 3
            sources:
              - type: config_file
                file: package.json
                line: 2
                field: name
                weight: 1.0
              - type: documentation
                file: README.md
                line: 1
                weight: 0.5
              - type: config_file
                file: docker-compose.yml
                line: 5
                weight: 0.8
          provenance:
            primary:
              file: package.json
              line: 2
              snippet: '"name": "my-app"'
            extracted_by: structure-scout

        - type: primary_language
          value: typescript
          certainty: certain
          certainty_score: 0.98
          corroboration:
            score: 0.98
            count: 4
            sources:
              - type: config_file
                file: tsconfig.json
                weight: 1.0
              - type: file_extensions
                pattern: "*.ts, *.tsx"
                count: 156
                weight: 0.8
              - type: dependencies
                file: package.json
                evidence: "typescript: ^5.0"
                weight: 1.0
              - type: source_code
                count: 156
                weight: 0.8
          provenance:
            primary:
              file: tsconfig.json
              line: 1

    domain_model:
      confidence: 0.88
      grade: B
      findings:
        - type: entity
          value: User
          certainty: certain
          certainty_score: 0.95
          corroboration:
            score: 0.92
            count: 3
          provenance:
            primary:
              file: src/models/user.ts
              line: 5
              snippet: "export class User {"
            supporting:
              - file: prisma/schema.prisma
                line: 12
                snippet: "model User {"
          attributes:
            - name: id
              certainty: certain
            - name: email
              certainty: certain
            - name: name
              certainty: certain

        - type: relationship
          value: "User has_many Posts"
          certainty: inferred
          certainty_score: 0.85
          corroboration:
            score: 0.75
            count: 2
          provenance:
            primary:
              file: prisma/schema.prisma
              line: 18
              snippet: "posts Post[]"

    stack:
      confidence: 0.96
      grade: A
      # ... additional findings

    architecture:
      confidence: 0.82
      grade: B
      # ... additional findings

    capabilities:
      confidence: 0.78
      grade: C
      # ... additional findings

    conventions:
      confidence: 0.85
      grade: B
      # ... additional findings

    constraints:
      confidence: 0.70
      grade: C
      # ... additional findings

    operations:
      confidence: 0.90
      grade: A
      # ... additional findings

  overall:
    confidence: 0.87
    grade: B
    interpretation: "Good extraction with minor gaps in capabilities and constraints"

    quality_metrics:
      total_findings: 47
      certainty_distribution:
        certain: 28
        inferred: 15
        speculated: 3
        unknown: 1
      average_corroboration: 0.82
      provenance_verified: 45

    adjustments_applied:
      - reason: "No critical sections below 0.5"
        factor: 1.0
      - reason: "Uncertainty count (7) within threshold"
        factor: 1.0
      - reason: "Conflict count (2) within threshold"
        factor: 1.0

  low_confidence_findings:
    - section: capabilities
      finding: "API rate limiting"
      certainty: speculated
      score: 0.65
      reason: "Only mentioned in README, no code evidence"

    - section: constraints
      finding: "PostgreSQL 14+ required"
      certainty: inferred
      score: 0.72
      reason: "Version from docker-compose, not documented"

  recommendations:
    - "Verify API rate limiting implementation"
    - "Confirm database version requirements"
    - "Add missing capability documentation"

confidence:
  overall: 0.95
  sections:
    certainty_classification: 0.98
    corroboration_counting: 0.95
    score_calculation: 0.95
    provenance_documentation: 0.92

uncertainties:
  - "Some provenance links may be stale if code changed during extraction"
  - "Custom validation logic not fully analyzed for certainty"
```

## Confidence Guidelines

### Scoring Consistency (target: ≥95%)
- **High (≥0.95)**: Deterministic rules applied consistently
- **Good (0.85-0.94)**: Minor edge cases with judgment calls
- **Moderate (0.70-0.84)**: Some inconsistent classifications
- **Low (<0.70)**: Significant scoring inconsistencies

### Provenance Accuracy (target: ≥90%)
- **High (≥0.95)**: All provenance verified, exact line numbers
- **Good (0.85-0.94)**: Most provenance verified, some approximate
- **Moderate (0.70-0.84)**: File-level provenance only
- **Low (<0.70)**: Many unverified sources

### Score Quality (target: ≥85%)
- **High (≥0.95)**: Scores accurately reflect extraction quality
- **Good (0.85-0.94)**: Minor calibration issues
- **Moderate (0.70-0.84)**: Some sections over/under-scored
- **Low (<0.70)**: Scores don't reflect actual quality

## Error Handling

- **Missing agent output**: Mark section as incomplete, reduce confidence
- **Invalid provenance**: Flag for review, don't include in corroboration
- **Circular corroboration**: Deduplicate sources, count once
- **Conflicting certainty**: Use lower certainty class
