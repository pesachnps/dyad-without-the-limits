@echo off
echo Getting public IP address...
echo.

REM Simple one-liner using PowerShell
powershell -Command "Write-Host 'Public IP Address:' -ForegroundColor Green; (Invoke-WebRequest -Uri 'https://ifconfig.me' -UseBasicParsing).Content"

echo.
pause