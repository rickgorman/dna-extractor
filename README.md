# DNA Extractor

A codebase analysis tool that extracts conventions, patterns, and architectural insights to generate comprehensive CLAUDE.md files.

## Overview

DNA Extractor analyzes source code repositories to identify:
- Coding conventions and style patterns
- API structures and interfaces
- Domain models and data flows
- Test patterns and coverage strategies
- Security considerations
- Infrastructure and deployment patterns

The extracted "DNA" is synthesized into structured documentation that helps AI assistants understand and work with the codebase effectively.

## Installation

```bash
# Clone the repository
git clone <repo-url>
cd dnaextractor

# Run the installer
./install.sh
```

## Usage

```bash
# Extract DNA from a codebase
dna extract /path/to/codebase

# Generate CLAUDE.md from extracted DNA
dna render /path/to/codebase
```

## Project Structure

```
dnaextractor/
├── skills/           # Claude Code skills for extraction
├── prompts/          # Analysis prompts by phase
│   ├── phase1/       # Initial extraction (gather raw data)
│   ├── phase2/       # Synthesis (process and analyze)
│   └── phase3/       # Rendering (generate output)
├── templates/        # Output templates
├── tests/            # Test suite
├── README.md         # This file
└── CLAUDE.md         # Project conventions
```

## Phases

1. **Phase 1 - Extraction**: Analyze the codebase to extract raw patterns, conventions, and structures
2. **Phase 2 - Synthesis**: Process extracted data, resolve conflicts, score confidence
3. **Phase 3 - Rendering**: Generate final CLAUDE.md and related documentation

## Development

See [CLAUDE.md](./CLAUDE.md) for coding conventions and contribution guidelines.

## License

MIT
