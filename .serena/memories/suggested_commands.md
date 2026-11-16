# Suggested Commands

## Build Commands

### Standard Build (Cross-Compile for Raspberry Pi)
```bash
mkdir build
cd build
cmake -DCMAKE_TOOLCHAIN_FILE=../cmake/toolchain-raspberry-pi.cmake ..
make
```

### Build for Local Development (Windows)
```bash
mkdir build
cd build
cmake ..
make
```

### VS Code Build
1. Press `Ctrl+Shift+P` → "CMake: Select a Kit"
2. Choose "Raspberry Pi Cross-Compile" (or "Local GCC" for Windows)
3. Press `F7` or click "Build" in status bar

### Clean Build
```bash
rm -rf build
mkdir build
cd build
cmake ..
make
```

## Run Commands

### Run Application (after build)
```bash
./build/RaspberryPiApp
```

### Run on Windows (local build)
```bash
./build/RaspberryPiApp.exe
```

## Task Management Commands (n2adr MCP Tool)

### List All Tasks
Use MCP tool: `task_list`

### Find Tasks by Query
Use MCP tool: `task_find` with query string and optional status filter

### Update Task Status
Use MCP tool: `task_update` with taskId and new status (New, Active, ReviewPending, Completed, etc.)

### Create New Task
Use MCP tool: `task_new` with title and description

### Generate Task TOC
Use MCP tool: `task_generate_toc` → creates `docs/tasks-toc.md`

## ADR Management Commands (n2adr MCP Tool)

### List All ADRs
Use MCP tool: `adr_list`

### Create New ADR
Use MCP tool: `adr_new` with title

### Find ADRs
Use MCP tool: `adr_find` with query string

## Git Commands (Windows/MSYS)

### Status
```bash
git status
```

### Commit Changes
```bash
git add .
git commit -m "commit message"
```

### View History
```bash
git log --oneline
```

## File Operations (Windows/MSYS)

### List Files
```bash
ls -la
```

### Find Files
```bash
find src -name "*.cpp"
```

### Search in Files
```bash
grep -r "pattern" src/
```

### View File
```bash
cat filename
```

## Project Navigation (Serena MCP Tool)

### Get File Overview
Use MCP tool: `get_symbols_overview` with relative_path

### Find Symbol
Use MCP tool: `find_symbol` with name_path (e.g., "ClassName/methodName")

### Search Pattern
Use MCP tool: `search_for_pattern` with regex pattern

### List Directory
Use MCP tool: `list_dir` with relative_path