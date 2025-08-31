# Snapshot Testing Guide

GitPeek uses **swift-snapshot-testing** by Point-Free for Visual Regression Testing (VRT).

## Overview

Snapshot tests capture visual representations of our SwiftUI views and compare them against baseline images to detect unintended UI changes.

## Running Snapshot Tests

### Run All Snapshot Tests
```bash
xcodebuild test \
  -scheme GitPeek \
  -destination 'platform=macOS' \
  -only-testing:GitPeekTests/ViewSnapshotTests
```

### Using the Generation Script
```bash
# Generate or update baseline snapshots
./scripts/generate-snapshots.sh
```

## Test Files

- `GitPeekTests/Snapshot/ViewSnapshotTests.swift` - Main snapshot tests for all views

## Covered Views

- **SettingsView** - Light and dark mode
- **MenuBarView** - Empty state and dark mode
- **ContentView** - Empty state and dark mode

## Updating Snapshots

When UI changes are intentional:

1. **Enable Recording Mode**
   ```swift
   // In ViewSnapshotTests.swift
   override func setUpWithError() throws {
       isRecording = true // Enable to update snapshots
   }
   ```

2. **Run Tests** to generate new baseline snapshots

3. **Disable Recording Mode**
   ```swift
   override func setUpWithError() throws {
       // isRecording = true // Disable after updating
   }
   ```

4. **Commit the Updated Snapshots**
   ```bash
   git add **/__Snapshots__/*.png
   git commit -m "chore: update snapshot baselines"
   ```

## CI Integration

### GitHub Actions Workflow

The snapshot tests run automatically on:
- Pull requests
- Pushes to main branch
- Manual workflow dispatch

See `.github/workflows/snapshot-tests.yml` for the full configuration.

### PR Workflow

1. Tests run on every PR
2. If snapshots fail, the workflow:
   - Uploads failed snapshots as artifacts
   - Comments on the PR with instructions
   - Shows visual differences

### Reviewing Failures

1. Download the `failed-snapshots` artifact from GitHub Actions
2. Compare with local snapshots
3. If changes are intentional, update baselines (see above)
4. If changes are bugs, fix the code

## Best Practices

### 1. Consistent Environment
- Always generate snapshots on macOS 14+ 
- Use the same Xcode version as CI (15.0+)

### 2. Test Coverage
- Test both light and dark modes
- Test empty states
- Test different window sizes

### 3. Snapshot Organization
```
GitPeekTests/
├── Snapshot/
│   ├── __Snapshots__/     # Generated baseline images
│   │   └── ViewSnapshotTests/
│   │       ├── testSettingsView.png
│   │       ├── testSettingsView_DarkMode.png
│   │       └── ...
│   └── ViewSnapshotTests.swift
```

### 4. Naming Convention
- Use descriptive test names: `testViewName_State`
- Examples:
  - `testSettingsView`
  - `testSettingsView_DarkMode`
  - `testMenuBarView_Empty`

## Troubleshooting

### Tests Not Running
```bash
# Clean build folder
xcodebuild clean -scheme GitPeek

# Resolve packages
xcodebuild -resolvePackageDependencies
```

### Snapshots Not Generating
1. Ensure `isRecording = true` is set
2. Check that SnapshotTesting package is resolved
3. Run tests with verbose output:
   ```bash
   xcodebuild test -scheme GitPeek -destination 'platform=macOS' \
     -only-testing:GitPeekTests/ViewSnapshotTests \
     -verbose
   ```

### CI Failures
- Check the uploaded artifacts for visual differences
- Ensure local environment matches CI (macOS version, Xcode version)
- Verify snapshots are committed to the repository

## Adding New Snapshot Tests

1. Add test method to `ViewSnapshotTests.swift`:
   ```swift
   func testNewView() async {
       let view = NewView()
           .frame(width: 400, height: 300)
       
       let hostingController = NSHostingController(rootView: view)
       assertSnapshot(of: hostingController, as: .image)
   }
   ```

2. Enable recording mode and run test
3. Verify generated snapshot
4. Disable recording mode
5. Commit the new baseline

## Resources

- [swift-snapshot-testing Documentation](https://github.com/pointfreeco/swift-snapshot-testing)
- [Point-Free Episode on Snapshot Testing](https://www.pointfree.co/episodes/ep41-a-tour-of-snapshot-testing)