# GitPeek Coding Standards and Conventions

## Naming Conventions
- **Classes/Structs**: PascalCase (e.g., `GitManager`, `Repository`)
- **Variables/Functions**: camelCase (e.g., `currentBranch`, `fetchStatus()`)
- **Constants**: camelCase (e.g., `maximumRetryCount`)
- **Files**: PascalCase (e.g., `GitManager.swift`)

## Code Style
- **Indentation**: 4 spaces (no tabs)
- **Line Length**: Max 120 characters (prefer 100)
- **Force Unwraps**: Avoid entirely - use guard/if-let
- **Access Control**: Use appropriate levels (private, internal, public)
- **async/await**: Preferred over completion handlers
- **@MainActor**: Use for UI-related classes

## Error Handling
- Use throwing functions with custom error types
- Implement LocalizedError for user-facing errors
- Prefer Result<T, Error> for async callbacks

## SwiftUI Guidelines
- Break down views into smaller components
- Use ViewModifiers for reusable styling
- Keep ViewModels as @MainActor @ObservableObject

## Documentation
- Use Swift DocC format for public APIs
- Add inline comments for complex logic only
- Avoid obvious comments

## Test Standards
- Follow AAA pattern (Arrange-Act-Assert)
- Test naming: `test<Method>_when<Condition>_<ExpectedResult>`
- Mock dependencies through protocols
- Target 80%+ code coverage