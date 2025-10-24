#!/usr/bin/env python3
"""
Cross-platform script to find the public IP address.
Works on Windows, Linux, macOS, and other Unix-like systems.
"""

import platform
import subprocess
import sys
import urllib.request
import urllib.error
import json
import socket

def detect_os():
    """Detect the operating system."""
    system = platform.system().lower()
    if system == "windows":
        return "windows"
    elif system == "darwin":
        return "macos"
    elif system in ["linux", "freebsd", "openbsd", "netbsd"]:
        return "unix"
    else:
        return "unknown"

def get_public_ip_web():
    """Get public IP using web services as fallback."""
    services = [
        "https://api.ipify.org",
        "https://ipv4.icanhazip.com",
        "https://checkip.amazonaws.com",
        "https://ifconfig.me/ip",
        "https://ipecho.net/plain"
    ]
    
    for service in services:
        try:
            print(f"Trying {service}...")
            with urllib.request.urlopen(service, timeout=10) as response:
                ip = response.read().decode('utf-8').strip()
                if ip and is_valid_ip(ip):
                    return ip
        except (urllib.error.URLError, urllib.error.HTTPError, Exception) as e:
            print(f"  Failed: {e}")
            continue
    
    return None

def is_valid_ip(ip):
    """Check if the string is a valid IP address."""
    try:
        socket.inet_aton(ip)
        return True
    except socket.error:
        return False

def get_public_ip_windows():
    """Get public IP using Windows-specific methods."""
    print("Detected Windows system")
    
    # Try PowerShell method first
    try:
        print("Trying PowerShell method...")
        cmd = [
            "powershell", "-Command",
            "(Invoke-WebRequest -Uri 'https://api.ipify.org' -UseBasicParsing).Content"
        ]
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=15)
        if result.returncode == 0:
            ip = result.stdout.strip()
            if is_valid_ip(ip):
                return ip
    except Exception as e:
        print(f"  PowerShell method failed: {e}")
    
    # Try curl if available
    try:
        print("Trying curl...")
        result = subprocess.run(["curl", "-s", "https://api.ipify.org"], 
                              capture_output=True, text=True, timeout=10)
        if result.returncode == 0:
            ip = result.stdout.strip()
            if is_valid_ip(ip):
                return ip
    except Exception as e:
        print(f"  Curl method failed: {e}")
    
    return None

def get_public_ip_unix():
    """Get public IP using Unix-like system methods."""
    print("Detected Unix-like system (Linux/macOS/BSD)")
    
    # Try curl first
    try:
        print("Trying curl...")
        result = subprocess.run(["curl", "-s", "https://api.ipify.org"], 
                              capture_output=True, text=True, timeout=10)
        if result.returncode == 0:
            ip = result.stdout.strip()
            if is_valid_ip(ip):
                return ip
    except Exception as e:
        print(f"  Curl method failed: {e}")
    
    # Try wget
    try:
        print("Trying wget...")
        result = subprocess.run(["wget", "-qO-", "https://api.ipify.org"], 
                              capture_output=True, text=True, timeout=10)
        if result.returncode == 0:
            ip = result.stdout.strip()
            if is_valid_ip(ip):
                return ip
    except Exception as e:
        print(f"  Wget method failed: {e}")
    
    # Try dig (if available)
    try:
        print("Trying dig...")
        result = subprocess.run(["dig", "+short", "myip.opendns.com", "@resolver1.opendns.com"], 
                              capture_output=True, text=True, timeout=10)
        if result.returncode == 0:
            ip = result.stdout.strip()
            if is_valid_ip(ip):
                return ip
    except Exception as e:
        print(f"  Dig method failed: {e}")
    
    return None

def get_local_ip():
    """Get local IP address as additional info."""
    try:
        # Connect to a remote address to determine local IP
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        local_ip = s.getsockname()[0]
        s.close()
        return local_ip
    except Exception:
        return "Unable to determine"

def main():
    print("=" * 50)
    print("Public IP Address Finder")
    print("=" * 50)
    
    # Detect operating system
    os_type = detect_os()
    print(f"Operating System: {platform.system()} {platform.release()}")
    print(f"Architecture: {platform.machine()}")
    print()
    
    public_ip = None
    
    # Try OS-specific methods first
    if os_type == "windows":
        public_ip = get_public_ip_windows()
    elif os_type in ["unix", "macos"]:
        public_ip = get_public_ip_unix()
    
    # Fallback to web-based method
    if not public_ip:
        print("Trying web-based methods...")
        public_ip = get_public_ip_web()
    
    print()
    print("=" * 50)
    print("RESULTS")
    print("=" * 50)
    
    if public_ip:
        print(f"✅ Public IP Address: {public_ip}")
    else:
        print("❌ Could not determine public IP address")
        print("   This might be due to:")
        print("   - No internet connection")
        print("   - Firewall blocking outbound connections")
        print("   - All IP services are down")
    
    # Show local IP as additional info
    local_ip = get_local_ip()
    print(f"📍 Local IP Address: {local_ip}")
    
    print()
    print("=" * 50)
    print("Additional Information")
    print("=" * 50)
    print(f"Python Version: {sys.version}")
    print(f"Platform: {platform.platform()}")
    
    return 0 if public_ip else 1

if __name__ == "__main__":
    sys.exit(main())