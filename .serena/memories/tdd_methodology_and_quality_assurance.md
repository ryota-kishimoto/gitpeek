# GitPeek TDD Methodology and Quality Assurance

## TDD Core Principles (Kent Beck/t-wada)
1. **Red**: Write a failing test first
2. **Green**: Write minimal code to pass the test
3. **Refactor**: Improve code while keeping tests green

## TDD Golden Rules (Uncle Bob)
1. Don't write production code until you have a failing test
2. Don't write more test than sufficient to fail
3. Don't write more production code than sufficient to pass the test

## TDD Tactics
- **Fake It**: Start with constants/hardcoded values
- **Triangulation**: Use multiple test cases to drive generalization
- **Obvious Implementation**: Direct implementation for simple cases

## Sub-Agents Quality Process
- **test-planner**: Designs comprehensive test cases
- **test-executor**: Implements tests from independent perspective
- **tdd-facilitator**: Guides TDD cycle adherence
- **code-reviewer**: Reviews for Swift API Guidelines compliance
- **security-auditor**: Checks security best practices
- **performance-optimizer**: Optimizes performance metrics

## Quality Gates
Each development step must pass:
- [ ] Test coverage > 80%
- [ ] SwiftLint warnings = 0
- [ ] All tests passing
- [ ] Sub-agent review complete

## Automation
- Pre-commit hooks enforce quality
- Commit message format validation
- Continuous integration with test runs
- Automatic code formatting and linting