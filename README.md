# Raspberry Pi Embedded Application

## Overview
This is an embedded C++ application designed to run on Raspberry Pi (compact).

## Project Structure
- `src/` - Application source code (C++)
- `docs/adr/` - Architecture Decision Records
- `CMakeLists.txt` - CMake build configuration

## Build
```bash
mkdir build
cd build
cmake ..
make
```

## Running
```bash
./build/RaspberryPiApp
```

## Documentation
Architecture decisions are documented in `docs/adr/`.

## Hats

https://www.waveshare.com/wiki/2-CH_CAN_HAT

## Hardware references

https://www.raspberrypi-spy.co.uk/2012/06/simple-guide-to-the-rpi-gpio-header-and-pins/