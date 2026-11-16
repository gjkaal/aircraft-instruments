# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an embedded C++ application for Raspberry Pi that monitors aircraft engine parameters in real-time. The system collects data from multiple sensors (EGT, CHT, RPM, engine hours) and transmits it via CAN-Bus to external display systems.

## Build System

### Building the Application
```bash
mkdir build
cd build
cmake ..
make
```

### Running the Application
```bash
./build/RaspberryPiApp
```

### Build Configuration
- **Language**: C++17 (required)
- **Build tool**: CMake 3.10+
- **Cross-compilation**: Requires ARM toolchain for Raspberry Pi deployment
- All source files in `src/` are automatically discovered via `GLOB_RECURSE`

## Architecture

The system follows a **layered, multi-threaded pipeline architecture** with clear separation of concerns:

### Core Layers
1. **Sensor Layer**: Hardware abstraction for different sensor types (temperature, RPM, time tracking)
2. **Data Acquisition Layer**: Timer-based sampling with lock-free ring buffers
3. **Processing Layer**: Calibration, filtering, validation, and alarm detection
4. **Communication Layer**: Multi-channel output (CAN-Bus primary, plus serial/network/logging)
5. **Application Layer**: Main control loop coordinating all subsystems

### Threading Model
- **Sensor Acquisition Thread** (high priority): Precise timer-based sampling, publishes to lock-free ring buffer
- **Data Processing Thread** (medium priority): Consumes raw data, applies calibration/filtering, detects alarms
- **CAN-Bus Transmission Thread** (medium priority): Formats and transmits CAN frames at specified rates
- **Main Control Thread** (low priority): Initialization, health monitoring, watchdog

### Key Design Patterns
- **Polymorphic sensor interface** (`ISensor` abstract base class)
- **Factory pattern** for sensor and channel instantiation from configuration
- **Publisher-Subscriber** for multi-channel data distribution
- **Lock-free SPSC ring buffers** for low-latency inter-thread communication

## Critical Interfaces

### ISensor Interface
All sensors implement this interface:
- `initialize()`, `readRaw()`, `readCalibrated()`, `isHealthy()`
- Concrete implementations: `TemperatureSensor`, `RpmSensor`, `EngineTimeSensor`
- Configured via `SensorConfig` structures with calibration data

### ICommChannel Interface
All communication channels implement this interface:
- `initialize()`, `isConnected()`, `send()`, `shutdown()`
- Implementations: `CanBusChannel`, `SerialChannel`, `NetworkChannel`, `FileLogChannel`
- Managed by `EngineDataPublisher` for multi-channel distribution

### CAN-Bus Protocol
- **Protocol**: CAN 2.0B (29-bit extended identifiers)
- **Hardware**: MCP2515 CAN controller via SPI, TJA1050/MCP2551 transceiver
- **Baud rate**: 500 kbps
- **ID structure**: Priority (5 bits) | Source Node (8 bits) | Message Type (8 bits) | Channel (8 bits)
- **Update rates**: EGT/CHT 10 Hz, RPM 20 Hz, Engine hours 1 Hz, Status 5 Hz

## Real-Time Requirements

### Performance Targets
- Sensor sampling jitter: < 1ms
- Processing latency: < 10ms (raw sample → CAN transmission)
- CPU utilization: < 50% at maximum sample rate
- Memory: < 100MB total
- Alarm detection: < 100ms

### Timing Configuration
- Temperature sensors: 10 Hz per cylinder (4-6 cylinders)
- RPM sensor: 20 Hz
- Engine time: 1 Hz
- Total sample rate: ~100-150 samples/second

## Configuration System

Configuration is JSON-based and controls:
- Sensor types, hardware channels, sample rates, calibration coefficients
- Communication channel enable/disable and parameters
- Thread priorities and buffer sizes
- Alarm thresholds and filtering coefficients

Factory pattern creates sensors and channels from config at runtime.

## Architecture Decision Records (ADRs)

Critical ADRs documenting key design decisions in `docs/adr/`:
- **ADR-0001**: Technology choice (C++ for Raspberry Pi)
- **ADR-0002**: Overall system architecture (layered, multi-threaded)
- **ADR-0003**: Sensor interface design (polymorphic ISensor)
- **ADR-0004**: CAN-Bus communication protocol
- **ADR-0005**: Data collection pipeline (lock-free buffers, threading model)
- **ADR-0006**: Communication channel abstraction (publisher-subscriber)
- **ADR-0008**: Aircraft wiring and wire gauge guidelines (power, CAN-Bus, sensors, radios)

When implementing features, consult relevant ADRs for design rationale and constraints.

## Development Workflow

### Task Management with n2adr
Project tasks are managed using the `n2adr` MCP tool for Architecture Decision Records and project planning:

**Configuration** (`adr.config.json`):
- ADR path: `docs\adr`
- Tasks path: `docs\planning`
- Templates: `docs\adr-templates`
- Project name: "Engine Monitor"

**Available n2adr MCP Tools:**
- `task_new`: Create new development tasks
- `task_list`: List all tasks with filtering options
- `task_find`: Search tasks by query with status filtering
- `task_update`: Update task status (New, OnHold, Planned, Active, ReviewPending, Completed, etc.)
- `task_link`: Link related tasks
- `task_generate_toc`: Generate table of contents at `docs/tasks-toc.md`
- `adr_new`: Create new Architecture Decision Records
- `adr_list`, `adr_find`, `adr_link`: Manage ADRs

**Task Files Location:**
All development tasks are stored in `docs/planning/` with both `.md` (human-readable) and `.json` (metadata) files. The current task list and progress can be viewed in `docs/tasks-toc.md`.

### Code Navigation with Serena
Use the `serena` MCP tool for intelligent code navigation and symbol-based operations:

**Key Serena Tools:**
- `find_symbol`: Locate classes, methods, functions by name path
- `get_symbols_overview`: Get high-level overview of symbols in a file
- `find_referencing_symbols`: Find all references to a symbol
- `replace_symbol_body`: Replace entire symbol implementations
- `insert_before_symbol`, `insert_after_symbol`: Add code around symbols
- `search_for_pattern`: Flexible regex-based code search

**Usage Notes:**
- Always use `get_symbols_overview` before reading full files
- Use symbol-based tools for token-efficient code exploration
- Avoid reading entire files unless strictly necessary
- Use `find_referencing_symbols` to understand code dependencies

### Implementation Phases
All 25 development tasks are defined in `docs/planning/`. See `docs/tasks-toc.md` for the complete task list. Critical path:
1. **Phase 1 (Foundation)**: Project setup → Core types/enums
2. **Phase 2 (Sensors)**: Sensor interface → Temperature/RPM/Engine time implementations
3. **Phase 3 (Data Pipeline)**: Lock-free buffers → Acquisition engine → Processing pipeline
4. **Phase 4 (CAN-Bus)**: CAN interface → MCP2515 driver → Engine data publisher
5. **Phase 5 (Channels)**: Channel abstraction → Multi-channel publisher
6. **Phase 6 (Integration)**: Configuration parser → Application main loop
7. **Phase 7 (Testing)**: Unit tests → Integration → Hardware validation
8. **Phase 8 (Deployment)**: Documentation → Production deployment package

**When Working on Tasks:**
1. Use `task_update` to mark tasks as Active when starting work
2. Consult related ADRs for design constraints and rationale
3. Use Serena tools for efficient code navigation and editing
4. Update task status to ReviewPending/Completed when done
5. Use `task_generate_toc` to update the task overview

## Hardware Interfaces

### Sensor Hardware
- **Temperature (EGT/CHT)**: K-type/J-type thermocouples via ADC with cold junction compensation
- **RPM**: Magnetic pickup or Hall effect sensor via GPIO interrupt/timer capture
- **Engine Time**: Software accumulator with persistent storage (file-based)

### CAN-Bus Hardware
- **Controller**: MCP2515 (SPI interface)
- **Transceiver**: TJA1050 or MCP2551
- **Physical**: CAN-H/CAN-L differential pair with 120Ω termination

## Error Handling Strategy

- **Sensor failures**: Mark reading invalid, continue with other sensors, don't block acquisition
- **Out-of-range values**: Log error, use last known good value
- **Buffer overflow**: Log critical error, oldest data dropped
- **Channel failures**: Isolate failed channel, continue with others, attempt reconnection
- **Thread deadlock**: Watchdog timer detection and recovery
