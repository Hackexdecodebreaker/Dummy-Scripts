#!/bin/bash
# Privilege escalation enumeration script
# Author: Hackexdecodebreaker (https://github.com/Hackexdecodebreaker)


figlet -f slant "PRIVESC"
toilet -f mono12 -F metal "Author: Hackexdecodebreaker"
toilet -f mono12 -F metal "GitHub: github.com/Hackexdecodebreaker"
echo ""

OUTDIR="privesc_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUTDIR"

echo "[+] Privilege escalation enumeration"
echo "[+] Output directory: $OUTDIR"

# System info
echo "[+] System information..."
uname -a > "$OUTDIR/system_info.txt"
cat /etc/os-release >> "$OUTDIR/system_info.txt" 2>/dev/null
cat /etc/issue >> "$OUTDIR/system_info.txt" 2>/dev/null
hostname >> "$OUTDIR/system_info.txt"
whoami >> "$OUTDIR/system_info.txt"
id >> "$OUTDIR/system_info.txt"

# Kernel exploits
echo "[+] Checking kernel version for known exploits..."
KERNEL=$(uname -r)
echo "Kernel: $KERNEL" >> "$OUTDIR/kernel_exploits.txt"
searchsploit --colour "Linux Kernel $KERNEL" >> "$OUTDIR/kernel_exploits.txt" 2>/dev/null || echo "  searchsploit not found"

# Sudo permissions
echo "[+] Sudo permissions..."
sudo -l 2>/dev/null > "$OUTDIR/sudo_perms.txt" || echo "  Cannot run sudo -l" >> "$OUTDIR/sudo_perms.txt"

# SUID/SGID binaries
echo "[+] SUID/SGID binaries..."
find / -type f \( -perm -4000 -o -perm -2000 \) -exec ls -la {} \; 2>/dev/null > "$OUTDIR/suid_sgid.txt"
echo "  Found $(wc -l < "$OUTDIR/suid_sgid.txt") binaries"

# Capabilities
echo "[+] File capabilities..."
getcap -r / 2>/dev/null > "$OUTDIR/capabilities.txt" || echo "  getcap not found"

# Cron jobs
echo "[+] Cron jobs..."
crontab -l 2>/dev/null > "$OUTDIR/user_cron.txt"
ls -la /etc/cron* 2>/dev/null >> "$OUTDIR/system_cron.txt"
cat /etc/crontab 2>/dev/null >> "$OUTDIR/system_cron.txt"
for f in /etc/cron.d/*; do [ -f "$f" ] && echo "=== $f ===" && cat "$f"; done 2>/dev/null >> "$OUTDIR/system_cron.txt"

# World-writable files
echo "[+] World-writable files..."
find / -type f -perm -002 -not -path "/proc/*" -not -path "/sys/*" -not -path "/dev/*" -exec ls -la {} \; 2>/dev/null > "$OUTDIR/world_writable.txt"

# PATH vulnerabilities
echo "[+] PATH analysis..."
echo $PATH | tr ':' '\n' | while read dir; do
    if [ -w "$dir" ]; then
        echo "  WORLD WRITABLE PATH DIR: $dir" >> "$OUTDIR/path_vulns.txt"
    fi
    ls -la "$dir" 2>/dev/null | head -20 >> "$OUTDIR/path_contents.txt"
done

# Docker/LXC escape checks
echo "[+] Container escape checks..."
if [ -f /.dockerenv ]; then
    echo "  Running inside Docker" >> "$OUTDIR/container.txt"
    cat /proc/1/cgroup >> "$OUTDIR/container.txt"
    docker version 2>/dev/null >> "$OUTDIR/container.txt"
fi
if grep -qa lxc /proc/1/cgroup 2>/dev/null; then
    echo "  Running inside LXC" >> "$OUTDIR/container.txt"
fi

# Kernel modules
echo "[+] Loaded kernel modules..."
lsmod > "$OUTDIR/kernel_modules.txt"

# Network info
echo "[+] Network configuration..."
ip a > "$OUTDIR/network.txt"
ip route >> "$OUTDIR/network.txt"
ss -tulpn 2>/dev/null >> "$OUTDIR/network.txt"
netstat -tulpn 2>/dev/null >> "$OUTDIR/network.txt"

# Interesting files
echo "[+] Interesting files..."
INTERESTING=(
    "/etc/passwd"
    "/etc/shadow"
    "/etc/sudoers"
    "/root/.ssh/id_rsa"
    "/home/*/.ssh/id_rsa"
    "/var/www/html/config.php"
    "/etc/nginx/nginx.conf"
    "/etc/apache2/apache2.conf"
    "/opt/"
    "/usr/local/"
)
for file in "${INTERESTING[@]}"; do
    ls -la $file 2>/dev/null >> "$OUTDIR/interesting_files.txt"
done

# LinPEAS / LinEnum style checks
echo "[+] Running LinPEAS-style checks..."
# Users with shell
grep -v "nologin\|false" /etc/passwd > "$OUTDIR/users_with_shell.txt"
# SSH keys
find /home -name "authorized_keys" -o -name "id_rsa" -o -name "id_ed25519" 2>/dev/null > "$OUTDIR/ssh_keys.txt"
# History files
find /home -name ".*history" 2>/dev/null > "$OUTDIR/history_files.txt"
# Web roots
find /var/www -type f -name "*.php" -o -name "*.py" -o -name "*.js" -o -name "*.jsp" 2>/dev/null | head -50 > "$OUTDIR/web_files.txt"

# GTFOBins check for SUID binaries
echo "[+] Checking SUID binaries against GTFOBins..."
if [ -f "$OUTDIR/suid_sgid.txt" ]; then
    while read line; do
        binary=$(echo "$line" | awk '{print $NF}' | xargs basename 2>/dev/null)
        if [ ! -z "$binary" ]; then
            curl -s "https://gtfobins.github.io/gtfobins/$binary/" 2>/dev/null | grep -q "functions" && echo "  GTFOBin found: $binary" >> "$OUTDIR/gtfobins.txt"
        fi
    done < "$OUTDIR/suid_sgid.txt"
fi

echo ""
echo "[+] Privilege escalation enumeration complete. Results in $OUTDIR/"
echo "[+] Key files:"
ls -la "$OUTDIR/"
