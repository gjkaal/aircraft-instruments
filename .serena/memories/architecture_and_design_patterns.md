# Architecture and Design Patterns

## System Architecture
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

## Design Patterns

### Polymorphic Interfaces
- **ISensor**: Abstract base class for all sensors
  - Methods: `initialize()`, `readRaw()`, `readCalibrated()`, `isHealthy()`
  - Implementations: `TemperatureSensor`, `RpmSensor`, `EngineTimeSensor`
  
- **ICommChannel**: Abstract base class for communication channels
  - Methods: `initialize()`, `isConnected()`, `send()`, `shutdown()`
  - Implementations: `CanBusChannel`, `SerialChannel`, `NetworkChannel`, `FileLogChannel`

### Factory Pattern
Sensors and channels are instantiated from JSON configuration at runtime.

### Publisher-Subscriber Pattern
Multi-channel data distribution managed by `EngineDataPublisher`.

### Lock-Free SPSC Ring Buffers
Used for low-latency inter-thread communication between acquisition and processing threads.

## Key ADRs
- **ADR-0002**: Overall system architecture (layered, multi-threaded)
- **ADR-0003**: Sensor interface design (polymorphic ISensor)
- **ADR-0004**: CAN-Bus communication protocol
- **ADR-0005**: Data collection pipeline (lock-free buffers, threading model)
- **ADR-0006**: Communication channel abstraction (publisher-subscriber)

All ADRs are in `docs/adr/` and should be consulted when implementing related features.