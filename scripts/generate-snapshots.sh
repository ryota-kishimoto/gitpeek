#!/bin/bash

# Script to generate baseline snapshots for GitPeek
# Usage: ./scripts/generate-snapshots.sh

set -e

echo "🎨 Generating baseline snapshots for GitPeek..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Clean previous snapshots
echo "🧹 Cleaning previous snapshots..."
find . -type d -name "__Snapshots__" -exec rm -rf {} + 2>/dev/null || true
find . -type d -name "Failures" -exec rm -rf {} + 2>/dev/null || true

# Set recording mode in test files
echo "📝 Setting recording mode in test files..."
for file in GitPeekTests/Snapshot/*.swift; do
    if [ -f "$file" ]; then
        # Temporarily uncomment isRecording = true
        sed -i '' 's|// isRecording = true|isRecording = true|g' "$file"
    fi
done

# Run snapshot tests to generate baselines
echo "📸 Running snapshot tests to generate baselines..."
xcodebuild test \
    -scheme GitPeek \
    -destination 'platform=macOS' \
    -only-testing:GitPeekTests/MenuBarViewSnapshotTests \
    -only-testing:GitPeekTests/SettingsViewSnapshotTests \
    -only-testing:GitPeekTests/ContentViewSnapshotTests \
    2>&1 | grep -E "(Test Suite|passed|failed|Executed)" || true

# Restore test files
echo "📝 Restoring test files..."
for file in GitPeekTests/Snapshot/*.swift; do
    if [ -f "$file" ]; then
        # Comment out isRecording = true
        sed -i '' 's|isRecording = true|// isRecording = true|g' "$file"
    fi
done

# Check if snapshots were generated
if find . -type d -name "__Snapshots__" | grep -q .; then
    echo -e "${GREEN}✅ Snapshots generated successfully!${NC}"
    echo ""
    echo "Generated snapshots:"
    find . -type f -path "*__Snapshots__*.png" | while read -r file; do
        echo "  📸 $(basename "$file")"
    done
else
    echo -e "${RED}❌ No snapshots were generated${NC}"
    echo "Please check that the tests are running correctly."
    exit 1
fi

echo ""
echo -e "${GREEN}✨ Done! Snapshots are ready for use.${NC}"
echo ""
echo "Next steps:"
echo "1. Review the generated snapshots in __Snapshots__ directories"
echo "2. Commit them to version control"
echo "3. Run tests normally to verify snapshots match"