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

if ! command -v curl &> /dev/null; then
    echo "Error: 'curl' is not installed." >&2
    exit 1
fi

read -p "Enter Target URL (e.g., https://example.com): " TARGET_URL

if [[ -z "$TARGET_URL" ]]; then
    echo "Error: Target URL cannot be empty." >&2
    exit 1
fi

echo "Checking HTTP headers for $TARGET_URL..."

HEADERS=$(curl -sI -L "$TARGET_URL")

if [[ $? -ne 0 ]]; then
    echo "Error: Failed to reach $TARGET_URL" >&2
    exit 1
fi

echo "----------------------------------------"
if echo "$HEADERS" | grep -iq "X-Forwarded-For"; then
    echo "X-Forwarded-For header found:"
    echo "$HEADERS" | grep -i "X-Forwarded-For"
else
    echo "X-Forwarded-For header is NOT present in the server response."
fi
echo "----------------------------------------"