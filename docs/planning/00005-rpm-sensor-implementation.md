# 00005. RPM Sensor Implementation

2025-10-07

## Status

__New__

## Description

Implement RPM sensor using frequency measurement with GPIO interrupt handler, timer capture, debouncing logic, and frequency-to-RPM conversion.

## Priority

High

## Estimated Duration

5-7 hours

## Subtasks

- Implement RpmSensor class (inherits ISensor)
- Add GPIO interrupt handler for pulse counting
- Implement timer capture for precise frequency measurement
- Add debouncing logic
- Implement frequency-to-RPM conversion
- Add filtering (moving average or median)
- Handle zero RPM (engine stopped) correctly
- Write unit tests with simulated pulse trains

## Acceptance Criteria

- RPM sensor accurately measures frequency
- Debouncing eliminates spurious pulses
- Conversion to RPM is accurate
- Zero RPM handled correctly
- Unit tests pass with various frequencies

## Dependencies

Task 2.1 (Sensor Interface Design)

## Related

Phase 2: Sensor Layer Implementation - Task 2.3
ADR-0003 (Sensor Interface Design and Abstraction)


