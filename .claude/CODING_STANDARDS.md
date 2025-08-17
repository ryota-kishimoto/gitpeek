# GitPeek コーディング規約

## Swift スタイルガイド

### 基本原則
- 読みやすさを最優先
- Swiftの慣習に従う
- 一貫性を保つ
- シンプルに保つ

### 命名規則

#### 型とプロトコル
```swift
// ✅ Good
struct Repository
class GitManager
protocol RepositoryManagerProtocol
enum GitStatus

// ❌ Bad
struct repository
class git_manager
protocol RepositoryManagerInterface
```

#### 変数と定数
```swift
// ✅ Good
let maximumRetryCount = 3
var currentBranch: String
private let gitCommand = GitCommand()

// ❌ Bad
let MAX_RETRY_COUNT = 3
var current_branch: String
private let git_cmd = GitCommand()
```

#### 関数とメソッド
```swift
// ✅ Good
func fetchRepositoryStatus() async throws -> GitStatus
func openInEditor(at path: String)

// ❌ Bad
func fetch_repository_status() async throws -> GitStatus
func OpenEditor(path: String)
```

### コードレイアウト

#### インデント
- スペース4つを使用
- タブは使用しない

#### 行の長さ
- 最大120文字
- 可能な限り100文字以内

#### 空白行
```swift
// ✅ Good
class RepositoryManager {
    private let store: RepositoryStore
    private let gitManager: GitManager
    
    init(store: RepositoryStore, gitManager: GitManager) {
        self.store = store
        self.gitManager = gitManager
    }
    
    func addRepository(_ path: String) throws {
        // Implementation
    }
}
```

### 型推論
```swift
// ✅ Good - 明確な場合は型推論を使用
let message = "Hello"
let repositories = [Repository]()

// ✅ Good - 不明確な場合は型を明示
let timeInterval: TimeInterval = 30
let completion: (Result<GitStatus, Error>) -> Void = { result in
    // Handle result
}
```

### オプショナル

#### アンラップ
```swift
// ✅ Good - guard let
func processRepository(_ repo: Repository?) {
    guard let repo = repo else { return }
    // Use repo
}

// ✅ Good - if let
if let branch = getCurrentBranch() {
    updateUI(with: branch)
}

// ❌ Bad - Force unwrap
let branch = getCurrentBranch()!
```

#### Nil-Coalescing
```swift
// ✅ Good
let branch = repository.branch ?? "main"
let count = changes?.count ?? 0
```

### エラーハンドリング

#### Throwing Functions
```swift
// ✅ Good
enum GitError: LocalizedError {
    case repositoryNotFound
    case gitCommandFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .repositoryNotFound:
            return "Repository not found"
        case .gitCommandFailed(let message):
            return "Git command failed: \(message)"
        }
    }
}

func executeGitCommand(_ command: String) throws -> String {
    guard let result = runCommand(command) else {
        throw GitError.gitCommandFailed(command)
    }
    return result
}
```

#### Result Type
```swift
// ✅ Good
func fetchStatus(completion: @escaping (Result<GitStatus, Error>) -> Void) {
    Task {
        do {
            let status = try await gitManager.getStatus()
            completion(.success(status))
        } catch {
            completion(.failure(error))
        }
    }
}
```

### 非同期処理

#### async/await
```swift
// ✅ Good
func updateAllRepositories() async throws {
    try await withThrowingTaskGroup(of: Void.self) { group in
        for repository in repositories {
            group.addTask {
                try await self.updateRepository(repository)
            }
        }
    }
}
```

#### @MainActor
```swift
// ✅ Good
@MainActor
class MenuBarViewModel: ObservableObject {
    @Published var repositories: [Repository] = []
    
    func refreshUI() {
        // UI updates
    }
}
```

### SwiftUI 規約

#### View構造
```swift
// ✅ Good
struct RepositoryRow: View {
    let repository: Repository
    @ObservedObject var viewModel: RepositoryViewModel
    
    var body: some View {
        HStack {
            icon
            content
            Spacer()
            statusBadge
        }
    }
    
    private var icon: some View {
        Image(systemName: "folder")
    }
    
    private var content: some View {
        VStack(alignment: .leading) {
            Text(repository.name)
            Text(repository.branch)
                .font(.caption)
        }
    }
    
    private var statusBadge: some View {
        // Badge implementation
    }
}
```

#### ViewModifier
```swift
// ✅ Good
struct ErrorBanner: ViewModifier {
    let error: Error?
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if let error = error {
                    ErrorBannerView(error: error)
                }
            }
    }
}

extension View {
    func errorBanner(_ error: Error?) -> some View {
        modifier(ErrorBanner(error: error))
    }
}
```

### アクセス制御

```swift
// ✅ Good
public struct Repository {
    public let id: UUID
    public private(set) var name: String
    private var internalState: State
    
    public init(name: String) {
        self.id = UUID()
        self.name = name
        self.internalState = .initial
    }
}
```

### コメント

#### ドキュメントコメント
```swift
// ✅ Good
/// Fetches the current Git status for the specified repository
/// - Parameters:
///   - repository: The repository to check
///   - forceRefresh: If true, bypasses cache
/// - Returns: The current Git status
/// - Throws: `GitError` if the operation fails
func fetchStatus(for repository: Repository, forceRefresh: Bool = false) async throws -> GitStatus {
    // Implementation
}
```

#### インラインコメント
```swift
// ✅ Good - 複雑なロジックの説明
// Convert SSH URL to HTTPS for GitHub compatibility
let httpsURL = sshURL
    .replacingOccurrences(of: "git@", with: "https://")
    .replacingOccurrences(of: ":", with: "/")

// ❌ Bad - 自明なコメント
// Increment counter
counter += 1
```

### パフォーマンス

#### 遅延初期化
```swift
// ✅ Good
class RepositoryManager {
    private lazy var gitCommand = GitCommand()
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
}
```

#### 値型 vs 参照型
```swift
// ✅ Good - 値型を優先
struct GitStatus {
    let branch: String
    let changes: [FileChange]
}

// ✅ Good - 必要な場合のみクラス
class GitManager: ObservableObject {
    @Published var status: GitStatus
}
```

### テスト

#### テスト命名
```swift
// ✅ Good
func testFetchStatus_whenRepositoryExists_returnsValidStatus() async throws {
    // Test implementation
}

func testAddRepository_whenPathIsInvalid_throwsError() {
    // Test implementation
}
```

#### アサーション
```swift
// ✅ Good
XCTAssertEqual(repository.branch, "main", "Branch should be main")
XCTAssertTrue(status.hasChanges, "Status should indicate changes")
XCTAssertThrows(try manager.addRepository("/invalid/path"))
```

### SwiftLint設定

`.swiftlint.yml`:
```yaml
included:
  - GitPeek
  - GitPeekTests

excluded:
  - Pods
  - .build

opt_in_rules:
  - empty_count
  - closure_spacing
  - contains_over_first_not_nil
  - discouraged_optional_boolean
  - explicit_init
  - first_where
  - implicit_return
  - joined_default_parameter
  - modifier_order
  - multiline_parameters
  - operator_usage_whitespace
  - overridden_super_call
  - private_outlet
  - prohibited_super_call
  - redundant_nil_coalescing
  - sorted_first_last
  - unneeded_parentheses_in_closure_argument

disabled_rules:
  - trailing_whitespace
  - line_length

line_length:
  warning: 120
  error: 150

type_body_length:
  warning: 300
  error: 500

file_length:
  warning: 500
  error: 1000

function_body_length:
  warning: 50
  error: 100

cyclomatic_complexity:
  warning: 10
  error: 20

identifier_name:
  min_length:
    warning: 2
  max_length:
    warning: 40
  excluded:
    - id
    - URL
    - url
```

## コードレビューチェックリスト

- [ ] 命名規則に従っているか
- [ ] エラーハンドリングが適切か
- [ ] Force unwrapを使用していないか
- [ ] メモリリークの可能性はないか
- [ ] パフォーマンスの問題はないか
- [ ] テストが書かれているか
- [ ] ドキュメントコメントがあるか
- [ ] SwiftLintの警告がないか