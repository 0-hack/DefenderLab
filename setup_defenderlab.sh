#!/bin/bash
# Defender Lab Setup Script
set -e

# Output formatting
COLOR_GREEN='\033[0;32m'
COLOR_RED='\033[0;31m'
COLOR_CYAN='\033[0;36m'
COLOR_YELLOW='\033[1;33m'
COLOR_RESET='\033[0m'
SECTION_BREAK="================================================================"

# Output functions (MUST COME FIRST)
print_status() { echo -e "${COLOR_CYAN}[STATUS]${COLOR_RESET} $1"; }
print_success() { echo -e "${COLOR_GREEN}[SUCCESS]${COLOR_RESET} $1"; }
print_error() { echo -e "${COLOR_RED}[ERROR]${COLOR_RESET} $1"; }
print_warning() { echo -e "${COLOR_YELLOW}[WARNING]${COLOR_RESET} $1"; }

# Initialization
echo -e "\n${COLOR_CYAN}${SECTION_BREAK}"
echo "           Defender Lab Setup - Initialization"
echo -e "${SECTION_BREAK}${COLOR_RESET}\n"

# Improved iframe URL prompt
echo -e "Webtop typically runs on port ${COLOR_CYAN}3000${COLOR_RESET} (default)."
echo -e "If using a remote server, include the full address (e.g.: ${COLOR_CYAN}http://your-domain.com:3000${COLOR_RESET})"
read -p "Enter the iframe source URL for the webtop [default: http://localhost:3000]: " IFRAME_SRC
IFRAME_SRC=${IFRAME_SRC:-http://localhost:3000}

# Validate URL format
if [[ ! "$IFRAME_SRC" =~ ^https?://[^\s]+$ ]]; then
    print_error "Invalid URL format. Must include http:// or https:// and no spaces"
    exit 1
fi

echo -e "\nUsing iframe source: ${COLOR_CYAN}${IFRAME_SRC}${COLOR_RESET}"
echo -e "Note: This should point to your webtop service (typically port 3000)"

# ... (keep previous configuration variables and root check)

# ... (keep file system setup, permissions, dependencies, and service configuration)

# Final Configuration
echo -e "\n${COLOR_CYAN}${SECTION_BREAK}"
echo "           Final Configuration"
echo -e "${SECTION_BREAK}${COLOR_RESET}"

print_status "Updating iframe source..."
if [ -f "$INDEX_HTML" ]; then
    if grep -q 'src="__IFRAME_SRC_PLACEHOLDER__"' "$INDEX_HTML"; then
        ESCAPED_SRC=$(sed -e 's/[\/&]/\\&/g' <<< "$IFRAME_SRC")
        sed -i.bak "s|src=\"__IFRAME_SRC_PLACEHOLDER__\"|src=\"${ESCAPED_SRC}\"|g" "$INDEX_HTML"
        
        if grep -q "src=\"${IFRAME_SRC}\"" "$INDEX_HTML"; then
            print_success "iframe source updated to:"
            echo -e "${COLOR_CYAN}${IFRAME_SRC}${COLOR_RESET}"
        else
            print_error "Replacement failed - check URL special characters"
        fi
    else
        print_warning "Placeholder not found in index.html"
    fi
else
    print_error "index.html missing at ${INDEX_HTML}"
fi

# ... (keep docker setup section)

# Enhanced completion message
echo -e "\n${COLOR_GREEN}${SECTION_BREAK}"
echo "           Setup Completed Successfully!"
echo -e "${SECTION_BREAK}${COLOR_RESET}"
echo -e "Access the Defender Lab interface at:"
echo -e "${COLOR_CYAN}http://$(hostname -I | awk '{print $1}'):5000${COLOR_RESET}"
echo -e "\nPort Requirements:"
echo -e "• Web Interface: ${COLOR_CYAN}5000${COLOR_RESET}"
echo -e "• Webtop Service: ${COLOR_CYAN}3000${COLOR_RESET} (configured in iframe)"
echo -e "\nRunning Docker containers:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep defenderlab
echo -e "\n"
