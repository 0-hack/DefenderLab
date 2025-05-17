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
if grep -q '<iframe[^>]*id="mainFrame"' "$INDEX_HTML"; then
    sed -i "s|<iframe[^>]*id=\"mainFrame\"[^>]*src=\"[^"]*\"|<iframe id=\"mainFrame\" src=\"$IFRAME_SRC\"|" "$INDEX_HTML"
    echo "Updated iframe src in index.html to $IFRAME_SRC"
else
    echo "iframe tag with id=mainFrame not found in $INDEX_HTML. Please update manually."
fi

echo "Defender Lab setup completed! Open your browser to access the web interface."
