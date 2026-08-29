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

if [[ $EUID -ne 0 ]]; then
   echo "Error: This script must be run as root (use sudo)." >&2
   exit 1
fi

if ! command -v macchanger &> /dev/null; then
    echo "Error: 'macchanger' is not installed." >&2
    exit 1
fi

read -p "Enter Network Interface (e.g., eth0, wlan0): " INTERFACE

if [[ -z "$INTERFACE" ]]; then
    echo "Error: Interface name cannot be empty." >&2
    exit 1
fi

if ! ip link show "$INTERFACE" &> /dev/null; then
    echo "Error: Interface '$INTERFACE' does not exist." >&2
    exit 1
fi

echo "Changing MAC address for $INTERFACE..."

ip link set dev "$INTERFACE" down
macchanger -r "$INTERFACE"
ip link set dev "$INTERFACE" up

echo "----------------------------------------"
echo "Updated MAC address details:"
macchanger -s "$INTERFACE"
echo "----------------------------------------"