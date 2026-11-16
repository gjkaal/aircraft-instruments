# Code Style and Conventions

## Language Standard
- **C++17** (required, enforced in CMakeLists.txt)
- Standard library features are encouraged

## Naming Conventions

### Interfaces
- Prefix with `I` (e.g., `ISensor`, `ICommChannel`)
- Abstract base classes with pure virtual methods

### Classes
- PascalCase (e.g., `TemperatureSensor`, `EngineDataPublisher`)

### Methods
- camelCase (e.g., `readRaw()`, `isHealthy()`, `initialize()`)

### Configuration Structures
- Suffix with `Config` (e.g., `SensorConfig`)

## File Organization

### Directory Structure
```
src/
  main.cpp              # Application entry point
  sensors/              # Sensor implementations
  acquisition/          # Data acquisition and buffers
  processing/           # Data processing and filtering
  can/                  # CAN-Bus communication
  channels/             # Communication channels
  config/               # Configuration parsing
```

### Header/Implementation Split
- Interface definitions in headers
- Implementations in `.cpp` files

## Documentation

### Comments
- Use Doxygen-style comments for classes and public methods
- Example from main.cpp:
```cpp
/**
 * Main entry point for Raspberry Pi embedded application.
 */
```

### Architecture Decisions
- Document in ADRs in `docs/adr/`
- Use n2adr MCP tool to manage ADRs

## Build Configuration
- All source files auto-discovered via `GLOB_RECURSE` in CMakeLists.txt
- Include directories: `src` is the root
- Cross-compilation flags: `-O2 -Wall -Wextra` for Raspberry Pi

## Error Handling Strategy
- **Sensor failures**: Mark reading invalid, continue with other sensors
- **Out-of-range values**: Log error, use last known good value
- **Buffer overflow**: Log critical error, oldest data dropped
- **Channel failures**: Isolate failed channel, continue with others
- **Thread deadlock**: Watchdog timer detection and recovery