# Phase 2-2: Git Status監視 (TDD)

## GitStatus実装

### TDDサイクル
```swift
// RED
func testParseGitStatus() {
    let output = "M  file.txt\n?? new.txt"
    let status = GitStatus.parse(output)
    XCTAssertEqual(status.modified.count, 1)
    XCTAssertEqual(status.untracked.count, 1)
}

// GREEN -> REFACTOR
struct GitStatus {
    let branch: String
    let modified: [String]
    let untracked: [String]
    
    var hasChanges: Bool {
        !modified.isEmpty || !untracked.isEmpty
    }
}
```

## リアルタイム監視

### Timer実装（TDD）
```swift
func testAutoRefresh() async {
    let manager = GitManager()
    manager.startMonitoring(interval: 1)
    
    await Task.sleep(2_000_000_000) // 2秒
    XCTAssertGreaterThan(manager.refreshCount, 0)
}
```

### 並列処理
```swift
func updateAll() async {
    await withTaskGroup(of: Void.self) { group in
        for repo in repositories {
            group.addTask { await self.update(repo) }
        }
    }
}
```

## パフォーマンス目標
- 更新時間 < 500ms/repo
- CPU使用率 < 5%