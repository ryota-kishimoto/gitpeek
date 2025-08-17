# GitPeek Makefile
# 開発タスクの自動化

.PHONY: help
help: ## ヘルプを表示
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# ========== Setup ==========

.PHONY: setup
setup: ## 開発環境のセットアップ
	@echo "🔧 Setting up development environment..."
	@brew install swiftlint || true
	@brew install swiftformat || true
	@echo "✅ Setup complete!"

.PHONY: install-hooks
install-hooks: ## Git hooksのインストール
	@echo "🔗 Installing git hooks..."
	@cp .githooks/* .git/hooks/
	@chmod +x .git/hooks/*
	@echo "✅ Git hooks installed!"

# ========== Code Quality ==========

.PHONY: lint
lint: ## SwiftLintを実行
	@echo "🔍 Running SwiftLint..."
	@swiftlint

.PHONY: lint-fix
lint-fix: ## SwiftLintで自動修正
	@echo "🔧 Auto-fixing with SwiftLint..."
	@swiftlint --fix

.PHONY: format
format: ## SwiftFormatを実行
	@echo "🎨 Formatting code with SwiftFormat..."
	@swiftformat .

.PHONY: format-check
format-check: ## SwiftFormatでチェックのみ
	@echo "🔍 Checking format with SwiftFormat..."
	@swiftformat --lint .

.PHONY: check
check: lint format-check ## Lint and Format チェック
	@echo "✅ All checks passed!"

.PHONY: fix
fix: lint-fix format ## Lint and Format 自動修正
	@echo "✅ All fixes applied!"

# ========== Build ==========

.PHONY: build
build: ## Debug ビルド
	@echo "🔨 Building Debug..."
	@xcodebuild -scheme GitPeek -configuration Debug build

.PHONY: build-release
build-release: ## Release ビルド
	@echo "🔨 Building Release..."
	@xcodebuild -scheme GitPeek -configuration Release build

.PHONY: clean
clean: ## ビルドをクリーン
	@echo "🧹 Cleaning build..."
	@xcodebuild clean
	@rm -rf ~/Library/Developer/Xcode/DerivedData/GitPeek-*

# ========== Test ==========

.PHONY: test
test: ## 全テストを実行
	@echo "🧪 Running all tests..."
	@xcodebuild test -scheme GitPeek -destination 'platform=macOS'

.PHONY: test-unit
test-unit: ## 単体テストのみ実行
	@echo "🧪 Running unit tests..."
	@xcodebuild test -scheme GitPeek -destination 'platform=macOS' -only-testing:GitPeekTests/Unit

.PHONY: test-integration
test-integration: ## 統合テストのみ実行
	@echo "🧪 Running integration tests..."
	@xcodebuild test -scheme GitPeek -destination 'platform=macOS' -only-testing:GitPeekTests/Integration

.PHONY: test-ui
test-ui: ## UIテストのみ実行
	@echo "🧪 Running UI tests..."
	@xcodebuild test -scheme GitPeek -destination 'platform=macOS' -only-testing:GitPeekUITests

.PHONY: test-coverage
test-coverage: ## テストカバレッジレポート生成
	@echo "📊 Generating coverage report..."
	@xcodebuild test -scheme GitPeek -destination 'platform=macOS' -enableCodeCoverage YES
	@xcrun xccov view --report --json DerivedData/Logs/Test/*.xcresult > coverage.json
	@echo "Coverage report saved to coverage.json"

# ========== TDD ==========

.PHONY: tdd
tdd: ## TDDサイクル開始（ウォッチモード）
	@echo "🔄 Starting TDD cycle..."
	@echo "Watching for changes..."
	@fswatch -o GitPeek GitPeekTests | xargs -n1 -I{} make test-unit

.PHONY: red
red: ## Red phase - 失敗するテストを確認
	@echo "🔴 Red phase - Running tests (should fail)..."
	@xcodebuild test -scheme GitPeek -destination 'platform=macOS' || true

.PHONY: green
green: ## Green phase - テストを通す
	@echo "🟢 Green phase - Running tests (should pass)..."
	@xcodebuild test -scheme GitPeek -destination 'platform=macOS'

.PHONY: refactor
refactor: check test ## Refactor phase - リファクタリング後の確認
	@echo "♻️ Refactor phase - Checking code quality and tests..."

# ========== Run ==========

.PHONY: run
run: ## アプリを実行
	@echo "🚀 Running GitPeek..."
	@xcodebuild -scheme GitPeek -configuration Debug run

.PHONY: run-release
run-release: ## リリースビルドを実行
	@echo "🚀 Running GitPeek (Release)..."
	@xcodebuild -scheme GitPeek -configuration Release run

# ========== Documentation ==========

.PHONY: docs
docs: ## ドキュメント生成
	@echo "📚 Generating documentation..."
	@swift-doc generate GitPeek --module-name GitPeek --output docs

# ========== Release ==========

.PHONY: archive
archive: ## アーカイブ作成
	@echo "📦 Creating archive..."
	@xcodebuild archive -scheme GitPeek -archivePath ./build/GitPeek.xcarchive

.PHONY: export
export: archive ## アプリをエクスポート
	@echo "📤 Exporting app..."
	@xcodebuild -exportArchive -archivePath ./build/GitPeek.xcarchive -exportPath ./build -exportOptionsPlist ExportOptions.plist

.PHONY: dmg
dmg: export ## DMGファイル作成
	@echo "💿 Creating DMG..."
	@create-dmg \
		--volname "GitPeek" \
		--window-pos 200 120 \
		--window-size 600 400 \
		--icon-size 100 \
		--icon "GitPeek.app" 175 190 \
		--hide-extension "GitPeek.app" \
		--app-drop-link 425 190 \
		"GitPeek.dmg" \
		"build/GitPeek.app"

# ========== CI ==========

.PHONY: ci
ci: check test ## CI用タスク
	@echo "✅ CI checks passed!"

.PHONY: pre-commit
pre-commit: check test-unit ## プリコミットチェック
	@echo "✅ Pre-commit checks passed!"

# ========== Utility ==========

.PHONY: stats
stats: ## コード統計
	@echo "📊 Code statistics:"
	@find GitPeek -name "*.swift" | xargs wc -l | tail -1
	@echo "Test files:"
	@find GitPeekTests -name "*.swift" | xargs wc -l | tail -1

.PHONY: todo
todo: ## TODOリスト表示
	@echo "📝 TODO items:"
	@grep -r "TODO\|FIXME\|HACK" --include="*.swift" GitPeek GitPeekTests || echo "No TODOs found!"

.PHONY: deps
deps: ## 依存関係の更新
	@echo "📦 Updating dependencies..."
	@swift package update

.PHONY: reset
reset: clean ## プロジェクトをリセット
	@echo "🔄 Resetting project..."
	@rm -rf .build
	@rm -rf DerivedData
	@echo "✅ Project reset complete!"

# ========== Sub-Agents ==========

.PHONY: agent-test-plan
agent-test-plan: ## Test Planner agentを使用
	@echo "🤖 Using Test Planner agent..."
	@echo "Run: Use the test-planner agent to design test cases"

.PHONY: agent-test-exec
agent-test-exec: ## Test Executor agentを使用
	@echo "🤖 Using Test Executor agent..."
	@echo "Run: Use the test-executor agent to implement tests"

.PHONY: agent-review
agent-review: ## Code Reviewer agentを使用
	@echo "🤖 Using Code Reviewer agent..."
	@echo "Run: Use the code-reviewer agent to review the code"

.PHONY: agent-tdd
agent-tdd: ## TDD Facilitator agentを使用
	@echo "🤖 Using TDD Facilitator agent..."
	@echo "Run: Use the tdd-facilitator agent for TDD cycle"

# デフォルトターゲット
.DEFAULT_GOAL := help