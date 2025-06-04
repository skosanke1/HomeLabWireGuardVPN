# WireGuard Home VM VPN

This project sets up a secure VPN using WireGuard on a Virtual Machine running Ubuntu. It allows remote clients (e.g. a mobile phone using cellular data) 
to securely access your home network via encrypted tunnels.  While completing this project, I learned a lot about VPN configuration, encryption, IP routing,
and secure remotely accessing infrastructure.

## Features

- WireGuard VPN server configured on an Ubuntu VM
- Easy client peer configuration
- Start-up script for automation
- Tested and working end-to-end VPN setup
- Launch-ready for Wireshark monitoring

## Requirements

- Ubuntu 20.04 or later (tested on Ubuntu 24.04 VM)
- WireGuard installed (`apt install wireguard`)
- Root or sudo privileges
- Port forwarding on your router for port 51820/UDP

## Setup Instructions
### 1. Clone the Repository

`git clone https://github.com/skosanke1/HomeLabWireGuardVPN;` <br>
`cd HomeLabWireGuardVPN`


### 2. Fill in Configuration Data
Replace `*Values*` within server.conf, client1.conf, and client2.conf to include your actual private/public keys and IPs. <br>
Generate keys (public and private) with: <br>
`wg genkey | tee privatekey | wg pubkey > publickey` <br>
Discover the public IPv4 for clients config file to by going to https://whatismyipaddress.com/ <br>


### 3. Enable IP Forwarding
Ensure that port forwarding has been enabled on your router, and the VM IP address has been routed<br>
`echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf` <br>
`sudo sysctl -p`

### 4. Install WireGuard (if not already)
`sudo apt update` <br>
`sudo apt install wireguard`

### 5. Place Config File
Move the server config file: <br>
`sudo cp server.conf /etc/wireguard/wg0.conf`

### 6. Start WireGuard VPN
Manually: <br>
`sudo wg-quick up wg0`

Or, use the provided start script: <br>
`chmod +x start.sh`<br>
`./start.sh`

### 7. Enable at Boot
`sudo systemctl enable wg-quick@wg0`
