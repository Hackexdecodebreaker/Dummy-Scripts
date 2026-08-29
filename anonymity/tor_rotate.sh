#!/usr/bin/env bash

if command -v figlet &> /dev/null; then
    figlet -f small "Xcyberex"
    echo "Github: Hackexdecodebreaker"
elif command -v toilet &> /dev/null; then
    toilet -f small "Xcyberex"
    echo "Github: Hackexdecodebreaker"
else
    echo "Xcyberex (Github: Hackexdecodebreaker)"
fi

if ! command -v tor &> /dev/null; then
    echo "Error: 'tor' is not installed." >&2
    exit 1
fi

if ! command -v curl &> /dev/null; then
    echo "Error: 'curl' is not installed." >&2
    exit 1
fi

echo "Starting Tor automated circuit renewal service..."

while true; do
    if command -v systemctl &> /dev/null; then
        systemctl reload tor
    elif command -v service &> /dev/null; then
        service tor reload
    fi

    sleep 3

    NEW_IP=$(curl -s --socks5-hostname 127.0.0.1:9050 https://api.ipify.org || echo "Failed to fetch IP")
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] Current Tor IP: $NEW_IP"
    
    sleep 600
done