#!/bin/bash
#
# PDF2TNS - PDF to TI-Nspire TNS Converter
# Converts PDFs to formatted, scrollable TNS files for TI-Nspire calculators
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="$SCRIPT_DIR/output"
LUNA_BIN="$SCRIPT_DIR/luna/luna"
CONVERTER="$SCRIPT_DIR/scripts/pdf_converter.py"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

show_banner() {
    echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║         PDF2TNS - PDF to TNS Converter        ║${NC}"
    echo -e "${BLUE}║     Für TI-Nspire CX/CAS (OS 4.4+)           ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
    echo ""
}

show_help() {
    show_banner
    echo "Usage:"
    echo "  $0 <pdf_file>              - Convert single PDF"
    echo "  $0 <directory>             - Convert all PDFs in directory"
    echo "  $0 --all                   - Convert all PDFs in ~/Downloads"
    echo ""
    echo "Examples:"
    echo "  $0 ~/Downloads/physik.pdf"
    echo "  $0 ~/Documents/pdfs/"
    echo "  $0 --all"
    echo ""
    echo "Output: $OUTPUT_DIR"
    echo ""
    echo "Features:"
    echo "  • Headlines in blue bold"
    echo "  • Bullet points with proper formatting"
    echo "  • Scrollable with arrow keys"
    echo "  • Compatible with TI-Nspire OS 4.4+"
    echo ""
}

check_dependencies() {
    local missing=0

    if ! command -v pdftotext &> /dev/null; then
        echo -e "${RED}✗ pdftotext not found${NC}"
        echo "  Install: sudo apt install poppler-utils"
        missing=1
    fi

    if ! command -v python3 &> /dev/null; then
        echo -e "${RED}✗ python3 not found${NC}"
        missing=1
    fi

    if [ ! -f "$LUNA_BIN" ]; then
        echo -e "${RED}✗ Luna not found at $LUNA_BIN${NC}"
        missing=1
    fi

    if [ $missing -eq 1 ]; then
        exit 1
    fi
}

convert_single_pdf() {
    local pdf_path="$1"

    if [ ! -f "$pdf_path" ]; then
        echo -e "${RED}✗ File not found: $pdf_path${NC}"
        return 1
    fi

    python3 "$CONVERTER" "$pdf_path" "$OUTPUT_DIR" "$LUNA_BIN"
}

convert_directory() {
    local dir="$1"
    local count=0
    local success=0

    echo -e "${BLUE}Searching for PDFs in: $dir${NC}"
    echo ""

    while IFS= read -r pdf; do
        ((count++))
        if convert_single_pdf "$pdf"; then
            ((success++))
        fi
        echo ""
    done < <(find "$dir" -maxdepth 1 -name "*.pdf" -type f | sort)

    echo -e "${GREEN}════════════════════════════════════════${NC}"
    echo -e "${GREEN}✓ Converted: $success / $count PDFs${NC}"
    echo -e "${GREEN}════════════════════════════════════════${NC}"
}

main() {
    show_banner

    # Check dependencies
    check_dependencies

    # Create output directory
    mkdir -p "$OUTPUT_DIR"

    # Parse arguments
    if [ $# -eq 0 ]; then
        show_help
        exit 0
    fi

    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        --all)
            convert_directory "$HOME/Downloads"
            ;;
        *)
            if [ -f "$1" ]; then
                convert_single_pdf "$1"
            elif [ -d "$1" ]; then
                convert_directory "$1"
            else
                echo -e "${RED}✗ Not a valid file or directory: $1${NC}"
                exit 1
            fi
            ;;
    esac

    echo ""
    echo -e "${YELLOW}Output files:${NC} $OUTPUT_DIR"
    echo -e "${YELLOW}Copy .tns files to your TI-Nspire via USB${NC}"
}

main "$@"
