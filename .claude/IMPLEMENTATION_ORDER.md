# GitPeek 実装順序（TDD優先）

## 🎯 開発方針
**全ての実装はTDD（Red→Green→Refactor）で進める**

## 📝 実装順序

### Step 1: プロジェクト基盤
```bash
# 1. Xcodeプロジェクト作成
# 2. ディレクトリ構造セットアップ
make setup
make install-hooks

# 3. 最初のテスト作成（必ず失敗させる）
# GitPeekTests/Unit/GitCommandTests.swift
```

### Step 2: GitCommand（TDD必須）
```swift
// 実装順序（各ステップでRed→Green→Refactor）
1. getCurrentBranch()    // ブランチ名取得
2. getStatus()           // ステータス取得  
3. isValidRepository()   // リポジトリ検証
4. getRemoteURL()        // リモートURL取得
```

### Step 3: Repository Model（TDD）
```swift
1. Repository構造体      // ID, path, name
2. RepositoryStore       // CRUD操作
3. 永続化                // UserDefaults
```

### Step 4: MenuBar MVP
```swift
1. MenuBarViewModel      // @Published properties
2. MenuBarView          // 最小UI
3. AppDelegate          // NSStatusItem
```

### Step 5: Git監視機能
```swift
1. GitManager           // 状態取得
2. Timer実装            // 30秒更新
3. 並列処理             // TaskGroup
```

### Step 6: 外部連携
```swift
1. Cursor連携           // URL scheme
2. GitHub URL           // SSH→HTTPS変換
3. Terminal            // AppleScript
```

### Step 7: UI改善
```swift
1. 設定画面             // @AppStorage
2. ダークモード         // 自動対応
3. アニメーション        // SwiftUI
```

### Step 8: 最終調整
```bash
make test-coverage      # カバレッジ確認
make check             # Lint/Format
make build-release     # リリースビルド
```

## 🤖 Sub-Agents活用タイミング

### 各ステップで使用
- **開始時**: `test-planner` → テストケース設計
- **実装時**: `tdd-facilitator` → TDDガイド
- **完了時**: `code-reviewer` → 品質チェック

### 統合時に使用
- `test-executor` → 統合テスト
- `performance-optimizer` → 最適化
- `security-auditor` → セキュリティ確認

## ⏱️ 時間配分目安

| フェーズ | 時間 | 重点 |
|---------|------|------|
| Step 1-2 | 2日 | TDD基盤確立 |
| Step 3-4 | 2日 | コア機能 |
| Step 5-6 | 2日 | 監視と連携 |
| Step 7-8 | 1日 | 品質向上 |

## ✅ 品質ゲート

各ステップ完了時に確認:
- [ ] テストカバレッジ > 80%
- [ ] SwiftLint警告 0
- [ ] 全テスト成功
- [ ] Sub-agentレビュー完了

## 📝 コミット規則

### 必須ルール
- ✅ **小さな変更ごとにコミット**（差分を明確に）
- ✅ **TDDの各フェーズでコミット**（Red/Green/Refactor）
- ⛔ **プッシュは許可を得てから**（勝手にプッシュしない）

### コミットタイミング
```bash
# ファイル作成時
git add . && git commit -m "chore: add [filename]"

# テスト追加時（Red）
git add . && git commit -m "test: add failing test for [feature]"

# 実装時（Green）
git add . && git commit -m "feat: implement [feature]"

# リファクタリング時
git add . && git commit -m "refactor: improve [feature]"

# 設定変更時
git add . && git commit -m "chore: update [config]"
```

## 🚫 アンチパターン

避けるべきこと:
- ❌ 大きな変更を1つのコミットにまとめる
- ❌ コミットメッセージが不明確
- ❌ 許可なくプッシュする
- ❌ テストなしで実装を進める
- ❌ Force unwrapの使用

## 📊 進捗管理

```bash
# 毎日の開始時
make test        # 全テスト確認
make todo        # TODOリスト確認

# コミット前
make pre-commit  # 自動チェック

# 週次
make stats       # コード統計
make test-coverage # カバレッジ確認
```