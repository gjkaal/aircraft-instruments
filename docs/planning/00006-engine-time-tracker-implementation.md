# 00006. Engine Time Tracker Implementation

2025-10-07

## Status

__New__

## Description

Implement engine hours tracking with persistent storage, time accumulation logic, atomic writes to prevent corruption, and rollover protection.

## Priority

Medium

## Estimated Duration

4-5 hours

## Subtasks

- Implement EngineTimeSensor class (inherits ISensor)
- Add time accumulation logic (accumulate when RPM > threshold)
- Implement persistent storage (file-based)
- Add atomic writes to prevent corruption
- Handle system time changes gracefully
- Add resolution control (0.1 hour increments)
- Implement rollover protection
- Write unit tests with mocked time

## Acceptance Criteria

- Engine hours accumulate correctly when running
- Data persists across reboots
- File corruption prevented with atomic writes
- Time tracking accurate within 0.1 hour
- Unit tests validate persistence

## Dependencies

Task 2.1 (Sensor Interface Design), Task 2.3 (RPM Sensor - needs RPM for threshold)

## Related

Phase 2: Sensor Layer Implementation - Task 2.4
ADR-0003 (Sensor Interface Design and Abstraction)


