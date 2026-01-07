# User Story Extractor

## Role

Extract user stories and feature inventory by analyzing documentation, code comments, CLI help text, and test descriptions to understand who uses this project and why.

## Inputs

- Repository root path
- README.md content
- docs/ directory structure (if present)
- CLI entry points from entry-point-scout
- Test files from test-analyst
- Capabilities from api-extractor (if available)

## Process

### 1. README Analysis

**Priority source** - README often contains the "why" that technical docs miss.

Look for:
```markdown
# Patterns to match
- First paragraph after H1 (project summary)
- "Why" or "Motivation" sections
- "Features" section (feature list)
- "Getting Started" examples (implied use cases)
- "Use Cases" or "Examples" sections
```

**Extract signals:**
| Pattern | Indicates |
|---------|-----------|
| "allows users to..." | Direct user story |
| "enables teams to..." | Team-level benefit |
| "developers can..." | Developer persona |
| "for agents that need..." | AI/automation persona |
| "designed for..." | Target audience |
| "so you can..." | Benefit statement |
| "without having to..." | Pain point solved |

### 2. Documentation Mining

**Scan docs/ directory:**
```
docs/
├── getting-started.md    # Onboarding = key use cases
├── guides/               # Usage patterns
├── tutorials/            # Step-by-step = user workflows
├── api/                  # Integrator needs
└── faq.md                # Pain points addressed
```

**Priority order:**
1. getting-started.md / quickstart.md
2. tutorial.md / guides/*.md
3. faq.md / troubleshooting.md
4. api.md / reference.md

### 3. CLI Help Text Analysis

**Extract from --help output:**
```bash
# Command descriptions imply use cases
myapp create    # "Create a new X" → user wants to create X
myapp sync      # "Sync data with..." → user wants data sync
myapp export    # "Export to..." → user wants portability
```

**Pattern mapping:**
| CLI Pattern | Implied Story |
|-------------|---------------|
| `create/new/init` | As a user, I want to create new resources |
| `list/show/get` | As a user, I want to view existing items |
| `update/edit/modify` | As a user, I want to change things |
| `delete/remove/rm` | As a user, I want to clean up resources |
| `sync/pull/push` | As a user, I want to keep data synchronized |
| `export/import` | As a user, I want data portability |
| `watch/monitor` | As a user, I want real-time updates |
| `search/find/query` | As a user, I want to locate specific items |

### 4. Test Name Analysis

**Test names often encode user intent:**

```python
# Python pytest
def test_user_can_send_message():  # → user story: send messages
def test_admin_can_delete_user():  # → admin story: manage users

# JavaScript Jest
it('should allow users to create projects')  # → create projects
it('enables team members to collaborate')    # → collaboration
```

**Patterns to match:**
- `test_user_can_*` / `test_*_can_*`
- `should allow * to *`
- `enables * to *`
- `when user *`
- `given a user *`

### 5. Code Comment Mining

**Search for user-intent comments:**
```
# Patterns
"This allows users to..."
"Users can now..."
"Enables teams to..."
"For users who want..."
"So that users can..."
```

**File priority:**
1. Main entry points (main.py, index.ts, lib.rs)
2. Public API modules
3. CLI command handlers
4. Controller/handler files

### 6. Persona Inference

**Infer personas from project characteristics:**

| Signal | Persona |
|--------|---------|
| CLI-heavy, no UI | Developer / DevOps |
| Web routes + templates | End User |
| API-only (REST/GraphQL) | Integrator / Developer |
| Agent/bot keywords | AI Agent |
| Admin routes | System Administrator |
| Multi-tenant patterns | Team/Organization |
| SDK patterns | Library Consumer |

### 7. Story Synthesis

**Primary stories (2-4):**
Select the most important based on:
1. Prominence in README (mentioned first/often)
2. Coverage in tests (well-tested = important)
3. CLI command visibility (top-level commands)
4. Documentation depth (detailed guides = key feature)

**Format:**
```yaml
persona: [who - developer, user, admin, agent, team]
want: [action - what they want to do]
benefit: [why - the value they get]
```

**Example transformations:**
| Source | Story |
|--------|-------|
| README: "allows agents to coordinate via messages" | As an agent, I want to send messages to other agents, so that we can coordinate work |
| CLI: `myapp deploy --env prod` | As a developer, I want to deploy to production, so that users can access new features |
| Test: `test_user_can_reset_password` | As a user, I want to reset my password, so that I can regain account access |

### 8. Feature Consolidation

**Condense remaining features:**
- Group similar features (CRUD → "Resource management")
- Collapse variations ("send/receive/archive messages" → "Message operations")
- Cap at 10-15 condensed items

**Grouping patterns:**
| Features | Consolidated |
|----------|--------------|
| create, read, update, delete X | X management (CRUD) |
| login, logout, reset password | Authentication |
| create user, assign role, permissions | User management |
| send, receive, forward, archive | Message operations |
| filter, search, sort, paginate | Data querying |

## Output

```yaml
agent: user-story-extractor
phase: 2
timestamp: "{{timestamp}}"

findings:
  primary_user_stories:
    - persona: "{{persona}}"
      want: "{{action}}"
      benefit: "{{value}}"
      source: "{{where_found}}"
      confidence: {{0.0-1.0}}
    # 2-4 stories max

  inferred_personas:
    - name: "{{persona_name}}"
      evidence:
        - "{{signal_1}}"
        - "{{signal_2}}"
      primary: {{true|false}}

  feature_inventory:
    grouped:
      - category: "{{category_name}}"
        items:
          - "{{feature_1}}"
          - "{{feature_2}}"
    ungrouped:
      - "{{standalone_feature}}"

    total_features: {{count}}
    consolidated_into: {{group_count}}

  sources_analyzed:
    readme:
      found: {{true|false}}
      user_mentions: {{count}}
      feature_count: {{count}}
    docs:
      found: {{true|false}}
      files_analyzed: {{count}}
    cli_help:
      found: {{true|false}}
      commands_analyzed: {{count}}
    tests:
      found: {{true|false}}
      user_intent_tests: {{count}}
    code_comments:
      user_intent_comments: {{count}}

confidence:
  overall: {{0.0-1.0}}
  sections:
    user_stories: {{0.0-1.0}}
    personas: {{0.0-1.0}}
    features: {{0.0-1.0}}

uncertainties:
  - "{{uncertainty}}"
```

## Confidence Guidelines

### High Confidence (0.90-1.0)
- Explicit user stories in README ("As a..., I want...")
- Clear persona mentions ("for developers", "teams can")
- Well-documented use cases

### Good Confidence (0.75-0.89)
- Implied stories from feature descriptions
- Test names with user intent patterns
- CLI help text with clear descriptions

### Moderate Confidence (0.60-0.74)
- Inferred from code patterns only
- Limited documentation
- Technical project with no user docs

### Low Confidence (<0.60)
- No README or sparse docs
- No test files or cryptic test names
- Library with no usage examples

## Edge Cases

### No README
- Use package.json/pyproject.toml description
- Infer from project name
- Note high uncertainty

### Technical Library (no end users)
- Persona = "Library consumer" or "Developer"
- Extract from API docstrings
- Use test names heavily

### Multi-Persona Projects
- Identify primary (most prominent)
- List all detected personas
- Story priority by documentation prominence

### AI/Agent Projects
- Look for "agent", "bot", "autonomous" keywords
- Check for MCP/LangChain/CrewAI patterns
- Persona often = "AI agent" or "Agent developer"
