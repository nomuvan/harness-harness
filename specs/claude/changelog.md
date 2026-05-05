# Claude Code 変更一覧

公式changelogを端的にまとめたもの。マイナーバグ修正は省略。
公式: https://code.claude.com/docs/en/changelog

最終更新: 2026-05-06

---

## v2.1.128 (2026-05-04)

- **`/mcp` がツール数を表示**: 接続済みサーバーのツール数を表示し、0 ツールで接続したサーバーを警告マーク
- **`--plugin-dir` が `.zip` 受理**: ディレクトリに加えて zip プラグインアーカイブも読み込み可能
- **`--channels` が console (API キー) 認証で利用可能に**: 管理設定を持つ console org は `channelsEnabled: true` で有効化
- **`/model` ピッカー整理**: Opus 4.7 重複エントリを統合、現行 Opus を「Opus」と表示
- **サブプロセスへの `OTEL_*` 継承を停止**: Bash/hooks/MCP/LSP サブプロセスが CLI の OTLP エンドポイントを誤って継承しないように
- **MCP `workspace` が予約サーバー名に**: 同名の既存サーバーは警告とともにスキップ
- **MCP 再接続時のツール一覧再公開を要約化**: 再接続毎に全ツール名を吐かず、サーバープレフィックスごとに集約
- **SDK ホスト向け `localSettings` サジェスト**: Bash 権限プロンプトで「Always allow」が `.claude/settings.local.json` に書き込まれるよう永続提案
- **`EnterWorktree` が local HEAD 起点に**: ドキュメント通り local HEAD から新ブランチを作成（従来は `origin/<default-branch>` 起点で未 push コミットが落ちていた）
- **オートモード: 分類器エラーにヒント追加**: 評価不能時に retry / `/compact` / `--debug` 起動の提案を表示
- **`/color` 引数なしでランダム色**: セッション色をランダム選択
- **重要バグ修正**:
  - 大入力（>10MB）を `claude -p` に stdin パイプするとクラッシュループする問題
  - 1M コンテキストモデルで autocompact ウィンドウが小さい場合に実 API 制限到達前に「Prompt is too long」で誤ブロックされる問題
  - 並列シェルツール呼び出し: read-only コマンド（grep/git diff/ls）が失敗すると兄弟呼び出しまでキャンセルされる問題
  - サブエージェントの進捗サマリがプロンプトキャッシュを取りこぼし `cache_creation` が約3倍になっていた問題
  - サブエージェントサマリがトランスクリプト静止中も繰り返し発火し、idle サブエージェントの最悪トークンコストが青天井だった問題
  - MCP stdio サーバー: `CLAUDE_CODE_SHELL_PREFIX` 設定時に空白/シェルメタ文字入り引数が破損する問題
  - MCP ツール結果: サーバーが structured content と content blocks の両方を返すと画像が落ちる問題
  - `/plugin update` が npm ソースプラグインの新バージョンを検出しない問題
  - `/plugin` Components パネルが `--plugin-dir` 経由ロードのプラグインで「Marketplace 'inline' not found」を表示する問題
  - `installed_plugins.json` の死んだキャッシュディレクトリエントリが PATH を汚染する問題
  - Bedrock デフォルトモデルがリージョン適切なプレフィックスではなく `global.*` に解決される問題
  - 3P プロバイダーで `/fast` が無関係スキルにファジーマッチする問題（「利用不可」を表示するように）
  - Remote Control: rate limit 時に空の "Opening your options…" 表示（実行可能なアップセル選択肢を表示）
  - 古い「remote-control is active」ステータスラインが `--resume`/`--continue` 後も残る問題
  - Kitty 等の OSC 9 通知解釈ターミナルで `/exit` 毎に "4;0;" デスクトップ通知が出る問題
  - 画像ドラッグ＆ドロップでファイル読み込み失敗時に「Pasting text…」でハングする問題
  - フルスクリーンモードで折り返し表示の長い URL が各行クリック不可だった問題
  - フォーカスモードで新プロンプト送信時に直前応答が一瞬暗くなる問題
  - OSC 8 非対応ターミナルで markdown リンクラベルが失われる問題（`label (url)` 形式で表示）
  - リスト項目内 fenced code block コピー時の先頭空白混入
  - `/config` タブナビゲーションがフォーカスを失う問題
  - vim モード NORMAL: `Space` でカーソル右移動（標準 vi/vim 互換）
  - ターミナル進捗インジケータ（OSC 9;4）がツール呼び出し間で点滅消失する問題
  - `/rename` 引数なしで compact 境界終端の resume セッションが失敗する問題
  - エフォート非対応モデルでバナーに「with X effort」と誤表示する問題
  - Headless `--output-format stream-json`: `init.plugin_errors` に `--plugin-dir` ロード失敗が含まれるように

> 注: v2.1.127 はステーブル未リリース（バージョンスキップ）。v2.1.126 → v2.1.128 へ。

## v2.1.126 (2026-05-01)

- **`/model` ピッカーがゲートウェイの `/v1/models` から取得**: `ANTHROPIC_BASE_URL` が Anthropic 互換ゲートウェイを指す場合、`/model` がそのゲートウェイの利用可能モデル一覧を表示
- **`claude project purge [path]` 追加**: プロジェクトの Claude Code 状態（トランスクリプト、タスク、ファイル履歴、設定エントリ）を一括削除。`--dry-run`、`-y/--yes`、`-i/--interactive`、`--all` オプション対応
- **`--dangerously-skip-permissions` の保護解除拡張**: `.claude/`、`.git/`、`.vscode/`、シェル設定ファイル等の従来保護パスへの書き込みプロンプトを抑制（破滅的削除コマンドは引き続き安全網として確認）
- **`claude auth login` の OAuth コードペースト対応**: ブラウザコールバックが localhost に到達できない環境（WSL2、SSH、コンテナ）で、ターミナルにペーストしたコードを受理
- **OpenTelemetry**: `claude_code.skill_activated` イベントがユーザー入力スラッシュコマンドでも発火するように。新属性 `invocation_trigger`（`"user-slash"` / `"claude-proactive"` / `"nested-skill"`）を追加
- **オートモードのスピナー赤色化**: 権限チェックが停滞しているときスピナーが赤くなり、ツール実行中と区別可能に
- **ホスト管理デプロイ**: `CLAUDE_CODE_PROVIDER_MANAGED_BY_HOST` 設定時でも Bedrock/Vertex/Foundry のアナリティクスが自動無効化されないように
- **Windows: PowerShell 7 検出範囲拡大**: Microsoft Store からのインストール、PATH 未設定 MSI、`.NET global tool` 経由の PowerShell も検出
- **Windows: PowerShell をプライマリシェルに**: PowerShell ツール有効時、Bash ではなく PowerShell が主シェルとして扱われる
- **Read ツール**: ファイル毎のマルウェア評価リマインダーを削除（誤拒否や「これはマルウェアではない」コメンタリーの原因を解消）
- **重要セキュリティ修正**: `allowManagedDomainsOnly` / `allowManagedReadPathsOnly` が、優先度の高い managed-settings ソースに `sandbox` ブロックがないとき無視される問題
- **重要バグ修正**:
  - 2000px 超の画像ペーストでセッションが破壊される問題（ペースト時に縮小、履歴内の超過画像は自動削除しリトライ）
  - 「OAuth not allowed for organization」エラーで誤ってログイン画面が表示される問題（管理者連絡を案内）
  - 低速/プロキシ接続、IPv6-only devcontainer、ブラウザコールバックが localhost に到達不能なケースでの OAuth ログインタイムアウト
  - 並行する認証情報書き込みが有効な OAuth refresh token を稀に消失させる競合
  - API リトライカウントダウンが「0s」で固まる問題
  - Mac スリープ復帰直後の「Stream idle timeout」エラー
  - 長時間モデル思考中にバックグラウンド/リモートセッションが「Stream idle timeout」で誤って中止される問題
  - 空ターン連発後にアシスタントが思考完了しても出力が表示されないハング
  - Cursor / VS Code 1.92–1.104 統合ターミナルでのトラックパッド過剰スクロール
  - needs-auth で停滞した手動 MCP サーバーが claude.ai MCP コネクタを抑制する問題
  - Windows no-flicker モードで日本語/韓国語/中国語が文字化けする問題
  - `Ctrl+L` がプロンプト入力をクリアしてしまう問題（readline 同様、画面再描画のみに）
  - `context: fork` スキルや他サブエージェントの初回ターンで deferred ツール（WebSearch、WebFetch 等）が利用不可
  - `--channels` 起動の対話セッションでプランモードツールが利用不可
  - `/plugin` Uninstall 後に "Enabled" と誤表示される問題
  - リンタが多数ファイルを変更したときのファイル変更リマインダーの総サイズ制限
  - `/remote-control` リトライが「connecting…」で停滞表示される問題（各リトライ結果を表示）
  - リモートコントロール初期接続失敗時に通知にエラー理由が含まれない問題
  - Windows: クリップボード書き込みでコピー内容がプロセスコマンドライン引数経由で EDR/SIEM テレメトリに露出する問題（22KB 超の選択もクリップボードに到達）
  - PowerShell ツール: 単独 `--`（例 `git diff -- file`）が `--%` パース停止トークンと誤認される問題
  - Agent SDK: 並列ツール呼び出しバッチでモデルが不正なツール名を出した際のハング

> 注: v2.1.124 / v2.1.125 はステーブル未リリース（バージョンスキップ）。v2.1.123 → v2.1.126 へ。

## v2.1.123 (2026-04-29)

- `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1` 設定時の OAuth 認証 401 リトライループを修正

## v2.1.122 (2026-04-28)

- **`ANTHROPIC_BEDROCK_SERVICE_TIER` 環境変数追加**: Bedrock サービスティア（`default` / `flex` / `priority`）を選択し、`X-Amzn-Bedrock-Service-Tier` ヘッダで送信
- **`/resume` 検索ボックスに PR URL ペースト対応**: その PR を作成したセッションを検索（GitHub / GitHub Enterprise / GitLab / Bitbucket）
- **`/mcp`**: 同一 URL の手動追加サーバーで隠れた claude.ai connector を表示し、重複削除のヒントを出す
- **OAuth サインイン後も未認可の MCP サーバー**に表示するメッセージを明確化
- **OpenTelemetry**: `api_request` / `api_error` の数値属性が文字列ではなく数値として送出されるように
- **OpenTelemetry**: `@`-mention 解決用に `claude_code.at_mention` ログイベントを追加
- **重要バグ修正**:
  - rewound タイムラインのエントリを含むセッションから `/branch` でフォークすると `tool_use ids were found without tool_result blocks` で失敗する問題
  - Bedrock application inference profile ARN で `/model` の Effort オプションが表示されない、`output_config.effort` が送られない問題
  - Vertex AI / Bedrock のセッションタイトル生成等の構造化出力で `invalid_request_error: output_config: Extra inputs are not permitted` が返る問題
  - プロキシゲートウェイ越しの Vertex AI `count_tokens` エンドポイントで 400 エラー
  - `spinnerTipsOverride.excludeDefault` で時間ベースのスピナーチップが抑制されない問題
  - nonblocking モードでセッション開始後に接続した MCP サーバーのツールを ToolSearch が見つけられない問題
  - bash モードでの `!exit` / `!quit` が CLI を終了させてしまう問題（シェルコマンドとして実行されるよう修正）
  - 新モデル送信画像が 2576px ではなく正しい 2000px 上限にリサイズされるように修正
  - Remote Control セッションの idle status が秒2回再描画され `tmux -CC` 制御パイプを溢れさせる問題
  - 古いビュー設定によりアシスタントメッセージが空表示になる問題
  - `settings.json` 内の hooks エントリが不正な形式でも全体が無効化されないように
  - Voice mode: Caps Lock にバインドしたキーバインドはターミナルがキーイベントを送らないためエラー表示

## v2.1.121 (2026-04-28)

- **MCP `alwaysLoad` オプション**: `true` を指定するとそのサーバーのツールが tool-search のディファード化対象から外れ常時ロードされる
- **`claude plugin prune` 追加**: 孤立した自動インストール済みプラグイン依存を削除。`plugin uninstall --prune` でカスケード削除
- **`/skills` に type-to-filter 検索ボックス**: 長いスキル一覧をスクロールせず即座に絞り込み可能
- **`PostToolUse` フックが全ツールの出力を置換可能に**: `hookSpecificOutput.updatedToolOutput`（従来は MCP 限定）
- **フルスクリーンモード**: スクロール上方で読書中のプロンプト入力で最下部へ戻らないように
- **オーバーフローダイアログがスクロール可能に**: 矢印・PgUp/PgDn・Home/End・マウスホイール対応（フル/非フル両対応）
- **SDK / `claude -p`**: `CLAUDE_CODE_FORK_SUBAGENT=1` が非インタラクティブセッションでも有効
- **`--dangerously-skip-permissions`**: `.claude/skills/`, `.claude/agents/`, `.claude/commands/` への書き込みでプロンプトを出さない
- **`/terminal-setup`**: iTerm2 の "Applications in terminal may access clipboard" を有効化（tmux 経由の `/copy` 対応）
- **MCP サーバー起動時の transient error は最大3回自動リトライ**（従来は接続失敗で停止）
- **ターミナルタブのセッションタイトルが `language` 設定に従って生成される**
- **Claude.ai connector の同一上流URLは重複排除**（重複表示の解消）
- **Vertex AI**: X.509 証明書ベースの Workload Identity Federation（mTLS ADC）対応
- 起動高速化: リリースノートスプラッシュから Recent Activity パネル削除
- LSP 診断サマリーがクリック / Ctrl+O で展開可能、展開ヒントを表示
- **SDK**: `mcp_authenticate` が `redirectUri` 対応（カスタムスキーム / claude.ai connector）
- **OpenTelemetry**: LLM リクエストスパンに `stop_reason`、`gen_ai.response.finish_reasons`、`user_system_prompt`（`OTEL_LOG_USER_PROMPTS` 有効時のみ）追加
- VSCode: 音声ディクテーションが Claude Code 言語未設定時 `accessibility.voice.speechLanguage` を尊重
- VSCode: `/context` がネイティブのトークン使用量ダイアログを開く
- **重要バグ修正**:
  - 多数の画像処理時の RSS 数 GB のメモリ無制限増大
  - 大規模トランスクリプト履歴での `/usage` の最大 ~2GB メモリリーク
  - 進捗イベントを発行しない長時間ツールでのメモリリーク
  - セッション中に開始ディレクトリが削除/移動された場合の Bash ツール永続不能
  - 外部ビルドでの `--resume` 起動時クラッシュ
  - 大規模セッションで unclean shutdown による破損行のスキップ機能（従来は `--resume` 失敗）
  - Bedrock application inference profile ARN での `thinking.type.enabled is not supported` エラー
  - Microsoft 365 MCP OAuth の重複/未対応 `prompt` パラメータ問題
  - tmux/GNOME Terminal/Windows Terminal/Konsole で Ctrl+L 時のスクロールバック重複
  - 起動時 connector-list fetch のtransient auth error で claude.ai MCP connector が消失
  - リモートセッションのビルトインツール "Always allow" がワーカー再起動で失われる
  - native build で `managed-settings.json` 経由 `NO_PROXY` が一部 HTTP クライアントで尊重されない
  - managed settings 承認プロンプトが受諾でもセッション終了する問題
  - stale OAuth token 後の `/usage` rate limit エラー（自動リフレッシュに）
  - レガシーenum値 1 つで `settings.json` 全体が無効化される問題
  - no-flicker 無効時の `/usage` ダイアログのクリッピング
  - フルスクリーンレンダラー無効時の `/focus` "Unknown command"（有効化方法を案内）
  - 実行中バイナリ削除中の grep/find/rg ラッパー失敗（インストール済みツールへフォールバック）
- 大規模ディレクトリツリーでの `find` のピーク FD 使用量削減

## v2.1.120 (2026-04-28)

- **Windows: Git Bash 不要に**: 未インストール時は PowerShell をシェルツールにフォールバック
- **`claude ultrareview [target]` 非インタラクティブサブコマンド**: CI / スクリプトから `/ultrareview` を実行。stdout に findings 出力（`--json` で raw）、終了コード 0/1
- **スキルが `${CLAUDE_EFFORT}` 参照可能**: スキル本文で現在の effort level を埋め込める
- **`AI_AGENT` 環境変数をサブプロセスに伝播**: `gh` などが Claude Code トラフィックを識別可能に
- スピナーのおすすめ表示はインストール済み機能（デスクトップアプリ・スキル・エージェント）に対しては非表示
- 矢印キーがスクロールイベント未発行のターミナルで「PgUp/PgDn でスクロール」ヒントを表示
- 多数の claude.ai connector を未認可で持つ場合のセッション開始高速化
- auto モードの拒否メッセージが設定ドキュメントへリンク
- **`claude plugin validate`**: `marketplace.json` トップレベルの `$schema`/`version`/`description` と `plugin.json` の `$schema` を受理
- auto モードの auto-compact 表示を `auto`（小文字、トークン数なし）に変更（誤解を招くトークン値の表示廃止）
- VSCode: `/usage` がネイティブの Account & Usage ダイアログを開く
- VSCode: 音声ディクテーションが `~/.claude/settings.json` の `language` 設定を尊重
- **重要バグ修正**:
  - Esc キーで stdio MCP ツール呼び出し中のサーバー接続全体が閉じる回帰（v2.1.105 起因）
  - `claude --resume` 起動後の `/rewind` など対話オーバーレイがキー入力に反応しない問題
  - 非フルスクリーンモードでのターミナルスクロールバック重複（リサイズ・ダイアログ・長セッション）
  - `DISABLE_TELEMETRY` / `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` が API/Enterprise ユーザーで使用量メトリクステレメトリを抑制しない問題
  - auto モードでパイプ＋リダイレクト含むマルチラインbashコマンドの "Dangerous rm operation" 誤検知
  - フルスクリーンモードで長い選択メニューがターミナル下部にクリップされる問題（フォーカス項目を画面に保持）
  - `find` ツールが大規模ディレクトリツリーで FD 枯渇しホスト全体クラッシュ（macOS/Linux ネイティブビルド）

## v2.1.119 (2026-04-23)

- **`/config` 設定の永続化**: theme、editor mode、verbose 等が `~/.claude/settings.json` に保存され、project/local/policy のオーバーライド優先順位に従う
- **`prUrlTemplate` 設定追加**: フッターの PR バッジを github.com 以外のカスタムコードレビュー URL に向けられる
- **`CLAUDE_CODE_HIDE_CWD` 環境変数**: 起動ロゴでの作業ディレクトリ表示を隠す
- **`--from-pr` 拡張**: GitLab merge-request、Bitbucket pull-request、GitHub Enterprise PR URL を受け付ける
- **`--print` モードがエージェントの `tools:` / `disallowedTools:` フロントマターを尊重**（インタラクティブモードと一致）
- **`--agent <name>` がビルトインエージェントの `permissionMode` を尊重**
- **PowerShell ツールの permission モード自動承認**: Bash と同じ扱いに
- **Hooks: `PostToolUse` / `PostToolUseFailure` に `duration_ms` 追加**（ツール実行時間。権限プロンプトと PreToolUse フックの時間は除く）
- サブエージェントと SDK MCP サーバーの再設定が並列接続に
- 別プラグインのバージョン制約でピン止めされたプラグインが、最上位の満たす git タグへ自動更新
- **Vim モード**: INSERT 中の Esc がキューされたメッセージを入力に戻さず、再度 Esc で中断
- `owner/repo#N` 省略リンクが github.com 固定ではなく git remote のホストを使用
- **セキュリティ**: `blockedMarketplaces` の `hostPattern` / `pathPattern` が正しく強制適用されるように
- **OpenTelemetry**: `tool_result` / `tool_decision` に `tool_use_id` 追加、`tool_result` に `tool_input_size_bytes` 追加
- ステータスライン stdin JSON に `effort.level` と `thinking.enabled` 追加
- **重要バグ修正**:
  - ネイティブ macOS/Linux ビルドで Bash が permissions で拒否されたときに Glob/Grep ツールが消える問題
  - フルスクリーンモードで上スクロール中にツール完了毎に最下部にスナップ戻りする問題
  - 非 JSON OAuth discovery レスポンスによる MCP HTTP 接続の "Invalid OAuth error response" 失敗
  - `async PostToolUse` フックが応答ペイロード無しの時にセッショントランスクリプトへ空エントリを書き込む問題
  - auto モードがプランモードを "Execute immediately" 指示で上書きする問題
  - Vertex AI でのツール検索デフォルト無効化（`ENABLE_TOOL_SEARCH` でオプトイン）
  - HTTP/SSE/WebSocket MCP サーバーの `headers` 内 `${ENV_VAR}` プレースホルダ未置換
  - `/skills` Enter キーがダイアログ閉じる代わりに `/<skill-name>` をプロンプトに pre-fill
  - `Agent` ツール `isolation: "worktree"` が前セッションの stale worktree を再利用
  - `/export` が会話で実際に使ったモデルではなく現在のデフォルトモデルを表示
  - verbose 出力設定が再起動後に永続化されない
  - `/plan` と `/plan open` がプランモード入時に既存プランに作用しない
  - auto-compaction 前に起動されたスキルが次のユーザーメッセージに対して再実行される
  - git worktree で作業中に PR がセッションに紐付かない

## v2.1.118 (2026-04-23)

- **vim ビジュアルモード**: `v`（visual）/`V`（visual-line）で選択、オペレータ適用、ビジュアルフィードバックを備えたビジュアルモード追加
- **`/cost` と `/stats` が `/usage` に統合**: 両コマンドはタイピングショートカットとして残り、対応タブを開く
- **カスタムテーマ機能**: `/theme` から名前付きカスタムテーマの作成・切替可能に。`~/.claude/themes/` で JSON 直接編集も可。プラグインも `themes/` ディレクトリでテーマを提供可能
- **フックが MCP ツールを直接呼び出し可能**: `type: "mcp_tool"` 新設
- **`DISABLE_UPDATES` 環境変数**: 手動 `claude update` 含む全更新パスをブロック（`DISABLE_AUTOUPDATER` より厳格）
- **WSL 管理設定継承**: `wslInheritsWindowsSettings` ポリシーキーで WSL on Windows が Windows 側 managed settings を継承可能
- **Auto mode `"$defaults"`**: `autoMode.allow` / `soft_deny` / `environment` に `"$defaults"` を含めることで組み込みルールを置換せずカスタムルールを追加
- Auto mode オプトインプロンプトに "Don't ask again" オプション追加
- **`claude plugin tag` 追加**: バージョンバリデーション付きでプラグインのリリース git タグを作成
- `--continue` / `--resume` が `/add-dir` で追加されたディレクトリを持つセッションも検索対象に
- `/color` がリモートコントロール接続時にセッションのアクセント色を claude.ai/code に同期
- `/model` ピッカーが `ANTHROPIC_BASE_URL` ゲートウェイ使用時の `ANTHROPIC_DEFAULT_*_MODEL_NAME` / `_DESCRIPTION` オーバーライドを尊重
- プラグイン自動更新が別プラグインのバージョン制約でスキップされた場合、`/doctor` と `/plugin` Errors タブに表示
- **重要バグ修正**:
  - `/mcp` メニューが `headersHelper` 設定サーバーの OAuth Authenticate/Re-authenticate アクションを隠す問題、HTTP/SSE MCP サーバーがカスタムヘッダーで 401 後に "needs authentication" 状態に固まる問題
  - MCP サーバーの OAuth トークンレスポンスが `expires_in` を省略すると毎時再認証を要求される問題
  - macOS キーチェーンレースで並行 MCP トークンリフレッシュが新鮮な OAuth トークンを上書きし "Please run /login" を誘発する問題
  - Linux/Windows でクレデンシャル保存クラッシュが `~/.claude/.credentials.json` を破損させる問題
  - `/login` が `CLAUDE_CODE_OAUTH_TOKEN` 起動セッションで無効化される問題（env トークンをクリアしディスククレデンシャルを有効化）
  - エージェントタイプフックが `Stop` / `SubagentStop` 以外のイベントで "Messages are required for agent hooks" で失敗する問題
  - `/fork` が fork 毎に親会話全体をディスクに書き込む問題（ポインタ方式に変更）
  - リモートセッション接続時に `~/.claude/settings.json` の `model` 設定が上書きされる問題
  - `plugin install` が不正バージョンインストール済み依存の再解決に失敗する問題

## v2.1.117 (2026-04-22)

- **ネイティブビルド Glob/Grep ツール廃止**: macOS/Linux ネイティブビルドで `Glob`/`Grep` ツールが廃止され、組み込み `bfs`/`ugrep` を Bash ツール経由で使用（ツール呼び出しラウンドトリップ削減で高速化）。Windows・npm インストール版は従来通り
- **外部ビルドでのフォークサブエージェント有効化**: `CLAUDE_CODE_FORK_SUBAGENT=1` でサードパーティビルドでもフォークサブエージェント利用可能に
- **エージェント `mcpServers` メインスレッド対応**: フロントマターの `mcpServers:` が `--agent` 経由のメインスレッド起動でも読み込まれる
- **`/model` 永続化**: 選択モデルが再起動後も維持される（プロジェクトが別モデルをピン止めしていても）。起動ヘッダにプロジェクト/managed-settings ピン止めの出典を表示
- **`/resume` 大規模セッション要約**: stale な大規模セッション再読み込み前に要約を提案（`--resume` 既存動作に整合）
- **MCP 起動高速化**: ローカル + claude.ai MCP サーバー両方設定時の並列接続がデフォルトに
- **Pro/Max デフォルト effort 変更**: Opus 4.6 / Sonnet 4.6 で `high` がデフォルトに（`medium` から昇格）
- **プラグイン依存自動解決**: `plugin install` 済みプラグインに対しても不足依存をインストール。`marketplace add` が設定済みマーケットプレースから不足依存を自動解決
- **Managed-settings 強制**: `blockedMarketplaces` と `strictKnownMarketplaces` がプラグイン install/update/refresh/autoupdate でも強制適用
- **Advisor Tool (experimental)**: "experimental" ラベル、learn-more リンク、起動時通知を追加。プロンプト毎に "Advisor tool result content could not be processed" で固まる問題を修正
- **`cleanupPeriodDays` 対象拡張**: `~/.claude/tasks/`、`~/.claude/shell-snapshots/`、`~/.claude/backups/` も保持期間スイープ対象に
- **OpenTelemetry 強化**:
  - `user_prompt` イベントに `command_name` / `command_source` 追加（スラッシュコマンド用）
  - `cost.usage` / `token.usage` / `api_request` / `api_error` に `effort` 属性追加（effort レベル対応モデル）
  - カスタム/MCP コマンド名は `OTEL_LOG_TOOL_DETAILS=1` 設定がない限り redact
- **Windows 起動高速化**: `where.exe` 実行ファイル検索をプロセス毎にキャッシュ
- **重要バグ修正**:
  - Plain-CLI OAuth セッションがアクセストークン期限切れで "Please run /login" で終了する問題を修正（401 で reactive refresh）
  - `WebFetch` が超大規模 HTML ページでハングする問題（HTML→markdown 変換前に truncate）
  - プロキシが HTTP 204 No Content を返す際の `TypeError` クラッシュ
  - `CLAUDE_CODE_OAUTH_TOKEN` で起動後トークン期限切れ時に `/login` が無効化される問題
  - Opus 4.7 セッションの `/context` 値が膨張し早期 autocompact される問題（200K コンテキスト前提の計算を 1M ネイティブに修正）
  - メイン/サブエージェントで異モデル実行時にファイル読み取りが malware 警告される問題
  - Bedrock application-inference-profile が Opus 4.7 + thinking 無効で 400 エラーを返す問題
  - プロンプト入力 undo (`Ctrl+_`) が入力直後に動作せず状態をスキップする問題
  - `NO_PROXY` が Bun 実行時に remote API リクエストで無視される問題
  - バックグラウンドタスク存在時の idle 再描画ループ（Linux でのメモリ増加）
  - MCP `elicitation/create` が print/SDK モードで接続完了と同時に自動キャンセルされる問題

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
