# /release

Create a new release with tag and GitHub release.

## Important Notes

- **リリースの実行はユーザーが最終決定する**
- このコマンドは自動的にタグをプッシュしない
- ユーザーの確認を得てから実行する

## Steps to execute:

1. Ask the user for the version number (e.g., v1.2.2)
2. Show recent commits for release notes
3. Generate release notes from commits
4. **Ask user for confirmation before creating tag**
5. Create and push a git tag only after user confirms
6. Monitor GitHub Actions workflow
7. Provide links to the release page and workflow

## Commands to run:

```bash
# First, show what will be released
git log --oneline -10

# Create annotated tag (after user confirmation)
git tag -a vX.X.X -m "Release vX.X.X with release notes"

# Push the tag (after user confirmation)
git push origin vX.X.X

# Check workflow status
gh run list --workflow=release.yml --limit=1
```

## GitHub Actions Workflow

The workflow will automatically:
- Build the Release version for macOS
- Create DMG installer
- Generate SHA256 checksum
- Create GitHub Release with release notes
- Upload assets (DMG and SHA256)

## Release Checklist

Before releasing, ensure:
- [ ] All tests pass
- [ ] Version number is updated in Info.plist
- [ ] CHANGELOG is updated
- [ ] No uncommitted changes
- [ ] User has reviewed and confirmed the release