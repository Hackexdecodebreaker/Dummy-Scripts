#!/bin/bash
# Recon automation script
# Author: Hackexdecodebreaker (https://github.com/Hackexdecodebreaker)

figlet -f slant "RECON"
toilet -f mono12 -F metal "Author: Hackexdecodebreaker"
toilet -f mono12 -F metal "GitHub: github.com/Hackexdecodebreaker"
echo ""

if [ $# -eq 0 ]; then
    echo "Usage: $0 <target-domain-or-ip>"
    echo "Example: $0 example.com"
    exit 1
fi

TARGET=$1
OUTDIR="recon_${TARGET}_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUTDIR"

echo "[+] Starting recon on $TARGET"
echo "[+] Output directory: $OUTDIR"

# Subdomain enumeration
echo "[+] Subdomain enumeration..."
subfinder -d "$TARGET" -silent -o "$OUTDIR/subdomains.txt" 2>/dev/null || echo "  subfinder not found, skipping"
assetfinder --subs-only "$TARGET" >> "$OUTDIR/subdomains.txt" 2>/dev/null || echo "  assetfinder not found, skipping"
amass enum -passive -d "$TARGET" >> "$OUTDIR/subdomains.txt" 2>/dev/null || echo "  amass not found, skipping"
sort -u "$OUTDIR/subdomains.txt" -o "$OUTDIR/subdomains.txt"
echo "  Found $(wc -l < "$OUTDIR/subdomains.txt") unique subdomains"

# Port scanning
echo "[+] Port scanning..."
nmap -sS -T4 -p- --min-rate 1000 "$TARGET" -oN "$OUTDIR/nmap_full.txt" 2>/dev/null || echo "  nmap failed"
nmap -sV -sC -p $(grep ^[0-9] "$OUTDIR/nmap_full.txt" | cut -d'/' -f1 | tr '\n' ',' | sed 's/,$//') "$TARGET" -oN "$OUTDIR/nmap_services.txt" 2>/dev/null || echo "  nmap service scan failed"

# HTTP probing
echo "[+] HTTP probing..."
httpx -l "$OUTDIR/subdomains.txt" -silent -status-code -title -tech-detect -o "$OUTDIR/httpx.txt" 2>/dev/null || echo "  httpx not found, skipping"

# Directory bruteforce
echo "[+] Directory enumeration..."
ffuf -u "https://$TARGET/FUZZ" -w /usr/share/wordlists/dirb/common.txt -mc 200,204,301,302,307,401,403 -o "$OUTDIR/ffuf.json" -of json 2>/dev/null || echo "  ffuf not found, skipping"

# SSL/TLS info
echo "[+] SSL/TLS analysis..."
testssl.sh "$TARGET" --jsonfile "$OUTDIR/testssl.json" 2>/dev/null || echo "  testssl.sh not found, skipping"

# Screenshots
echo "[+] Taking screenshots..."
gowitness file -f "$OUTDIR/httpx.txt" -P "$OUTDIR/screenshots/" 2>/dev/null || echo "  gowitness not found, skipping"

echo "[+] Recon complete. Results in $OUTDIR/"
