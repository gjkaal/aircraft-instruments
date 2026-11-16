# 00001. Use C++ for Raspberry Pi Embedded Application

2025-10-06

## Status

__New__

## Context

This project is an embedded application for Raspberry Pi (compact). We need to select a programming language that provides:
- Direct hardware access and low-level control
- Good performance on resource-constrained devices
- Mature ecosystem for embedded development
- Cross-compilation support for ARM architecture

## Decision

We will use C++ as the primary programming language for this Raspberry Pi embedded application.

## Consequences

**Positive:**
- Excellent performance and minimal runtime overhead
- Direct memory management and hardware access
- Strong type safety and modern language features (C++17)
- Extensive libraries available for embedded systems
- Native cross-compilation support for ARM/Raspberry Pi
- No runtime dependencies or garbage collection overhead

**Negative:**
- Manual memory management increases development complexity
- Longer compilation times compared to interpreted languages
- Requires more careful attention to resource management
- Steeper learning curve for developers unfamiliar with C++

**Neutral:**
- CMake will be used as the build system for cross-platform compatibility
- Code will target C++17 standard for balance between features and compatibility
