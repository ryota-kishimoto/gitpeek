# GitPeek TDD ガイドライン

## TDD原則（Kent Beck / t-wada基準）

### 基本哲学
> "テストがないコードは、レガシーコードである" - Michael Feathers
> "テストがドキュメントである" - t-wada

### TDDの黄金の三原則（Uncle Bob）
1. **失敗するテストを書くまで、プロダクションコードを書いてはならない**
2. **失敗させるのに十分なテストだけを書く**（コンパイルが通らないのも失敗）
3. **現在失敗しているテストを通すのに十分なプロダクションコードだけを書く**

## Red-Green-Refactorサイクル

### 1. Red Phase（失敗するテストを書く）
```swift
// ❌ まず失敗するテストを書く
func testGetCurrentBranch_returnsCorrectBranchName() throws {
    // Arrange
    let gitCommand = GitCommand()
    
    // Act
    let branch = try gitCommand.getCurrentBranch(at: testRepoPath)
    
    // Assert
    XCTAssertEqual(branch, "main")
}
```

### 2. Green Phase（テストを通す最小限の実装）
```swift
// ✅ 最小限の実装（仮実装でもOK）
class GitCommand {
    func getCurrentBranch(at path: String) throws -> String {
        return "main" // 仮実装
    }
}
```

### 3. Refactor Phase（リファクタリング）
```swift
// ♻️ テストが通った状態でリファクタリング
class GitCommand {
    func getCurrentBranch(at path: String) throws -> String {
        let output = try executeGitCommand("branch --show-current", at: path)
        return output.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
```

## TDD戦術

### 1. 仮実装（Fake It）
最初は定数を返すだけの仮実装から始める
```swift
// Step 1: 仮実装
func add(_ a: Int, _ b: Int) -> Int {
    return 3 // 仮実装
}

// Step 2: 三角測量のため別のテストケース追加
// Step 3: 一般化
func add(_ a: Int, _ b: Int) -> Int {
    return a + b // 一般化
}
```

### 2. 三角測量（Triangulation）
複数のテストケースから一般化を導く
```swift
// Test 1
XCTAssertEqual(converter.convert(1), "I")

// Test 2 - 三角測量
XCTAssertEqual(converter.convert(2), "II")

// Test 3 - パターンが見える
XCTAssertEqual(converter.convert(3), "III")

// 実装を一般化
```

### 3. 明白な実装（Obvious Implementation）
明らかに簡単な場合は直接実装
```swift
// 明白な場合は直接実装してOK
var isEmpty: Bool {
    return items.count == 0
}
```

## Swift特有のTDDパターン

### プロトコル駆動TDD
```swift
// 1. プロトコルを定義
protocol GitManagerProtocol {
    func fetchStatus(for repository: Repository) async throws -> GitStatus
}

// 2. テストでモックを使用
class MockGitManager: GitManagerProtocol {
    var shouldSucceed = true
    var mockStatus = GitStatus.mock()
    
    func fetchStatus(for repository: Repository) async throws -> GitStatus {
        if shouldSucceed {
            return mockStatus
        } else {
            throw GitError.commandFailed
        }
    }
}

// 3. テストを書く
func testRepositoryViewModel_whenFetchSucceeds_updatesStatus() async {
    // Arrange
    let mockManager = MockGitManager()
    let viewModel = RepositoryViewModel(gitManager: mockManager)
    
    // Act
    await viewModel.refresh()
    
    // Assert
    XCTAssertEqual(viewModel.status, mockManager.mockStatus)
}
```

### async/await TDD
```swift
// 非同期処理のテスト
func testAsyncGitOperation() async throws {
    // Given
    let expectation = XCTestExpectation(description: "Git operation completes")
    
    // When
    let result = try await gitManager.performOperation()
    
    // Then
    XCTAssertNotNil(result)
    expectation.fulfill()
}
```

### SwiftUI View TDD
```swift
// ViewModelのテスト
class MenuBarViewModelTests: XCTestCase {
    @MainActor
    func testToggleMenu_changesIsShowingState() {
        // Arrange
        let viewModel = MenuBarViewModel()
        let initialState = viewModel.isShowing
        
        // Act
        viewModel.toggleMenu()
        
        // Assert
        XCTAssertEqual(viewModel.isShowing, !initialState)
    }
}
```

## TDDのリズム

### マイクロサイクル（分単位）
1. **テストを書く**（1-2分）
2. **実装する**（1-2分）
3. **リファクタリング**（1-2分）

### 開発フロー
```
🔴 Red → 🟢 Green → ♻️ Refactor → 🔴 Red → 🟢 Green → ♻️ Refactor...
```

### コミットタイミング
- Green後にコミット（テストが通った状態）
- Refactor後にコミット（きれいな状態）
- **Red状態ではコミットしない**

## テストの構造（AAA Pattern）

### Arrange-Act-Assert
```swift
func testRepositoryAddition() throws {
    // Arrange（準備）
    let manager = RepositoryManager()
    let repoPath = "/valid/git/repo"
    
    // Act（実行）
    try manager.addRepository(at: repoPath)
    
    // Assert（検証）
    XCTAssertEqual(manager.repositories.count, 1)
    XCTAssertEqual(manager.repositories.first?.path, repoPath)
}
```

### Given-When-Then (BDD style)
```swift
func testGitStatus_whenChangesExist_showsModifiedState() async throws {
    // Given
    let repository = createRepositoryWithChanges()
    
    // When
    let status = try await gitManager.fetchStatus(for: repository)
    
    // Then
    XCTAssertTrue(status.hasChanges)
    XCTAssertEqual(status.state, .modified)
}
```

## テストの品質指標

### F.I.R.S.T原則
- **Fast**: 高速に実行できる
- **Independent**: 独立している
- **Repeatable**: 再現可能
- **Self-validating**: 自己検証可能
- **Timely**: タイムリー（コードより先に書く）

### テストの粒度
```swift
// ✅ Good - 1つのテストで1つの振る舞い
func testBranchName_isCorrect() { }
func testChangeCount_isAccurate() { }

// ❌ Bad - 複数の振る舞いを1つでテスト
func testGitStatusEverything() { }
```

## TDDアンチパターン

### 避けるべきこと
1. **テストを後から書く**（Test-After）
2. **テストなしでリファクタリング**
3. **失敗を確認しないテスト**
4. **実装の詳細をテストする**
5. **モックの使いすぎ**

### コードカバレッジの罠
- カバレッジ100%が目的ではない
- 意味のあるテストを書く
- ミューテーションテストで品質確認

## 実践的なTDDワークフロー

### 新機能開発
```bash
# 1. ブランチ作成
git checkout -b feature/new-feature

# 2. 失敗するテスト作成
# GitPeekTests/NewFeatureTests.swift を作成

# 3. Red確認
xcodebuild test # 失敗を確認

# 4. 最小限の実装
# GitPeek/NewFeature.swift を実装

# 5. Green確認
xcodebuild test # 成功を確認

# 6. コミット
git add .
git commit -m "test: add test for new feature"
git commit -m "feat: implement new feature"

# 7. リファクタリング
# コードを整理

# 8. テスト再実行
xcodebuild test

# 9. コミット
git commit -m "refactor: improve new feature implementation"
```

### バグ修正
```swift
// 1. バグを再現するテストを書く（Red）
func testBugScenario_reproducesIssue() throws {
    // This test should fail, demonstrating the bug
    XCTAssertEqual(buggyFunction(), expectedResult)
}

// 2. バグを修正（Green）
// 3. 他のテストも全て通ることを確認
// 4. リファクタリング可能なら実施
```

## 継続的TDD

### CI/CDでのTDD
```yaml
# .github/workflows/tdd.yml
name: TDD Workflow
on: [push, pull_request]

jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run tests
        run: |
          xcodebuild test -scheme GitPeek
      - name: Check coverage
        run: |
          xcrun xccov view --report TestResults.xcresult
```

### プリコミットフック
```bash
#!/bin/bash
# .git/hooks/pre-commit

# テストを実行
if ! xcodebuild test -scheme GitPeek -quiet; then
    echo "Tests failed. Please fix before committing."
    exit 1
fi
```

## 参考資料

### 必読書
- 「テスト駆動開発」Kent Beck
- 「実践テスト駆動開発」Steve Freeman, Nat Pryce
- 「テスト駆動開発入門」t-wada訳

### TDDの心得（t-wada）
1. **テストは品質を上げない、品質を測るだけ**
2. **TDDは設計手法**
3. **動作するきれいなコード**が目標

### Kent Beckの格言
> "Make it work, make it right, make it fast"
> 1. 動かす
> 2. 正しくする
> 3. 速くする

## まとめ

TDDは単なるテスト手法ではなく、**設計手法**であり**開発手法**です。

### TDDで得られるもの
- ✅ 即座のフィードバック
- ✅ リグレッションからの保護
- ✅ 実行可能なドキュメント
- ✅ 設計の改善
- ✅ 開発者の自信

### 成功の鍵
- 🔑 小さなステップで進む
- 🔑 継続的にテストを実行
- 🔑 リファクタリングを恐れない
- 🔑 テストファーストを徹底

> "Legacy code is code without tests" - だからテストを書こう！