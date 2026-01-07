#!/usr/bin/env bash
#
# DNA Extractor Installer
# Interactive installer for the /dna-extractor Claude Code command
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

# Source files in the repo
COMMAND_SOURCE="${SCRIPT_DIR}/.claude/commands/dna-extractor.md"
SKILL_SOURCE="${SCRIPT_DIR}/skills/dna-extractor.md"
PROMPTS_SOURCE="${SCRIPT_DIR}/prompts"
TEMPLATES_SOURCE="${SCRIPT_DIR}/templates"

# Installation targets
COMMANDS_DIR="${HOME}/.claude/commands"
SKILLS_DIR="${HOME}/.claude/skills"
SKILL_SUBDIR="${SKILLS_DIR}/dna-extractor"

COMMAND_TARGET="${COMMANDS_DIR}/dna-extractor.md"
SKILL_TARGET="${SKILL_SUBDIR}/dna-extractor.md"
PROMPTS_TARGET="${SKILL_SUBDIR}/prompts"
TEMPLATES_TARGET="${SKILL_SUBDIR}/templates"

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

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
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

    if [[ ! -f "$COMMAND_SOURCE" ]]; then
        error "Command file not found: $COMMAND_SOURCE"
        missing=1
    fi

    if [[ ! -f "$SKILL_SOURCE" ]]; then
        error "Skill file not found: $SKILL_SOURCE"
        missing=1
    fi

    if [[ ! -d "$PROMPTS_SOURCE" ]]; then
        error "Prompts directory not found: $PROMPTS_SOURCE"
        missing=1
    fi

    if [[ ! -d "$TEMPLATES_SOURCE" ]]; then
        error "Templates directory not found: $TEMPLATES_SOURCE"
        missing=1
    fi

    if [[ $missing -eq 1 ]]; then
        echo ""
        error "Please run this script from within the cloned dna-extractor repository."
        exit 1
    fi
}

#------------------------------------------------------------------------------
# Installation status
#------------------------------------------------------------------------------

check_existing_installation() {
    local status="none"

    if [[ -L "$COMMAND_TARGET" ]]; then
        local current_target
        current_target="$(readlink "$COMMAND_TARGET" 2>/dev/null || echo "")"
        if [[ "$current_target" == "$COMMAND_SOURCE" ]]; then
            status="up_to_date"
        else
            status="different:$current_target"
        fi
    elif [[ -e "$COMMAND_TARGET" ]]; then
        status="file_exists"
    fi

    echo "$status"
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
# Installation actions
#------------------------------------------------------------------------------

explain_actions() {
    echo "This installer will:"
    echo ""
    echo "  1. Install the /dna-extractor command:"
    echo "     ${COMMAND_TARGET}"
    echo "     (with resource paths configured to this repo)"
    echo ""
    echo "  2. Create symlinks for skill files, prompts, and templates:"
    echo "     ${SKILL_TARGET}"
    echo "     ${PROMPTS_TARGET}"
    echo "     ${TEMPLATES_TARGET}"
    echo ""
    echo "After installation:"
    echo "  - Restart Claude Code (or start a new session)"
    echo -e "  - Type ${BOLD}/dna-extractor${NC} to use the command"
    echo ""
}

create_symlink() {
    local source="$1"
    local target="$2"
    local target_dir
    target_dir="$(dirname "$target")"

    # Create parent directory if needed
    if [[ ! -d "$target_dir" ]]; then
        mkdir -p "$target_dir"
        info "Created directory: $target_dir"
    fi

    # Remove existing file/symlink if present
    if [[ -e "$target" || -L "$target" ]]; then
        rm -f "$target"
    fi

    # Create the symlink
    ln -s "$source" "$target"
}

perform_installation() {
    # Create commands directory if needed
    if [[ ! -d "$COMMANDS_DIR" ]]; then
        mkdir -p "$COMMANDS_DIR"
        info "Created directory: $COMMANDS_DIR"
    fi

    # Remove existing command file if present
    if [[ -e "$COMMAND_TARGET" || -L "$COMMAND_TARGET" ]]; then
        rm -f "$COMMAND_TARGET"
    fi

    # Copy command file and update @prompts/ and @templates/ references to absolute paths
    # This ensures resources are findable regardless of CWD
    sed -e "s|@prompts/|@${PROMPTS_SOURCE}/|g" \
        -e "s|@templates/|@${TEMPLATES_SOURCE}/|g" \
        "$COMMAND_SOURCE" > "$COMMAND_TARGET"
    if [[ -f "$COMMAND_TARGET" ]]; then
        info "Command file installed: $COMMAND_TARGET"
        info "  (resource paths configured to: ${SCRIPT_DIR})"
    else
        error "Failed to install command file"
        return 1
    fi

    # Create skill directory
    if [[ ! -d "$SKILL_SUBDIR" ]]; then
        mkdir -p "$SKILL_SUBDIR"
        info "Created skill directory: $SKILL_SUBDIR"
    fi

    # Create skill file symlink
    create_symlink "$SKILL_SOURCE" "$SKILL_TARGET"
    if [[ -L "$SKILL_TARGET" ]]; then
        info "Skill symlink created: $SKILL_TARGET"
    else
        error "Failed to create skill symlink"
        return 1
    fi

    # Create prompts symlink (for reference, though command uses absolute paths)
    create_symlink "$PROMPTS_SOURCE" "$PROMPTS_TARGET"
    if [[ -L "$PROMPTS_TARGET" ]]; then
        info "Prompts symlink created: $PROMPTS_TARGET"
    else
        error "Failed to create prompts symlink"
        return 1
    fi

    # Create templates symlink
    create_symlink "$TEMPLATES_SOURCE" "$TEMPLATES_TARGET"
    if [[ -L "$TEMPLATES_TARGET" ]]; then
        info "Templates symlink created: $TEMPLATES_TARGET"
    else
        error "Failed to create templates symlink"
        return 1
    fi

    return 0
}

#------------------------------------------------------------------------------
# Main
#------------------------------------------------------------------------------

main() {
    print_header

    # Validate we have all source files
    validate_source_files

    # Check for existing installation
    local existing
    existing="$(check_existing_installation)"

    if [[ "$existing" == "up_to_date" ]]; then
        info "Already installed at: $COMMAND_TARGET"
        info "The /dna-extractor command is available in Claude Code."
        echo ""
        echo "Note: Restart Claude Code if the command doesn't appear."
        echo ""

        if ! ask_yes_no "Reinstall anyway?" "n"; then
            echo ""
            echo "Nothing to do. Exiting."
            exit 0
        fi
        echo ""
    fi

    # Explain what we'll do
    explain_actions

    # Final confirmation
    if ! ask_yes_no "Proceed with installation?"; then
        echo ""
        echo "Installation cancelled."
        exit 0
    fi

    echo ""
    echo "Installing..."
    echo ""

    # Perform the installation
    if perform_installation; then
        echo ""
        echo -e "${GREEN}${BOLD}Installation complete!${NC}"
        echo ""
        echo "Next steps:"
        echo "  1. Restart Claude Code (or start a new conversation)"
        echo "  2. Run: /dna-extractor /path/to/repo"
        echo ""
        echo "Usage:"
        echo "  /dna-extractor <repo-path>              # Full extraction"
        echo "  /dna-extractor <repo-path> --level=snapshot  # Quick scan"
        echo "  /dna-extractor --help                   # Show help"
        echo ""
        echo -e "${YELLOW}Important:${NC} Keep this repo cloned - the symlinks point here!"
        echo "  Location: ${SCRIPT_DIR}"
        echo ""
    else
        echo ""
        error "Installation failed."
        exit 1
    fi
}

# Run main
main "$@"
