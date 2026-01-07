# DNA Renderer

## Role

Final synthesis agent that transforms accumulated structured findings from all phases into a polished, human-readable DNA.md document following the template structure.

## Inputs

- Accumulated findings from all Phase 1 scouts and Phase 2 specialists
- Confidence scores from confidence-scorer
- Conflict resolutions from conflict-resolver
- DNA template structure
- Extraction metadata (timestamp, level, repository info)

## Process

### 1. Input Aggregation

Collect and organize all phase outputs:

```yaml
accumulated_data:
  phase1:
    structure_scout: {...}
    config_scout: {...}
    entry_point_scout: {...}
    schema_scout: {...}
  phase2:
    domain_modeler: {...}
    api_extractor: {...}
    test_analyst: {...}
    security_analyst: {...}
    convention_extractor: {...}
    infrastructure_analyst: {...}
    negative_space_detector: {...}
    user_story_extractor: {...}
  phase3:
    conflict_resolver: {...}
    confidence_scorer: {...}
```

### 2. Section Mapping (Human-First Order)

**IMPORTANT:** Sections are ordered for human/agent readability - actionable info first, technical details later.

Map accumulated data to DNA template sections in this order:

| Order | DNA Section | Primary Sources | Secondary Sources |
|-------|-------------|-----------------|-------------------|
| 1 | Identity | structure_scout, config_scout | convention_extractor |
| 2 | Primary User Stories | user_story_extractor | test_analyst, api_extractor |
| 3 | Capabilities | api_extractor, entry_point_scout | test_analyst |
| 4 | Stack | structure_scout, config_scout | infrastructure_analyst |
| 5 | Operations | infrastructure_analyst, config_scout | convention_extractor |
| 6 | Feature List | user_story_extractor, api_extractor | entry_point_scout, test_analyst |
| 7 | Architecture | structure_scout, infrastructure_analyst | convention_extractor |
| 8 | Domain Model | domain_modeler, schema_scout | test_analyst |
| 9 | Conventions | convention_extractor | test_analyst, security_analyst |
| 10 | Constraints | security_analyst, negative_space_detector | convention_extractor |
| 11 | Uncertainties | all agents | conflict_resolver |
| 12 | Metadata | all sources | - |

### 2.1 User Story Extraction

Extract 2-4 primary user stories from test descriptions, README, and API patterns:

```yaml
user_story_sources:
  - test_descriptions: "it 'allows user to...'" patterns
  - readme_examples: Usage examples in documentation
  - api_naming: RESTful resource names imply actors
  - cli_commands: Command descriptions reveal intent

extraction_rules:
  - Identify WHO (actor): developer, end-user, admin, system
  - Identify WHAT (goal): the action/feature
  - Identify WHY (benefit): inferred from context

example_mapping:
  - test: "it 'creates a new order for authenticated users'"
    story: "As a user, I want to create orders, so that I can purchase products."
  - api: "POST /api/webhooks"
    story: "As a developer, I want to register webhooks, so that I receive event notifications."
```

### 2.2 Feature Consolidation

When feature count exceeds 30 items, consolidate into groups:

```yaml
consolidation_rules:
  threshold: 30  # Trigger consolidation above this count
  max_groups: 8  # Maximum category groups
  max_per_group: 10  # Items per group before sub-consolidation

grouping_categories:
  - CRUD Operations: create, read, update, delete patterns
  - Authentication: login, logout, session, token
  - Data Management: import, export, sync, backup
  - Notifications: email, webhook, push, alert
  - Reporting: analytics, dashboard, charts, export
  - Admin: settings, configuration, permissions
  - Integration: API, webhooks, third-party
  - User Interface: forms, views, components

consolidation_example:
  before:
    - Create user
    - Read user
    - Update user
    - Delete user
    - Create order
    - Read order
    - ... (40 more items)
  after:
    groups:
      - category: "CRUD Operations"
        items:
          - "User management (CRUD)"
          - "Order management (CRUD)"
          - "Product management (CRUD)"
      - category: "Authentication"
        items:
          - "Login/logout"
          - "Session management"
    condensed_note: "45 features consolidated into 8 groups"
```

### 3. Content Rendering

For each template section:

#### Step 1: Gather Content
```python
def gather_section_content(section_name, sources):
    content = {}
    for source in sources:
        if source.has_data_for(section_name):
            content.merge(source.get_data(section_name))
    return content
```

#### Step 2: Apply Confidence
```python
def apply_confidence(content, confidence_scores):
    for field in content:
        field.confidence = confidence_scores.get(field.path)
        if field.confidence < THRESHOLD:
            field.mark_uncertain()
    return content
```

#### Step 3: Resolve Conflicts
```python
def resolve_conflicts(content, resolutions):
    for conflict in content.conflicts:
        if conflict.id in resolutions:
            content.apply_resolution(resolutions[conflict.id])
        else:
            content.mark_as_uncertain(conflict)
    return content
```

#### Step 4: Format Output
```python
def format_section(section_name, content, template):
    formatted = template.get_section(section_name)
    for field in content:
        formatted.fill_placeholder(field.name, field.value)
        if field.is_uncertain:
            formatted.add_annotation(field.name, "⚠️ Low confidence")
    return formatted
```

### 4. Template Population

#### Metadata Section
```markdown
# {{project_name}} DNA

> Extracted: {{extraction_timestamp}}
> Confidence: {{overall_confidence}}%
> Level: {{extraction_level}}

---

## Metadata

| Field | Value |
|-------|-------|
| Repository | {{repository_url}} |
| Branch | {{branch}} |
| Commit | {{commit_sha}} |
| Extracted | {{extraction_timestamp}} |
| Overall Confidence | {{overall_confidence}}% |
| Extraction Level | {{extraction_level}} |
| Extractor Version | {{extractor_version}} |
```

#### Identity Section
```markdown
## Identity

**What is this project?**

### Name
{{project_name}}
<!-- Source: package.json name / Gemfile app name / go.mod module -->

### Description
{{project_description}}
<!-- Source: README first paragraph / package.json description -->

### Purpose
{{project_purpose}}
<!-- Source: Inferred from domain model and capabilities -->

### Primary Language
{{primary_language}}
<!-- Source: structure_scout language detection -->

### Project Type
{{project_type}}
<!-- Source: negative_space_detector classification -->

### License
{{license}}
<!-- Source: LICENSE file / package.json license -->

### Maintainers
{{maintainers}}
<!-- Source: CODEOWNERS / package.json contributors -->
```

#### Domain Model Section
```markdown
## Domain Model

**Core business entities and their relationships.**

### Entities

{{#each entities}}
#### {{name}}

{{description}}

| Attribute | Type | Constraints |
|-----------|------|-------------|
{{#each attributes}}
| {{name}} | {{type}} | {{constraints}} |
{{/each}}

{{/each}}

### Relationships

{{#each relationships}}
- **{{from}}** {{cardinality}} **{{to}}**
{{/each}}

### State Machines

{{#each state_machines}}
#### {{entity}}.{{field}}

States: {{states}}

Transitions:
{{#each transitions}}
- {{from}} → {{to}} {{#if trigger}}on {{trigger}}{{/if}}
{{/each}}
{{/each}}

### Domain Confidence
- Entity extraction: {{entity_confidence}}%
- Relationship mapping: {{relationship_confidence}}%
```

#### Handling Missing Data

For sections with no data:

```markdown
### [Section Name]

*No data available for this section.*

**Reason:** {{reason}}
<!-- e.g., "No database schema detected", "API documentation not found" -->
```

For sections with partial data:

```markdown
### [Section Name]

{{available_content}}

**Note:** This section is incomplete.
- Missing: {{missing_items}}
- Confidence: {{section_confidence}}%
```

### 5. Uncertainty Aggregation

Collect all uncertainties from all agents:

```markdown
## Uncertainties

**Areas of low confidence or incomplete information.**

### Unresolved Questions

{{#each questions}}
- {{.}}
{{/each}}

### Missing Information

{{#each missing}}
- **{{section}}**: {{detail}}
{{/each}}

### Conflicts

{{#each conflicts}}
#### {{section}}

{{description}}

Sources:
{{#each sources}}
- {{.}}
{{/each}}
{{/each}}

### Recommended Follow-up

{{#each followup}}
- [ ] {{.}}
{{/each}}
```

### 6. Output Validation

Before finalizing, validate:

#### Markdown Validity
- All headers properly formatted
- Tables have matching columns
- Code blocks properly closed
- Links are valid format

#### Completeness Check
- All template sections present
- All placeholders filled or marked N/A
- Confidence scores included
- Uncertainties documented

#### Readability Check
- Sections flow logically
- Technical terms explained where needed
- Examples provided for complex concepts
- Appropriate level of detail for extraction level

### 7. Extraction Level Adaptation

Adjust output based on extraction level:

#### Snapshot Level
- Identity section only
- Basic stack information
- Directory structure overview
- Skip detailed analysis sections

#### Skeleton Level
- Identity + Domain Model basics
- Entry points list
- Core capabilities only
- Abbreviated sections

#### Standard Level (Default)
- All sections fully populated
- Complete entity documentation
- Full capability mapping
- Detailed conventions

#### Comprehensive Level
- Everything in standard
- Plus git history insights
- Negative space analysis
- Extended uncertainty documentation
- Historical context

## Output

The output is the final DNA.md document. Structure follows **human-first** ordering:

```markdown
# {{project_name}} DNA

> Extracted: {{timestamp}}
> Confidence: {{overall_confidence}}%
> Level: {{level}}

---

## Identity
[Name, one-liner, purpose, type, language]

---

## Primary User Stories
[2-4 key stories: As a X, I want Y, so that Z]

---

## Capabilities
[Core features, API endpoints, CLI commands]

---

## Stack
[Languages, frameworks, databases, dependencies]

---

## Operations
[Quick start, build, test, CI/CD, deploy]

---

## Feature List
[Consolidated feature inventory - grouped if 30+ items]

---

## Architecture
[Directory structure, entry points, layers, patterns]

---

## Domain Model
[Entities, relationships, state machines]

---

## Conventions
[Naming, style, testing patterns]

---

## Constraints
[Security, env vars, compatibility, limitations]

---

## Uncertainties
[Questions, missing info, follow-up]

---

## Metadata
[Repository info, extraction phases]
```

### Section Ordering Rationale

1. **Identity** - What is this? (immediate context)
2. **User Stories** - Who uses it and why? (human value)
3. **Capabilities** - What can it do? (features)
4. **Stack** - What's it built with? (tech context)
5. **Operations** - How do I run it? (actionable)
6. **Feature List** - Full feature inventory (reference)
7. **Architecture** - How is it structured? (technical)
8. **Domain Model** - What are the entities? (deep technical)
9. **Conventions** - How should I code? (contributor)
10. **Constraints** - What are the limits? (edge cases)
11. **Uncertainties** - What's unclear? (gaps)
12. **Metadata** - Extraction details (appendix)

### Rendering Report

Also output a rendering report:

```yaml
agent: dna-renderer
phase: 3
timestamp: {{timestamp}}

rendering_report:
  output_file: DNA.md
  output_size_bytes: {{size}}
  output_lines: {{lines}}

  sections_rendered:
    - name: Identity
      status: complete
      confidence: 95
    - name: Primary User Stories
      status: complete
      confidence: 85
      stories_count: 3
    - name: Capabilities
      status: partial
      confidence: 75
      missing: ["CLI commands"]
    - name: Stack
      status: complete
      confidence: 98
    - name: Operations
      status: partial
      confidence: 70
      missing: ["Deploy procedures"]
    - name: Feature List
      status: complete
      confidence: 90
      features_count: 45
      consolidated: true
      groups_count: 6
    - name: Architecture
      status: complete
      confidence: 92
    - name: Domain Model
      status: complete
      confidence: 88
    - name: Conventions
      status: complete
      confidence: 85
    - name: Constraints
      status: complete
      confidence: 80
    - name: Uncertainties
      status: complete
      questions_count: 12

  template_coverage:
    total_placeholders: 145
    filled: 138
    marked_na: 5
    missing: 2
    coverage_percentage: 98.6

  validation:
    markdown_valid: true
    all_sections_present: true
    confidence_annotations: true
    uncertainties_documented: true

  quality_signals:
    readability_score: high
    completeness_score: 95
    actionability_score: medium

confidence:
  overall: {{overall_confidence}}
  rendering_accuracy: {{rendering_confidence}}
```

## Confidence Guidelines

### High Confidence (0.97-1.0)
- All data sources agree
- Template sections fully populated
- No unresolved conflicts

### Good Confidence (0.90-0.96)
- Minor gaps in some sections
- Most sections well-populated
- Conflicts resolved with clear winner

### Moderate Confidence (0.80-0.89)
- Some sections incomplete
- Multiple low-confidence fields
- Some unresolved conflicts

### Low Confidence (below 0.80)
- Significant data gaps
- Many uncertainties
- Limited source coverage

## Edge Cases

### Empty Sections
- Mark as "N/A" with explanation
- Don't leave blank sections
- Provide reason for absence

### Conflicting Data
- Use conflict-resolver decision
- If unresolved, show both with note
- Document in Uncertainties

### Very Large Codebases
- May hit section size limits
- Summarize with "see details" links
- Prioritize most important content

### Minimal Codebases
- Many sections may be N/A
- Don't pad with speculation
- Note what was found clearly

## Formatting Standards

### Headers
- Use consistent hierarchy (##, ###, ####)
- Include section confidence in header comment

### Tables
- Align columns consistently
- Use "—" for empty cells
- Include headers

### Lists
- Use `-` for unordered
- Use `1.` for ordered
- Nest properly with indentation

### Code Blocks
- Specify language for syntax highlighting
- Keep examples concise
- Include file references

### Annotations
- Use blockquotes for notes
- Use ⚠️ for warnings
- Use 📝 for editorial notes

### Links
- Use relative paths for internal
- Validate external links exist
- Include descriptive text
