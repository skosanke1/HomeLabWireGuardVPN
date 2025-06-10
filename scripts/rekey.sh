#!/bin/bash

# WireGuard Configuration Script
# This script generates keys and configuration files for a WireGuard VPN server and two clients.
# Ensure WireGuard and curl are installed before running.

set -e  # Exit on error

# ----------------------------
# Ensure dependencies are installed
# ----------------------------
if ! command -v wg &> /dev/null; then
    echo "Error: 'wg' (WireGuard) is not installed. Please install WireGuard."
    exit 1
fi

if ! command -v curl &> /dev/null; then
    echo "Error: 'curl' is not installed. Run: sudo snap install curl"
    exit 1
fi

# ----------------------------
# Set directory paths
# ----------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
KEY_DIR="$BASE_DIR/keys"
CONFIG_DIR="$BASE_DIR/config"

mkdir -p "$KEY_DIR" "$CONFIG_DIR"

# ----------------------------
# 3. Generate WireGuard key pairs
# ----------------------------
generate_keys() {
    local prefix=$1
    wg genkey | tee "$KEY_DIR/${prefix}_private.key" | wg pubkey > "$KEY_DIR/${prefix}_public.key"
}

generate_keys "server"
generate_keys "client1"
generate_keys "client2"

# ----------------------------
# Read keys into variables
# ----------------------------
SERVER_PRIV=$(<"$KEY_DIR/server_private.key")
SERVER_PUB=$(<"$KEY_DIR/server_public.key")
CLIENT1_PRIV=$(<"$KEY_DIR/client1_private.key")
CLIENT1_PUB=$(<"$KEY_DIR/client1_public.key")
CLIENT2_PRIV=$(<"$KEY_DIR/client2_private.key")
CLIENT2_PUB=$(<"$KEY_DIR/client2_public.key")

# Fetch public IP
PUBLIC_IP=$(curl -s ifconfig.me)

# ----------------------------
# Create server configuration
# ----------------------------
cat > "$CONFIG_DIR/wg0.conf" <<EOF
[Interface]
PrivateKey = $SERVER_PRIV
Address = 10.0.0.1/24
ListenPort = 51820
SaveConfig = true

# NAT setup
PostUp = iptables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE
PostDown = iptables -t nat -D POSTROUTING -o enp0s3 -j MASQUERADE

[Peer]
PublicKey = $CLIENT1_PUB
AllowedIPs = 10.0.0.2/32

[Peer]
PublicKey = $CLIENT2_PUB
AllowedIPs = 10.0.0.3/32
EOF

# Optionally copy the server config to WireGuard's system config directory or uncomment below.
# sudo cp "$CONFIG_DIR/wg0.conf" /etc/wireguard/wg0.conf

# ----------------------------
# Create client configuration files
# ----------------------------
create_client_config() {
    local client_priv=$1
    local client_ip=$2
    local file_path=$3

    cat > "$file_path" <<EOF
[Interface]
PrivateKey = $client_priv
Address = $client_ip/24
DNS = 1.1.1.1

[Peer]
PublicKey = $SERVER_PUB
Endpoint = $PUBLIC_IP:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOF
}

create_client_config "$CLIENT1_PRIV" "10.0.0.2" "$CONFIG_DIR/wgclient1.conf"
create_client_config "$CLIENT2_PRIV" "10.0.0.3" "$CONFIG_DIR/wgclient2.conf"

# ----------------------------
# Secure the keys
# ----------------------------
chmod 600 "$KEY_DIR"/*.key
chmod 600 "$CONFIG_DIR"/wg*.conf

echo "✅ WireGuard configuration and keys generated successfully."
echo "Ensure that s0.conf has been added to /etc/wireguard/ and clients securely receive keys."



