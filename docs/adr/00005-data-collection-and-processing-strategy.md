# 00005. Data Collection and Processing Strategy

2025-10-06

## Status

__New__

## Context

The engine monitoring system must handle:

**Multiple Sensor Streams:**
- 4-6 EGT sensors (10 Hz each)
- 4-6 CHT sensors (10 Hz each)
- 1 RPM sensor (20 Hz)
- 1 Engine time accumulator (1 Hz)
- Total: ~100-150 samples/second

**Real-time Requirements:**
- Sensors must be sampled at precise intervals
- CAN-Bus transmission has strict timing windows
- Alarm detection must be immediate (<100ms)
- System must handle sensor failures gracefully
- No data loss under normal operating conditions

**Processing Requirements:**
- Data validation and range checking
- Digital filtering (noise reduction)
- Rate of change monitoring (detect rapid temperature changes)
- Alarm threshold detection
- Data aggregation (per-cylinder averages, peaks)

**Resource Constraints:**
- Single-core Raspberry Pi (limited CPU)
- No hard real-time guarantees (Linux OS)
- Minimal memory footprint
- Must coexist with CAN-Bus communication

## Decision

We will implement a **multi-threaded pipeline architecture** with dedicated threads for:

### Thread Architecture:

1. **Sensor Acquisition Thread** (High Priority)
   - Samples all sensors at their configured rates
   - Uses timer-based scheduling for precise timing
   - Minimal processing - just raw data collection
   - Publishes to lock-free ring buffer

2. **Data Processing Thread** (Medium Priority)
   - Consumes raw sensor data from ring buffer
   - Applies calibration and filtering
   - Performs validation and range checking
   - Detects alarm conditions
   - Publishes processed data to output queues

3. **CAN-Bus Transmission Thread** (Medium Priority)
   - Consumes processed data
   - Formats CAN frames
   - Handles transmission scheduling
   - Manages retries and error recovery

4. **Main Control Thread** (Low Priority)
   - System initialization and configuration
   - Health monitoring and watchdog
   - Logging and diagnostics
   - Handles shutdown sequences

### Data Flow:

```
┌─────────────┐     Lock-Free      ┌──────────┐     Queue      ┌─────────┐
│  Sensor     │───▶  Ring Buffer ──▶│Processing│───▶ (MPSC)  ──▶│ CAN-Bus │
│Acquisition  │                     │  Thread  │                │  Thread │
│  Thread     │                     └──────────┘                └─────────┘
└─────────────┘                           │
   (Timer ISR)                            │ Alarm Queue
                                          ▼
                                   ┌─────────────┐
                                   │Main Control │
                                   │   Thread    │
                                   └─────────────┘
```

### Timing and Scheduling:

```cpp
// Sensor sampling uses POSIX timers
struct SamplingSchedule {
    std::chrono::milliseconds interval;
    std::function<void()> sampleCallback;
};

class DataAcquisitionEngine {
public:
    void schedulePeriodicSampling(ISensor* sensor);
    void run(); // High-priority thread loop
};
```

### Data Structures:

```cpp
// Lock-free ring buffer for sensor data
template<typename T, size_t Capacity>
class SPSCRingBuffer {
    // Single producer, single consumer
    // Wait-free push/pop operations
};

// Sensor data packet
struct SensorReading {
    uint64_t timestamp_us;
    uint16_t sensorId;
    SensorType type;
    double rawValue;
    uint8_t flags; // Error flags
};

// Processed data packet
struct ProcessedReading {
    uint64_t timestamp_us;
    uint16_t sensorId;
    double calibratedValue;
    double filteredValue;
    AlarmLevel alarmLevel;
};
```

### Data Processing Pipeline:

1. **Calibration**: Raw → Physical units using sensor-specific curves
2. **Filtering**: Exponential moving average or median filter
3. **Validation**: Range checking, rate-of-change limits
4. **Alarm Detection**: Threshold comparisons with hysteresis
5. **Aggregation**: Calculate cylinder averages, deltas

### Error Handling:

- **Sensor timeout**: Mark reading as invalid, continue with other sensors
- **Out-of-range**: Log error, use last known good value
- **Buffer overflow**: Log critical error, oldest data dropped
- **Processing lag**: Monitor queue depths, adjust priorities

## Consequences

**Positive:**
- Clear thread separation enables priority-based scheduling
- Lock-free data structures minimize latency and jitter
- Pipeline architecture allows independent scaling of stages
- Fault isolation - sensor failures don't block processing
- Testable components (mock sensors, mock CAN interface)
- CPU usage distributed across multiple cores (if available)

**Negative:**
- Increased complexity from multi-threading
- Potential timing issues if Linux scheduler preempts threads
- Memory overhead from buffering
- Debugging complexity (race conditions, timing bugs)
- Requires careful thread synchronization

**Implementation Requirements:**
- POSIX threads (pthread) or C++11 std::thread
- Real-time scheduling policies (SCHED_FIFO) for acquisition thread
- CPU affinity to avoid migration overhead
- Lock-free queue implementation (boost::lockfree or custom)
- Thread-safe logging mechanism
- Watchdog timer for deadlock detection

**Performance Targets:**
- Sensor sampling jitter: < 1ms
- Processing latency: < 10ms (raw sample → CAN transmission)
- CPU utilization: < 50% at maximum sample rate
- Memory: < 100MB total

**Monitoring and Diagnostics:**
- Per-thread CPU usage metrics
- Queue depth monitoring (detect bottlenecks)
- Missed deadline counters
- Sensor health status
- CAN transmission success rate

**Configuration:**
- Thread priorities configurable via config file
- Buffer sizes tunable based on available memory
- Filter coefficients adjustable per sensor type
- Alarm thresholds user-configurable
