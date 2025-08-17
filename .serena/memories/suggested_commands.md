# GitPeek Suggested Commands

## Daily Development Workflow

### Starting Development Session
```bash
make test               # Verify all tests pass
make todo               # Check TODO list
git status              # Check current state
```

### TDD Development Cycle
```bash
# 1. Write failing test (Red)
make red                # Verify test fails

# 2. Implement minimal solution (Green)  
make green              # Verify test passes

# 3. Refactor and improve (Refactor)
make refactor           # Run quality checks + tests
```

### Before Committing
```bash
make pre-commit         # Runs lint, format, and unit tests
# OR manually:
make check              # Lint and format check
make test-unit          # Quick unit test run
```

### Code Quality Maintenance
```bash
make lint-fix           # Auto-fix linting issues
make format             # Auto-format code
make test-coverage      # Check test coverage
make stats              # View code statistics
```

### Project Maintenance
```bash
make setup              # Setup dev environment (first time)
make install-hooks      # Install git hooks
make clean              # Clean build artifacts
make deps               # Update dependencies
```

### CI/Release Preparation
```bash
make ci                 # Full CI check (lint + all tests)
make build-release      # Release build
make test               # Full test suite
```

## Key Reminders
- Always run `make test` before starting work
- Use `make pre-commit` before every commit
- Follow TDD: Red → Green → Refactor
- Never push without permission
- Keep commits small and focused