# Task Completion Workflow

## When Starting a Task

1. **Review Task Details**
   - Use `task_list` or `task_find` to identify the task
   - Read the task description in `docs/planning/XXXXX-task-name.md`

2. **Consult Related ADRs**
   - Check which ADRs are relevant (listed in task description)
   - Read ADRs in `docs/adr/` to understand design constraints
   - Use `adr_find` to search for related decisions

3. **Update Task Status to Active**
   - Use `task_update` to mark the task as Active
   - This signals you're working on it

4. **Plan Implementation**
   - Use Serena tools to explore existing code (`get_symbols_overview`, `find_symbol`)
   - Identify files that need creation or modification
   - Plan the implementation approach

## During Implementation

1. **Use Serena for Code Navigation**
   - `get_symbols_overview` before reading full files
   - `find_symbol` to locate classes, methods, functions
   - `find_referencing_symbols` to understand dependencies
   - Avoid reading entire files unless necessary

2. **Follow Code Style**
   - C++17 standard
   - Interface prefix: `I` (e.g., `ISensor`)
   - PascalCase for classes, camelCase for methods
   - Doxygen-style comments for public APIs

3. **Implement According to ADRs**
   - Follow architectural decisions documented in ADRs
   - Use specified design patterns (Factory, Publisher-Subscriber, etc.)
   - Maintain threading model and performance requirements

## After Implementation

1. **Build the Project**
   ```bash
   mkdir build
   cd build
   cmake ..
   make
   ```
   - Fix any compilation errors
   - Ensure no warnings (build uses `-Wall -Wextra`)

2. **Test the Implementation**
   - Run the application: `./build/RaspberryPiApp`
   - Verify functionality works as expected
   - Check that changes don't break existing code

3. **Update Task Status**
   - Use `task_update` to mark as ReviewPending or Completed
   - Status meanings:
     - **ReviewPending**: Implementation done, awaiting review
     - **Completed**: Fully done and verified

4. **Update Documentation**
   - Update CLAUDE.md if workflow changes
   - Create new ADR if architectural decision was made
   - Update task TOC: use `task_generate_toc`

## Task Status Workflow

```
New → Active → ReviewPending → Completed
        ↓
      OnHold (if blocked)
        ↓
      Abandoned (if cancelled)
```

## Quality Checklist Before Marking Complete

- [ ] Code compiles without errors or warnings
- [ ] Follows C++17 standard and project conventions
- [ ] Adheres to relevant ADR design decisions
- [ ] Threading model is respected (if applicable)
- [ ] Error handling follows project strategy
- [ ] Real-time performance requirements considered
- [ ] Code is tested (manual or automated)
- [ ] Task status updated in n2adr
- [ ] Related documentation updated if needed