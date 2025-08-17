# GitPeek Development Commands and Workflow

## Essential Development Commands

### Setup and Installation
```bash
make setup              # Setup development environment (installs SwiftLint, SwiftFormat)
make install-hooks      # Install git hooks
```

### Code Quality
```bash
make lint               # Run SwiftLint
make lint-fix           # Auto-fix SwiftLint issues
make format             # Format code with SwiftFormat
make format-check       # Check format without changing
make check              # Run both lint and format check
make fix                # Auto-fix both lint and format
```

### Build and Test
```bash
make build              # Debug build
make build-release      # Release build
make clean              # Clean build
make test               # Run all tests
make test-unit          # Run unit tests only
make test-integration   # Run integration tests only
make test-ui            # Run UI tests only
make test-coverage      # Generate coverage report
```

### TDD Workflow
```bash
make tdd                # Start TDD watch mode
make red                # Red phase - check failing tests
make green              # Green phase - check passing tests
make refactor           # Refactor phase - check after refactoring
```

### CI/CD
```bash
make ci                 # CI checks (lint + test)
make pre-commit         # Pre-commit checks
```

### Utilities
```bash
make stats              # Show code statistics
make todo               # List TODO items
make deps               # Update dependencies
make reset              # Reset project state
```

## System Commands (macOS Darwin)
- `git` - Version control
- `xcodebuild` - Build and test
- `swiftlint` - Code linting
- `swiftformat` - Code formatting
- `find` - File searching
- `grep` - Text searching
- `make` - Task automation