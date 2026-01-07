#!/usr/bin/env bash
#
# DNA Extractor Installer
# Interactive installer for the /dna-extractor Claude Code command
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Get the directory where this script lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMAND_SOURCE="${SCRIPT_DIR}/.claude/commands/dna-extractor.md"

# Installation location for personal commands
COMMANDS_DIR="${HOME}/.claude/commands"
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
# Detection and validation
#------------------------------------------------------------------------------

check_existing_installation() {
    if [[ -L "$COMMAND_TARGET" ]]; then
        local current_target
        current_target="$(readlink "$COMMAND_TARGET" 2>/dev/null || echo "")"
        if [[ "$current_target" == "$COMMAND_SOURCE" ]]; then
            echo "up_to_date"
        else
            echo "different:$current_target"
        fi
    elif [[ -e "$COMMAND_TARGET" ]]; then
        echo "file_exists"
    else
        echo "none"
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
# Installation actions
#------------------------------------------------------------------------------

explain_actions() {
    echo "This installer will:"
    echo ""
    echo "  1. Create the commands directory (if needed):"
    echo "     ${COMMANDS_DIR}"
    echo ""
    echo "  2. Create a symlink for the /dna-extractor command:"
    echo "     ${COMMAND_TARGET}"
    echo "     -> ${COMMAND_SOURCE}"
    echo ""
    echo "After installation:"
    echo "  - Restart Claude Code (or start a new session)"
    echo -e "  - Type ${BOLD}/dna-extractor${NC} to use the command"
    echo ""
}

perform_installation() {
    # Create commands directory if needed
    if [[ ! -d "$COMMANDS_DIR" ]]; then
        info "Creating directory: $COMMANDS_DIR"
        mkdir -p "$COMMANDS_DIR"
    fi

    # Handle existing installation
    local existing
    existing="$(check_existing_installation)"

    case "$existing" in
        "up_to_date")
            info "Symlink already exists and is correct."
            return 0
            ;;
        different:*)
            local old_target="${existing#different:}"
            warn "Updating symlink (was: $old_target)"
            rm "$COMMAND_TARGET"
            ;;
        "file_exists")
            warn "Replacing existing file with symlink"
            rm "$COMMAND_TARGET"
            ;;
        "none")
            # Fresh install, nothing to do
            ;;
    esac

    # Create the symlink
    ln -s "$COMMAND_SOURCE" "$COMMAND_TARGET"

    # Verify
    if [[ -L "$COMMAND_TARGET" ]]; then
        info "Symlink created successfully"
        return 0
    else
        error "Failed to create symlink"
        return 1
    fi
}

#------------------------------------------------------------------------------
# Main
#------------------------------------------------------------------------------

main() {
    print_header

    # Check if source command file exists
    if [[ ! -f "$COMMAND_SOURCE" ]]; then
        error "Command file not found: $COMMAND_SOURCE"
        error "Please ensure .claude/commands/dna-extractor.md exists."
        exit 1
    fi

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
    else
        echo ""
        error "Installation failed."
        exit 1
    fi
}

# Run main unless sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
