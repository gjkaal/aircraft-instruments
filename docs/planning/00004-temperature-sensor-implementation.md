# 00004. Temperature Sensor Implementation

2025-10-07

## Status

__New__

## Description

Implement temperature sensor support for EGT and CHT measurements with thermocouple linearization, cold junction compensation, and calibration coefficient support.

## Priority

High

## Estimated Duration

6-8 hours

## Subtasks

- Implement TemperatureSensor class (inherits ISensor)
- Add ADC interface abstraction (SPI/I2C)
- Implement thermocouple linearization (K-type, J-type)
- Add PT100 sensor support
- Implement cold junction compensation
- Add calibration coefficient support
- Create sensor validation and range checking
- Write unit tests with mock ADC

## Acceptance Criteria

- Temperature sensors read raw ADC values
- Linearization produces accurate temperature readings
- Calibration adjusts readings correctly
- Out-of-range values detected
- Unit tests achieve >80% code coverage

## Dependencies

Task 2.1 (Sensor Interface Design)

## Related

Phase 2: Sensor Layer Implementation - Task 2.2
ADR-0003 (Sensor Interface Design and Abstraction)


