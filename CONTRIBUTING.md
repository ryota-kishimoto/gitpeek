# Contributing to GitPeek

GitPeekへの貢献ありがとうございます！

## 開発環境のセットアップ

```bash
git clone https://github.com/ryota-kishimoto/gitpeek.git
cd gitpeek
open Package.swift
```

## Pull Requestのプロセス

1. Issueを作成または既存のIssueを選択
2. フォークしてfeatureブランチを作成 (`git checkout -b feature/amazing-feature`)
3. 変更をコミット (`git commit -m 'feat: add amazing feature'`)
4. ブランチにプッシュ (`git push origin feature/amazing-feature`)
5. Pull Requestを開く

## コミットメッセージ

- `feat:` 新機能
- `fix:` バグ修正
- `docs:` ドキュメント
- `style:` コードスタイル
- `refactor:` リファクタリング
- `test:` テスト
- `chore:` その他

## コードスタイル

- SwiftLintの設定に従う
- `swiftlint` を実行してエラーがないことを確認

## テスト

新機能には必ずテストを追加してください。

```bash
swift test
```

## 質問・サポート

- [Issues](https://github.com/ryota-kishimoto/gitpeek/issues)
- [Discussions](https://github.com/ryota-kishimoto/gitpeek/discussions)