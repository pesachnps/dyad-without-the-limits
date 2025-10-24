@echo off
REM Cross-platform script to find public IP address
REM Works on Windows systems

echo ==================================================
echo Public IP Address Finder
echo ==================================================

REM Detect Windows version
for /f "tokens=4-5 delims=. " %%i in ('ver') do set VERSION=%%i.%%j
echo Operating System: Windows %VERSION%
echo Architecture: %PROCESSOR_ARCHITECTURE%
echo.

set PUBLIC_IP=

REM Try PowerShell method first
echo Trying PowerShell method...
powershell -Command "(Invoke-WebRequest -Uri 'https://api.ipify.org' -UseBasicParsing).Content" > temp_ip.txt 2>nul
if %errorlevel% equ 0 (
    set /p PUBLIC_IP=<temp_ip.txt
    del temp_ip.txt
    if not "%PUBLIC_IP%"=="" (
        echo ✅ Found IP with PowerShell
        goto :found
    )
)
echo   PowerShell method failed

REM Try curl if available
echo Trying curl...
curl -s https://api.ipify.org > temp_ip.txt 2>nul
if %errorlevel% equ 0 (
    set /p PUBLIC_IP=<temp_ip.txt
    del temp_ip.txt
    if not "%PUBLIC_IP%"=="" (
        echo ✅ Found IP with curl
        goto :found
    )
)
echo   Curl method failed

REM Try wget if available
echo Trying wget...
wget -qO- https://api.ipify.org > temp_ip.txt 2>nul
if %errorlevel% equ 0 (
    set /p PUBLIC_IP=<temp_ip.txt
    del temp_ip.txt
    if not "%PUBLIC_IP%"=="" (
        echo ✅ Found IP with wget
        goto :found
    )
)
echo   Wget method failed

REM Try alternative services
echo Trying alternative services...
for %%s in (
    "https://ipv4.icanhazip.com"
    "https://checkip.amazonaws.com"
    "https://ifconfig.me/ip"
    "https://ipecho.net/plain"
) do (
    curl -s %%s > temp_ip.txt 2>nul
    if %errorlevel% equ 0 (
        set /p PUBLIC_IP=<temp_ip.txt
        del temp_ip.txt
        if not "%PUBLIC_IP%"=="" (
            echo ✅ Found IP with %%s
            goto :found
        )
    )
)

:found
echo.
echo ==================================================
echo RESULTS
echo ==================================================

if not "%PUBLIC_IP%"=="" (
    echo ✅ Public IP Address: %PUBLIC_IP%
) else (
    echo ❌ Could not determine public IP address
    echo    This might be due to:
    echo    - No internet connection
    echo    - Firewall blocking outbound connections
    echo    - All IP services are down
)

REM Get local IP
echo -n 📍 Local IP Address: 
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /c:"IPv4"') do (
    set LOCAL_IP=%%a
    goto :local_found
)
:local_found
if defined LOCAL_IP (
    echo %LOCAL_IP%
) else (
    echo Unable to determine
)

echo.
echo ==================================================
echo Additional Information
echo ==================================================
echo Computer Name: %COMPUTERNAME%
echo User: %USERNAME%
echo.

REM Check available tools
echo Available tools:
where powershell >nul 2>&1 && echo   ✅ PowerShell || echo   ❌ PowerShell
where curl >nul 2>&1 && echo   ✅ curl || echo   ❌ curl
where wget >nul 2>&1 && echo   ✅ wget || echo   ❌ wget
where ipconfig >nul 2>&1 && echo   ✅ ipconfig || echo   ❌ ipconfig

REM Clean up
if exist temp_ip.txt del temp_ip.txt

if not "%PUBLIC_IP%"=="" (
    exit /b 0
) else (
    exit /b 1
)