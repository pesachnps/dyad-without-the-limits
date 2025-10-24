#!/bin/bash
# Cross-platform script to find public IP address
# Works on Linux, macOS, BSD, and Windows (with WSL/Git Bash)

echo "=================================================="
echo "Public IP Address Finder"
echo "=================================================="

# Detect OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="Linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macOS"
elif [[ "$OSTYPE" == "freebsd"* ]]; then
    OS="FreeBSD"
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
    OS="Windows (Git Bash/WSL)"
else
    OS="Unknown"
fi

echo "Operating System: $OS"
echo "Architecture: $(uname -m)"
echo

# Function to check if IP is valid
is_valid_ip() {
    local ip=$1
    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        return 0
    else
        return 1
    fi
}

# Function to try getting IP with a service
try_service() {
    local service=$1
    local method=$2
    local url=$3
    
    echo "Trying $service..."
    
    case $method in
        "curl")
            if command -v curl >/dev/null 2>&1; then
                result=$(curl -s --connect-timeout 10 "$url" 2>/dev/null)
                if [[ $? -eq 0 ]] && is_valid_ip "$result"; then
                    echo "$result"
                    return 0
                fi
            fi
            ;;
        "wget")
            if command -v wget >/dev/null 2>&1; then
                result=$(wget -qO- --timeout=10 "$url" 2>/dev/null)
                if [[ $? -eq 0 ]] && is_valid_ip "$result"; then
                    echo "$result"
                    return 0
                fi
            fi
            ;;
        "dig")
            if command -v dig >/dev/null 2>&1; then
                result=$(dig +short "$url" @resolver1.opendns.com 2>/dev/null)
                if [[ $? -eq 0 ]] && is_valid_ip "$result"; then
                    echo "$result"
                    return 0
                fi
            fi
            ;;
    esac
    
    echo "  Failed"
    return 1
}

# Try different methods to get public IP
PUBLIC_IP=""

# Try curl first
if command -v curl >/dev/null 2>&1; then
    PUBLIC_IP=$(try_service "curl" "curl" "https://api.ipify.org")
    if [[ -n "$PUBLIC_IP" ]]; then
        echo "✅ Found IP with curl"
    fi
fi

# Try wget if curl failed
if [[ -z "$PUBLIC_IP" ]] && command -v wget >/dev/null 2>&1; then
    PUBLIC_IP=$(try_service "wget" "wget" "https://api.ipify.org")
    if [[ -n "$PUBLIC_IP" ]]; then
        echo "✅ Found IP with wget"
    fi
fi

# Try dig if others failed
if [[ -z "$PUBLIC_IP" ]] && command -v dig >/dev/null 2>&1; then
    PUBLIC_IP=$(try_service "dig" "dig" "myip.opendns.com")
    if [[ -n "$PUBLIC_IP" ]]; then
        echo "✅ Found IP with dig"
    fi
fi

# Try alternative services
if [[ -z "$PUBLIC_IP" ]]; then
    echo "Trying alternative services..."
    
    services=(
        "https://ipv4.icanhazip.com"
        "https://checkip.amazonaws.com"
        "https://ifconfig.me/ip"
        "https://ipecho.net/plain"
    )
    
    for service in "${services[@]}"; do
        if command -v curl >/dev/null 2>&1; then
            result=$(curl -s --connect-timeout 10 "$service" 2>/dev/null)
            if [[ $? -eq 0 ]] && is_valid_ip "$result"; then
                PUBLIC_IP="$result"
                echo "✅ Found IP with $service"
                break
            fi
        elif command -v wget >/dev/null 2>&1; then
            result=$(wget -qO- --timeout=10 "$service" 2>/dev/null)
            if [[ $? -eq 0 ]] && is_valid_ip "$result"; then
                PUBLIC_IP="$result"
                echo "✅ Found IP with $service"
                break
            fi
        fi
    done
fi

echo
echo "=================================================="
echo "RESULTS"
echo "=================================================="

if [[ -n "$PUBLIC_IP" ]]; then
    echo "✅ Public IP Address: $PUBLIC_IP"
else
    echo "❌ Could not determine public IP address"
    echo "   This might be due to:"
    echo "   - No internet connection"
    echo "   - Firewall blocking outbound connections"
    echo "   - All IP services are down"
fi

# Show local IP
echo -n "📍 Local IP Address: "
if command -v hostname >/dev/null 2>&1; then
    # Try to get local IP
    if command -v ip >/dev/null 2>&1; then
        # Linux with ip command
        local_ip=$(ip route get 8.8.8.8 2>/dev/null | grep -oP 'src \K\S+' | head -1)
        if [[ -n "$local_ip" ]]; then
            echo "$local_ip"
        else
            echo "Unable to determine"
        fi
    elif command -v ifconfig >/dev/null 2>&1; then
        # macOS/BSD with ifconfig
        local_ip=$(ifconfig | grep -E "inet.*broadcast" | awk '{print $2}' | head -1)
        if [[ -n "$local_ip" ]]; then
            echo "$local_ip"
        else
            echo "Unable to determine"
        fi
    else
        echo "Unable to determine"
    fi
else
    echo "Unable to determine"
fi

echo
echo "=================================================="
echo "Additional Information"
echo "=================================================="
echo "OS Type: $OSTYPE"
echo "Kernel: $(uname -s) $(uname -r)"
echo "Architecture: $(uname -m)"

# Check available tools
echo
echo "Available tools:"
for tool in curl wget dig hostname ip ifconfig; do
    if command -v "$tool" >/dev/null 2>&1; then
        echo "  ✅ $tool"
    else
        echo "  ❌ $tool"
    fi
done

exit $([ -n "$PUBLIC_IP" ] && echo 0 || echo 1)