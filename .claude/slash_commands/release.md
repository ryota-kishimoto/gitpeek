# /release

Create a new release by pushing a tag to trigger GitHub Actions.

## Simplified Release Flow

1. **Ask for version number** (e.g., v1.3.3)
2. **Update version in Info.plist**
3. **Commit version change**
4. **Push commit**
5. **Create and push tag**
6. **Monitor GitHub Actions**

That's it! GitHub Actions will:
- Build the release
- Create DMG
- Sign with Sparkle
- Update appcast.xml
- Create GitHub Release

Local GitPeek will receive update notification via Sparkle.

## Commands to execute:

```bash
# 1. Update version in Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString X.X.X" GitPeek/Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion X.X.X" GitPeek/Info.plist

# 2. Commit version change
git add GitPeek/Info.plist
git commit -m "chore: bump version to X.X.X"

# 3. Push commit
git push origin main

# 4. Create and push tag
git tag -a vX.X.X -m "Release vX.X.X"
git push origin vX.X.X

# 5. Monitor workflow
gh run list --workflow=release.yml --limit=1
```

## What happens next:

1. **GitHub Actions** builds and releases automatically
2. **appcast.xml** gets updated on main branch
3. **Sparkle** checks for updates (every 24 hours or manual check)
4. **GitPeek** shows update notification
5. **User** clicks update to install new version

## Notes

- No local build needed
- No manual DMG creation
- No manual app installation
- Everything is automated via CI/CD
- Sparkle handles the update process