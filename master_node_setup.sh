#!/bin/bash

echo "[Node Exporter] : download..."
su vagrant -c "cd ~/"
su vagrant -c "wget https://github.com/prometheus/node_exporter/releases/download/v1.5.0/node_exporter-1.5.0.linux-amd64.tar.gz"
echo "[Node Exporter] : successfully downloaded..."

echo "[Node Exporter] : installation..."
su vagrant -c "cd ~/"
su vagrant -c "tar xvfz node_exporter-*.linux-amd64.tar.gz"
cd node_exporter-*.*-amd64
cp node_exporter /usr/bin

echo "[Node Exporter] : creating a user..."
useradd -r -M -s /bin/false node_exporter
chown node_exporter:node_exporter /usr/bin/node_exporter

echo "[Node Exporter] : creating a system unit..."
{   echo '[Unit]'; \
    echo 'Description=Prometheus Node Exporter'; \
    echo '[Service]'; \
    echo 'User=node_exporter'; \
    echo 'Group=node_exporter'; \
    echo 'Type=simple'; \
    echo 'ExecStart=/usr/bin/node_exporter'; \
    echo '[Install]'; \
    echo 'WantedBy=multi-user.target'; \
} | tee /etc/systemd/system/node_exporter.service; \
echo "[Node Exporter] : reload daemon..."
systemctl daemon-reload
echo "[Node Exporter] : enable node exporter..."
systemctl enable --now node_exporter
systemctl status node_exporter
su vagrant -c "rm -rf ~/node_exporter-*"
echo "Node exporter has been setup succefully!"
echo "[GoCD] : add repository..."
echo "deb https://download.gocd.org /" | sudo tee /etc/apt/sources.list.d/gocd.list
su vagrant -c "curl https://download.gocd.org/GOCD-GPG-KEY.asc | sudo apt-key add -"
echo "[GoCD] : update system..."
apt update && apt upgrade
echo "[GoCD] : installing..."
apt-get install go-agent
