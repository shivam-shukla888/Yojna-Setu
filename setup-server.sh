#!/bin/bash
sudo tee /etc/systemd/system/yojna-setu.service << 'EOF'
[Unit]
Description=Yojna Setu Spring Boot App
After=network.target mysql.service

[Service]
Type=forking
User=ubuntu
ExecStart=/home/ubuntu/start-app.sh
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable yojna-setu
sudo systemctl start yojna-setu
echo "Service setup complete!"
