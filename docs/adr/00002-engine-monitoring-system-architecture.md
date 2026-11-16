# 00002. Engine Monitoring System Architecture

2025-10-06

## Status

__New__

## Context

The system needs to monitor critical engine parameters in real-time:
- Exhaust Gas Temperature (EGT) - multiple cylinders
- Cylinder Head Temperature (CHT) - multiple cylinders
- Engine RPM (Revolutions Per Minute)
- Engine operating time/hours
- Other engine vitals

The data must be:
- Collected reliably from various sensors
- Processed in real-time
- Transmitted to external systems via CAN-Bus
- Available for local display/logging

## Decision

We will implement a modular, layered architecture consisting of:

1. **Sensor Layer**: Hardware abstraction for different sensor types (temperature, RPM, time)
2. **Data Acquisition Layer**: Sampling, filtering, and validation of sensor data
3. **Processing Layer**: Data aggregation, calculations, and alarm detection
4. **Communication Layer**: CAN-Bus interface for external data distribution
5. **Application Layer**: Main control loop coordinating all subsystems

### Key Architectural Components:

```
┌─────────────────────────────────────────────┐
│         Application Layer                   │
│   (Main Control Loop & Coordination)        │
└──────────────┬──────────────────────────────┘
               │
    ┌──────────┴──────────┬──────────────────┐
    ▼                     ▼                  ▼
┌─────────┐      ┌──────────────┐   ┌────────────┐
│Sensor   │      │ Processing   │   │Communication│
│Layer    │─────▶│ Layer        │──▶│Layer (CAN) │
└─────────┘      └──────────────┘   └────────────┘
    │                                       │
    │                                       ▼
    ▼                               External Systems
Hardware I/O
(ADC, GPIO, Timers)
```

## Consequences

**Positive:**
- Clear separation of concerns enables independent testing and development
- Modular design allows easy addition of new sensor types
- Hardware abstraction makes code portable across different Raspberry Pi models
- Standardized interfaces enable component reuse
- CAN-Bus support enables integration with existing aviation/automotive systems

**Negative:**
- More complex initial architecture requiring careful interface design
- Potential performance overhead from abstraction layers
- Requires disciplined adherence to layer boundaries

**Technical Decisions:**
- Real-time constraints require careful thread/task management
- Sensor sampling rates must be configurable per sensor type
- CAN-Bus messaging will follow standardized protocols (to be defined)
- Error handling and fault tolerance are critical for safety
- System must gracefully handle sensor failures
