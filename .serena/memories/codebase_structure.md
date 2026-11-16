# Codebase Structure

## Current Directory Layout

```
C:\git\engine-monitor\
├── .claude\                    # Claude Code configuration
├── .serena\                    # Serena MCP configuration
├── .vscode\                    # VS Code settings
├── build\                      # Build output directory (CMake)
├── cmake\                      # CMake toolchain files
│   └── toolchain-raspberry-pi.cmake
├── docs\
│   ├── adr\                    # Architecture Decision Records
│   ├── adr-templates\          # ADR templates
│   ├── planning\               # Task definitions (25 tasks)
│   ├── adr-toc.md             # ADR table of contents
│   └── tasks-toc.md           # Tasks table of contents
├── src\                        # Source code
│   └── main.cpp               # Application entry point
├── .mcp.json                  # MCP server configuration
├── adr.config.json            # n2adr tool configuration
├── CLAUDE.md                  # Claude Code instructions
├── CMakeLists.txt             # Build configuration
├── package.json               # Node dependencies (for MCP SDK)
├── README.md                  # Basic project readme
└── README-BUILD.md            # Build instructions

```

## Planned Source Code Structure (to be implemented)

Based on ADRs and task definitions, the `src/` directory will be organized as:

```
src/
├── main.cpp                   # Application entry point
├── types/
│   └── EngineTypes.h          # Core type definitions and enums
├── sensors/
│   ├── ISensor.h              # Sensor interface
│   ├── TemperatureSensor.h/.cpp
│   ├── RpmSensor.h/.cpp
│   └── EngineTimeSensor.h/.cpp
├── acquisition/
│   ├── RingBuffer.h           # Lock-free SPSC ring buffer
│   └── DataAcquisitionEngine.h/.cpp
├── processing/
│   └── DataProcessor.h/.cpp   # Calibration, filtering, alarms
├── can/
│   ├── ICanInterface.h        # CAN interface abstraction
│   ├── Mcp2515Driver.h/.cpp   # MCP2515 CAN controller driver
│   └── CanEngineDataPublisher.h/.cpp
├── channels/
│   ├── ICommChannel.h         # Communication channel interface
│   ├── SerialChannel.h/.cpp
│   ├── NetworkChannel.h/.cpp
│   └── FileLogChannel.h/.cpp
├── publisher/
│   └── EngineDataPublisher.h/.cpp  # Publisher-Subscriber hub
├── config/
│   └── ConfigParser.h/.cpp    # JSON configuration parser
└── app/
    └── Application.h/.cpp     # Main application loop
```

## Key Files and Their Purpose

### Existing Files

- **src/main.cpp**: Application entry point, currently minimal skeleton
- **CMakeLists.txt**: Build configuration, auto-discovers all .cpp files in src/
- **cmake/toolchain-raspberry-pi.cmake**: Cross-compilation toolchain for ARM

### Configuration Files

- **adr.config.json**: Configures n2adr tool paths (ADRs, tasks, templates)
- **.mcp.json**: MCP server configuration for n2adr and serena tools
- **CLAUDE.md**: Instructions for Claude Code with project context

### Documentation Files

- **docs/adr/*.md**: Architecture Decision Records (7 ADRs currently)
- **docs/planning/*.md**: Task definitions (25 tasks planned)
- **docs/adr-toc.md**: Generated table of contents for ADRs
- **docs/tasks-toc.md**: Generated table of contents for tasks

## Source File Discovery

CMakeLists.txt uses `GLOB_RECURSE` to automatically discover all .cpp files:
```cmake
file(GLOB_RECURSE SOURCES "src/*.cpp")
```

This means:
- No need to manually add new source files to CMakeLists.txt
- Just create .cpp files anywhere under src/ and they'll be compiled
- Header files (.h) are included via `target_include_directories`

## Build Artifacts

All build outputs go to `build/` directory:
- `build/RaspberryPiApp` - compiled executable
- `build/CMakeFiles/` - CMake intermediate files
- `build/compile_commands.json` - compilation database for IDE integration