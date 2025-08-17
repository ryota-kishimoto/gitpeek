# Phase 1-2: Git操作実装 (TDD)

## TDDサイクル

### 1. RED: テストファースト
```swift
// GitCommandTests.swift
func testGetCurrentBranch() async throws {
    let branch = try await GitCommand.getCurrentBranch(at: testRepo)
    XCTAssertEqual(branch, "main")
}

func testGetStatus() async throws {
    let status = try await GitCommand.getStatus(at: testRepo)
    XCTAssertFalse(status.hasChanges)
}
```

### 2. GREEN: 最小実装
```swift
// GitCommand.swift
class GitCommand {
    static func getCurrentBranch(at path: String) async throws -> String {
        return "main" // 仮実装
    }
}
```

### 3. REFACTOR: 本実装
```swift
class GitCommand {
    static func execute(_ command: String, at path: String) async throws -> String {
        // Process実行
    }
}
```

## 実装順序（TDD）
1. `getCurrentBranch` - ブランチ名取得
2. `getStatus` - ステータス取得
3. `getDiff` - 差分取得
4. `getRemoteURL` - リモートURL取得

## Sub-agent活用
```bash
# Test Planner: テストケース設計
# TDD Facilitator: 実装ガイド
# Code Reviewer: 品質チェック
```