# Claude Code 変更一覧

公式changelogを端的にまとめたもの。マイナーバグ修正は省略。
公式: https://code.claude.com/docs/en/changelog

最終更新: 2026-04-04

---

## v2.1.91 (2026-04-02)

- MCP ツール結果の永続化上限をサーバー側から指定可能に（`_meta["anthropic/maxResultSizeChars"]` アノテーション、最大500K。DBスキーマ等の大規模結果の切り詰め防止）
- `disableSkillShellExecution` 設定追加（スキル・カスタムコマンド・プラグインコマンド内のインラインシェル実行 `` !`cmd` `` を無効化）
- `claude-cli://open?q=` ディープリンクで複数行プロンプト対応（`%0A` エンコード改行）
- プラグインが `bin/` 配下に実行ファイルを同梱し、Bash ツールから直接呼び出し可能に
- `--resume` でのトランスクリプトチェーン断裂修正（非同期書き込み失敗時の会話履歴喪失）
- リモートセッションでのプランモード修正（コンテナ再起動後にプランファイルを見失い、権限プロンプトが表示される問題）
- `permissions.defaultMode: "auto"` の JSON スキーマ検証修正
- `/feedback` が利用不可時に理由を表示（メニューから消えるのではなく）
- `/claude-api` スキルのエージェント設計パターンガイダンス改善（ツール選定・コンテキスト管理・キャッシュ戦略）
- Edit ツールが短い `old_string` アンカーを使用し出力トークン削減
- パフォーマンス改善: Bun環境で `stripAnsi` を `Bun.stripANSI` にルーティング

## v2.1.90 (2026-04-01)

- `/powerup` コマンド追加（Claude Code機能のインタラクティブレッスン＋アニメーションデモ）
- `CLAUDE_CODE_PLUGIN_KEEP_MARKETPLACE_ON_FAILURE` 環境変数追加（`git pull` 失敗時にマーケットプレースキャッシュを保持。オフライン環境向け）
- `.husky` を保護ディレクトリに追加（acceptEditsモード）
- レート制限オプションダイアログの無限ループ修正（自動再表示→クラッシュの問題）
- `--resume` のプロンプトキャッシュミス修正（deferred tools/MCP/カスタムエージェント使用時。v2.1.69からのリグレッション）
- Edit/Write ツールの "File content has changed" エラー修正（PostToolUse format-on-save フックによるファイル書き換え時）
- `PreToolUse` フックの exit code 2 + JSON stdout が正しくツールコールをブロックするように修正
- Auto Mode がユーザーの明示的境界（"don't push", "wait for X before Y"）を尊重するように修正
- PowerShell ツールの脆弱性修正（`&` バックグラウンドジョブバイパス、デバッガーハング、アーカイブ展開TOCTOU、パース失敗フォールバック）
- パフォーマンス改善（MCPツールスキーマのper-turn JSON.stringify廃止、SSEトランスポート線形時間化、SDK長会話最適化）
- `/resume` が全プロジェクトセッションを並列ロードに改善
- DNSキャッシュコマンドを自動許可リストから削除（プライバシー）

## v2.1.89 (2026-04-01)

- `PreToolUse` フックに `"defer"` permission decision 追加（ヘッドレスセッションがツールコールで一時停止、`-p --resume` で再評価）
- `PermissionDenied` フックイベント追加（Auto Mode分類器の拒否後に発火。`{retry: true}` で再試行指示可能）
- `CLAUDE_CODE_NO_FLICKER=1` 環境変数追加（フリッカーフリーのalt-screen描画、仮想スクロールバック）
- `MCP_CONNECTION_NONBLOCKING=true` 環境変数（`-p` モードでMCP接続待機スキップ。`--mcp-config` サーバー接続は5秒上限）
- 名前付きサブエージェントが `@` メンションタイプアヘッドに表示
- Auto Mode: 拒否コマンドが通知表示、`/permissions` → Recent タブで `r` キーでリトライ可能
- `Edit` ツールが `Bash` の `sed -n` / `cat` で閲覧したファイルに対しても `Read` 不要で動作
- フック出力50K文字超がディスク保存（ファイルパス+プレビューをコンテキストに注入）
- `cleanupPeriodDays: 0` が検証エラーで拒否されるように変更（以前はトランスクリプト永続化が無効化）
- thinking summaries がインタラクティブセッションでデフォルト非生成に変更（`showThinkingSummaries: true` で復元）
- `Edit(//path/**)`/`Read(//path/**)` の allow ルールがシンボリックリンクの解決先をチェックするよう修正
- autocompact スラッシュループ検出（3回連続で即座にリフィルした場合にエラー停止）
- プロンプトキャッシュミス修正（ツールスキーマバイト変更によるセッション中のミス）
- ネストされた CLAUDE.md の重複再注入修正（長セッションで数十回再注入される問題）
- `StructuredOutput` スキーマキャッシュバグ修正（複数スキーマ使用時の50%失敗率）
- フック `if` 条件が複合コマンド（`ls && git push`）や環境変数プレフィックス付きコマンドにマッチするよう修正
- `-p --resume` のハング修正（64KB超ツール入力、deferred マーカー不在時）
- CJK・絵文字・デーヴァナーガリーテキストの切り詰め/ドロップ修正
- Windows: Edit/Write の CRLF 二重化修正、PowerShell stderr 偽エラー修正
- macOS: 音声モードマイク権限修正（Apple Silicon）
- `/stats` がサブエージェント使用量を含むよう修正
- `/env` が PowerShell ツールコマンドにも適用
- `/buddy` エイプリルフール機能

## v2.1.87 (2026-03-29)

- Cowork Dispatch のメッセージ未配信バグ修正

## v2.1.86 (2026-03-27)

- `X-Claude-Code-Session-Id` ヘッダーをAPIリクエストに追加（プロキシのセッション集約用）
- `.jj`（Jujutsu）、`.sl`（Sapling）をVCSディレクトリ除外リストに追加
- `@` メンションファイル内容のJSON エスケープ廃止（トークンオーバーヘッド削減）
- スキル説明文の上限を250文字に制限（コンテキスト使用量削減）
- `/skills` メニューがアルファベット順ソートに
- Read ツールがコンパクトな行番号形式に変更、未変更の再読み込みを重複排除
- Bedrock/Vertex/Foundry のプロンプトキャッシュヒット率改善

## v2.1.85 (2026-03-26)

- Hooks に `if` 条件フィールド追加（permission rule構文でツールイベントをフィルタリング）
- `CLAUDE_CODE_MCP_SERVER_NAME`, `CLAUDE_CODE_MCP_SERVER_URL` 環境変数（MCP `headersHelper` スクリプト用）
- MCP OAuth が RFC 9728 Protected Resource Metadata ディスカバリに対応
- `PreToolUse` フックで `AskUserQuestion` の `updatedInput` 返却が可能に
- スケジュールタスク（`/loop`, `CronCreate`）のトランスクリプトにタイムスタンプマーカー
- deep link クエリが5,000文字まで対応
- 組織ポリシーでブロックされたプラグインがマーケットプレースから非表示に
- `@` メンションファイル補完のパフォーマンス改善
- WASM yoga-layout を Pure TypeScript に置換（スクロールパフォーマンス改善）

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
