# 00011. MCP2515 CAN Controller Driver

2025-10-07

## Status

__New__

## Description

Implement MCP2515 CAN controller driver via SPI with initialization sequence, frame transmission/reception, bus-off recovery logic, and error flag monitoring.

## Priority

High

## Estimated Duration

10-12 hours

## Subtasks

- Create Mcp2515CanInterface class (implements ICanInterface)
- Implement SPI communication layer
- Add MCP2515 register definitions
- Implement initialization sequence (timing, filters, masks)
- Add frame transmission with error handling
- Implement frame reception
- Add bus-off recovery logic
- Implement error flag monitoring
- Create integration tests (requires hardware or simulator)

## Acceptance Criteria

- MCP2515 initializes correctly
- CAN frames transmitted successfully
- CAN frames received correctly
- Bus errors detected and handled
- Baud rate configured to 500 kbps

## Dependencies

Task 4.1 (CAN Interface Abstraction)

## Related

Phase 4: CAN-Bus Communication
ADR-0004 (CAN-Bus Communication Interface)


