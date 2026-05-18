# Codex CLI 変更一覧

公式changelogを端的にまとめたもの。マイナーバグ修正は省略。
公式: https://developers.openai.com/codex/changelog

最終更新: 2026-05-19

---

## CLI 0.131.0 (2026-05-18)

- **`codex doctor` コマンド追加**: runtime, auth, terminal, network, config, ローカル状態を横断するサポート向け診断ツール
- **`codex remote-control` の daemon 化**: daemon ライフサイクル管理、ランタイム enable/disable API、ステータス読み取り、registry-backed 環境を追加
- **プラグインマーケットプレース CLI 追加**: `codex plugin` 配下にマーケットプレース操作コマンドが追加。バージョン対応の share、share checkout、共有ワークスペースの discoverability 区分も導入
- **プラグイン Hooks がデフォルト有効化**: 旧来の opt-in から default-enabled に変更
- **統一 `@` メンション**: ファイル / ディレクトリ / プラグイン / スキルを単一ピッカーで検索（app-server プラグインメタデータ駆動）
- **TUI 表示の刷新**:
  - サービスティアのスラッシュコマンドがデータ駆動に
  - ステータスラインに blended token count・権限・承認モードを表示
  - 有効ワークスペースルートを exec/summary 表示に追加
  - レスポンシブ Markdown テーブルレンダリング
- **Python SDK が `openai-codex` / `openai_codex` にリネーム**: ピン留め runtime-generated types、並行ターンルーティング、承認モード API、app-server 統合ハーネスを追加
- **`/goal edit` コマンド追加**: 既存ゴール内容を TUI から編集可能に
- **`--dangerously-bypass-hook-trust` CLI フラグ追加**: hook trust フローを意図的にバイパス（CI 等向け）
- **`--profile-v2` レイヤー化プロファイル設定**: 複数 TOML を重ねるプロファイル v2。旧 `[profiles]` 併用時は明示拒否
- **strict config parsing**: 設定スキーマ外フィールドの厳格チェック
- **Network proxy feature flag**: ネットワークプロキシ機能の段階的ロールアウト用フラグ
- **Windows hook command overrides**: Windows 上で hook コマンドをプラットフォーム別に差し替え可能
- **Multi-environment `apply_patch` 選択**: 複数環境に跨る apply_patch のターゲット指定
- **Windows サンドボックス強化**: deny-read parity、scoped write root SID、firewall policy が無効な場合の elevated setup 失敗
- **権限永続化の堅牢化**: escalation 中の managed deny-read 維持、workspace-roots と danger-full-access の正規化
- **SQLite/状態起動の安全化**: 破壊的バージョンバンプ廃止、state db オープン失敗時の fail-closed、復旧パス追加
- **`git` 周り改善**: 連結 worktree でルート repo hooks を使用、helper コマンドで repo hook/fsmonitor 設定を無視、login OAuth のローカルコールバック binding、再ログイン時の旧トークン失効
- **ambient terminal pets** (`tui.pets`): TUI にデコラティブなペットを表示（実験的）
- **削除・非推奨**:
  - `/collab` スラッシュコマンドを削除
  - 組み込み MCP を廃止（プラグイン経由で利用）
  - `experimental_use_freeform_apply_patch` / `windows_wsl_setup_acknowledged` / `tools.view_image` / `Feature::CodexGitCommit` 等の設定を削除
  - レガシー after-tool-use hooks を削除
  - Issue labeler を非推奨化
- **主要バグ修正**:
  - TUI: URL 周囲のテキスト wrap、ライトモード選択のコントラスト、tmux 内 Shift+Enter、`/review` MCP 起動表示、`/side` の Esc 抑止
  - exec-server: Windows での `taskkill` 出力抑制、transport timeout 延長
  - 設定: TUI keymap で `minus` を許容

## CLI 0.130.0 (2026-05-08)

- **`codex remote-control` コマンド追加**: ヘッドレス・リモート制御可能な app-server を起動するシンプルなエントリポイント
- **プラグイン共有・詳細表示の拡張**: プラグイン詳細にバンドル済み hooks を表示。プラグイン共有でリンクメタデータと discoverability コントロールを公開
- **App-server: 大規模スレッドのページング対応**: unloaded / summary / full ターン項目ビューで巨大スレッドを段階ロード
- **Bedrock auth が `aws login` プロファイル credentials を利用可能に**: AWS console-login credentials を直接使用
- **`view_image` がマルチ環境セッションで選択環境経由でファイルを解決**
- **重要バグ修正**:
  - ライブ app-server スレッドが再起動なしで設定変更を取り込むように
  - `apply_patch` の部分失敗（ファイル変更済みでも失敗）でターン差分が正確に保たれるように
  - `ThreadStore` 経由のスレッドサマリ・リネーム・resume・fork 経路改善（ローカル rollout パスがないスレッドを含む）
  - リモートコンパクション v2 ストリームで `response.processed` を発行、API キー compact リクエストでの `service_tier` 送信回避
  - Windows サンドボックスでサンドボックスユーザーがデスクトップランタイムバイナリキャッシュにアクセス可能に
  - `codex exec` 起動バナーから陳腐化した「research preview」文言を削除
- **OpenTelemetry 拡張**: トレースメタデータの設定可能化、レビュー/フィードバックアナリティクス強化
- **依存関係衛生**: GitHub Action の完全修飾ピン、Dependabot 7日クールダウン、`cargo-shear` 1.11.2 アップグレード

> 注: 0.126.0 / 0.127.0 / 0.130.0 はステーブル前段で多数の alpha が出たが、`-alpha` を含まないタグが付与されたのは 0.128.0 → 0.130.0 のジャンプで、stable ラインは 0.128.0 → 0.129.0 → 0.130.0 と進行している。

## CLI 0.129.0 (2026-05-07)

- **TUI コンポーザーの Vim モーダル編集対応**: `/vim` コマンドで Vim キーバインドを有効化
- **ワークフロー再開ピッカーを刷新**: より明確なバリデーションとセッション間の再開操作を改善
- **Raw scrollback モード**: 端末ネイティブスクロールバックを活用するレンダリングモード
- **ワークスペース対応の `/diff` コマンド**: 複数ワークスペースを跨いだ差分表示
- **ステータスラインがテーマ対応化**: PR/ブランチ変更サマリ表示のオプション追加
- **プラグイン管理拡張**: ワークスペース共有、アクセス制御、ソースフィルタ、ローカルパストラッキング、マーケットプレース操作を強化
- **実験的 Goals 機能**: 検出可能化、一時停止状態の永続化、再開セッション横断のバリデーション明確化
- **Linux サンドボックス強化**:
  - スタンドアロン `bwrap` フォールバックを Linux リリースに同梱
  - Bubblewrap vendoring を 0.11.2 に更新（上流のセキュリティ変更を取り込み）
  - 古い `bwrap` バージョンと symlink 保護パスでの信頼性向上
- **その他バグ修正**: tmux 互換 `/copy`、Alt+Enter 挙動修正、Windows タイピングレイテンシ低減

## CLI 0.128.0 (2026-04-30)

- **`/goal` 永続化ワークフロー導入**: app-server API・モデルツール・ランタイム継続・TUI コントロール（create / pause / resume / clear）を備えた目標駆動ワークフロー
- **`codex update` コマンド追加**: CLI 自身を最新版にアップグレード
- **TUI キーマップを設定可能に**: ユーザー定義のキーマップ対応
- **プランモードのナッジ強化**: ユーザーへの誘導表示改善
- **Action-required ターミナルタイトル**: 承認待ち等の状態をターミナルタイトルに反映
- **アクティブターン中の `/statusline` / `/title` 編集**: ターン進行中でも変更可能
- **権限プロファイル拡張**: ビルトインデフォルト・サンドボックス CLI プロファイル選択・cwd 制御・アクティブプロファイルメタデータをクライアントに公開
- **プラグインワークフロー強化**: マーケットプレースインストール、リモートバンドルキャッシュ、リモートアンインストール、プラグインバンドル hooks、hook 有効化状態、外部エージェント設定インポート
- **外部エージェントセッションインポート**: バックグラウンドインポートとインポート済みセッションタイトル処理
- **MultiAgentV2 設定の明示化**: スレッド上限、待機時間制御、root/subagent ヒント、v2 固有の depth 処理
- 主要バグ修正:
  - resume / interruption 関連（stale interrupt ハング、永続化プロバイダー復元、巨大リモート resume レスポンス、フィルター済み resume 一覧の遅延）
  - TUI 安定性（リサイズリフロー、Markdown リスト間隔、スラッシュコマンドポップアップレイアウト、シェルモード Esc）
  - Managed network 強化（deferred denials、proxy bypass デフォルト、IPv6 ホスト一致、`git -C` 承認）
  - Windows サンドボックス / PTY エッジケース（pseudoconsole 起動、elevated runner、コアシェル環境継承、名前付きパイプ検証）
  - Bedrock の `apply_patch` / GPT-5.4 reasoning level / GPT-5.4 エンドポイント・モデルメタデータ
  - MCP / プラグイン（stdio サーバークリーンアップ、プラグイン MCP 承認永続化、カスタム MCP メタデータ分離）
- ドキュメント更新: バンドル OpenAI Docs スキルが GPT-5.5 / `gpt-image-2` 対応、アップグレードガイダンス明確化

> 注: 0.126.0 / 0.127.0 はステーブルとしてリリースされず（alpha のみ）、0.125.0 → 0.128.0 にバージョンスキップ。

## CLI 0.125.0 (2026-04-24)

- **App-server 統合の拡張**: Unix socket トランスポート対応、ページネーション対応の resume/fork、固定環境（sticky environments）、リモートスレッド設定/ストア機能を追加
- **権限プロファイルの永続化**: TUI セッション・ユーザーターン・MCP サンドボックス状態・シェルエスカレーション・app-server API を横断して `permission profiles` が保持される
- **リモートプラグインのインストール / マーケットプレースアップグレード**: ローカル外のプラグインを直接インストール・更新可能
- **モデル検出強化**: AWS / Bedrock アカウント状態を含むモデルカタログ検出
- **`codex exec --json` に reasoning-token 報告追加**: プログラマティック利用者向けに reasoning-token の使用量が出力に含まれる
- **ロールアウトトレーシング**: ツール、コードモード、セッション、マルチエージェント関係を記録するデバッグリデューサー機能
- App-server: 明示的に信頼されていないプロジェクト設定の自動永続化を回避
- **設定スキーマ**: MultiAgentV2 のスレッド制限競合検出、相対エージェント設定パスの解決、MCP bearer-token の非対応フィールド隠蔽、`js_repl` 無効 MIME 型の拒否
- TUI: `/review` 中断と終了時にインターフェースが固まる問題を修正
- Exec-server: プロセス終了後のバッファ出力保持、ストリーム完全クローズ待機を修正
- WebSocket: ターンとツール出力通知バースト時の切断問題を軽減
- Windows サンドボックス: 複数 CLI バージョンと設定ディレクトリの互換性向上、PowerShell 表示ウィンドウの非表示化

## CLI 0.124.0 (2026-04-23)

- **TUI 推論コントロールのクイック操作**: `Alt+,` で推論レベル下げ、`Alt+.` で上げ
- **app-server が複数環境を管理**: ターンごとに環境/作業ディレクトリを選択可能
- **Amazon Bedrock ファーストクラス対応**: OpenAI 互換プロバイダーとして AWS SigV4 署名込みで組み込み
- **リモートプラグインマーケットプレース**: 直接一覧・読み取り可能、より大きなページサイズ対応
- **Hooks が正式化（stable）**: `config.toml` にインライン設定可能、managed `requirements.toml` で管理
- **Fast サービスティアがデフォルト**: 対象 ChatGPT プランでは明示オプトアウトしない限り Fast を利用
- Cloudflare Cookie が承認済み ChatGPT ホスト間で保持
- リモート app-server の websocket イベント排出信頼性向上
- `/permissions` 変更時の permission モードドリフト修正
- `wait_agent` がメールボックスに作業がキューされている際に即返却
- ローカル stdio MCP 起動で相対コマンドが動作
- 管理対象 config エッジケースでの起動失敗削減

## CLI 0.123.0 (2026-04-23)

- **Amazon Bedrock プロバイダー対応**: モデルプロバイダーとして Bedrock が利用可能に
- **`/mcp verbose` 診断**: MCP 接続状態とツール一覧の詳細出力でトラブルシュート容易化
- **バックグラウンドエージェント Realtime ハンドオフ強化**: 進捗転送とセッション復帰が改善
- `/copy` がロールバック後も正常動作
- VS Code WSL ターミナルでの Unicode 入力修正

## CLI 0.122.0 (2026-04-20)

- **スタンドアロンインストール改善**: Windows/Intel Mac で `codex app` が Desktop を正しく開く/インストール
- **`/side` コマンド追加**: TUI サイド会話で作業中でもクイック質問可能。キュー入力はスラッシュコマンド・シェルプロンプトに対応
- **プランモード強化**: フレッシュコンテキストで実装開始可能。継続判断前にコンテキスト使用量を表示
- **プラグインワークフロー刷新**: タブブラウジング、インラインの有効/無効トグル、マーケットプレース削除、リモート・クロスリポジトリ・ローカルマーケットプレースソース対応
- **ファイルシステム権限拡張**: deny-read グロブポリシー、管理対象 deny-read 要件、プラットフォームサンドボックス強制、ユーザー設定をバイパスする隔離 `codex exec` 実行
- ツール検出・画像生成がデフォルト有効、MCP と `js_repl` 出力向けの original-detail メタデータ対応
- App-server 承認と MCP elicitation が別クライアント解決時に TUI から消える（stale プロンプト防止）
- リモートコントロール起動が ChatGPT 認証欠如に耐性、MCP 起動キャンセルが app-server セッション経由で動作
- resume/fork された app-server スレッドがトークン使用量を即時リプレイ
- **セキュリティ**: logout が管理対象 ChatGPT トークンを取り消し、プロジェクトフックは信頼済みワークスペースを要求
- sandboxed `apply_patch` が split filesystem ポリシー下で正常動作
- `SECURITY.md` にセキュリティ境界リファレンス追加（サンドボックス、承認、ネットワーク制御）

## CLI 0.121.0 (2026-04-15)

- **マーケットプレースインストール**: GitHub、git URL、ローカルディレクトリからインストール可能に
- TUI 履歴改善: `Ctrl+R` で逆方向検索
- メモリモード制御と削除エンドポイント追加
- MCP Apps のツールコール対応と並列コール対応
- Realtime API 拡張（output modality、transcript events）
- bubblewrap 対応のセキュア devcontainer プロファイル
- macOS sandbox/proxy、Windows パスマッチング、レート制限、Guardian タイムアウトの修正

## CLI 0.120.0 (2026-04-11)

- Realtime V2 のバックグラウンドエージェント進捗ストリーミング
- TUI でのフック実行可視化改善
- MCP `outputSchema` 対応（構造化ツール結果）
- `/clear` セッション向け SessionStart フック区別
- Windows elevated サンドボックスの split policy 処理、symlink writable root、TLS websocket、ツール検索順序、live stop-hook、MCP クリーンアップの修正

## CLI 0.119.0 (2026-04-10)

- **Realtime 音声セッションが v2 WebRTC デフォルト**（transport 設定可）
- MCP Apps のリソース読み取り、ツールコールメタデータ、カスタムサーバーツール検索
- Remote workflow: egress websocket、remote `--cd` 転送、ランタイムリモートコントロール
- TUI `Ctrl+O` で最新エージェント応答をコピー
- `/resume` で ID・名前によるセッションジャンプ
- TUI 起動高速化（async レート制限取得）、resume ピッカー安定化、composer 挙動改善、MCP ノイズ削減

## CLI 0.118.0 (2026-03-31)

- Windows サンドボックスがプロキシ限定ネットワーキング対応（OSレベルのegressルール）
- アプリサーバークライアントがChatGPTデバイスコードフローでサインイン可能に
- `codex exec` がプロンプト+stdin ワークフローに対応
- カスタムモデルプロバイダーが動的ベアラートークン取得に対応

## CLI 0.117.0 (2026-03-26)

- プラグインをファーストクラスワークフローに昇格
- サブエージェントがパスベースアドレスに対応
- ターミナルタイトルピッカー機能
- アプリサーバーのシェルコマンド・ファイルシステム監視機能強化
- 推論サマリー重複、ChatGPTログイン、ターミナル状態復元、サンドボックス信頼性のバグ修正

## Plugin Support Released (2026-03-25)

- プラグインをインストール可能なバンドル（skills + アプリ統合 + MCP設定）として導入
- マニフェストファイル + オプションディレクトリ構造
- ユーザー/リポジトリ単位のインストール対応（キュレーション済みリスト + ローカル開発）

## CLI 0.116.0 (2026-03-19)

- アプリサーバーTUIでChatGPTデバイスコードサインイン対応
- プラグインセットアップの改善（インストールプロンプト、同期機能）
- `userpromptsubmit` hook追加（実行前のプロンプトインターセプト）
- リアルタイムセッションが直近スレッドコンテキストで開始

## アプリ 26.323 (2026-03-24)

- 過去スレッドの検索機能（サイドバーショートカット）
- ローカルプロジェクトスレッドのワンクリックアーカイブ
- アプリとVS Code拡張間の設定同期

## アプリ 26.318 (2026-03-19)

- Skillsが `@` メニューに表示（他のメンションと並列）
- `Cmd/Ctrl+F` 検索が選択テキストから開始

## アプリ 26.317 (2026-03-17)

- **GPT-5.4 mini 利用可能** — 軽量コーディングタスク向け高速モデル
- GPT-5.4の2倍速、利用量上限の30%で動作
- 会話フォーキング（最新ターンだけでなく過去のメッセージから分岐）
- スラッシュコマンドでモデル・推論レベル切り替え

## アプリ 26.316 (2026-03-16)

- 戻る/進むナビゲーションボタン
- スレッドメニューからファイルエクスプローラショートカット

## CLI 0.115.0 (2026-03-16)

- フル解像度画像検査（`view_image`, `codex.emitImage()`）
- リアルタイムWebSocket転写モード（v2ハンドオフ対応）
- ファイルシステムRPC（Python SDK連携）
- Smart Approvals（ガーディアンサブエージェントルーティング）

## アプリ 26.312 (2026-03-12)

- カスタムテーマシステム（色・フォントカスタマイズ）
- オートメーション刷新（ローカル/worktree実行オプション）

## アプリ 26.311 (2026-03-11)

- 統合ターミナル読み取り機能（開発サーバーのステータス確認）

## CLI 0.114.0 (2026-03-11)

- 実験的コードモード（分離ワークフロー）
- **Hooksエンジン**（SessionStart, Stopイベント）
- WebSocketヘルスチェックエンドポイント
