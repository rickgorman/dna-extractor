# DNA Extractor

Extract the "DNA" of any codebase - conventions, patterns, architecture, and tribal knowledge - into structured documentation that AI assistants can use to understand and work with your code effectively.

## Quick Start

### Clone and install

```bash
gh repo clone rickgorman/dna-extractor
cd dna-extractor
./install.sh
```

### Extract DNA from a codebase

```bash
/dna-extractor /path/to/your/repo
```

Output: `PROJECT_DNA.md` in current working directory

## What is DNA Extraction?

DNA Extractor analyzes source code repositories to identify:

- **Identity**: Project name, purpose, type, primary language
- **Domain Model**: Entities, relationships, state machines, invariants
- **Capabilities**: Features, API endpoints, CLI commands, events
- **Architecture**: Directory structure, layers, patterns, data flow
- **Stack**: Languages, frameworks, databases, dependencies
- **Conventions**: Naming patterns, code style, documentation practices
- **Constraints**: Security considerations, performance requirements
- **Operations**: Build, test, deploy procedures

The extracted "DNA" is synthesized into a structured DNA.md document that helps AI coding assistants understand your codebase quickly.

## Installation

```bash
# Clone the repository
gh repo clone rickgorman/dna-extractor
cd dna-extractor

# Run the installer
./install.sh
```

The installer creates:
1. `~/.claude/skills/dna-extractor-skill/` - symlink to skill folder (prompts, templates, SKILL.md)
2. `~/.claude/commands/dna-extractor.md` - command file with configured paths

### Requirements

- Claude Code CLI installed and configured
- GitHub CLI (`gh`) for cloning

## Usage

### Basic Usage

```bash
# Extract DNA from current directory
/dna-extractor .

# Extract DNA from a specific path
/dna-extractor /path/to/repo

# Output is written to PROJECT_DNA.md in current working directory
```

### Extraction Levels

DNA Extractor supports four extraction levels for different needs:

| Level | Time | Scope | Use Case |
|-------|------|-------|----------|
| `snapshot` | ~2 min | Languages, frameworks, structure | Quick overview |
| `skeleton` | 3-10 min | + Entry points, core entities | Planning/estimation |
| `standard` | 10-15 min | Full extraction (default) | Most projects |
| `comprehensive` | 15+ min | + Negative space, git history | Large/complex projects |

```bash
# Quick snapshot (languages and frameworks only)
/dna-extractor /path/to/repo --level=snapshot

# Skeleton extraction (add entry points and entities)
/dna-extractor /path/to/repo --level=skeleton

# Standard extraction (default - full analysis)
/dna-extractor /path/to/repo --level=standard

# Comprehensive extraction (include git history analysis)
/dna-extractor /path/to/repo --level=comprehensive
```

### Output Options

```bash
# Custom output filename
/dna-extractor /path/to/repo --output=PROJECT_DNA.md

# Output to different directory
/dna-extractor /path/to/repo --output=/docs/DNA.md
```

### Command Reference

```
/dna-extractor <path> [options]

Arguments:
  path                  Path to the repository to analyze (default: .)

Options:
  --level=<level>       Extraction depth: snapshot, skeleton, standard, comprehensive
                        (default: standard)
  --output=<file>       Output file path (default: PROJECT_DNA.md in cwd)
  --help                Show help message
```

## Example Output

Here's a snippet of what DNA.md looks like:

```markdown
# MyProject DNA

> Extracted: 2026-01-06T12:00:00Z
> Confidence: 87%
> Level: standard

---

## Identity

### Name
MyProject

### Description
A web application for managing customer orders and inventory.

### Primary Language
Python

### Project Type
Web application (Django)

---

## Domain Model

### Entities

#### Order
| Attribute | Type | Constraints |
|-----------|------|-------------|
| id | UUID | primary_key |
| customer_id | FK(Customer) | required |
| status | OrderStatus | enum |
| total | Decimal | >= 0 |

#### Customer
| Attribute | Type | Constraints |
|-----------|------|-------------|
| id | UUID | primary_key |
| email | String | unique, required |
| name | String | required |

### Relationships
- **Order** many_to_one **Customer**
- **Order** one_to_many **LineItem**

---

## Stack

| Component | Technology |
|-----------|------------|
| Language | Python 3.11 |
| Framework | Django 4.2 |
| Database | PostgreSQL 15 |
| Cache | Redis |

...
```

## How It Works

DNA Extractor uses a three-phase approach:

### Phase 1: Reconnaissance (Scouts)

Parallel agents scan the codebase for raw information:
- **Structure Scout**: Directory layout, languages, frameworks
- **Config Scout**: Configuration files, environment variables
- **Entry Point Scout**: Routes, CLI commands, background jobs
- **Schema Scout**: Database schemas, API specs, message formats

### Phase 2: Deep Analysis (Specialists)

Domain experts analyze specific aspects:
- **Domain Modeler**: Entities, relationships, state machines
- **API Extractor**: Endpoints, request/response schemas
- **Test Analyst**: Test coverage, behavioral specifications
- **Security Analyst**: Auth mechanisms, trust boundaries
- **Convention Extractor**: Naming patterns, code style
- **Infrastructure Analyst**: Deployment, CI/CD, monitoring
- **Negative Space Detector**: Expected-but-missing features

### Phase 3: Synthesis

Final agents combine and validate findings:
- **Conflict Resolver**: Reconcile contradictory information
- **Confidence Scorer**: Assign confidence levels to sections
- **DNA Renderer**: Generate final DNA.md document

## Project Structure

```
dna-extractor/
├── commands/                    # -> ~/.claude/commands/
│   └── dna-extractor.md         # Slash command (copied with path substitution)
├── skills/                      # -> ~/.claude/skills/
│   └── dna-extractor-skill/     # Skill folder (symlinked)
│       ├── SKILL.md             # Skill description
│       ├── prompts/             # Analysis prompts by phase
│       │   ├── orchestrator.md
│       │   ├── phase1/          # Scout prompts
│       │   ├── phase2/          # Specialist prompts
│       │   └── phase3/          # Synthesis prompts
│       └── templates/           # Output templates
│           └── dna-template.md
├── install.sh                   # Installation script
├── README.md                    # This file
└── CLAUDE.md                    # Project conventions
```

## Troubleshooting

### "Command not found: /dna-extractor"

The command isn't installed. From the cloned repo directory, run:
```bash
./install.sh
```

Or manually install from within the cloned repo:
```bash
mkdir -p ~/.claude/commands ~/.claude/skills

# Symlink skill folder
ln -sf "$(pwd)/skills/dna-extractor-skill" ~/.claude/skills/

# Copy command with path substitution
sed "s|@SKILL_DIR@|$HOME/.claude/skills/dna-extractor-skill|g" \
    commands/dna-extractor.md > ~/.claude/commands/dna-extractor.md
```

### Extraction takes too long

For large codebases, use a lower extraction level:
```bash
/dna-extractor /path/to/repo --level=skeleton
```

The `skeleton` level provides useful output in 3-10 minutes vs 10-15 minutes for `standard`.

### Low confidence scores

Low confidence usually means:
1. **Non-standard project structure**: The scouts may not recognize unconventional layouts
2. **Missing documentation**: Projects without READMEs or comments have less to analyze
3. **Custom frameworks**: Lesser-known frameworks may not be detected accurately

Check the "Uncertainties" section of the DNA.md for specific issues.

### Missing sections in output

If a section shows "N/A" or is empty:
1. The project may not have that component (e.g., no database = no schema)
2. The component exists but uses an unsupported pattern
3. Run at a higher extraction level for more thorough analysis

### Memory issues with large codebases

For repositories with >100k files:
```bash
# Use snapshot level first
/dna-extractor /path/to/repo --level=snapshot

# Then target specific directories
/dna-extractor /path/to/repo/src --level=standard
```

### Extraction crashes or hangs

1. Update to the latest version:
   ```bash
   cd /path/to/dna-extractor
   git pull
   ./install.sh  # Re-run installer
   ```

2. Check for file permission issues:
   ```bash
   ls -la /path/to/repo  # Verify read access
   ```

3. Try a simpler extraction level:
   ```bash
   /dna-extractor /path/to/repo --level=snapshot
   ```

## Contributing

See [CLAUDE.md](./CLAUDE.md) for coding conventions and contribution guidelines.

### Adding Support for New Frameworks

1. Identify the framework's characteristic files and patterns
2. Add detection logic to the relevant scout (usually `structure-scout.md`)
3. Add specialized extraction in the appropriate specialist prompt
4. Test against a real project using that framework
5. Update the multi-repo test suite

## License

MIT

## Related Projects

- [Beads](https://github.com/steveyegge/beads) - Issue tracking system
- [Claude Code](https://claude.com/claude-code) - AI coding assistant
