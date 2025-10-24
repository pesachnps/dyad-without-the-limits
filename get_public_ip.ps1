# PowerShell script to get public IP address
Write-Host "Getting public IP address..." -ForegroundColor Green
Write-Host ""

# Method 1: Using Invoke-WebRequest
Write-Host "Method 1: Using ifconfig.me" -ForegroundColor Yellow
try {
    $ip1 = (Invoke-WebRequest -Uri "https://ifconfig.me" -UseBasicParsing).Content
    Write-Host "Public IP: $ip1" -ForegroundColor Cyan
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Method 2: Using ipinfo.io
Write-Host "Method 2: Using ipinfo.io" -ForegroundColor Yellow
try {
    $ip2 = (Invoke-WebRequest -Uri "https://ipinfo.io/ip" -UseBasicParsing).Content
    Write-Host "Public IP: $ip2" -ForegroundColor Cyan
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Method 3: Using icanhazip.com
Write-Host "Method 3: Using icanhazip.com" -ForegroundColor Yellow
try {
    $ip3 = (Invoke-WebRequest -Uri "https://icanhazip.com" -UseBasicParsing).Content
    Write-Host "Public IP: $ip3" -ForegroundColor Cyan
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Method 4: Using checkip.amazonaws.com
Write-Host "Method 4: Using checkip.amazonaws.com" -ForegroundColor Yellow
try {
    $ip4 = (Invoke-WebRequest -Uri "https://checkip.amazonaws.com" -UseBasicParsing).Content
    Write-Host "Public IP: $ip4" -ForegroundColor Cyan
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

Write-Host "All methods completed. The IP addresses above should be the same." -ForegroundColor Green
Read-Host "Press Enter to continue"