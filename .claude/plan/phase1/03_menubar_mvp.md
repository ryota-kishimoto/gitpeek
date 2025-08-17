# Phase 1-3: メニューバーMVP

## 最小実装（TDD）

### テストファースト
```swift
// MenuBarViewModelTests.swift
func testToggleMenu() {
    let vm = MenuBarViewModel()
    vm.toggleMenu()
    XCTAssertTrue(vm.isShowing)
}
```

### 実装
```swift
@MainActor
class MenuBarViewModel: ObservableObject {
    @Published var isShowing = false
    @Published var repositories: [Repository] = []
    
    func toggleMenu() {
        isShowing.toggle()
    }
}
```

### UI最小構成
```swift
struct MenuBarView: View {
    @StateObject var viewModel = MenuBarViewModel()
    
    var body: some View {
        VStack {
            ForEach(viewModel.repositories) { repo in
                Text(repo.name)
            }
        }
    }
}
```

## 完了条件
- [ ] メニューバーにアイコン表示
- [ ] クリックでポップオーバー
- [ ] テストカバレッジ > 80%