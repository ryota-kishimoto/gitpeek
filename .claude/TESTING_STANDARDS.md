# GitPeek テスト規約

## テスト方針

### 基本原則
- テストファーストで開発
- カバレッジ目標: 80%以上
- 全ての公開APIをテスト
- エッジケースを網羅

### テストピラミッド
```
         /\
        /UI\        (10%) - UIテスト
       /----\       
      /Integr\      (20%) - 統合テスト
     /--------\     
    /   Unit   \    (70%) - 単体テスト
   /____________\   
```

## テスト構造

### ディレクトリ構成
```
GitPeekTests/
├── Unit/
│   ├── Models/
│   ├── ViewModels/
│   └── Utils/
├── Integration/
│   ├── GitOperations/
│   └── ExternalApps/
├── UI/
│   └── Views/
├── Mocks/
│   ├── MockGitManager.swift
│   └── MockRepositoryStore.swift
└── Helpers/
    ├── TestData.swift
    └── XCTestCase+Extensions.swift
```

### テストファイル命名
```swift
// 対象: Repository.swift
// テスト: RepositoryTests.swift

// 対象: GitManager.swift  
// テスト: GitManagerTests.swift
```

## 単体テスト

### テスト構造 (AAA Pattern)
```swift
func testAddRepository_whenValidPath_addsSuccessfully() throws {
    // Arrange
    let manager = RepositoryManager()
    let validPath = "/Users/test/valid-repo"
    
    // Act
    try manager.addRepository(at: validPath)
    
    // Assert
    XCTAssertEqual(manager.repositories.count, 1)
    XCTAssertEqual(manager.repositories.first?.path, validPath)
}
```

### テストメソッド命名
```swift
// Pattern: test<MethodName>_when<Condition>_<ExpectedResult>

// ✅ Good
func testFetchStatus_whenRepositoryExists_returnsValidStatus()
func testAddRepository_whenPathIsInvalid_throwsError()
func testUpdateBranch_whenDetachedHead_showsHashInstead()

// ❌ Bad
func testFetch()
func testError()
func test1()
```

### 非同期テスト
```swift
func testFetchGitStatus_whenRemoteExists_includesRemoteInfo() async throws {
    // Arrange
    let gitManager = GitManager()
    let repository = TestData.createRepository()
    
    // Act
    let status = try await gitManager.fetchStatus(for: repository)
    
    // Assert
    XCTAssertNotNil(status.remoteURL)
    XCTAssertTrue(status.hasRemote)
}
```

### エラーテスト
```swift
func testExecuteCommand_whenCommandFails_throwsAppropriateError() {
    // Arrange
    let gitCommand = GitCommand()
    let invalidCommand = "git invalid-command"
    
    // Act & Assert
    XCTAssertThrowsError(try gitCommand.execute(invalidCommand)) { error in
        XCTAssertEqual(error as? GitError, GitError.commandFailed)
    }
}
```

## モック

### モック作成ガイドライン
```swift
// Protocol definition
protocol GitManagerProtocol {
    func fetchStatus(for repository: Repository) async throws -> GitStatus
    func refresh() async
}

// Mock implementation
class MockGitManager: GitManagerProtocol {
    var fetchStatusCallCount = 0
    var fetchStatusResult: Result<GitStatus, Error> = .success(TestData.defaultStatus)
    
    func fetchStatus(for repository: Repository) async throws -> GitStatus {
        fetchStatusCallCount += 1
        
        switch fetchStatusResult {
        case .success(let status):
            return status
        case .failure(let error):
            throw error
        }
    }
    
    func refresh() async {
        // No-op for testing
    }
}
```

### 依存性注入
```swift
class RepositoryViewModel {
    private let gitManager: GitManagerProtocol
    
    // Dependency injection through initializer
    init(gitManager: GitManagerProtocol = GitManager.shared) {
        self.gitManager = gitManager
    }
}

// In tests
func testViewModel() {
    let mockGitManager = MockGitManager()
    let viewModel = RepositoryViewModel(gitManager: mockGitManager)
    // Test with mock
}
```

## 統合テスト

### Git操作テスト
```swift
class GitIntegrationTests: XCTestCase {
    var testRepoPath: String!
    
    override func setUpWithError() throws {
        // Create temporary test repository
        testRepoPath = NSTemporaryDirectory() + UUID().uuidString
        try FileManager.default.createDirectory(atPath: testRepoPath, withIntermediateDirectories: true)
        
        // Initialize git repo
        try GitCommand.execute("git init", at: testRepoPath)
        try GitCommand.execute("git config user.email 'test@gitpeek.app'", at: testRepoPath)
        try GitCommand.execute("git config user.name 'Test User'", at: testRepoPath)
    }
    
    override func tearDownWithError() throws {
        // Clean up
        try? FileManager.default.removeItem(atPath: testRepoPath)
    }
    
    func testGitWorkflow() async throws {
        // Create file
        let filePath = testRepoPath + "/test.txt"
        try "test content".write(toFile: filePath, atomically: true, encoding: .utf8)
        
        // Add and commit
        try GitCommand.execute("git add .", at: testRepoPath)
        try GitCommand.execute("git commit -m 'Initial commit'", at: testRepoPath)
        
        // Verify
        let status = try await GitManager().fetchStatus(at: testRepoPath)
        XCTAssertFalse(status.hasChanges)
    }
}
```

## UIテスト

### UIテスト構造
```swift
class GitPeekUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
    }
    
    func testAddRepository_throughUI_appearsInList() {
        // Open add repository dialog
        app.statusItems.firstMatch.click()
        app.buttons["Add Repository"].click()
        
        // Select directory
        let dialog = app.dialogs.firstMatch
        XCTAssertTrue(dialog.waitForExistence(timeout: 5))
        
        // Verify repository appears
        XCTAssertTrue(app.staticTexts["test-repo"].exists)
    }
}
```

### Page Object Pattern
```swift
class MenuBarPage {
    private let app: XCUIApplication
    
    init(app: XCUIApplication) {
        self.app = app
    }
    
    var statusItem: XCUIElement {
        app.statusItems.firstMatch
    }
    
    var addRepositoryButton: XCUIElement {
        app.buttons["Add Repository"]
    }
    
    func openMenu() {
        statusItem.click()
    }
    
    func addRepository() {
        openMenu()
        addRepositoryButton.click()
    }
}

// Usage in test
func testAddRepositoryFlow() {
    let menuBar = MenuBarPage(app: app)
    menuBar.addRepository()
    // Continue test...
}
```

## パフォーマンステスト

```swift
func testLargeRepositoryList_performance() {
    let manager = RepositoryManager()
    
    // Add 100 repositories
    for i in 0..<100 {
        try? manager.addRepository(TestData.createRepository(index: i))
    }
    
    measure {
        // Measure refresh performance
        manager.refreshAll()
    }
}

func testGitStatusParsing_performance() {
    let gitOutput = TestData.largeGitStatusOutput // 1000+ files
    
    measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
        _ = GitStatusParser.parse(gitOutput)
    }
}
```

## テストデータ

### TestData Helper
```swift
enum TestData {
    static func createRepository(
        name: String = "test-repo",
        branch: String = "main",
        hasChanges: Bool = false
    ) -> Repository {
        Repository(
            id: UUID(),
            name: name,
            path: "/test/\(name)",
            branch: branch,
            status: hasChanges ? .modified : .clean
        )
    }
    
    static var defaultGitStatus: GitStatus {
        GitStatus(
            branch: "main",
            ahead: 0,
            behind: 0,
            staged: [],
            unstaged: [],
            untracked: []
        )
    }
    
    static func gitStatusWithChanges(
        staged: Int = 0,
        unstaged: Int = 0,
        untracked: Int = 0
    ) -> GitStatus {
        var status = defaultGitStatus
        
        for i in 0..<staged {
            status.staged.append(FileChange(path: "staged\(i).txt", status: .modified))
        }
        
        for i in 0..<unstaged {
            status.unstaged.append(FileChange(path: "unstaged\(i).txt", status: .modified))
        }
        
        for i in 0..<untracked {
            status.untracked.append("untracked\(i).txt")
        }
        
        return status
    }
}
```

## カバレッジ

### 目標
- 全体: 80%以上
- Models: 90%以上
- ViewModels: 85%以上
- Utils: 95%以上
- Views: 60%以上

### カバレッジ測定
```bash
# Xcodeでカバレッジを有効化
xcodebuild test \
  -scheme GitPeek \
  -enableCodeCoverage YES \
  -resultBundlePath TestResults

# カバレッジレポート生成
xcrun xccov view --report TestResults.xcresult
```

## CI/CD

### GitHub Actions設定
```yaml
name: Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: macos-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Select Xcode
      run: sudo xcode-select -s /Applications/Xcode.app
    
    - name: Run Unit Tests
      run: |
        xcodebuild test \
          -scheme GitPeek \
          -destination 'platform=macOS' \
          -only-testing:GitPeekTests/Unit \
          -enableCodeCoverage YES
    
    - name: Run Integration Tests
      run: |
        xcodebuild test \
          -scheme GitPeek \
          -destination 'platform=macOS' \
          -only-testing:GitPeekTests/Integration
    
    - name: Generate Coverage Report
      run: |
        xcrun xccov view --report --json TestResults.xcresult > coverage.json
    
    - name: Upload Coverage
      uses: codecov/codecov-action@v3
      with:
        file: ./coverage.json
        fail_ci_if_error: true
```

## テストのベストプラクティス

### DO
- ✅ 各テストは独立して実行可能に
- ✅ テスト名は明確で説明的に
- ✅ 1つのテストで1つの事柄をテスト
- ✅ エッジケースをテスト
- ✅ テストの実行時間を短く保つ

### DON'T
- ❌ 実際のネットワーク呼び出しをテスト内で行う
- ❌ テスト間で状態を共有する
- ❌ ランダムな値に依存する
- ❌ UIテストで詳細なロジックをテスト
- ❌ プライベートメソッドを直接テスト

## デバッグ

### テスト失敗時の調査
```swift
func testDebugExample() throws {
    let result = calculateSomething()
    
    // Add context to assertions
    XCTAssertEqual(result, expected, 
                  "Result was \(result), expected \(expected). Input: \(input)")
    
    // Use XCTUnwrap for better error messages
    let unwrapped = try XCTUnwrap(optionalValue, 
                                  "Optional value should not be nil")
    
    // Add breakpoints conditionally
    if result != expected {
        // Set breakpoint here
        print("Debug info: \(debugDescription)")
    }
}
```