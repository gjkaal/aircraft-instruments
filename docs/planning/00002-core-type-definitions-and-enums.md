# 00002. Core Type Definitions and Enums

2025-10-07

## Status

__New__

## Description

Define fundamental types, enums, and constants used throughout the system including SensorType, AlarmLevel, ChannelType, and DataType enums.

## Priority

High

## Estimated Duration

2-3 hours

## Subtasks

- Create SensorType enum (EGT, CHT, RPM, ENGINE_TIME)
- Create AlarmLevel enum (NONE, CAUTION, WARNING, CRITICAL)
- Create ChannelType enum (CAN_BUS, SERIAL, NETWORK, FILE_LOG)
- Create DataType enum for messaging
- Define constants (max cylinders, sample rates, timeouts)
- Create common utility header files

## Acceptance Criteria

- All enums defined in header files
- Type-safe enum classes used (C++11 style)
- Constants documented and organized
- No circular dependencies

## Dependencies

Task 1.1 (Project Setup and Build System)

## Related

Phase 1: Foundation and Infrastructure - Task 1.2


