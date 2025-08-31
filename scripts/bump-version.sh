#!/bin/bash

# GitPeek Version Bump Script
# Updates version numbers across the project

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_info() { echo -e "${YELLOW}ℹ️  $1${NC}"; }

# Check if version argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 1.3.0"
    echo ""
    echo "This script will update:"
    echo "  - GitPeek/Info.plist"
    echo "  - Package.swift (if needed)"
    echo "  - Create a git commit"
    exit 1
fi

VERSION=$1

# Validate version format (semantic versioning)
if ! [[ $VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    print_error "Invalid version format. Please use semantic versioning (e.g., 1.3.0)"
    exit 1
fi

# Remove 'v' prefix if provided
VERSION=${VERSION#v}

print_info "Updating GitPeek to version $VERSION"

# Update Info.plist using PlistBuddy (safer than sed)
INFO_PLIST="GitPeek/Info.plist"
if [ -f "$INFO_PLIST" ]; then
    print_info "Updating $INFO_PLIST..."
    
    # Get current version for comparison
    CURRENT_VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$INFO_PLIST" 2>/dev/null || echo "unknown")
    print_info "Current version: $CURRENT_VERSION"
    
    # Update version
    /usr/libexec/PlistBuddy -c "Set CFBundleShortVersionString $VERSION" "$INFO_PLIST" || {
        print_error "Failed to update Info.plist"
        exit 1
    }
    
    # Also update CFBundleVersion (build number - using same as version for simplicity)
    /usr/libexec/PlistBuddy -c "Set CFBundleVersion $VERSION" "$INFO_PLIST" 2>/dev/null || true
    
    print_success "Updated Info.plist to version $VERSION"
else
    print_error "Info.plist not found at $INFO_PLIST"
    exit 1
fi

# Update Package.swift if it contains version info (optional)
PACKAGE_SWIFT="Package.swift"
if [ -f "$PACKAGE_SWIFT" ]; then
    if grep -q "version:" "$PACKAGE_SWIFT"; then
        print_info "Updating $PACKAGE_SWIFT..."
        sed -i '' "s/version: \".*\"/version: \"$VERSION\"/" "$PACKAGE_SWIFT"
        print_success "Updated Package.swift"
    fi
fi

# Check if there are changes to commit
if git diff --quiet; then
    print_error "No changes detected. Version might already be $VERSION"
    exit 1
fi

# Show the changes
print_info "Changes to be committed:"
git diff --stat

# Commit the changes
print_info "Creating git commit..."
git add "$INFO_PLIST" "$PACKAGE_SWIFT" 2>/dev/null || git add "$INFO_PLIST"
git commit -m "chore: bump version to $VERSION

- Update CFBundleShortVersionString to $VERSION
- Prepare for release v$VERSION" || {
    print_error "Failed to create commit"
    exit 1
}

print_success "Version bumped to $VERSION successfully!"
echo ""
echo "Next steps:"
echo "1. Review the commit: git show HEAD"
echo "2. Push to main: git push origin main"
echo "3. Create and push tag: git tag -a v$VERSION -m \"Release v$VERSION\""
echo "4. Push the tag: git push origin v$VERSION"
echo ""
echo "Or use the /release command for automated release"