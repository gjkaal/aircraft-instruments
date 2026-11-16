# 00006. Communication Channel and Display Interface Abstraction

2025-10-06

## Status

__New__

## Context

The engine monitoring system needs to support multiple output channels:

**Communication Channels:**
1. **CAN-Bus** - Primary interface for external systems (EFIS, data loggers)
2. **Serial/UART** - Backup/debug interface, legacy instrument support
3. **Network (TCP/UDP)** - Remote monitoring, WiFi/Ethernet dashboards
4. **Local Storage** - Flight data logging to SD card

**Display/Instrument Interfaces:**
1. **Digital Glass Displays** - Modern EFIS/MFD systems
2. **Analog Gauge Emulation** - PWM signals for legacy analog instruments
3. **Local LCD/OLED** - Direct-attached display for standalone operation
4. **Web Dashboard** - Browser-based monitoring interface

**Requirements:**
- Add new channels without modifying core engine monitoring code
- Support multiple simultaneous outputs (e.g., CAN + Network + Local display)
- Handle different data formats and protocols per channel
- Configurable channel enable/disable at runtime
- Performance: Outputs should not block sensor acquisition
- Reliability: Failure in one channel shouldn't affect others

## Decision

We will implement a **Publisher-Subscriber pattern** with abstract channel interfaces:

### Communication Channel Interface:

```cpp
// Abstract base class for all communication channels
class ICommChannel {
public:
    virtual ~ICommChannel() = default;

    virtual bool initialize() = 0;
    virtual bool isConnected() const = 0;
    virtual bool send(const EngineData& data) = 0;
    virtual void shutdown() = 0;

    virtual std::string getChannelName() const = 0;
    virtual ChannelType getType() const = 0;
};

// Concrete implementations
class CanBusChannel : public ICommChannel { /* ... */ };
class SerialChannel : public ICommChannel { /* ... */ };
class NetworkChannel : public ICommChannel { /* ... */ };
class FileLogChannel : public ICommChannel { /* ... */ };
```

### Instrument/Display Interface:

```cpp
// Abstract base class for display outputs
class IDisplayInstrument {
public:
    virtual ~IDisplayInstrument() = default;

    virtual bool initialize() = 0;
    virtual void updateEGT(uint8_t cylinder, float tempC) = 0;
    virtual void updateCHT(uint8_t cylinder, float tempC) = 0;
    virtual void updateRPM(float rpm) = 0;
    virtual void updateEngineHours(float hours) = 0;
    virtual void updateAlarms(uint32_t alarmMask) = 0;
    virtual void refresh() = 0; // Update physical display
};

// Concrete implementations
class OledDisplay : public IDisplayInstrument { /* ... */ };
class AnalogGaugeDriver : public IDisplayInstrument { /* ... */ };
class WebDashboard : public IDisplayInstrument { /* ... */ };
```

### Publisher (Data Distribution Hub):

```cpp
class EngineDataPublisher {
private:
    std::vector<std::shared_ptr<ICommChannel>> channels_;
    std::vector<std::shared_ptr<IDisplayInstrument>> instruments_;
    std::mutex mutex_;

public:
    // Channel management
    void registerChannel(std::shared_ptr<ICommChannel> channel);
    void unregisterChannel(const std::string& name);

    // Instrument management
    void registerInstrument(std::shared_ptr<IDisplayInstrument> instrument);

    // Publishing methods (called by data processing thread)
    void publishEGT(uint8_t cylinder, float tempC);
    void publishCHT(uint8_t cylinder, float tempC);
    void publishRPM(float rpm);
    void publishEngineHours(float hours);
    void publishAlarms(uint32_t alarmMask);

private:
    // Asynchronously send to all registered channels
    void distributeToChannels(const EngineData& data);
};
```

### Data Format Abstraction:

```cpp
// Common data structure passed to all outputs
struct EngineData {
    uint64_t timestamp_us;
    DataType type; // EGT, CHT, RPM, etc.
    uint8_t channel; // Cylinder number or 0 for global
    float value;
    AlarmLevel alarmLevel;

    // Serialization for different formats
    std::vector<uint8_t> toCanFrame() const;
    std::string toJson() const;
    std::string toCsv() const;
    std::vector<uint8_t> toNMEA() const;
};
```

### Configuration-Driven Channel Setup:

```json
{
  "communication_channels": [
    {
      "type": "can_bus",
      "enabled": true,
      "config": {
        "interface": "can0",
        "baudrate": 500000
      }
    },
    {
      "type": "network",
      "enabled": true,
      "config": {
        "protocol": "udp",
        "port": 8888,
        "broadcast": true
      }
    },
    {
      "type": "serial",
      "enabled": false,
      "config": {
        "device": "/dev/ttyUSB0",
        "baudrate": 115200
      }
    }
  ],
  "instruments": [
    {
      "type": "oled_display",
      "enabled": true,
      "config": {
        "i2c_address": "0x3C"
      }
    }
  ]
}
```

### Factory Pattern for Channel Creation:

```cpp
class ChannelFactory {
public:
    static std::shared_ptr<ICommChannel> createChannel(
        const ChannelConfig& config);

    static std::shared_ptr<IDisplayInstrument> createInstrument(
        const InstrumentConfig& config);
};
```

## Consequences

**Positive:**
- **Extensibility**: New channels/instruments added without modifying core logic
- **Testability**: Mock channels for unit testing data processing
- **Flexibility**: Runtime configuration of active outputs
- **Fault Isolation**: Channel failures don't affect sensor acquisition
- **Multi-output**: Same data simultaneously sent to multiple destinations
- **Protocol Independence**: Core code doesn't know about CAN, serial, etc.
- **Performance**: Asynchronous distribution prevents blocking

**Negative:**
- Abstraction overhead (virtual function calls, dynamic allocation)
- More complex initialization sequence
- Configuration file parsing adds startup complexity
- Memory overhead from multiple channel instances
- Requires careful error handling across channel boundaries

**Implementation Requirements:**
- Thread-safe channel registration/unregistration
- Channel health monitoring and auto-reconnect
- Buffering for slow channels (network, file I/O)
- Backpressure handling if channel can't keep up
- Graceful degradation on channel failures
- Configuration validation on startup

**Error Handling Strategy:**
- Failed channel initialization → Log warning, continue with other channels
- Send failure → Retry with timeout, then mark channel as failed
- Critical channels (e.g., CAN) → Raise alarm if disconnected
- Non-critical channels (e.g., web dashboard) → Silent failure, background retry

**Performance Considerations:**
- Async publishing thread to avoid blocking data processing
- Buffered channels for variable-latency outputs
- Channel priority levels (CAN highest, logging lowest)
- Rate limiting for bandwidth-constrained channels
- Batch updates for display instruments (e.g., refresh at 10 Hz, not per-sample)

**Future Extensions:**
- **Two-way channels**: Receive configuration commands via network/CAN
- **Data compression**: For low-bandwidth channels
- **Encryption/authentication**: Secure network channels
- **Redundant channels**: Automatic failover between CAN interfaces
- **Cloud telemetry**: MQTT/HTTP upload to cloud services
