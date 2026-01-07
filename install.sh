#!/usr/bin/env bash
#
# DNA Extractor Installer
# Interactive installer for the /dna-extractor Claude Code skill
#
# Usage: Clone the repo, then run ./install.sh from within it
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Script location (the cloned repo)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source: skill folder and command file (mirroring ~/.claude/ layout)
SKILL_FOLDER="${SCRIPT_DIR}/skills/dna-extractor-skill"
COMMAND_SOURCE="${SCRIPT_DIR}/commands/dna-extractor.md"

# Installation targets
COMMANDS_DIR="${HOME}/.claude/commands"
SKILLS_DIR="${HOME}/.claude/skills"

SKILL_TARGET="${SKILLS_DIR}/dna-extractor-skill"
COMMAND_TARGET="${COMMANDS_DIR}/dna-extractor.md"

#------------------------------------------------------------------------------
# Output helpers
#------------------------------------------------------------------------------

print_header() {
    echo ""
    echo -e "${BOLD}DNA Extractor Installer${NC}"
    echo "======================="
    echo ""
}

info() {
    echo -e "${GREEN}[OK]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

prompt() {
    echo -en "${BLUE}[?]${NC} $1"
}

#------------------------------------------------------------------------------
# Validation
#------------------------------------------------------------------------------

validate_source_files() {
    local missing=0

    if [[ ! -d "$SKILL_FOLDER" ]]; then
        error "Skill folder not found: $SKILL_FOLDER"
        missing=1
    fi

    if [[ ! -f "$COMMAND_SOURCE" ]]; then
        error "Command file not found: $COMMAND_SOURCE"
        missing=1
    fi

    if [[ ! -f "${SKILL_FOLDER}/SKILL.md" ]]; then
        error "SKILL.md not found in: $SKILL_FOLDER"
        missing=1
    fi

    if [[ ! -d "${SCRIPT_DIR}/commands" ]]; then
        error "Commands directory not found: ${SCRIPT_DIR}/commands"
        missing=1
    fi

    if [[ $missing -eq 1 ]]; then
        echo ""
        error "Please run this script from within the cloned dna-extractor repository."
        exit 1
    fi
}

#------------------------------------------------------------------------------
# User interaction
#------------------------------------------------------------------------------

ask_yes_no() {
    local prompt_text="$1"
    local default="${2:-y}"
    local response

    if [[ "$default" == "y" ]]; then
        prompt "$prompt_text [Y/n]: "
    else
        prompt "$prompt_text [y/N]: "
    fi

    read -r response
    response="${response:-$default}"
    response="${response,,}"  # lowercase

    [[ "$response" == "y" || "$response" == "yes" ]]
}

#------------------------------------------------------------------------------
# Installation
#------------------------------------------------------------------------------

explain_actions() {
    echo "This installer will create two symlinks:"
    echo ""
    echo "  1. Command (enables /dna-extractor):"
    echo "     ${COMMAND_TARGET} -> ${COMMAND_SOURCE}"
    echo ""
    echo "  2. Skill folder (prompts, templates, SKILL.md):"
    echo "     ${SKILL_TARGET} -> ${SKILL_FOLDER}"
    echo ""
    echo "After installation:"
    echo "  - Restart Claude Code (or start a new session)"
    echo -e "  - Type ${BOLD}/dna-extractor${NC} to use the command"
    echo ""
}

perform_installation() {
    # Create directories if needed
    mkdir -p "$COMMANDS_DIR" "$SKILLS_DIR"

    # Remove existing skill symlink/folder if present
    if [[ -e "$SKILL_TARGET" || -L "$SKILL_TARGET" ]]; then
        rm -rf "$SKILL_TARGET"
    fi

    # Create skill folder symlink
    ln -s "$SKILL_FOLDER" "$SKILL_TARGET"
    if [[ -L "$SKILL_TARGET" ]]; then
        info "Skill folder: $SKILL_TARGET"
    else
        error "Failed to create skill symlink"
        return 1
    fi

    # Remove existing command symlink if present
    if [[ -e "$COMMAND_TARGET" || -L "$COMMAND_TARGET" ]]; then
        rm -f "$COMMAND_TARGET"
    fi

    # Create command symlink
    ln -s "$COMMAND_SOURCE" "$COMMAND_TARGET"
    if [[ -L "$COMMAND_TARGET" ]]; then
        info "Command: $COMMAND_TARGET"
    else
        error "Failed to create command symlink"
        return 1
    fi

    return 0
}

#------------------------------------------------------------------------------
# Main
#------------------------------------------------------------------------------

main() {
    print_header
    validate_source_files

    # Check for existing installation
    if [[ -e "$SKILL_TARGET" || -e "$COMMAND_TARGET" ]]; then
        info "Existing installation found"
        echo ""
        if ! ask_yes_no "Reinstall?" "y"; then
            echo ""
            echo "Installation cancelled."
            exit 0
        fi
        echo ""
    fi

    explain_actions

    if ! ask_yes_no "Proceed with installation?"; then
        echo ""
        echo "Installation cancelled."
        exit 0
    fi

    echo ""
    echo "Installing..."
    echo ""

    if perform_installation; then
        echo ""
        echo -e "${GREEN}${BOLD}Installation complete!${NC}"
        echo ""
        echo "Next steps:"
        echo "  1. Restart Claude Code (or start a new conversation)"
        echo "  2. Run: /dna-extractor /path/to/repo"
        echo ""
        echo "Usage:"
        echo "  /dna-extractor <repo-path>                   # Full extraction"
        echo "  /dna-extractor <repo-path> --level=snapshot  # Quick scan"
        echo "  /dna-extractor --help                        # Show help"
        echo ""
        echo -e "${YELLOW}Important:${NC} Keep this repo - symlinks point here!"
        echo "  Location: ${SCRIPT_DIR}"
        echo ""
    else
        echo ""
        error "Installation failed."
        exit 1
    fi
}

main "$@"
