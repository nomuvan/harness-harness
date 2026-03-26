# Claude Code 変更一覧

公式changelogを端的にまとめたもの。マイナーバグ修正は省略。
公式: https://code.claude.com/docs/en/changelog

最終更新: 2026-03-26

---

## v2.1.84 (2026-03-26)

- PowerShellツール（Windows、opt-inプレビュー）
- `TaskCreated` hookイベント追加
- `WorktreeCreate` hookが `type: "http"` 対応（`hookSpecificOutput.worktreePath`）
- `allowedChannelPlugins` managed設定
- `CLAUDE_STREAM_IDLE_TIMEOUT_MS` 環境変数
- `ANTHROPIC_DEFAULT_{OPUS,SONNET,HAIKU}_MODEL_SUPPORTS` 環境変数
- `paths:` フロントマターがYAMLリスト形式のglobを受け付けるように
- MCPツール説明文・サーバー指示の上限2KB
- ローカル/claude.aiコネクタ間のMCPサーバー重複排除
- 75分以上アイドル後のプロンプト復帰機能
- deep link (`claude-cli://`) が優先ターミナルで開くように
- トークン表示 1M以上は「1.5m」形式に

## v2.1.83 (2026-03-25)

- `managed-settings.d/` ドロップインディレクトリでポリシー分割管理
- `CwdChanged`, `FileChanged` hookイベント追加
- `sandbox.failIfUnavailable` 設定
- `disableDeepLinkRegistration` 設定
- `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` 環境変数
- `CLAUDE_CODE_DISABLE_NONSTREAMING_FALLBACK` 環境変数
- トランスクリプト検索（`/`キー、`Ctrl+O` でトランスクリプトモード内）
- エージェントが `initialPrompt` フロントマターを宣言可能に
- 画像ペースト時に `[Image #N]` チップ挿入
- `chat:killAgents`, `chat:fastMode` キーバインド再設定可能
- `TaskOutput` 非推奨化（`Read` でタスク出力ファイルを直接読む方式へ）
- MEMORY.md インデックスが25KB/200行で切り詰め

## v2.1.81 (2026-03-20)

- `--bare` フラグ（スクリプト用最小モード。hooks/LSP/pluginsスキップ）
- `--channels` パーミッションリレー（リサーチプレビュー）

## v2.1.80 (2026-03-19)

- ステータスラインにレート制限情報（5時間/7日ウィンドウ）
- skills/slashコマンドに `effort` フロントマター対応
- `--channels` リサーチプレビュー

## v2.1.79 (2026-03-18)

- `claude auth login --console` でAnthropic Console認証
- ターン所要時間表示トグル（`/config`）
- `SessionEnd` フックが対話型 `/resume` で発火するように修正

## v2.1.78 (2026-03-17)

- `StopFailure` hookイベント（APIエラー時）
- `${CLAUDE_PLUGIN_DATA}` 変数（プラグイン永続ステート）
- `effort`, `maxTurns`, `disallowedTools` フロントマター対応

## v2.1.77 (2026-03-17)

- Opus 4.6の出力トークン上限拡張（デフォルト64k、上限128k）
- `allowRead` サンドボックスファイルシステム設定

## v2.1.76 (2026-03-14)

- MCP elicitation（構造化入力のインタラクティブダイアログ）
- `Elicitation`, `ElicitationResult` hook
- `-n` / `--name` フラグでセッション表示名
- `worktree.sparsePaths` 設定（大規模monorepo向け）
- `PostCompact` hook
- `/effort` slashコマンド

## v2.1.75 (2026-03-13)

- **Opus 4.6で1Mコンテキストウィンドウ**（Max/Team/Enterprise）
- `/color` コマンド（プロンプトバーの色変更）
- メモリファイルに最終更新タイムスタンプ

## v2.1.74 (2026-03-12)

- `autoMemoryDirectory` 設定（オートメモリ保存先変更）
- `/context` コマンドに改善提案表示

## v2.1.73 (2026-03-11)

- `modelOverrides` 設定（カスタムモデルIDマッピング）
- Bedrock/Vertex/Foundryのデフォルト Opus を 4.6 に変更
- `/output-style` コマンド非推奨化

## v2.1.72 (2026-03-10)

- `/copy` で `w` キーでファイル直接書き出し
- `/plan` にオプション説明引数
- `ExitWorktree` ツール
- `CLAUDE_CODE_DISABLE_CRON` 環境変数

## v2.1.71 (2026-03-07)

- **`/loop` コマンド**（定期実行プロンプト/コマンド）
- cronスケジューリングツール

## v2.1.69 (2026-03-05)

- `/claude-api` スキル（Claude API開発支援）
- 音声STT 10言語追加（計20言語）

## v2.1.68 (2026-03-04)

- **Opus 4.6のデフォルト effort が medium に変更**
- "ultrathink" キーワードでhigh effort

## v2.1.63 (2026-02-28)

- **`/simplify` と `/batch` バンドルslashコマンド**
- HTTP hooks（URLにPOST JSON）
- claude.aiからMCPサーバー利用可能

## v2.1.59 (2026-02-26)

- **auto-memory機能**（Claudeが自動でコンテキストを `/memory` に保存）
- `/copy` コマンド（インタラクティブピッカー）

## v2.1.51 (2026-02-24)

- `claude remote-control` サブコマンド
- ツール結果50K超をディスクに永続化

## v2.1.50 (2026-02-20)

- `WorktreeCreate`, `WorktreeRemove` hookイベント
- エージェント `isolation: worktree` サポート
- `claude agents` CLIコマンド
- `--worktree` (`-w`) フラグ

## v2.1.49 (2026-02-19)

- MCP OAuth step-up auth
- `--worktree` (`-w`) フラグ（git worktree分離）
- エージェント `background: true` サポート
- プラグインが `settings.json` を同梱可能

## v2.1.45 (2026-02-17)

- **Claude Sonnet 4.6 サポート**

## v2.1.33 (2026-02-06)

- `TeammateIdle`, `TaskCompleted` hook
- エージェント `tools`, `memory` フロントマター

## v2.1.32 (2026-02-05)

- **Claude Opus 4.6 リリース**
- **Agent Teams機能**（マルチエージェント協調）
- auto-memory記録・呼び出し
- スキル自動発見（`--add-dir` から）

## v2.1.30 (2026-02-03)

- ReadツールのPDF `pages` パラメータ
- MCP OAuth事前設定クライアント
- `/debug` コマンド
