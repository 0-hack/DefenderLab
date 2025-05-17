# Defender Lab

This is a simple web interface to recreate your webtop docker container through a side bar. Ideal for user who just want to run a quick check against website or verify content in an isolated environment. This was developed to easily reset the container without accessing the host, or other container management tool like portainer. Aside from all the well-known sandbox out there, this was created based on the author's personal preference.

More features may be added in the future as development continues.

---

## Prerequisites
- Ubuntu OS (tested on version 22.04 64 bit)
- Docker & Docker Compose installed
- Python 3 and pip3 (the setup script will install pip3 if missing)
- Root (sudo) access

## Tested on RackNerd VPS
Support my work by buying a VPS from RackNerd at https://my.racknerd.com/aff.php?aff=12799 to keep my project going.

## Quick Start

1. **Clone or Download the Repository**
   - Place the DefenderLab folder anywhere on your system. The setup script will move it to `/opt/DefenderLab` if needed.

2. **Run the Setup Script**
   ```bash
   cd /path/to/DefenderLab
   sudo bash setup_defenderlab.sh
   ```
   - You will be prompted for the webtop docker's source URL for the Defender Lab's website iframe.
   - **If you are not exposing your server IP/domain for your webtop Docker container, just press Enter to use the default (`http://localhost:3000`).**

3. **What the Script Does**
   - Installs required Python dependencies (Flask)
   - Sets executable permissions for scripts
   - Sets up a systemd service for the web interface
   - Prompts for and injects the correct iframe source into the web interface
   - Starts and enables the service

4. **Access the Web Interface**
   - Open your browser and go to the address `http://localhost:5000` if you used the default.
   - The Defender Lab web interface should now be running and accessible.

5. **Resetting the Webtop**
   - Use the sidebar button in the web interface to reset the webtop Docker container. This will restart the container using your current Docker Compose setup.
   - Click refresh button to refresh the iframe in order to get back to a new session.

---

## Troubleshooting
- Ensure you run the setup script as root (`sudo`).
- Make sure Docker and Docker Compose are installed and running.
- If you change the iframe source later, you can re-run the setup script or manually edit `webtop-control/index.html`.
- Check the systemd service status:
  ```bash
  sudo systemctl status webtop-control
  ```

---

## Notes
- This project is under active development. More features and improvements will be added as time permits.
- For issues or suggestions, please contact the developer or open an issue if hosted on a platform like GitHub.

---

Enjoy using Defender Lab!
