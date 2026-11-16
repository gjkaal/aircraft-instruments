# Engine Monitor Project Overview

## Purpose
This is an embedded C++ application for Raspberry Pi that monitors aircraft engine parameters in real-time. The system collects data from multiple sensors (EGT/CHT temperatures, RPM, engine hours) and transmits it via CAN-Bus to external display systems.

## Tech Stack
- **Language**: C++17 (required)
- **Build System**: CMake 3.10+ (configured with CMake 4.1+)
- **Target Platform**: Raspberry Pi (ARM Cortex-A7)
- **Cross-Compilation**: ARM GCC toolchain (arm-none-eabi-gcc) from Windows
- **Development OS**: Windows (MSYS_NT)
- **Hardware Interfaces**: 
  - CAN-Bus (MCP2515 controller via SPI)
  - GPIO for RPM sensors
  - ADC for thermocouples
  - SPI interface

## Key Features
- Multi-sensor monitoring (temperature, RPM, engine time)
- Real-time data acquisition with lock-free ring buffers
- Multi-threaded pipeline architecture
- CAN-Bus primary communication (CAN 2.0B, 500 kbps)
- Multiple output channels (CAN, Serial, Network, File logging)
- JSON-based configuration system
- Real-time performance: <1ms jitter, <10ms latency

## Project Status
Currently in initial development phase with 25 planned tasks in `docs/planning/`. Main application skeleton exists but sensor and communication layers are not yet implemented.