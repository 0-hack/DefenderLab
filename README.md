# Defender Lab
This is a simple web interface for recreating your [webtop](https://docs.linuxserver.io/images/docker-webtop/) Docker container via a sidebar. For now, it's ideal for users who need to quickly check a suspicious website or verify unknown file/tool in an isolated Linux environment (without using container platform/backend CLI), and then revert to a clean state afterward. 

Why not [KasmWeb](https://www.kasmweb.com)? This web interface is a lightweight solution built specifically for quickly launching and resetting a Webtop container. It’s ideal for users who want a fast, simple way to check websites or content in an isolated environment without the complexity or setup. 
*I'm still a fan of Kasm, but it would be nice if it's fully free (to support personalize logo and multiple user session).*

![Alt Text](https://github.com/0-hack/DefenderLab/blob/main/webtop-control/img/Dashboard.png)
---

## Prerequisites
- Ubuntu OS (tested on version 22.04 64 bit)
- Docker & Docker Compose installed
- Python 3 and pip3 (the setup script will install pip3 if missing)
- Root (sudo) access

## Tested on RackNerd VPS
Support my work by buying a VPS from RackNerd at https://my.racknerd.com/aff.php?aff=12799 to keep my project going.
OR you may also buy me a coffee over https://buymeacoffee.com/zerohack

## Quick Start

1. **Clone or Download the Repository**
   - Place the DefenderLab folder anywhere on your system. The setup script will move it to `/opt/DefenderLab` if needed.

2. **Run the Setup Script**
   ```bash
   cd /path/to/DefenderLab
   chmod +x setup_defenderlab.sh
   ./setup_defenderlab.sh
   ```
   - You will be prompted for the webtop docker's source URL for the Defender Lab's website iframe.
   - **If you are not exposing your server IP/domain for your webtop Docker container, just press Enter to use the default (`http://localhost:3000`).**
   - Issues may arise when accessing the interface from a different internal host. Use your local IP address instead to avoid problems.

3. **What the Script Does**
   - Update your system’s hosts file to map your hostname to 127.0.0.1 to avoid issues resolving the backend.
   - Installs required Python dependencies (Flask)
   - Sets executable permissions for scripts
   - Sets up a systemd service for the web interface
   - Prompts for and injects the correct iframe source into the web interface
   - Starts and enables the service

5. **Access the Web Interface**
   - Open your browser and go to the address `http://localhost:5000` if you used the default.
   - The Defender Lab web interface should now be running and accessible.

6. **Resetting the Webtop**
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

## Security
- Set up a firewall or third-party access control if you plan to expose this web interface publicly.
- If you're using Cloudflare Tunnel, you can implement an access policy to restrict access to your domain. However, on cloud servers, your public IP remains exposed.
- Ensure your firewall (ufw) and iptables is configured to block/prevent direct access via the server’s IP address.
- You can run setup_rules.sh to allow only localhost (127.0.0.1:5000) access (compatible with Cloudflare Tunnel) and deny all external traffic to ports 3000 (webtop) and 5000 (webtop-control). Remember to change the port detail on your docker-compose.yaml from "3000:3000" to "127.0.0.1:3000:3000" for this setup.
- SSH (port 22) remains open in this firewall rule to retain remote access.

## Notes
- This project is under active development. More features and improvements will be added as time permits.
- For issues or suggestions, please contact the developer or open an issue if hosted on a platform like GitHub.

---

Enjoy using Defender Lab!
