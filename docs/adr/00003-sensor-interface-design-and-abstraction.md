# 00003. Sensor Interface Design and Abstraction

2025-10-06

## Status

__New__

## Context

The engine monitoring system requires multiple sensor types:

1. **Temperature Sensors** (EGT, CHT)
   - K-type thermocouples for EGT (up to 900°C)
   - J-type or PT100 for CHT (up to 300°C)
   - Multiple cylinders (typically 4-6 per engine)
   - Requires ADC with cold junction compensation

2. **RPM Sensor**
   - Magnetic pickup or Hall effect sensor
   - Frequency-based measurement
   - Wide range (0-6000+ RPM for aircraft engines)
   - Requires precise timing measurement

3. **Engine Time Tracker**
   - Software-based accumulator
   - Persistent storage required
   - Hobbs meter functionality

Each sensor type has different:
- Hardware interfaces (ADC, GPIO, timers)
- Sampling rates and timing requirements
- Data validation needs
- Calibration requirements

## Decision

We will implement a **polymorphic sensor interface** using C++ abstract base classes:

```cpp
class ISensor {
public:
    virtual ~ISensor() = default;

    // Core interface
    virtual bool initialize() = 0;
    virtual bool readRaw(double& value) = 0;
    virtual bool readCalibrated(double& value) = 0;
    virtual bool isHealthy() const = 0;

    // Metadata
    virtual SensorType getType() const = 0;
    virtual std::string getName() const = 0;
    virtual uint32_t getSampleRateHz() const = 0;
};
```

### Concrete Implementations:

1. **TemperatureSensor** (for EGT/CHT)
   - Wraps ADC with thermocouple linearization
   - Supports K-type, J-type, PT100
   - Configurable channel and calibration coefficients

2. **RpmSensor**
   - Uses GPIO interrupt or timer capture
   - Frequency-to-RPM conversion
   - Debouncing and filtering

3. **EngineTimeSensor**
   - Tracks running time when RPM > threshold
   - Persists to non-volatile storage
   - Resolution: 0.1 hour increments

### Sensor Configuration:

Each sensor instance will be configured via a descriptor:
```cpp
struct SensorConfig {
    std::string name;
    SensorType type;
    uint8_t hardwareChannel;
    uint32_t sampleRateHz;
    CalibrationData calibration;
};
```

## Consequences

**Positive:**
- Uniform interface simplifies data acquisition layer
- Easy to add new sensor types without modifying core logic
- Mock sensors can be created for testing
- Runtime polymorphism enables dynamic sensor configuration
- Type-safe sensor registration and discovery

**Negative:**
- Virtual function calls add minor overhead (acceptable for sensor rates)
- More complex initial implementation
- Requires careful management of sensor lifecycle

**Implementation Requirements:**
- Factory pattern for sensor instantiation from config
- Sensor manager/registry for lifecycle management
- Health monitoring with timeout detection
- Calibration data storage format (JSON/config file)
- Error reporting mechanism for failed sensors

**Example Usage:**
```cpp
// Create sensors from configuration
auto egtSensor = SensorFactory::create(egtConfig);
auto rpmSensor = SensorFactory::create(rpmConfig);

// Uniform interface
double egt, rpm;
if (egtSensor->readCalibrated(egt)) {
    // Process EGT
}
if (rpmSensor->readCalibrated(rpm)) {
    // Process RPM
}
```
