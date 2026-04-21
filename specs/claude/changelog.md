# Claude Code 変更一覧

公式changelogを端的にまとめたもの。マイナーバグ修正は省略。
公式: https://code.claude.com/docs/en/changelog

最終更新: 2026-04-22

---

## v2.1.116 (2026-04-20)

- **`/resume` 高速化**: 40MB 超の大規模セッションで最大67%高速化、dead-fork エントリを含むセッションの処理効率改善
- **MCP 起動高速化**: 複数 stdio サーバー設定時の起動が高速化。`resources/templates/list` は最初の `@` メンションまで遅延実行
- **フルスクリーンスクロール改善**: VS Code/Cursor/Windsurf ターミナルでスムーズに。`/terminal-setup` がエディタのスクロール感度を設定
- Thinking スピナーが進捗をインライン表示（"still thinking" → "thinking more" → "almost done thinking"）
- `/config` 検索がオプション値にもマッチ（例: "vim" で Editor mode 設定がヒット）
- `/doctor` が応答中でも起動可能に
- `/reload-plugins` とバックグラウンドプラグイン自動更新が、追加済みマーケットプレースから不足プラグイン依存を自動インストール
- Bash ツールが `gh` コマンドの GitHub API レート制限ヒット時にヒントを表示（エージェントがバックオフ可能）
- Settings の Usage タブが 5時間・週次使用量を即時表示、レート制限時もフェイル回避
- Agent フロントマターの `hooks:` が `--agent` 経由のメインスレッド実行でも発火
- **セキュリティ**: サンドボックス自動許可が `rm`/`rmdir` の `/`, `$HOME` 等重要ディレクトリ対象時の危険パスチェックをバイパスしないよう修正
- Devanagari 等インド系文字のターミナル列整列修正、Kitty キーボードプロトコル下での `Ctrl+-`（undo）・`Cmd+←/→` 修正
- npx/bun run 等ラッパー経由起動時の `Ctrl+Z` ハング修正、インラインモードのスクロールバック重複修正
- `/branch` が 50MB 超トランスクリプトを拒否する問題、`/resume` が大規模セッションで空会話を表示する問題修正
- `/update` と `/tui` が worktree 投入後に動作しない問題修正

## v2.1.114 (2026-04-18)

- エージェントチームのチームメイトがツール権限リクエスト時の権限ダイアログクラッシュを修正

## v2.1.113 (2026-04-17)

- **ネイティブバイナリ化**: bundled JavaScript ではなくネイティブ Claude Code バイナリを直接起動（起動高速化）
- `sandbox.network.deniedDomains` 設定追加（特定ドメインのブロック。allow/deny の併用可）
- フルスクリーンモード改善: `Shift+↑/↓` でスクロール、`Ctrl+A/E` で行頭・行末移動
- Windows: `Ctrl+Backspace` で直前単語削除
- `/loop` 改善: `Esc` で pending wakeup キャンセル
- `/extra-usage` が Remote Control クライアントから利用可能に
- `/ultrareview` 改善: 起動高速化、並列チェック、diffstat 表示
- Bash ツール・権限ルールのセキュリティハードニング
- MCP・UI/UX 各種改善

## v2.1.112 (2026-04-16)

- "claude-opus-4-7 is temporarily unavailable" エラー（Auto mode）修正

## v2.1.111 (2026-04-16)

- **Claude Opus 4.7 xhigh 利用可能** （`/effort` で段階調整）
- Max サブスクライバー向け Auto mode が Opus 4.7 対応
- `/effort` が矢印キーのインタラクティブスライダーに
- "Auto (match terminal)" テーマ追加
- `/less-permission-prompts` スキル追加
- `/ultrareview` コマンド追加（クラウドベースの包括的コードレビュー）
- Windows: PowerShell ツール段階展開（opt-in）
- Auto mode に `--enable-auto-mode` フラグ不要化
- プランファイル名がプロンプト由来に（例: `fix-auth-race-snug-otter.md`）
- グロブ付き読み取り専用 bash コマンドが権限プロンプトをトリガーしないように
- `/skills` メニューにトークン数ソート追加

## v2.1.110 (2026-04-15)

- `/tui` コマンド追加（フリッカーフリー・フルスクリーン描画）
- Remote Control 向け push notification ツール追加
- `Ctrl+O` を normal/verbose トランスクリプトビュー切り替えに変更
- `/focus` コマンド追加
- `/plugin` Installed タブ改善（favorites、注意インジケーター）
- `/doctor` の MCP サーバー警告改善
- `--resume`/`--continue` が未失効のスケジュールタスクを復元
- MCP・権限各種修正

## v2.1.109 (2026-04-15)

- 拡張思考インジケーター改善（回転式プログレスヒント）

## v2.1.108 (2026-04-14)

- `ENABLE_PROMPT_CACHING_1H` 環境変数追加（プロンプトキャッシュTTL 1時間化）
- recap 機能追加（セッション復帰時のおさらい。`/config` で設定可）
- モデルが Skill ツール経由で組み込みスラッシュコマンドを発見・実行可能に
- `/undo` を `/rewind` のエイリアスとして追加
- `/model` がセッション中の切り替え前に警告
- `/resume` ピッカーが現在ディレクトリのセッション優先に
- オンデマンド文法ロードでメモリフットプリント削減

## v2.1.107 (2026-04-14)

- 長時間処理中に thinking ヒントを早めに表示

## v2.1.105 (2026-04-13)

- `EnterWorktree` ツールに `path` パラメータ追加
- **PreCompact フック対応**（コンパクト前のフック実行）
- プラグインのバックグラウンドモニター対応
- `/proactive` を `/loop` のエイリアスとして追加
- API ストリーム停滞処理改善（5分タイムアウト）
- WebFetch 改善（`<style>`・`<script>` タグを除去）
- プラグイン・スキル・MCP 各種修正

## v2.1.101 (2026-04-10)

- `/team-onboarding` コマンド追加
- OS の CA 証明書ストアをデフォルトで信頼
- `/ultraplan` がクラウド環境を自動作成
- brief・focus モード改善
- Bash ツール権限バイパス修正（セキュリティ）
- レート制限リトライメッセージ修正
- 設定回復性改善

## v2.1.98 (2026-04-09)

- Google Vertex AI インタラクティブセットアップウィザード追加
- `CLAUDE_CODE_PERFORCE_MODE` 環境変数追加
- **Monitor ツール追加**（バックグラウンドイベントのストリーミング）
- Linux: サブプロセスサンドボックスで PID namespace 分離
- Bash ツール権限バイパス修正（セキュリティ）
- ストリーミング応答停滞時のフォールバックモード修正

## v2.1.92 (2026-04-04)

- `forceRemoteSettingsRefresh` ポリシー設定追加（リモート設定取得をfail-closed化。取得失敗時にセッション起動をブロック）
- Bedrock インタラクティブセットアップウィザード追加（ログイン画面から直接起動可能）
- `/cost` にモデル別・キャッシュヒット内訳を追加（サブスクリプションユーザー向け）
- `/release-notes` がインタラクティブバージョンピッカーに変更
- Remote Control セッション名のデフォルトプレフィックスがホスト名に変更（`CLAUDE_REMOTE_CONTROL_SESSION_NAME_PREFIX` でカスタマイズ）
- Pro ユーザーにプロンプトキャッシュ有効期限のフッターヒント表示
- `Write` ツールの差分計算が大規模ファイルで60%高速化
- `/tag` コマンド削除
- `/vim` コマンド削除（`/config` → Editor mode に統合）
- Linux サンドボックスに `apply-seccomp` ヘルパー追加（unix-socketブロッキング）
- サブエージェント起動時の "Could not determine pane count" エラー修正
- prompt-type Stop フック、ツール入力バリデーション、拡張思考ホワイトスペースAPI 400等のバグ修正
- プラグインMCPサーバーが "connecting" で停止する問題修正

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
