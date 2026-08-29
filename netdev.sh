#!/bin/bash
# Network device enumeration script
# Author: Hackexdecodebreaker (https://github.com/Hackexdecodebreaker)

figlet -f slant "NETDEV"
toilet -f mono12 -F metal "Author: Hackexdecodebreaker"
toilet -f mono12 -F metal "GitHub: github.com/Hackexdecodebreaker"
echo ""

if [ $# -eq 0 ]; then
    echo "Usage: $0 <network-range>"
    echo "Example: $0 192.168.1.0/24"
    echo "         $0 10.0.0.0/8"
    exit 1
fi

NETWORK=$1
OUTDIR="netdev_${NETWORK//\//_}_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUTDIR"

echo "[+] Scanning network: $NETWORK"
echo "[+] Output directory: $OUTDIR"

# ARP scan (local network)
echo "[+] ARP scan..."
arp-scan --interface=$(ip route | grep default | awk '{print $5}' | head -1) "$NETWORK" -o "$OUTDIR/arp_scan.txt" 2>/dev/null || echo "  arp-scan not found or needs root, trying nmap..."

# Nmap ping sweep
echo "[+] Nmap ping sweep..."
nmap -sn "$NETWORK" -oN "$OUTDIR/nmap_ping.txt" -oX "$OUTDIR/nmap_ping.xml" 2>/dev/null
grep "Nmap scan report" "$OUTDIR/nmap_ping.txt" | awk '{print $5}' | sort -u > "$OUTDIR/live_hosts.txt"
LIVE_COUNT=$(wc -l < "$OUTDIR/live_hosts.txt")
echo "  Found $LIVE_COUNT live hosts"

# Service scan on live hosts
if [ $LIVE_COUNT -gt 0 ]; then
    echo "[+] Service scanning live hosts..."
    nmap -sS -sV -T4 -iL "$OUTDIR/live_hosts.txt" --min-rate 1000 -oN "$OUTDIR/nmap_services.txt" -oX "$OUTDIR/nmap_services.xml" 2>/dev/null
    
    # OS detection
    echo "[+] OS detection..."
    nmap -O -iL "$OUTDIR/live_hosts.txt" --min-rate 500 -oN "$OUTDIR/nmap_os.txt" 2>/dev/null || echo "  OS detection needs root"
    
    # Vulnerability scan
    echo "[+] Vulnerability scan..."
    nmap --script vuln -iL "$OUTDIR/live_hosts.txt" -oN "$OUTDIR/nmap_vuln.txt" 2>/dev/null || echo "  vuln scripts need root or failed"
fi

# Masscan for fast port discovery
echo "[+] Masscan (fast port scan)..."
masscan "$NETWORK" -p1-65535 --rate 10000 -oL "$OUTDIR/masscan.txt" 2>/dev/null || echo "  masscan not found or needs root"

# Netdiscover
echo "[+] Netdiscover..."
netdiscover -r "$NETWORK" -P -o "$OUTDIR/netdiscover.txt" 2>/dev/null || echo "  netdiscover not found"

# Summary
echo ""
echo "[+] Scan complete. Results in $OUTDIR/"
echo "[+] Live hosts: $LIVE_COUNT"
echo "[+] Files generated:"
ls -la "$OUTDIR/"
