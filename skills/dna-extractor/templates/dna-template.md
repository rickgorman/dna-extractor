# {{project_name}} DNA

> Extracted: {{extraction_timestamp}}
> Confidence: {{overall_confidence}}%
> Level: {{extraction_level}}

---

## Identity

**What is this project?**

### Name
{{project_name}}

### One-Liner
{{one_liner}}

### Description
{{project_description}}

### Purpose
{{project_purpose}}

### Primary Language
{{primary_language}}

### Project Type
{{project_type}}
<!-- e.g., library, web-app, cli-tool, api-service, monorepo -->

---

## Primary User Stories

**Who uses this and why?**

{{#each user_stories}}
- **As a** {{actor}}, **I want** {{goal}}, **so that** {{benefit}}.
{{/each}}

{{#if no_user_stories}}
*User stories not detected. See Feature List for capabilities.*
{{/if}}

---

## Capabilities

**What can this system do?**

### Core Features

{{#each features}}
- **{{name}}**: {{description}}
{{/each}}

### API Endpoints

{{#if endpoints}}
| Method | Path | Description |
|--------|------|-------------|
{{#each endpoints}}
| {{method}} | `{{path}}` | {{description}} |
{{/each}}
{{/if}}

{{#if no_endpoints}}
*No API endpoints detected.*
{{/if}}

### CLI Commands

{{#each commands}}
- `{{name}}` - {{description}}
{{/each}}

{{#if no_commands}}
*No CLI commands detected.*
{{/if}}

### Events/Hooks

{{#each events}}
- **{{name}}**: {{description}}
{{/each}}

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

{{#if no_databases}}
*No database detected.*
{{/if}}

### Key Dependencies

| Dependency | Version | Purpose |
|------------|---------|---------|
{{#each dependencies}}
| {{name}} | {{version}} | {{purpose}} |
{{/each}}

---

## Operations

**How to run, build, deploy.**

### Quick Start

```bash
{{quick_start}}
```

### Build

```bash
{{build_command}}
```

### Test

```bash
{{test_command}}
```

### CI/CD

{{ci_description}}

{{#each ci_steps}}
- {{.}}
{{/each}}

### Deploy

{{#each deploy_targets}}
#### {{name}}
{{instructions}}
{{/each}}

### Scripts

| Script | Purpose |
|--------|---------|
{{#each scripts}}
| `{{name}}` | {{purpose}} |
{{/each}}

---

## Feature List

**Consolidated feature inventory.**

{{#if feature_groups}}
{{#each feature_groups}}
### {{category}}
{{#each items}}
- {{.}}
{{/each}}

{{/each}}
{{else}}
{{#each all_features}}
- {{.}}
{{/each}}
{{/if}}

{{#if features_condensed}}
*Note: {{features_condensed_count}} similar features consolidated into groups above.*
{{/if}}

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
| `{{path}}` | {{purpose}} |
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
- `{{.}}`
{{/each}}

{{/each}}

### Data Flow

{{data_flow_description}}

### Architecture Patterns

{{#each patterns}}
- **{{name}}**: {{description}}
{{/each}}

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
- {{from}} → {{to}} {{#if trigger}}on {{trigger}}{{/if}}
{{/each}}

{{/each}}

### Invariants

{{#each invariants}}
- {{description}} `[{{entity}}]`
{{/each}}

---

## Conventions

**Coding standards and patterns.**

### Naming Conventions

| Element | Pattern | Example |
|---------|---------|---------|
{{#each naming}}
| {{element}} | {{pattern}} | `{{example}}` |
{{/each}}

### File Organization

{{file_organization}}

### Code Style

{{#each style_rules}}
- {{.}}
{{/each}}

### Testing Patterns

| Type | Location | Pattern |
|------|----------|---------|
{{#each test_patterns}}
| {{type}} | `{{location}}` | {{pattern}} |
{{/each}}

---

## Constraints

**Limitations, requirements, and security considerations.**

### Security

{{#each security}}
- **{{category}}**: {{description}}
{{/each}}

### Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
{{#each env_vars}}
| `{{name}}` | {{required}} | {{description}} |
{{/each}}

### Compatibility

| Requirement | Value |
|-------------|-------|
{{#each compatibility}}
| {{name}} | {{value}} |
{{/each}}

### Known Limitations

{{#each limitations}}
- {{.}}
{{/each}}

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

### Recommended Follow-up

{{#each followup}}
- [ ] {{.}}
{{/each}}

---

## Metadata

| Field | Value |
|-------|-------|
| Repository | {{repository_url}} |
| Branch | {{branch}} |
| Commit | {{commit_sha}} |
| License | {{license}} |
| Maintainers | {{maintainers}} |
| Extracted | {{extraction_timestamp}} |
| Extractor Version | {{extractor_version}} |

### Extraction Phases

| Phase | Status | Confidence |
|-------|--------|------------|
| Reconnaissance | {{phase1_status}} | {{phase1_confidence}}% |
| Deep Analysis | {{phase2_status}} | {{phase2_confidence}}% |
| Synthesis | {{phase3_status}} | {{phase3_confidence}}% |
