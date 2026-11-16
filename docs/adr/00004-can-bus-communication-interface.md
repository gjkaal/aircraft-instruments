# 00004. CAN-Bus Communication Interface

2025-10-06

## Status

__New__

## Context

Engine monitoring data must be transmitted to external systems for:
- Display on glass cockpit systems (EFIS/MFD)
- Data logging and flight data recording
- Integration with engine control units (FADEC)
- Remote monitoring and diagnostics

Requirements:
- Real-time transmission with minimal latency (<10ms)
- Reliable delivery in electrically noisy engine environment
- Standard protocol for interoperability
- Support for multiple receivers (broadcast capability)
- Bandwidth efficient (multiple parameters at high rates)

CAN-Bus is the industry standard for:
- Automotive and aviation systems
- Deterministic, priority-based arbitration
- Built-in error detection and fault confinement
- Multi-master capability
- Well-supported on Raspberry Pi (MCP2515, SocketCAN)

## Decision

We will implement **CAN 2.0B** (extended frame format) for engine data transmission using:

### Hardware Interface:
- **MCP2515 CAN controller** via SPI
- **TJA1050/MCP2551 CAN transceiver** for physical layer
- CAN-H/CAN-L differential pair with 120Ω termination
- Standard aviation-grade connectors

### Protocol Design:

**CAN ID Structure (29-bit extended identifier):**
```
Bits 28-24: Message Priority (0=highest)
Bits 23-16: Source Node ID (0x01 = Engine Monitor)
Bits 15-8:  Message Type
Bits 7-0:   Cylinder/Channel ID
```

**Message Types:**
- `0x01` - EGT data (per cylinder)
- `0x02` - CHT data (per cylinder)
- `0x03` - RPM data
- `0x04` - Engine hours/time
- `0x10` - System status/health
- `0x11` - Alarms/warnings
- `0x20` - Configuration/commands (received)

**Data Payload (8 bytes max per CAN frame):**
```cpp
struct CanEngineData {
    uint32_t timestamp_ms;  // 4 bytes
    float value;            // 4 bytes (IEEE 754)
};
```

### Software Interface:

```cpp
class ICanInterface {
public:
    virtual ~ICanInterface() = default;

    virtual bool initialize(uint32_t baudRate) = 0;
    virtual bool sendFrame(const CanFrame& frame) = 0;
    virtual bool receiveFrame(CanFrame& frame, uint32_t timeoutMs) = 0;
    virtual bool isConnected() const = 0;
};

class CanEnginePublisher {
public:
    void publishEGT(uint8_t cylinder, float tempC);
    void publishCHT(uint8_t cylinder, float tempC);
    void publishRPM(float rpm);
    void publishEngineHours(float hours);
    void publishStatus(uint8_t statusFlags);
};
```

### Transmission Strategy:
- **Periodic broadcast** (no request/response)
- Update rates:
  - EGT/CHT: 10 Hz per cylinder
  - RPM: 20 Hz
  - Engine hours: 1 Hz
  - Status: 5 Hz
- Priority ordering: Alarms > RPM > Temperatures > Status

### CAN-Bus Configuration:
- **Baud rate**: 500 kbps (standard for aviation/automotive)
- **Sample point**: 87.5%
- **Bit timing**: TQ=8, Prop=7, Phase1=7, Phase2=1

## Consequences

**Positive:**
- Industry-standard protocol ensures interoperability
- Broadcast nature allows multiple receivers without modification
- Priority-based arbitration ensures critical data (alarms) transmits first
- Error detection (15-bit CRC, ACK, bit stuffing) provides reliability
- No custom protocol development required
- SocketCAN on Linux provides mature driver stack
- Extends to CAN FD in future if higher bandwidth needed

**Negative:**
- CAN bandwidth limited (500 kbps) - careful message rate planning required
- Additional hardware (MCP2515 module) increases cost (~$5-10)
- SPI bus contention if multiple SPI devices present
- 8-byte payload limit requires efficient data encoding
- No built-in encryption/security (not typically needed for engine monitoring)

**Implementation Requirements:**
- Linux SocketCAN kernel module configuration
- SPI interface initialization and timing configuration
- Message queue for transmit buffering
- Frame filtering for received commands
- Bus-off recovery and error handling
- Testing with CAN analyzer/simulator

**Integration Points:**
- Sensor data → CanEnginePublisher → MCP2515 → CAN-Bus
- Periodic timer triggers data publishing
- Asynchronous reception for configuration commands
- Health monitoring of CAN interface (bus errors, tx failures)

**Future Considerations:**
- J1939 protocol layer for standardized PGNs (Parameter Group Numbers)
- CAN FD for higher data rates if needed
- Dual-CAN redundancy for safety-critical applications
