# GitPeek Git運用ルール

## ブランチ戦略

### GitHub Flow
シンプルな GitHub Flow を採用します。

```
main (protected)
 ├── feature/add-menu-bar
 ├── feature/github-integration
 ├── fix/memory-leak
 └── docs/update-readme
```

### ブランチ命名規則

| プレフィックス | 用途 | 例 |
|--------------|------|-----|
| `feature/` | 新機能追加 | `feature/add-settings-panel` |
| `fix/` | バグ修正 | `fix/crash-on-launch` |
| `refactor/` | リファクタリング | `refactor/git-command-structure` |
| `docs/` | ドキュメント | `docs/add-contributing-guide` |
| `test/` | テスト追加・修正 | `test/add-integration-tests` |
| `chore/` | その他の作業 | `chore/update-dependencies` |

## コミット規約

### コミットメッセージ形式

```
<type>: <subject>

[optional body]

[optional footer]
```

### Type一覧

| Type | 説明 | 例 |
|------|------|-----|
| `feat` | 新機能 | `feat: add repository search functionality` |
| `fix` | バグ修正 | `fix: resolve crash when repository path is invalid` |
| `docs` | ドキュメント | `docs: update installation instructions` |
| `style` | コードスタイル | `style: format code with SwiftLint` |
| `refactor` | リファクタリング | `refactor: extract git operations to separate class` |
| `perf` | パフォーマンス改善 | `perf: optimize repository status fetching` |
| `test` | テスト | `test: add unit tests for GitManager` |
| `build` | ビルド関連 | `build: update Xcode project settings` |
| `ci` | CI/CD | `ci: add GitHub Actions workflow` |
| `chore` | その他 | `chore: update .gitignore` |

### コミットメッセージ例

```bash
# ✅ Good
git commit -m "feat: add ability to open repository in Cursor

- Implement URL scheme handling
- Add Cursor detection logic
- Update context menu with new option"

git commit -m "fix: prevent duplicate repositories in list

Fixes #42"

git commit -m "docs: add troubleshooting section to README"

# ❌ Bad
git commit -m "updated stuff"
git commit -m "fix"
git commit -m "WIP"
```

## プルリクエスト

### PRタイトル
コミットメッセージと同じ形式を使用
```
feat: implement diff preview functionality
fix: resolve memory leak in status updates
```

### PRテンプレート

`.github/pull_request_template.md`:
```markdown
## 概要
<!-- このPRで何を実装/修正したか簡潔に説明 -->

## 変更内容
<!-- 主な変更点をリスト形式で -->
- 
- 
- 

## スクリーンショット
<!-- UI変更がある場合は必須 -->

## テスト
<!-- 実施したテストを記載 -->
- [ ] 単体テスト追加/更新
- [ ] 統合テスト実施
- [ ] 手動テスト完了

## チェックリスト
- [ ] コードがプロジェクトのスタイルガイドに従っている
- [ ] セルフレビュー実施済み
- [ ] コメント追加（特に複雑な箇所）
- [ ] ドキュメント更新（必要な場合）
- [ ] 破壊的変更なし（ある場合は説明を追加）
- [ ] 依存関係の更新なし（ある場合は理由を追加）

## 関連Issue
Fixes #(issue number)

## その他
<!-- レビュアーへの注意事項など -->
```

### PRのサイズ
- 理想: 200行以下の変更
- 最大: 500行以下の変更
- 大きな機能は複数のPRに分割

## ワークフロー

### 機能開発フロー

```bash
# 1. mainブランチを最新に
git checkout main
git pull origin main

# 2. 機能ブランチ作成
git checkout -b feature/new-functionality

# 3. 開発・コミット
git add .
git commit -m "feat: implement new functionality"

# 4. リモートにプッシュ
git push origin feature/new-functionality

# 5. GitHub でPR作成

# 6. レビュー・修正

# 7. マージ後、ローカルブランチ削除
git checkout main
git pull origin main
git branch -d feature/new-functionality
```

### バグ修正フロー

```bash
# 1. mainから修正ブランチ作成
git checkout main
git pull origin main
git checkout -b fix/critical-bug

# 2. 修正実施
# ... edit files ...

# 3. テスト追加/更新
# ... add tests ...

# 4. コミット
git add .
git commit -m "fix: resolve critical bug in repository detection

The issue was caused by incorrect path validation.
Added proper error handling and validation.

Fixes #123"

# 5. プッシュ & PR作成
git push origin fix/critical-bug
```

## マージ戦略

### Squash and Merge
- デフォルトで使用
- 機能ブランチの複数コミットを1つにまとめる
- クリーンな履歴を維持

### Merge Commit
- 複数の重要なコミットを保持したい場合
- 大きな機能追加時

### Rebase and Merge
- 使用しない（履歴が複雑になるため）

## 保護ルール（main ブランチ）

### 必須要件
- [ ] PR必須（直接プッシュ禁止）
- [ ] レビュー承認必須（最低1人）
- [ ] CI/CDテスト成功必須
- [ ] ブランチが最新である必要あり

### 推奨設定
- [ ] 承認の却下時に再レビュー必要
- [ ] マージ後の自動ブランチ削除

## リリースフロー

### バージョニング
Semantic Versioning (SemVer) を使用
```
MAJOR.MINOR.PATCH
1.2.3
```

- MAJOR: 破壊的変更
- MINOR: 後方互換性のある機能追加
- PATCH: 後方互換性のあるバグ修正

### リリース手順

```bash
# 1. リリースブランチ作成
git checkout -b release/v1.2.0

# 2. バージョン番号更新
# Update Info.plist, README, etc.

# 3. CHANGELOG更新
# Update CHANGELOG.md

# 4. コミット
git commit -m "chore: prepare release v1.2.0"

# 5. タグ作成
git tag -a v1.2.0 -m "Release version 1.2.0"

# 6. プッシュ
git push origin release/v1.2.0
git push origin v1.2.0

# 7. GitHub Releaseを作成
```

## Git Hooks

### pre-commit
`.git/hooks/pre-commit`:
```bash
#!/bin/bash

# SwiftLint実行
if which swiftlint >/dev/null; then
    swiftlint --quiet
    if [ $? -ne 0 ]; then
        echo "SwiftLint failed. Please fix warnings before committing."
        exit 1
    fi
fi

# テスト実行（オプション）
# xcodebuild test -scheme GitPeek -destination 'platform=macOS' -quiet
```

### commit-msg
`.git/hooks/commit-msg`:
```bash
#!/bin/bash

# コミットメッセージ形式チェック
commit_regex='^(feat|fix|docs|style|refactor|perf|test|build|ci|chore)(\(.+\))?: .{1,50}'

if ! grep -qE "$commit_regex" "$1"; then
    echo "Invalid commit message format!"
    echo "Format: <type>: <subject>"
    echo "Example: feat: add new feature"
    echo ""
    echo "Allowed types:"
    echo "  feat, fix, docs, style, refactor, perf, test, build, ci, chore"
    exit 1
fi
```

## トラブルシューティング

### コンフリクト解決

```bash
# 1. mainを取り込み
git checkout feature/your-branch
git fetch origin
git merge origin/main

# 2. コンフリクト解決
# エディタで該当ファイルを編集

# 3. 解決をマーク
git add <resolved-files>

# 4. マージコミット
git commit

# 5. プッシュ
git push origin feature/your-branch
```

### 間違ったコミットの修正

```bash
# 直前のコミットメッセージ修正
git commit --amend -m "correct: commit message"

# 直前のコミットに変更追加
git add forgotten-file.swift
git commit --amend --no-edit

# プッシュ済みの場合（注意：force push）
git push --force-with-lease origin feature/your-branch
```

## .gitignore

```gitignore
# macOS
.DS_Store
.AppleDouble
.LSOverride

# Xcode
build/
*.pbxuser
!default.pbxuser
*.mode1v3
!default.mode1v3
*.mode2v3
!default.mode2v3
*.perspectivev3
!default.perspectivev3
xcuserdata/
*.xccheckout
*.moved-aside
DerivedData/
*.hmap
*.ipa
*.dSYM.zip
*.dSYM

# Swift Package Manager
.build/
.swiftpm/
Package.resolved

# CocoaPods (if used)
Pods/

# Carthage (if used)
Carthage/Build/

# fastlane
fastlane/report.xml
fastlane/Preview.html
fastlane/screenshots/**/*.png
fastlane/test_output

# Code coverage
*.xcresult
*.coverage

# IDE
.idea/
*.swp
*.swo
*~

# Project specific
GitPeek.app
*.dmg
```