# 00012. CAN Engine Data Publisher

2025-10-07

## Status

__New__

## Description

Implement CAN-Bus publisher for engine data with message formatting, CAN ID construction, periodic transmission scheduling, and retry logic.

## Priority

High

## Estimated Duration

5-6 hours

## Subtasks

- Create CanEnginePublisher class
- Implement message formatting for each data type (EGT, CHT, RPM, hours)
- Add CAN ID construction (priority, source, type, channel)
- Implement periodic transmission scheduling
- Add transmission queue with priority ordering
- Implement retry logic for failed transmissions
- Create CAN transmission thread
- Write unit tests with mock CAN interface

## Acceptance Criteria

- Engine data correctly formatted as CAN frames
- Transmission rates match specification
- Priority ordering works correctly
- Failed transmissions retried
- Unit tests validate message format

## Dependencies

Task 4.1 (CAN Interface Abstraction), Task 3.3 (Data Processing Pipeline)

## Related

Phase 4: CAN-Bus Communication
ADR-0004 (CAN-Bus Communication Interface)


