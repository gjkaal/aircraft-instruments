# Raspberry Pi Deployment Guide

This guide covers different methods to deploy the engine-monitor application to your Raspberry Pi using USB connection.

## Quick Start

### Method 1: Automated PowerShell Script
```powershell
# Build only
.\deploy.ps1 -BuildOnly

# Deploy via USB Mass Storage
.\deploy.ps1 -UseUSBMassStorage -USBDriveLetter "D:"

# Deploy via SSH (USB gadget or network)
.\deploy.ps1 -PiAddress "192.168.4.1" -PiUser "pi"
```

### Method 2: Simple Batch Script
```cmd
.\build_and_deploy.bat
```

## Raspberry Pi USB Connection Methods

### 1. USB Gadget Mode (Pi Zero/Pi 4)

For Pi Zero or Pi 4, you can enable USB gadget mode to create a network interface over USB:

1. **Enable USB gadget on Pi:**
   - Add to `/boot/config.txt`: `dtoverlay=dwc2`
   - Add to `/boot/cmdline.txt`: `modules-load=dwc2,g_ether` after `rootwait`
   - Enable SSH: `sudo systemctl enable ssh`

2. **Connect Pi via USB to PC**
   - Pi should appear as network interface (e.g., "USB Ethernet/RNDIS Gadget")
   - Default IP is usually `192.168.4.1` (Pi) and `192.168.4.2` (PC)

3. **Deploy using script:**
   ```powershell
   .\deploy.ps1 -PiAddress "192.168.4.1"
   ```

### 2. USB Mass Storage Mode

Enable USB mass storage to mount Pi's filesystem on PC:

1. **On Pi, enable mass storage:**
   ```bash
   sudo modprobe g_mass_storage file=/dev/mmcblk0p2 removable=1
   ```

2. **Deploy using USB drive method:**
   ```powershell
   .\deploy.ps1 -UseUSBMassStorage -USBDriveLetter "D:"
   ```

### 3. SSH over Network

If your Pi is connected to the same network as your PC:

```powershell
.\deploy.ps1 -PiAddress "YOUR_PI_IP_ADDRESS"
```

### 4. Manual SD Card Method

1. **Build the project:**
   ```powershell
   .\deploy.ps1 -BuildOnly
   ```

2. **Copy files manually:**
   - Remove SD card from Pi
   - Insert into PC card reader
   - Copy `build\RaspberryPiApp` to SD card
   - Insert SD card back to Pi

3. **Run on Pi:**
   ```bash
   chmod +x /path/to/RaspberryPiApp
   ./RaspberryPiApp
   ```

## Troubleshooting

### Connection Issues

1. **Check USB connection:**
   ```powershell
   Get-NetAdapter | Where-Object {$_.Name -like "*USB*" -or $_.Name -like "*RNDIS*"}
   ```

2. **Test Pi connectivity:**
   ```cmd
   ping 192.168.4.1
   ```

3. **Check COM ports:**
   ```powershell
   Get-WmiObject -Class Win32_SerialPort
   ```

### SSH Issues

1. **Enable SSH on Pi:**
   ```bash
   sudo systemctl enable ssh
   sudo systemctl start ssh
   ```

2. **Set Pi password:**
   ```bash
   sudo passwd pi
   ```

3. **Check SSH service:**
   ```bash
   sudo systemctl status ssh
   ```

### Build Issues

1. **Verify ARM toolchain:**
   ```cmd
   arm-none-eabi-gcc --version
   ```

2. **Clean build:**
   ```cmd
   cd build
   make clean
   make
   ```

## File Structure After Deployment

```
/home/pi/engine-monitor/
├── RaspberryPiApp          # Main executable
└── run_engine_monitor.sh   # Helper script (if using USB method)
```

## Running the Application

On the Raspberry Pi:

```bash
# Make executable (if not already)
chmod +x ~/engine-monitor/RaspberryPiApp

# Run the application
~/engine-monitor/RaspberryPiApp

# Or use the helper script (USB deployment)
bash ~/run_engine_monitor.sh
```

## Performance Notes

- Binary size: ~6MB
- Optimized for ARM Cortex-A7 (Pi 2/3/Zero 2)
- Hard float ABI enabled
- Requires minimal Pi OS or Raspbian