#!/usr/bin/env bash
#
# DNA Extractor Installer
# Interactive installer for the dna-extractor Claude skill
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
SKILL_SOURCE="${SCRIPT_DIR}/skills/dna-extractor.md"

# Possible installation locations (in order of preference)
INSTALL_LOCATIONS=(
    "${HOME}/.claude/skills"
    "${HOME}/.local/share/claude/skills"
)

# Selected installation directory
SKILLS_DIR=""
SKILL_TARGET=""

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
    echo -e "${BLUE}[?]${NC} $1"
}

#------------------------------------------------------------------------------
# Detection and validation
#------------------------------------------------------------------------------

detect_install_location() {
    # Check each location in order of preference
    for loc in "${INSTALL_LOCATIONS[@]}"; do
        if [[ -d "$loc" ]]; then
            SKILLS_DIR="$loc"
            return 0
        fi
    done

    # Check if parent directories exist
    for loc in "${INSTALL_LOCATIONS[@]}"; do
        local parent
        parent="$(dirname "$loc")"
        if [[ -d "$parent" ]]; then
            SKILLS_DIR="$loc"
            return 0
        fi
    done

    # Default to first option
    SKILLS_DIR="${INSTALL_LOCATIONS[0]}"
}

check_existing_installation() {
    if [[ -L "$SKILL_TARGET" ]]; then
        local current_target
        current_target="$(readlink "$SKILL_TARGET" 2>/dev/null || echo "")"
        if [[ "$current_target" == "$SKILL_SOURCE" ]]; then
            echo "up_to_date"
        else
            echo "different:$current_target"
        fi
    elif [[ -e "$SKILL_TARGET" ]]; then
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

show_install_plan() {
    echo "Installation plan:"
    echo ""
    echo "  Directory: ${SKILLS_DIR}"
    echo "  Symlink:   dna-extractor.md -> ${SKILL_SOURCE}"
    echo ""
    echo -e "After installation, use ${BOLD}/dna-extractor${NC} in Claude Code."
    echo ""
}

#------------------------------------------------------------------------------
# Installation actions
#------------------------------------------------------------------------------

perform_installation() {
    # Create skills directory if needed
    if [[ ! -d "$SKILLS_DIR" ]]; then
        info "Creating directory: $SKILLS_DIR"
        mkdir -p "$SKILLS_DIR"
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
            rm "$SKILL_TARGET"
            ;;
        "file_exists")
            warn "Replacing existing file with symlink"
            rm "$SKILL_TARGET"
            ;;
        "none")
            # Fresh install, nothing to do
            ;;
    esac

    # Create the symlink
    ln -s "$SKILL_SOURCE" "$SKILL_TARGET"

    # Verify
    if [[ -L "$SKILL_TARGET" ]]; then
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

    # Check if source skill file exists
    if [[ ! -f "$SKILL_SOURCE" ]]; then
        error "Skill file not found: $SKILL_SOURCE"
        error "Please ensure skills/dna-extractor.md exists."
        exit 1
    fi

    # Detect installation location
    detect_install_location
    SKILL_TARGET="${SKILLS_DIR}/dna-extractor.md"

    # Check for existing installation
    local existing
    existing="$(check_existing_installation)"

    case "$existing" in
        "up_to_date")
            info "Already installed and up-to-date."
            info "Location: $SKILL_TARGET"
            echo ""
            echo -e "The ${BOLD}/dna-extractor${NC} command is available in Claude Code."
            echo ""
            exit 0
            ;;
        different:*)
            local old_target="${existing#different:}"
            warn "Existing symlink points to different location:"
            echo "     Current: $old_target"
            echo "     New:     $SKILL_SOURCE"
            echo ""
            ;;
        "file_exists")
            warn "File exists at install location (will be replaced):"
            echo "     $SKILL_TARGET"
            echo ""
            ;;
        "none")
            # Fresh install - show plan
            show_install_plan
            ;;
    esac

    # Single confirmation
    if ! ask_yes_no "Install dna-extractor skill?"; then
        echo ""
        echo "Installation cancelled."
        exit 0
    fi

    echo ""

    # Perform the installation
    if perform_installation; then
        echo ""
        echo -e "${GREEN}${BOLD}Installation complete!${NC}"
        echo ""
        echo "Usage: /dna-extractor [path-or-url] [options]"
        echo "Help:  /dna-extractor --help"
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
