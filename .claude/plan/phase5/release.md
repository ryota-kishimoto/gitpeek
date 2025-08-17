# Phase 5: リリース

## 最終QA

### チェックリスト
```bash
make ci           # 全テスト実行
make check        # Lint/Format確認
make test-coverage # カバレッジ確認
```

### Sub-agents QAプロセス
1. Test Planner: 最終テスト計画
2. Test Executor: 独立検証
3. Security Auditor: セキュリティ監査

## 配布準備

### ビルド
```bash
make build-release  # リリースビルド
make archive        # アーカイブ
make dmg           # DMG作成
```

### 署名とNotarization
```bash
codesign --deep --force --verify --verbose \
  --sign "Developer ID" GitPeek.app
  
xcrun notarytool submit GitPeek.dmg \
  --apple-id "email" --team-id "TEAM"
```

## GitHub Release
- セマンティックバージョニング
- CHANGELOG更新
- Release Notes作成

## 配布チャネル
1. GitHub Releases（即時）
2. Homebrew Cask（PR作成）
3. Mac App Store（将来）