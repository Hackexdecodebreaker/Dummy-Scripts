#!/usr/bin/env bash

if command -v figlet &> /dev/null; then
    figlet "Xcyberex"
elif command -v toilet &> /dev/null; then
    toilet "Xcyberex"
fi

if ! command -v nmap &> /dev/null; then
    echo "Error: 'nmap' is not installed." >&2
    exit 1
fi

TARGET_NETWORK="${1:-}"

if [[ -z "$TARGET_NETWORK" ]]; then
    read -p "Enter target network CIDR (e.g., 192.168.1.0/24): " TARGET_NETWORK
fi

echo "Scanning $TARGET_NETWORK..."

HOST_COUNT=$(nmap -sn -n "$TARGET_NETWORK" | grep -oP 'Nmap done: \d+ IP addresses \(\K\d+(?= host)' || echo "0")

echo "----------------------------------------"
echo "Active devices found: $HOST_COUNT"
