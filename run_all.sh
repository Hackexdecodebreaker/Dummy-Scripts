#!/bin/bash
# Master launcher for all custom scripts
# Author: Hackexdecodebreaker (https://github.com/Hackexdecodebreaker)

figlet -f slant "CUSTOM SCRIPTS"
toilet -f mono12 -F metal "Author: Hackexdecodebreaker"
toilet -f mono12 -F metal "GitHub: github.com/Hackexdecodebreaker"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Available scripts by category:"
echo ""
echo "  RECON:"
echo "    recon/recon.sh      - Full recon automation (subdomains, ports, HTTP, dirs, SSL)"
echo "    recon/X-For.sh      - HTTP header checker"
echo "    recon/rec.sh        - Network host discovery via nmap"
echo ""
echo "  NETWORK:"
echo "    network/netdev.sh   - Network device enumeration (ARP, nmap, masscan, netdiscover)"
echo "    network/mac_change.sh - MAC address changer"
echo ""
echo "  BYPASS:"
echo "    bypass/bypass.sh          - Security bypass techniques (WAF, headers, paths, methods, SSRF)"
echo "    bypass/ipblock_bypass.sh  - IP blocking bypass via header manipulation"
echo ""
echo "  PRIVESC:"
echo "    privesc/privesc.sh  - Privilege escalation enumeration (SUID, sudo, caps, cron, GTFOBins)"
echo ""
echo "  PAYLOAD:"
echo "    payload/RVS.sh      - Metasploit payload generator"
echo ""
echo "  ANONYMITY:"
echo "    anonymity/tor_rotate.sh - Tor circuit rotation"
echo ""
echo "  UTILS:"
echo "    utils/MyArchive.sh  - Custom archive packager with manifest"
echo "    utils/run_all.sh    - This launcher"
echo ""
echo "Usage:"
echo "  $0 <category/script-name> [args...]"
echo "  $0 recon/recon.sh example.com"
echo "  $0 network/netdev.sh 192.168.1.0/24"
echo "  $0 bypass/bypass.sh https://target.com"
echo "  $0 privesc/privesc.sh"
echo "  $0 bypass/ipblock_bypass.sh https://target.com"
echo ""

if [ $# -eq 0 ]; then
    exit 0
fi

SCRIPT_PATH="$1"
shift

if [ -f "$SCRIPT_DIR/$SCRIPT_PATH" ]; then
    exec "$SCRIPT_DIR/$SCRIPT_PATH" "$@"
else
    echo "Script not found: $SCRIPT_DIR/$SCRIPT_PATH"
    exit 1
fi
