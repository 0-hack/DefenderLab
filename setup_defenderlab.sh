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
if [[ ! "$IFRAME_SRC" =~ ^https?://[^ ]+$ ]]; then
    print_error "Invalid URL format. Must include http:// or https:// and no spaces"
    exit 1
fi

echo -e "\nUsing iframe source: ${COLOR_CYAN}${IFRAME_SRC}${COLOR_RESET}"
echo -e "Note: This should point to your webtop service (typically port 3000)"

# Configuration variables
INSTALL_DIR="/opt/DefenderLab"
SERVICE_FILE="/etc/systemd/system/webtop-control.service"
INDEX_HTML="$INSTALL_DIR/webtop-control/index.html"

# Root check
if [ "$(id -u)" -ne 0 ]; then
    print_error "Please run this script as root (sudo)."
    exit 1
fi

# Hostname Configuration
echo -e "\n${COLOR_CYAN}${SECTION_BREAK}"
echo "           Hostname Configuration"
echo -e "${SECTION_BREAK}${COLOR_RESET}"

print_status "Configuring system hostname resolution..."
CURRENT_HOSTNAME=$(hostname)
HOSTS_LINE="127.0.0.1       localhost ${CURRENT_HOSTNAME}"

# Check if hostname already exists in hosts file
if ! grep -qE "127.0.0.1.*${CURRENT_HOSTNAME}" /etc/hosts && \
   ! grep -qE "127.0.1.1.*${CURRENT_HOSTNAME}" /etc/hosts; then
    
    # Backup original hosts file
    cp /etc/hosts /etc/hosts.bak
    
    # Append to existing 127.0.0.1 line or create new line
    if grep -q "^127.0.0.1" /etc/hosts; then
        sed -i "/^127.0.0.1/s/$/ ${CURRENT_HOSTNAME}/" /etc/hosts
    else
        sed -i "1i${HOSTS_LINE}" /etc/hosts
    fi
    
    print_success "Added hostname '${CURRENT_HOSTNAME}' to /etc/hosts"
else
    print_status "Hostname already configured - skipping"
fi

# Verify configuration
if ! grep -qE "127.0.[01].1.*${CURRENT_HOSTNAME}" /etc/hosts; then
    print_warning "Hostname configuration incomplete. Manual check recommended:"
    echo -e "Add this line to /etc/hosts:\n${COLOR_CYAN}${HOSTS_LINE}${COLOR_RESET}"
fi

# File System Setup
echo -e "\n${COLOR_CYAN}${SECTION_BREAK}"
echo "           File System Setup"
echo -e "${SECTION_BREAK}${COLOR_RESET}"

if [ ! -d "$INSTALL_DIR" ]; then
    print_status "Copying DefenderLab files to ${INSTALL_DIR}..."
    if cp -r "$(dirname "$0")" "$INSTALL_DIR" > /dev/null; then
        print_success "Files copied successfully"
    else
        print_error "Failed to copy files to ${INSTALL_DIR}"
        exit 1
    fi
else
    print_status "Installation directory already exists - skipping copy"
fi

# Permissions
print_status "Setting file permissions..."
if chmod +x "$INSTALL_DIR/reset_webtop.sh" > /dev/null && \
   chmod 755 "$INSTALL_DIR/webtop-control/app.py" > /dev/null; then
    print_success "Permissions configured"
else
    print_error "Failed to set permissions"
    exit 1
fi
print_status "Setting image permissions..."
mkdir -p "$INSTALL_DIR/webtop-control/img"
chmod -R 755 "$INSTALL_DIR/webtop-control/img"
find "$INSTALL_DIR/webtop-control/img" -type f -exec chmod 644 {} \;

# Dependency Installation
echo -e "\n${COLOR_CYAN}${SECTION_BREAK}"
echo "           Dependency Installation"
echo -e "${SECTION_BREAK}${COLOR_RESET}"

# Install pip3
if ! command -v pip3 >/dev/null 2>&1; then
    print_status "Installing python3-pip..."
    if apt-get update > /dev/null && apt-get install python3-pip -y > /dev/null; then
        print_success "python3-pip installed"
    else
        print_error "Failed to install python3-pip"
        exit 1
    fi
else
    print_status "python3-pip already installed - skipping"
fi

# Install Flask
print_status "Installing Python dependencies..."
if pip3 install flask > /dev/null; then
    print_success "Flask installed"
else
    print_error "Failed to install Flask"
    exit 1
fi

# Service Configuration
echo -e "\n${COLOR_CYAN}${SECTION_BREAK}"
echo "           Service Configuration"
echo -e "${SECTION_BREAK}${COLOR_RESET}"

print_status "Creating systemd service..."
cat <<EOF > "$SERVICE_FILE"
[Unit]
Description=Webtop Control Interface
After=network.target

[Service]
ExecStart=/usr/bin/python3 $INSTALL_DIR/webtop-control/app.py
WorkingDirectory=$INSTALL_DIR/webtop-control
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

print_status "Reloading systemd..."
if systemctl daemon-reload > /dev/null && \
   systemctl enable webtop-control > /dev/null && \
   systemctl restart webtop-control > /dev/null; then
    print_success "Webtop control service active and running"
else
    print_error "Failed to configure systemd service"
    exit 1
fi

# Iframe Configuration
echo -e "\n${COLOR_CYAN}${SECTION_BREAK}"
echo "           Final Configuration"
echo -e "${SECTION_BREAK}${COLOR_RESET}"

print_status "Updating iframe source..."
if [ -f "$INDEX_HTML" ]; then
    if grep -q 'src="__IFRAME_SRC_PLACEHOLDER__"' "$INDEX_HTML"; then
        # Escape special characters
        ESCAPED_SRC=$(sed -e 's/[\/&]/\\&/g' <<< "$IFRAME_SRC")
        
        # Perform replacement
        sed -i.bak "s|src=\"__IFRAME_SRC_PLACEHOLDER__\"|src=\"${ESCAPED_SRC}\"|g" "$INDEX_HTML"
        
        # Verify replacement
        if grep -q "src=\"${IFRAME_SRC}\"" "$INDEX_HTML"; then
            print_success "iframe source updated to ${COLOR_CYAN}${IFRAME_SRC}${COLOR_RESET}"
        else
            print_error "Failed to update iframe source - please check URL format"
        fi
    else
        print_warning "Placeholder not found - ensure index.html contains: src=\"__IFRAME_SRC_PLACEHOLDER__\""
    fi
else
    print_error "index.html not found at ${INDEX_HTML}"
    exit 1
fi

# Docker Setup
echo -e "\n${COLOR_CYAN}${SECTION_BREAK}"
echo "           Docker Container Setup"
echo -e "${SECTION_BREAK}${COLOR_RESET}"

print_status "Checking Docker requirements..."
if ! command -v docker >/dev/null 2>&1; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi

if ! docker compose version >/dev/null 2>&1; then
    print_error "Docker Compose plugin is required. Please install Docker Compose V2."
    exit 1
fi

print_status "Starting Docker containers..."
if cd "$INSTALL_DIR" && docker compose up -d; then
    print_success "Docker containers started successfully"
else
    print_error "Failed to start Docker containers"
    exit 1
fi

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
