#!/bin/bash
# Master launcher for all custom scripts
# Author: Hackexdecodebreaker (https://github.com/Hackexdecodebreaker)

figlet -f slant "CUSTOM SCRIPTS"
toilet -f mono12 -F metal "Author: Hackexdecodebreaker"
toilet -f mono12 -F metal "GitHub: github.com/Hackexdecodebreaker"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Available scripts:"
echo "  1) recon.sh     - Full recon automation (subdomains, ports, HTTP, dirs, SSL)"
echo "  2) netdev.sh    - Network device enumeration (ARP, nmap, masscan, netdiscover)"
echo "  3) bypass.sh    - Security bypass techniques (WAF, headers, paths, methods, SSRF)"
echo "  4) privesc.sh   - Privilege escalation enumeration (SUID, sudo, caps, cron, GTFOBins)"
echo ""
echo "Usage:"
echo "  $0 <script-name> [args...]"
echo "  $0 recon.sh example.com"
echo "  $0 netdev.sh 192.168.1.0/24"
echo "  $0 bypass.sh https://target.com"
echo "  $0 privesc.sh"
echo ""

if [ $# -eq 0 ]; then
    exit 0
fi

SCRIPT="$1"
shift

case "$SCRIPT" in
    recon.sh|netdev.sh|bypass.sh|privesc.sh)
        if [ -f "$SCRIPT_DIR/$SCRIPT" ]; then
            exec "$SCRIPT_DIR/$SCRIPT" "$@"
        else
            echo "Script not found: $SCRIPT_DIR/$SCRIPT"
            exit 1
        fi
        ;;
    *)
        echo "Unknown script: $SCRIPT"
        exit 1
        ;;
esac
