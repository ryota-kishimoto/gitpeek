# Snapshot Testing Guide

## Automated Recording Mode

The snapshot tests now support automated recording mode without manual code changes.

### Local Development

**Generate new snapshots:**
```bash
# Using environment variable (recommended)
RECORD_SNAPSHOTS=true swift test -c debug --filter ViewSnapshotTests

# Using Xcode with environment variable
# In scheme editor: Environment Variables → Add RECORD_SNAPSHOTS=true
```

**Compare against existing snapshots (default):**
```bash
# Normal test run - compares against existing baselines
swift test -c debug --filter ViewSnapshotTests
```

### CI/CD Integration

The CI workflows automatically:
- **Comparison mode (default)**: Tests compare against committed baseline images
- **Recording mode**: When `RECORD_SNAPSHOTS=true` is set, generates new baselines

### No More Manual Code Changes

**Before:**
```swift
override func setUpWithError() throws {
    isRecording = true // Manual toggle required
}
```

**Now:**
```swift
override func setUpWithError() throws {
    // Automatically detects recording mode
    isRecording = shouldRecordSnapshots()
}
```

### How It Works

1. **Environment Variable**: `RECORD_SNAPSHOTS=true`
2. **Command Line Flag**: `--record-snapshots`
3. **Default Behavior**: Comparison mode (isRecording = false)

The system checks for:
1. Environment variable `RECORD_SNAPSHOTS=true`
2. Falls back to comparison mode (default)

This eliminates the need to manually edit test files for baseline generation.