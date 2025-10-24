# How to Get the Public IP Address of a Windows Computer

## Problem
When you run a script from your local machine to check the public IP of a remote Windows computer, it shows your own public IP instead of the target computer's IP.

## Solution
You need to run the script **directly on the Windows computer** that's hosting the shared drive.

## Methods

### Method 1: Copy and Run Batch Script (Easiest)
1. Copy the `get_public_ip_simple.bat` file to the Windows computer
2. Double-click the file to run it
3. The script will display the public IP address

### Method 2: Run PowerShell Script (Most Reliable)
1. Copy the `get_public_ip.ps1` file to the Windows computer
2. Right-click on the file and select "Run with PowerShell"
3. The script will try multiple services to get the public IP

### Method 3: Manual Command Line
If you have access to the Windows computer directly:
1. Open Command Prompt or PowerShell
2. Run one of these commands:
   ```cmd
   curl ifconfig.me
   ```
   or
   ```powershell
   (Invoke-WebRequest -Uri "https://ifconfig.me" -UseBasicParsing).Content
   ```

### Method 4: Using Windows Remote Desktop
If you can remote into the Windows computer:
1. Connect via Remote Desktop
2. Run any of the scripts or commands above

## Alternative: Network Discovery
If you can't run scripts on the Windows computer, you can try:
1. Check the router's admin interface for connected devices
2. Look for the Windows computer's hostname in the device list
3. Some routers show the public IP for each device

## Files Created
- `get_public_ip.bat` - Comprehensive batch script with multiple methods
- `get_public_ip.ps1` - PowerShell script with error handling
- `get_public_ip_simple.bat` - Simple one-liner batch script

## Notes
- The scripts use multiple IP detection services for reliability
- All methods should return the same public IP address
- Make sure the Windows computer has internet access
- Some corporate networks may block these services