# Phase 2-1: Repository管理 (TDD)

## Repositoryモデル

### テストファースト
```swift
func testRepositoryCreation() {
    let repo = Repository(path: "/path/to/repo")
    XCTAssertNotNil(repo.id)
    XCTAssertEqual(repo.name, "repo")
}

func testRepositoryValidation() throws {
    XCTAssertThrowsError(try Repository(path: "/invalid"))
}
```

### 実装
```swift
struct Repository: Identifiable, Codable {
    let id = UUID()
    let path: String
    let name: String
    
    init(path: String) throws {
        guard GitCommand.isValidRepository(path) else {
            throw RepositoryError.invalidPath
        }
        self.path = path
        self.name = URL(fileURLWithPath: path).lastPathComponent
    }
}
```

## RepositoryStore (TDD)

### テスト
```swift
func testAddRepository() async throws {
    let store = RepositoryStore()
    try await store.add("/valid/repo")
    XCTAssertEqual(store.repositories.count, 1)
}
```

### 永続化
- UserDefaults（パスのみ）
- JSON（詳細データ）

## Sub-agents
- Test Planner: エッジケース設計
- Test Executor: 統合テスト実施