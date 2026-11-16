# Build Instructions

## Raspberry Pi Cross-Compilation

This project is configured to cross-compile for Raspberry Pi from Windows using the ARM GCC toolchain.

### Prerequisites

- CMake 4.1+
- ARM GCC toolchain (arm-none-eabi-gcc)
- Visual Studio Code with CMake Tools extension

### Building for Raspberry Pi

#### Command Line
```bash
mkdir build
cd build
cmake -DCMAKE_TOOLCHAIN_FILE=../cmake/toolchain-raspberry-pi.cmake ..
make
```

#### VS Code
1. Open the project in VS Code
2. Press `Ctrl+Shift+P` and select "CMake: Select a Kit"
3. Choose "Raspberry Pi Cross-Compile"
4. Press `F7` or click "Build" in the status bar

The toolchain is configured for:
- **CPU**: Cortex-A7 (Raspberry Pi 2/3/Zero 2)
- **FPU**: NEON-VFPv4
- **ABI**: Hard float

### Building for Local Development

To build for your local Windows system (for testing):
1. Select "CMake: Select a Kit" → "Local GCC"
2. Build normally

### Output

The compiled binary will be in `build/RaspberryPiApp` (or `RaspberryPiApp.exe` for local builds).
