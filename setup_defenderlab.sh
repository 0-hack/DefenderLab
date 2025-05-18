#!/bin/bash
# Defender Lab Setup Script
set -e

# Setup output formatting
COLOR_GREEN='\033[0;32m'
COLOR_CYAN='\033[0;36m'
COLOR_RESET='\033[0m'
SECTION_BREAK="================================================================"

print_status() {
    echo -e "${COLOR_CYAN}[STATUS]${COLOR_RESET} $1"
}

print_success() {
    echo -e "${COLOR_GREEN}[SUCCESS]${COLOR_RESET} $1"
}

# Initialization Phase
echo -e "\n${COLOR_CYAN}${SECTION_BREAK}"
echo "           Defender Lab Setup - Initialization"
echo -e "${SECTION_BREAK}${COLOR_RESET}\n"

# Prompt for iframe source with default
read -p "Enter the iframe source URL for the webtop (default: http://localhost:3000): " IFRAME_SRC
IFRAME_SRC=${IFRAME_SRC:-http://localhost:3000}
echo -e "\nUsing iframe source: ${COLOR_CYAN}${IFRAME_SRC}${COLOR_RESET}"
echo "(Default is suitable if you do not have a public-facing server IP/domain)"

# Set variables
INSTALL_DIR="/opt/DefenderLab"
SERVICE_FILE="/etc/systemd/system/webtop-control.service"
INDEX_HTML="$INSTALL_DIR/webtop-control/index.html"

# Ensure running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run this script as root (sudo)."
    exit 1
fi

# File Copy Phase
echo -e "\n${COLOR_CYAN}${SECTION_BREAK}"
echo "           File System Setup"
echo -e "${SECTION_BREAK}${COLOR_RESET}"

if [ ! -d "$INSTALL_DIR" ]; then
    print_status "Copying DefenderLab files to ${INSTALL_DIR}..."
    cp -r "$(dirname "$0")" "$INSTALL_DIR" > /dev/null
    print_success "Files copied successfully"
else
    print_status "Installation directory already exists - skipping copy"
fi

# Permissions Setup
print_status "Setting file permissions..."
chmod +x "$INSTALL_DIR/reset_webtop.sh" > /dev/null
chmod 755 "$INSTALL_DIR/webtop-control/app.py" > /dev/null
print_success "Permissions configured"

# Dependency Installation
echo -e "\n${COLOR_CYAN}${SECTION_BREAK}"
echo "           Dependency Installation"
echo -e "${SECTION_BREAK}${COLOR_RESET}"

if ! command -v pip3 >/dev/null 2>&1; then
    print_status "Installing python3-pip..."
    apt-get update > /dev/null && apt-get install python3-pip -y > /dev/null
    print_success "python3-pip installed"
else
    print_status "python3-pip already installed - skipping"
fi

print_status "Installing Python dependencies..."
pip3 install flask > /dev/null
print_success "Flask installed"

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
systemctl daemon-reload > /dev/null
systemctl enable webtop-control > /dev/null
systemctl restart webtop-control > /dev/null
print_success "Webtop control service active and running"

# Configuration Phase
echo -e "\n${COLOR_CYAN}${SECTION_BREAK}"
echo "           Final Configuration"
echo -e "${SECTION_BREAK}${COLOR_RESET}"

print_status "Updating iframe source..."
if grep -q '<iframe[^>]*id="mainFrame"' "$INDEX_HTML"; then
    ESCAPED_SRC=$(sed -e 's/[\/&]/\\&/g' <<< "$IFRAME_SRC")
    sed -i "s|<iframe[^>]*id=\"mainFrame\"[^>]*src=\"[^"]*\"|<iframe id=\"mainFrame\" src=\"$ESCAPED_SRC\"|" "$INDEX_HTML"
    print_success "iframe source updated to ${IFRAME_SRC}"
else
    echo "Warning: iframe tag with id=mainFrame not found - please update manually"
fi

# Completion Message
echo -e "\n${COLOR_GREEN}${SECTION_BREAK}"
echo "           Setup Completed Successfully!"
echo -e "${SECTION_BREAK}${COLOR_RESET}"
echo -e "You can now access the Defender Lab web interface at:"
echo -e "${COLOR_CYAN}http://$(hostname -I | awk '{print $1}')${COLOR_RESET}\n"
