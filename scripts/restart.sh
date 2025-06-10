#!/bin/bash

SERVICE="wg-quick@wg0"
STATUS=$(systemctl is-active $SERVICE)

if ["$STATUS" != "active" ]; then
  echo "$(date "+%Y-%m-%d %H:%M:%S") - $SERVICE is down. Restarting.." >>/home/server123/Desktop/wg/logs/logs.txt
  sudo systemctl restart SERVICE
fi