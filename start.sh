#!/bin/bash

# Enable IPv4 forwarding (necessary for routing traffic through the VPN)
sudo sysctl -w net.ipv4.ip_forward=1

# Start the WireGuard interface named 'wg0'
sudo systemctl start wg-quick@wg0

# Enable the WireGuard service to start at boot
sudo systemctl enable wg-quick@wg0

# Show the current status and configuration of the WireGuard interface
sudo wg show
