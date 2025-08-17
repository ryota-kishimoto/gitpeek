# Phase 3: 統合機能

## 外部アプリ連携 (TDD)

### Cursor
```swift
func testOpenInCursor() {
    let launcher = AppLauncher()
    XCTAssertNoThrow(try launcher.openInCursor(path: "/test"))
}

// 実装
func openInCursor(path: String) {
    let url = URL(string: "cursor://open?path=\(path.escaped)")!
    NSWorkspace.shared.open(url)
}
```

### GitHub URL変換
```swift
func testSSHToHTTPS() {
    let url = GitHubURL.convert("git@github.com:user/repo.git")
    XCTAssertEqual(url, "https://github.com/user/repo")
}
```

## 実装優先順位
1. Cursor連携（最重要）
2. GitHub URL開く
3. Terminal開く
4. SourceTree（オプション）

## エラーハンドリング
- アプリ未インストール → 適切なメッセージ
- URL変換失敗 → フォールバック

## テスト戦略
- モックNSWorkspace使用
- URL生成の単体テスト
- 統合テスト（実際のアプリ起動）