# /release

Create a new release with tag and automated GitHub Actions deployment.

## Important Notes

- **リリースの実行はユーザーが最終決定する**
- このコマンドは自動的にタグをプッシュしない
- ユーザーの確認を得てから実行する
- GitHub Actionsが自動的にビルド・署名・配信を行う

## Steps to execute:

1. Ask the user for the version number (e.g., v1.3.0)
2. Update Info.plist version number
3. Show recent commits for release notes
4. Generate release notes from commits
5. **Ask user for confirmation before proceeding**
6. Commit version update
7. Create and push a git tag
8. Monitor GitHub Actions workflow
9. Confirm appcast.xml was updated
10. Provide links to the release page

## Version Update:

```bash
# Update Info.plist version
sed -i '' "s/<string>.*<\/string>/<string>VERSION<\/string>/" GitPeek/Info.plist
```

## Git Commands:

```bash
# Commit version update
git add GitPeek/Info.plist
git commit -m "chore: bump version to vX.X.X"
git push origin main

# Create annotated tag (after user confirmation)
git tag -a vX.X.X -m "Release vX.X.X

Release notes here..."

# Push the tag
git push origin vX.X.X

# Check workflow status
gh run list --workflow=release.yml --limit=1
gh run watch
```

## GitHub Actions Workflow

The workflow will automatically:
- Build the Release version for macOS
- Create DMG installer
- **Sign DMG with Sparkle EdDSA signature**
- Generate SHA256 checksum
- Create GitHub Release with release notes
- Upload assets (DMG and SHA256)
- **Update appcast.xml for auto-updates**
- **Commit appcast.xml to main branch**

## Auto-Update Flow

After release:
1. Existing users receive update notification
2. New version downloads automatically
3. App restarts with new version
4. No manual download required!

## Release Checklist

Before releasing, ensure:
- [ ] All tests pass (CI green)
- [ ] No uncommitted changes
- [ ] User has reviewed and confirmed the release
- [ ] Version number follows semantic versioning
- [ ] Info.plist version updated

## Post-Release Verification

After tag push, verify:
- [ ] GitHub Actions workflow succeeds
- [ ] DMG is uploaded to GitHub Release
- [ ] appcast.xml is updated in main branch
- [ ] Test auto-update on a local copy