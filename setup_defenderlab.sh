#!/bin/bash
# Defender Lab Setup Script
set -e

# Prompt for iframe source with default
read -p "Enter the iframe source URL for the webtop (default: http://localhost:3000): " IFRAME_SRC
IFRAME_SRC=${IFRAME_SRC:-http://localhost:3000}
echo "Using iframe source: $IFRAME_SRC"
echo "(Default is suitable if you do not have a public-facing server IP/domain for the webtop Docker container.)"

# Set variables
INSTALL_DIR="/opt/DefenderLab"
SERVICE_FILE="/etc/systemd/system/webtop-control.service"
INDEX_HTML="$INSTALL_DIR/webtop-control/index.html"

# Ensure running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run this script as root (sudo)."
    exit 1
fi

# Check for Docker requirements
if ! command -v docker >/dev/null 2>&1; then
    echo "Error: Docker is required but not installed. Please install Docker first."
    exit 1
fi

if ! docker compose version >/dev/null 2>&1; then
    echo "Error: Docker Compose plugin is required. Please install Docker Compose V2."
    exit 1
fi

# Copy files if not already in /opt/DefenderLab
if [ ! -d "$INSTALL_DIR" ]; then
    echo "Copying DefenderLab files to $INSTALL_DIR ..."
    cp -r "$(dirname "$0")" "$INSTALL_DIR"
fi

# Set permissions
chmod +x "$INSTALL_DIR/reset_webtop.sh"
chmod 755 "$INSTALL_DIR/webtop-control/app.py"

# Install dependencies
if ! command -v pip3 >/dev/null 2>&1; then
    echo "Installing python3-pip ..."
    apt-get update && apt-get install python3-pip -y
fi
pip3 install flask

# Create systemd service
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

# Reload and enable/start service
systemctl daemon-reload
systemctl enable webtop-control
systemctl restart webtop-control

echo "Systemd service installed and started."

# Update iframe src in index.html
ESCAPED_SRC=$(sed -e 's/[\/&]/\\&/g' <<< "$IFRAME_SRC")
if grep -q 'src="__IFRAME_SRC_PLACEHOLDER__"' "$INDEX_HTML"; then
    sed -i.bak "s|src=\"__IFRAME_SRC_PLACEHOLDER__\"|src=\"${ESCAPED_SRC}\"|g" "$INDEX_HTML"
    echo "Updated iframe src in index.html to $IFRAME_SRC"
else
    echo "Placeholder not found in $INDEX_HTML. Please update manually."
fi

# Start Docker containers
echo "Starting Docker containers in $INSTALL_DIR..."
cd "$INSTALL_DIR" && docker compose up -d

echo "Defender Lab setup completed! Open your browser to access the web interface."
