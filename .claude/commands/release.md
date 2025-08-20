# /release

Create a new release with tag and GitHub release.

## Steps to execute:

1. Ask the user for the version number (e.g., v1.2.2)
2. Ask for release notes or generate them from recent commits
3. Create and push a git tag with the version
4. GitHub Actions will automatically create the release
5. Confirm the release was created successfully

## Commands to run:

```bash
# Create annotated tag
git tag -a vX.X.X -m "Release vX.X.X"

# Push the tag
git push origin vX.X.X
```

The GitHub Actions workflow will automatically:
- Build the Release version
- Create DMG installer
- Generate SHA256 checksum
- Create GitHub Release with release notes
- Upload assets (DMG and SHA256)