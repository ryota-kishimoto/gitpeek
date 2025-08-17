# Phase 1-1: プロジェクトセットアップ

## タスク

### 1. Xcodeプロジェクト作成
```bash
- macOSアプリ (SwiftUI)
- Bundle ID: com.gitpeek.app
- Deployment: macOS 13.0+
```

### 2. TDDディレクトリ構造
```
GitPeek/
├── App/           # Entry point
├── Models/        # Data models
├── ViewModels/    # Business logic (TDD)
├── Views/         # SwiftUI views
└── Utils/         # Git commands (TDD)

GitPeekTests/
├── Unit/          # 単体テスト
├── Integration/   # 統合テスト
└── Mocks/         # テスト用モック
```

### 3. 開発環境
```bash
make setup          # SwiftLint/SwiftFormat
make install-hooks  # Git hooks (TDD強制)
```

## 完了条件
- [ ] テスト環境動作確認
- [ ] `make test` 成功
- [ ] Git hooks有効化