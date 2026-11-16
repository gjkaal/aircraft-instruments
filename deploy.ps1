param(
    [string]$PiAddress = "192.168.4.1",
    [string]$PiUser = "pi", 
    [string]$PiPath = "/home/pi/engine-monitor",
    [switch]$BuildOnly,
    [switch]$UseUSB,
    [string]$USBDrive = "D:"
)

Write-Host "=== Raspberry Pi Deployment Script ===" -ForegroundColor Green

if (-not (Test-Path "CMakeLists.txt")) {
    Write-Host "ERROR: Run this script from project root directory" -ForegroundColor Red
    exit 1
}

Write-Host "Building for Raspberry Pi..." -ForegroundColor Cyan

if (-not (Test-Path "build")) {
    New-Item -ItemType Directory -Path "build" | Out-Null
}

Set-Location "build"

Write-Host "Running cmake..." -ForegroundColor Yellow
cmake -DCMAKE_TOOLCHAIN_FILE=../cmake/toolchain-raspberry-pi.cmake ..

if ($LASTEXITCODE -ne 0) {
    Write-Host "CMake failed!" -ForegroundColor Red
    Set-Location ..
    exit 1
}

Write-Host "Running make..." -ForegroundColor Yellow  
make

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed!" -ForegroundColor Red
    Set-Location ..
    exit 1
}

if (-not (Test-Path "RaspberryPiApp")) {
    Write-Host "Binary not found!" -ForegroundColor Red
    Set-Location ..
    exit 1
}

$size = (Get-Item "RaspberryPiApp").Length
Write-Host "Build successful! Binary size: $([math]::Round($size/1KB, 2)) KB" -ForegroundColor Green

Set-Location ..

if ($BuildOnly) {
    Write-Host "Build complete. Binary at: build\RaspberryPiApp" -ForegroundColor Green
    exit 0
}

Write-Host "Deploying to Raspberry Pi..." -ForegroundColor Cyan

if ($UseUSB) {
    Write-Host "USB deployment mode..." -ForegroundColor Yellow
    
    if (-not (Test-Path "${USBDrive}\")) {
        Write-Host "USB drive ${USBDrive} not found!" -ForegroundColor Red
        exit 1
    }
    
    Copy-Item "build\RaspberryPiApp" "${USBDrive}\RaspberryPiApp" -Force
    
    $script = "#!/bin/bash`nchmod +x ./RaspberryPiApp`n./RaspberryPiApp"
    $script | Out-File "${USBDrive}\run.sh" -Encoding ASCII -Force
    
    Write-Host "Files copied to USB drive!" -ForegroundColor Green
    Write-Host "On Pi, run: bash /media/pi/*/run.sh" -ForegroundColor Cyan
    
} else {
    Write-Host "Network deployment to $PiAddress..." -ForegroundColor Yellow
    
    $ping = Test-Connection $PiAddress -Count 1 -Quiet
    
    if (-not $ping) {
        Write-Host "Cannot reach $PiAddress" -ForegroundColor Yellow
        Write-Host "Try: deploy-quick.ps1 -UseUSB" -ForegroundColor Cyan
        exit 0
    }
    
    Write-Host "Pi reachable! Attempting file transfer..." -ForegroundColor Green
    
    $scp = Get-Command scp -ErrorAction SilentlyContinue
    
    if ($scp) {
        ssh "${PiUser}@${PiAddress}" "mkdir -p ${PiPath}" 2>$null
        scp "build\RaspberryPiApp" "${PiUser}@${PiAddress}:${PiPath}/"
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Transfer complete!" -ForegroundColor Green
            ssh "${PiUser}@${PiAddress}" "chmod +x ${PiPath}/RaspberryPiApp"
            Write-Host "To run: ssh ${PiUser}@${PiAddress} '${PiPath}/RaspberryPiApp'" -ForegroundColor Cyan
        } else {
            Write-Host "Transfer failed!" -ForegroundColor Red
        }
    } else {
        Write-Host "SCP not available. Manual copy required." -ForegroundColor Yellow
        Write-Host "Copy build\RaspberryPiApp to your Pi manually" -ForegroundColor White
    }
}

Write-Host "Deployment complete!" -ForegroundColor Green