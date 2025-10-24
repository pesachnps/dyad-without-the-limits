@echo off
echo Getting public IP address...
echo.

REM Method 1: Using curl (if available)
echo Method 1: Using curl
curl -s ifconfig.me
echo.
echo.

REM Method 2: Using PowerShell
echo Method 2: Using PowerShell
powershell -Command "(Invoke-WebRequest -Uri 'https://ifconfig.me' -UseBasicParsing).Content"
echo.
echo.

REM Method 3: Alternative service
echo Method 3: Using ipinfo.io
curl -s ipinfo.io/ip
echo.
echo.

REM Method 4: Using wget (if available)
echo Method 4: Using wget
wget -qO- ifconfig.me
echo.
echo.

echo All methods completed. The IP addresses above should be the same.
pause