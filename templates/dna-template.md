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

---

## Identity

**What is this project?**

### Name
{{project_name}}

### Description
{{project_description}}

### Purpose
{{project_purpose}}

### Primary Language
{{primary_language}}

### Project Type
{{project_type}}
<!-- e.g., library, web-app, cli-tool, api-service, monorepo -->

### License
{{license}}

### Maintainers
{{maintainers}}

---

## Domain Model

**Core business entities and their relationships.**

### Entities

{{#each entities}}
#### {{name}}

| Attribute | Type | Constraints |
|-----------|------|-------------|
{{#each attributes}}
| {{name}} | {{type}} | {{constraints}} |
{{/each}}

{{/each}}

<!-- If no entities detected -->
{{#if no_entities}}
*No domain entities detected. This may be a utility library or infrastructure project.*
{{/if}}

### Relationships

{{#each relationships}}
- **{{from}}** {{cardinality}} **{{to}}** {{#if via}}(via {{via}}){{/if}}
{{/each}}

### State Machines

{{#each state_machines}}
#### {{entity}}.{{field}}

States: {{states}}

Transitions:
{{#each transitions}}
- {{from}} -> {{to}} {{#if trigger}}on {{trigger}}{{/if}}
{{/each}}

{{/each}}

### Invariants

{{#each invariants}}
- {{description}} `[{{entity}}]`
{{/each}}

### Domain Confidence
- Entity extraction: {{entity_confidence}}%
- Relationship mapping: {{relationship_confidence}}%
- State machine detection: {{state_machine_confidence}}%

---

## Capabilities

**What can this system do?**

### Core Features

{{#each features}}
- **{{name}}**: {{description}}
{{/each}}

### API Endpoints

{{#each endpoints}}
#### {{method}} {{path}}

{{description}}

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
{{#each params}}
| {{name}} | {{type}} | {{required}} | {{description}} |
{{/each}}

{{/each}}

### CLI Commands

{{#each commands}}
- `{{name}}` - {{description}}
{{/each}}

### Events/Hooks

{{#each events}}
- **{{name}}**: {{description}}
{{/each}}

### Capabilities Confidence
- Feature detection: {{feature_confidence}}%
- API coverage: {{api_confidence}}%

---

## Architecture

**How is this system structured?**

### Directory Structure

```
{{directory_tree}}
```

### Key Paths

| Path | Purpose |
|------|---------|
{{#each key_paths}}
| {{path}} | {{purpose}} |
{{/each}}

### Entry Points

{{#each entry_points}}
- **{{file}}**: {{purpose}}
{{/each}}

### Layers

{{#each layers}}
#### {{name}}
{{description}}

Key files:
{{#each files}}
- {{.}}
{{/each}}

{{/each}}

### Data Flow

{{data_flow_description}}

### Architecture Patterns

{{#each patterns}}
- **{{name}}**: {{description}}
{{/each}}

### Architecture Confidence
- Structure mapping: {{structure_confidence}}%
- Pattern detection: {{pattern_confidence}}%

---

## Stack

**Technologies and dependencies.**

### Languages

| Language | Version | Purpose |
|----------|---------|---------|
{{#each languages}}
| {{name}} | {{version}} | {{purpose}} |
{{/each}}

### Frameworks

| Framework | Version | Purpose |
|-----------|---------|---------|
{{#each frameworks}}
| {{name}} | {{version}} | {{purpose}} |
{{/each}}

### Databases

{{#each databases}}
- **{{name}}** ({{type}}): {{purpose}}
{{/each}}

### External Services

{{#each services}}
- **{{name}}**: {{description}}
{{/each}}

### Key Dependencies

| Dependency | Version | Purpose |
|------------|---------|---------|
{{#each dependencies}}
| {{name}} | {{version}} | {{purpose}} |
{{/each}}

### Stack Confidence
- Language detection: {{language_confidence}}%
- Framework detection: {{framework_confidence}}%
- Dependency analysis: {{dependency_confidence}}%

---

## Conventions

**Coding standards and patterns.**

### Naming Conventions

| Element | Pattern | Example |
|---------|---------|---------|
{{#each naming}}
| {{element}} | {{pattern}} | {{example}} |
{{/each}}

### File Organization

{{file_organization}}

### Code Style

{{#each style_rules}}
- {{.}}
{{/each}}

### Documentation Patterns

{{#each doc_patterns}}
- **{{type}}**: {{pattern}}
{{/each}}

### Testing Patterns

| Type | Location | Pattern |
|------|----------|---------|
{{#each test_patterns}}
| {{type}} | {{location}} | {{pattern}} |
{{/each}}

### Conventions Confidence
- Naming patterns: {{naming_confidence}}%
- Style detection: {{style_confidence}}%

---

## Constraints

**Limitations, requirements, and security considerations.**

### Security

{{#each security}}
- **{{category}}**: {{description}}
{{/each}}

### Performance

{{#each performance}}
- {{description}}
{{/each}}

### Compatibility

| Requirement | Value |
|-------------|-------|
{{#each compatibility}}
| {{name}} | {{value}} |
{{/each}}

### Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
{{#each env_vars}}
| {{name}} | {{required}} | {{description}} |
{{/each}}

### Known Limitations

{{#each limitations}}
- {{.}}
{{/each}}

### Constraints Confidence
- Security analysis: {{security_confidence}}%
- Environment detection: {{env_confidence}}%

---

## Operations

**How to run, deploy, and maintain.**

### Local Development

```bash
{{dev_setup}}
```

### Build

```bash
{{build_command}}
```

### Test

```bash
{{test_command}}
```

### Deploy

{{#each deploy_targets}}
#### {{name}}

{{instructions}}

{{/each}}

### Scripts

| Script | Purpose |
|--------|---------|
{{#each scripts}}
| {{name}} | {{purpose}} |
{{/each}}

### CI/CD

{{ci_description}}

### Monitoring

{{#each monitoring}}
- **{{type}}**: {{description}}
{{/each}}

### Operations Confidence
- Setup detection: {{setup_confidence}}%
- Deploy detection: {{deploy_confidence}}%

---

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

---

## Extraction Details

### Phases Completed

| Phase | Status | Confidence |
|-------|--------|------------|
| Phase 1: Reconnaissance | {{phase1_status}} | {{phase1_confidence}}% |
| Phase 2: Deep Analysis | {{phase2_status}} | {{phase2_confidence}}% |
| Phase 3: Synthesis | {{phase3_status}} | {{phase3_confidence}}% |

### Files Analyzed

- Total files: {{files_total}}
- Files processed: {{files_processed}}
- Files skipped: {{files_skipped}}

### Extraction Log

```
{{extraction_log}}
```
