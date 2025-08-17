# GitPeek Development Guide for Claude Code

## プロジェクト概要
GitPeekは、macOSのメニューバーから複数のGitリポジトリを管理するネイティブアプリケーションです。

## 技術スタック
- **言語**: Swift 5.9+
- **UI Framework**: SwiftUI
- **最小対応OS**: macOS 13.0 (Ventura)
- **アーキテクチャ**: MVVM
- **依存管理**: Swift Package Manager

## プロジェクト構造
```
GitPeek/
├── App/                 # アプリケーションエントリポイント
├── Views/              # SwiftUIビュー
├── ViewModels/         # ビジネスロジック
├── Models/             # データモデル
├── Utils/              # ユーティリティ
└── Resources/          # リソースファイル
```

## 開発ルール

### TDD（テスト駆動開発）
- **必須**: Red-Green-Refactorサイクルの徹底
- Kent Beck/t-wadaの原則に従う
- テストファーストで実装
- 詳細は `.claude/TDD_GUIDELINES.md` 参照

### Sub-Agents活用
- テスト計画と実施は別のagentが担当
- コードレビューは独立したagentが実施
- 詳細は `.claude/sub-agents.yml` 参照

### コーディング規約
- Apple's API Design Guidelines準拠
- SwiftLint/SwiftFormat設定済み（強力な設定）
- 関数は単一責任原則に従う
- エラーハンドリングは明示的に行う
- Force unwrapは絶対に避ける
- `@MainActor`を適切に使用

### 命名規則
- クラス/構造体: PascalCase
- 変数/関数: camelCase
- 定数: camelCase
- ファイル名: PascalCase

### Git運用

#### コミット戦略
- **頻繁にコミット**: 小さな変更ごとにコミット（差分を明確に）
- **プッシュ禁止**: ユーザーの許可を得るまでプッシュしない
- **ローカル履歴重視**: こまめなコミットで作業履歴を残す

#### TDDコミットパターン
```bash
# Red Phase
git commit -m "test: add failing test for [feature]"

# Green Phase  
git commit -m "feat: implement [feature] to pass test"

# Refactor Phase
git commit -m "refactor: improve [feature] implementation"
```

#### コミットメッセージ
- feat: 新機能
- fix: バグ修正
- test: テスト追加・修正
- refactor: リファクタリング
- docs: ドキュメント
- style: コードスタイル
- chore: その他

### テスト方針
- 新機能には必ずテストを書く
- テストカバレッジ目標: 80%以上
- XCTestを使用
- モックは最小限に

## Serena MCP サーバーセットアップ

### インストール
```bash
# npmが必要（Node.js 18以上推奨）
npm install -g @mcp-servers/serena
```

### 設定
Claude Codeの設定ファイル (`~/Library/Application Support/Claude/claude_desktop_config.json`) に以下を追加:

```json
{
  "mcpServers": {
    "serena": {
      "command": "npx",
      "args": ["-y", "@mcp-servers/serena"],
      "env": {}
    }
  }
}
```

### プロジェクト設定
GitPeekはSwiftプロジェクトのため、`.serena/project.yml`を手動で作成:

```yaml
project_name: gitpeek
language: swift
description: macOS menu bar Git repository manager
```

### 使用方法
Claude Codeで以下のコマンドを使用:
- プロジェクトアクティベート: Serenaツールを使用
- メモリ管理: プロジェクト情報を永続化
- ファイル検索: 高度な検索機能を利用

注: SerenaはSwiftを公式サポートしていないため、一部機能に制限があります

## ビルド・実行

### 開発環境セットアップ
```bash
# リポジトリクローン
git clone https://github.com/yourusername/gitpeek.git
cd gitpeek

# Xcodeで開く
open GitPeek.xcodeproj
```

### ビルドコマンド
```bash
# Debug ビルド
xcodebuild -scheme GitPeek -configuration Debug build

# Release ビルド
xcodebuild -scheme GitPeek -configuration Release build

# テスト実行
xcodebuild test -scheme GitPeek -destination 'platform=macOS'
```

### コード品質ツール

#### SwiftLint（強力な設定済み）
```bash
# インストール
brew install swiftlint

# 実行
swiftlint

# 自動修正
swiftlint --fix

# レポート生成
swiftlint --reporter html > swiftlint.html
```

#### SwiftFormat
```bash
# インストール
brew install swiftformat

# 実行
swiftformat .

# ドライラン（変更確認のみ）
swiftformat --lint .

# 特定ファイルのみ
swiftformat GitPeek/
```

#### 統合実行
```bash
# Makefile使用
make lint    # SwiftLint実行
make format  # SwiftFormat実行
make check   # 両方実行
```

## 主要コンポーネント

### GitCommand
Git操作を抽象化したユーティリティクラス
- 非同期実行サポート
- エラーハンドリング
- タイムアウト処理

### RepositoryStore
リポジトリ情報の管理
- 永続化
- CRUD操作
- 状態管理

### MenuBarController
メニューバーUIの制御
- NSStatusItem管理
- ポップオーバー制御
- アイコン更新

## 外部連携

### Cursor
```swift
URL(string: "cursor://open?path=\(encodedPath)")
```

### SourceTree
```swift
NSWorkspace.shared.open(path, withApplicationAt: sourceTreeURL)
```

### GitHub URL
```swift
// SSH → HTTPS変換
git@github.com:user/repo.git → https://github.com/user/repo
```

## トラブルシューティング

### よくある問題
1. **Git操作が失敗する**
   - Gitがインストールされているか確認
   - パスが正しいか確認
   - 権限があるか確認

2. **外部アプリが開かない**
   - アプリがインストールされているか確認
   - URL schemeが正しいか確認

3. **パフォーマンス問題**
   - リポジトリ数を確認
   - キャッシュをクリア
   - 更新間隔を調整

## デバッグ

### ログ出力
```swift
#if DEBUG
print("[GitPeek] \(message)")
#endif
```

### メモリリーク検出
Instrumentsを使用してメモリリークを検出

### パフォーマンス測定
```swift
let startTime = CFAbsoluteTimeGetCurrent()
// 処理
let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
print("Time elapsed: \(timeElapsed) s")
```

## リリース準備

### チェックリスト
- [ ] SwiftLint警告解消
- [ ] テスト全て成功
- [ ] バージョン番号更新
- [ ] CHANGELOG更新
- [ ] README更新

### ビルド手順
1. Xcodeでアーカイブ作成
2. Developer ID証明書で署名
3. Notarization実行
4. DMG作成
5. GitHub Releaseアップロード

## 今後の拡張予定
- プルリクエスト状態表示
- 簡易コミット機能
- ブランチ検索
- カスタムアクション
- チーム設定共有