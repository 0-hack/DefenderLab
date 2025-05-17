Download the repository and place them in /opt folder.

Setup permission
Run 	chmod +x /opt/webtop-control/reset_webtop.sh
	chmod 755 /opt/webtop-control/app.py

Create a systemd service to run the web interface
[Unit]
Description=Webtop Control Interface
After=network.target

[Service]
ExecStart=/usr/bin/python3 /opt/webtop-control/app.py
WorkingDirectory=/opt/webtop-control
Restart=always
User=root

[Install]
WantedBy=multi-user.target

Download python pip and flask 
sudo apt-get update && sudo apt-get install python3-pip -y
sudo pip3 install flask

Enable and start the service
sudo systemctl daemon-reload
sudo systemctl enable webtop-control
sudo systemctl start webtop-control

Open your browser to:
http://your-server-ip:5000