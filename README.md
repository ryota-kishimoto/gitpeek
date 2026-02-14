<p align="center">
  <img src="gitpeek-icon.svg" width="128" alt="GitPeek Icon">
</p>

<h1 align="center">GitPeek</h1>

<p align="center">macOSのメニューバーでGitリポジトリを管理するアプリ</p>

## 機能

- 複数のGitリポジトリをメニューバーから一括管理
- 変更ファイル数（staged/modified/untracked）とブランチ名をリアルタイム表示
- リモートとの差分（ahead/behind）を表示
- ワンクリックでエディタ/ターミナル/GitHubを開く
- Git pull / fetch操作
- Git worktreeの検出・表示
- 自動更新（10秒間隔、設定可能）
- Sparkleによるアプリの自動アップデート

## 対応アプリ

### エディタ
Cursor / VS Code / Sublime Text / Xcode / Nova

### ターミナル
Terminal / iTerm2 / Warp / Hyper

### その他
GitHub（ブラウザ）/ SourceTree

## インストール

[最新版をダウンロード](https://github.com/ryota-kishimoto/gitpeek/releases)してApplicationsフォルダにドラッグ

## 使い方

1. メニューバーのGitPeekアイコンをクリック
2. 「+」ボタンでリポジトリを追加
3. リポジトリをクリックでエディタ/ターミナル/GitHubを開く

## ビルド

```bash
# アプリのビルド
./build.sh

# /Applicationsにインストール
make install
```

## 動作環境

- macOS 13.0 (Ventura) 以降
- Git

## ライセンス

MIT
