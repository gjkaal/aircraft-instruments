cmake_minimum_required(VERSION 3.10)
project(RaspberryPiApp)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Raspberry Pi optimization flags
if(CMAKE_CROSSCOMPILING)
    message(STATUS "Cross-compiling for Raspberry Pi")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O2 -Wall -Wextra")
    # Disable dependency tracking to avoid temp file issues on Windows
    set(CMAKE_DEPENDS_IN_PROJECT_ONLY ON)
else()
    message(STATUS "Building for host system")
endif()

# Add source files
file(GLOB_RECURSE SOURCES "src/*.cpp")

# Create executable
add_executable(${PROJECT_NAME} ${SOURCES})

# Include directories
target_include_directories(${PROJECT_NAME} PRIVATE src)
