@echo off
echo Building and deploying Raspberry Pi Engine Monitor...
echo.

REM Check if we're in the correct directory
if not exist "CMakeLists.txt" (
    echo Error: CMakeLists.txt not found. Please run this script from the project root.
    pause
    exit /b 1
)

REM Build the project
echo Building project...
cd build
make
if %errorlevel% neq 0 (
    echo Build failed!
    pause
    exit /b 1
)

echo.
echo Build completed successfully!
echo Binary location: build\RaspberryPiApp
echo Binary size: 
dir RaspberryPiApp | find "RaspberryPiApp"

echo.
echo Deployment options:
echo 1. Copy to USB drive connected to PC
echo 2. Use SSH/SCP (requires network connection)
echo 3. Use SD card reader
echo.
echo For USB deployment, use: powershell -ExecutionPolicy Bypass -File ..\deploy.ps1 -UseUSBMassStorage -USBDriveLetter "D:"
echo For SSH deployment, use: powershell -ExecutionPolicy Bypass -File ..\deploy.ps1 -PiAddress "YOUR_PI_IP"
echo.
pause