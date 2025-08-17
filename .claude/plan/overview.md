# GitPeek 開発計画

## 概要
macOSメニューバーから複数Gitリポジトリを管理するネイティブアプリケーション

## 開発原則
- **TDD必須**: Red-Green-Refactorサイクル厳守
- **Sub-agents活用**: 独立した視点での品質保証
- **Apple Guidelines準拠**: API Design Guidelines遵守

## フェーズ

### Phase 1: TDD基盤
- Xcodeプロジェクト + テスト環境構築
- GitCommandクラス（TDDで実装）
- メニューバー最小実装

### Phase 2: コア機能（TDD）
- Repository管理
- GitStatus監視
- 差分表示

### Phase 3: 統合
- 外部アプリ連携（Cursor/SourceTree/Terminal）
- GitHub/GitLab対応

### Phase 4: 品質
- UI/UX最適化
- パフォーマンスチューニング
- 設定機能

### Phase 5: リリース
- 最終QA
- 配布準備

## 技術スタック
- Swift 5.9+ / SwiftUI
- macOS 13.0+
- MVVM + TDD

## 品質基準
- テストカバレッジ > 80%
- 起動時間 < 1秒
- メモリ < 50MB