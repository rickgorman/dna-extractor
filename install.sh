#!/usr/bin/env bash
#
# DNA Extractor Installer
# Creates symlink for the dna-extractor skill in Claude's skills directory
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the directory where this script lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_SOURCE="${SCRIPT_DIR}/skills/dna-extractor.md"
SKILL_TARGET="${HOME}/.claude/skills/dna-extractor.md"
SKILLS_DIR="${HOME}/.claude/skills"

info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Check if source skill file exists
if [[ ! -f "$SKILL_SOURCE" ]]; then
    error "Skill file not found: $SKILL_SOURCE"
    error "Please ensure skills/dna-extractor.md exists in the project."
    exit 1
fi

# Create skills directory if it doesn't exist
if [[ ! -d "$SKILLS_DIR" ]]; then
    info "Creating directory: $SKILLS_DIR"
    mkdir -p "$SKILLS_DIR"
fi

# Handle existing symlink or file
if [[ -L "$SKILL_TARGET" ]]; then
    # It's a symlink - check if it points to the right place
    CURRENT_TARGET="$(readlink "$SKILL_TARGET")"
    if [[ "$CURRENT_TARGET" == "$SKILL_SOURCE" ]]; then
        info "Symlink already exists and is correct."
        info "Installation complete. Use /dna-extractor in Claude."
        exit 0
    else
        warn "Removing existing symlink pointing to: $CURRENT_TARGET"
        rm "$SKILL_TARGET"
    fi
elif [[ -e "$SKILL_TARGET" ]]; then
    # It's a regular file
    warn "Removing existing file at: $SKILL_TARGET"
    rm "$SKILL_TARGET"
fi

# Create the symlink
info "Creating symlink: $SKILL_TARGET -> $SKILL_SOURCE"
ln -s "$SKILL_SOURCE" "$SKILL_TARGET"

# Verify
if [[ -L "$SKILL_TARGET" ]]; then
    info "Installation complete!"
    info "The /dna-extractor command is now available in Claude."
else
    error "Failed to create symlink."
    exit 1
fi
