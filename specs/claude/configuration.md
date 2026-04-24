# Claude Code 設定仕様書

最終更新: 2026-04-18（巡回更新）

公式ドキュメント: https://code.claude.com/docs/en/settings / https://code.claude.com/docs/en/memory

---

## 1. CLAUDE.md

CLAUDE.md はセッション開始時にコンテキストウィンドウへ読み込まれるMarkdownファイル。Claude の振る舞いに対する持続的な指示を提供する。

### 1.1 配置場所とスコープ

| スコープ | パス | 用途 | 共有範囲 |
|:--|:--|:--|:--|
| **Managed Policy** | macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md`<br>Linux/WSL: `/etc/claude-code/CLAUDE.md`<br>Windows: `C:\Program Files\ClaudeCode\CLAUDE.md` | 組織全体の指示（IT/DevOps管理） | 組織内全ユーザー |
| **Project** | `./CLAUDE.md` または `./.claude/CLAUDE.md` | チーム共有のプロジェクト指示 | バージョン管理経由でチーム |
| **User** | `~/.claude/CLAUDE.md` | 全プロジェクト共通の個人設定 | 自分のみ |

### 1.2 階層構造と読み込み順

- カレントディレクトリからルートへ向かってディレクトリツリーを走査し、各階層の CLAUDE.md を読み込む
- サブディレクトリの CLAUDE.md は起動時には読み込まれず、Claude がそのディレクトリのファイルを読むときにオンデマンドで読み込まれる
- より具体的なスコープが優先される

### 1.3 インポート構文

`@path/to/import` 構文で外部ファイルをインポートできる。

```markdown
See @README.md for project overview and @package.json for available npm commands.

# Additional Instructions
- Git workflow: @docs/git-instructions.md
- Personal overrides: @~/.claude/my-project-instructions.md
```

- 相対パスはインポート元ファイルからの相対
- 絶対パスも使用可能
- 再帰的インポートは最大5階層まで
- 初回のプロジェクト外インポート時に承認ダイアログが表示される

### 1.4 CLAUDE.md の書き方ガイドライン

- **サイズ**: 1ファイルあたり200行以下を目標
- **構造**: Markdownの見出しと箇条書きでグループ化
- **具体性**: 検証可能な具体的指示を書く（例: 「2スペースインデント」）
- **一貫性**: 矛盾する指示がないか定期的に見直す

### 1.5 CLAUDE.md の除外

大規模モノレポで不要な CLAUDE.md を除外するには `claudeMdExcludes` 設定を使用する。

```json
{
  "claudeMdExcludes": [
    "**/monorepo/CLAUDE.md",
    "/home/user/monorepo/other-team/.claude/rules/**"
  ]
}
```

Managed Policy の CLAUDE.md は除外不可。

### 1.6 `--add-dir` からの読み込み

デフォルトでは `--add-dir` で追加したディレクトリの CLAUDE.md は読み込まれない。環境変数で有効化する:

```bash
CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1 claude --add-dir ../shared-config
```

---

## 2. settings.json

### 2.1 スコープ

| スコープ | ファイルパス | 対象 | チーム共有 |
|:--|:--|:--|:--|
| **Managed** | サーバー管理 / plist / レジストリ / `managed-settings.json` / `managed-settings.d/*.json` | マシン上の全ユーザー | Yes（IT配布） |
| **User** | `~/.claude/settings.json` | 全プロジェクトの自分 | No |
| **Project** | `.claude/settings.json` | リポジトリの全コラボレーター | Yes（gitコミット） |
| **Local** | `.claude/settings.local.json` | このリポジトリの自分のみ | No（gitignored） |

### 2.2 優先順位（高い順）

1. **Managed** -- 他の設定で上書き不可
2. **コマンドライン引数** -- セッション単位の一時的上書き
3. **Local** -- Project/User を上書き
4. **Project** -- User を上書き
5. **User** -- 最低優先

配列設定（`permissions.allow` 等）は各スコープから**マージ**（結合・重複排除）される。

#### Managed ドロップインディレクトリ

`managed-settings.d/` ディレクトリで複数チームが独立したポリシーフラグメントをデプロイ可能（v2.1.83）:

```
/Library/Application Support/ClaudeCode/     # macOS
├── managed-settings.json                     # メインポリシー
└── managed-settings.d/
    ├── security-team.json                    # セキュリティチームのポリシー
    └── platform-team.json                    # プラットフォームチームのポリシー
```

### 2.3 主要設定キー一覧

| キー | 説明 |
|:--|:--|
| `permissions.allow` | 許可するツール使用ルール配列 |
| `permissions.deny` | 拒否するツール使用ルール配列 |
| `permissions.ask` | 確認を求めるツール使用ルール配列 |
| `permissions.defaultMode` | デフォルト権限モード |
| `permissions.additionalDirectories` | 追加ワーキングディレクトリ |
| `permissions.disableBypassPermissionsMode` | `bypassPermissions` モード無効化 |
| `hooks` | ライフサイクルフック設定 |
| `disableAllHooks` | 全フック無効化 |
| `allowManagedHooksOnly` | Managed フックのみ許可（Managed設定のみ） |
| `allowedHttpHookUrls` | HTTP フック許可URL |
| `httpHookAllowedEnvVars` | HTTP フック許可環境変数 |
| `env` | 環境変数設定 |
| `model` | デフォルトモデル上書き |
| `availableModels` | 選択可能モデル制限 |
| `modelOverrides` | モデルIDマッピング |
| `effortLevel` | エフォートレベル (`low` / `medium` / `high`) |
| `autoMode` | Auto Modeの分類器設定。`environment`, `allow`, `soft_deny` 配列で構成。共有プロジェクト設定からは読み込まれない。v2.1.118 で `"$defaults"` を配列に含めることで組み込みルールを置換せず追加可能 |
| `disableAutoMode` | `"disable"` で Auto Mode の有効化を阻止。`Shift+Tab` サイクルから除外し `--permission-mode auto` を拒否 |
| `useAutoModeDuringPlan` | プランモードで Auto Mode セマンティクスを使用（デフォルト: `true`）。共有プロジェクト設定からは読み込まれない |
| `defaultShell` | `!` コマンドのデフォルトシェル。`"bash"`（デフォルト）または `"powershell"`（Windows、`CLAUDE_CODE_USE_POWERSHELL_TOOL=1` 必要） |
| `otelHeadersHelper` | 動的OpenTelemetryヘッダー生成スクリプト。起動時と定期的に実行 |
| `apiKeyHelper` | カスタムAPIキー生成スクリプト |
| `autoMemoryEnabled` | オートメモリ有効/無効（デフォルト: true） |
| `autoMemoryDirectory` | オートメモリ保存先ディレクトリ |
| `cleanupPeriodDays` | セッション保持日数（デフォルト: 30）。`0` は全トランスクリプト削除+永続化無効。検証エラーで拒否されなくなった（v2.1.89で `0` の動作変更）。v2.1.117 で `~/.claude/tasks/`、`~/.claude/shell-snapshots/`、`~/.claude/backups/` もスイープ対象に拡張 |
| `showThinkingSummaries` | thinking summariesの表示（v2.1.89でデフォルト `false` に変更。`true` で復元） |
| `companyAnnouncements` | 起動時通知メッセージ |
| `forceLoginMethod` | ログイン方式強制（`claudeai` / `console`） |
| `forceLoginOrgUUID` | 組織UUID強制選択 |
| `enableAllProjectMcpServers` | プロジェクトMCPサーバー全自動承認 |
| `enabledMcpjsonServers` | 承認するMCPサーバーリスト |
| `disabledMcpjsonServers` | 拒否するMCPサーバーリスト |
| `allowManagedMcpServersOnly` | Managed MCPサーバーのみ許可 |
| `allowedMcpServers` | MCPサーバー許可リスト |
| `deniedMcpServers` | MCPサーバー拒否リスト |
| `statusLine` | カスタムステータスライン設定 |
| `fileSuggestion` | `@` ファイル補完カスタムコマンド |
| `outputStyle` | 出力スタイル設定 |
| `agent` | メインスレッドをサブエージェントとして実行 |
| `language` | 応答言語設定 |
| `sandbox.*` | サンドボックス設定 |
| `attribution` | git commit/PR 帰属表記設定（`commit`, `pr` キー） |
| `alwaysThinkingEnabled` | 拡張思考のデフォルト有効化 |
| `plansDirectory` | プランファイル保存先 |
| `spinnerVerbs` | スピナー動詞カスタマイズ |
| `autoUpdatesChannel` | 更新チャンネル (`stable` / `latest`) |
| `respectGitignore` | `@` ファイルピッカーで `.gitignore` を尊重（デフォルト: `true`） |
| `includeGitInstructions` | 組み込みcommit/PRワークフロー指示の有効化（デフォルト: `true`） |
| `includeCoAuthoredBy` | **非推奨**: `attribution` を使用 |
| `channelsEnabled` | （Managed のみ）Team/Enterprise ユーザーのチャンネル機能 |
| `allowManagedPermissionRulesOnly` | （Managed のみ）ユーザー/プロジェクトの権限ルール定義を禁止 |
| `strictKnownMarketplaces` | プラグインマーケットプレース許可リスト |
| `wslInheritsWindowsSettings` | （Managed のみ）WSL on Windows が Windows 側の managed settings を継承（v2.1.118） |
| `blockedMarketplaces` | （Managed のみ）マーケットプレースブロックリスト |
| `pluginTrustMessage` | （Managed のみ）プラグイン信頼警告のカスタムメッセージ |
| `awsAuthRefresh` | AWS認証リフレッシュカスタムスクリプト |
| `awsCredentialExport` | AWS認証情報JSON出力カスタムスクリプト |
| `voiceEnabled` | プッシュトゥトーク音声入力の有効化 |
| `spinnerTipsEnabled` | スピナーヒント表示（デフォルト: `true`） |
| `spinnerTipsOverride` | カスタムスピナーヒント（`excludeDefault`, `tips` キー） |
| `prefersReducedMotion` | UIアニメーション削減 |
| `fastModePerSessionOptIn` | セッションごとのFastモードオプトイン要求 |
| `teammateMode` | Agent Teams表示モード（`auto` / `in-process` / `tmux`） |
| `feedbackSurveyRate` | セッション品質アンケート確率（0-1） |
| `showClearContextOnPlanAccept` | プラン承認画面で「コンテキストクリア」オプション表示 |
| `worktree.symlinkDirectories` | ワークツリーシンボリックリンク対象 |
| `worktree.sparsePaths` | ワークツリースパースチェックアウト対象 |
| `sandbox.failIfUnavailable` | サンドボックス起動不可時にエラー終了（v2.1.83） |
| `sandbox.network.deniedDomains` | サンドボックスでブロックするドメイン一覧。`allowedDomains` と併用可（v2.1.113） |
| `disableDeepLinkRegistration` | `claude-cli://` プロトコルハンドラ登録の無効化（v2.1.83） |
| `allowedChannelPlugins` | （Managed のみ）チャンネルプラグイン許可リスト（v2.1.84） |
| `disableSkillShellExecution` | スキル・カスタムコマンド・プラグインコマンド内のインラインシェル実行（`` !`cmd` ``）を無効化（v2.1.91） |
| `forceRemoteSettingsRefresh` | （Managed のみ）リモート設定の取得をfail-closed化。取得失敗時にセッション起動をブロック（v2.1.92） |
| `prUrlTemplate` | フッターの PR バッジを github.com 以外のカスタムコードレビュー URL に向けるテンプレート（v2.1.119） |

### 2.4 `~/.claude.json` のグローバル設定

`settings.json` ではなく `~/.claude.json` に格納される設定:

| キー | 説明 |
|:--|:--|
| `autoConnectIde` | IDE自動接続 |
| `autoInstallIdeExtension` | IDE拡張自動インストール |
| `editorMode` | キーバインドモード (`normal` / `vim`) |
| `showTurnDuration` | ターン所要時間表示 |
| `terminalProgressBarEnabled` | ターミナルプログレスバー |

---

## 3. settings.local.json

`.claude/settings.local.json` はプロジェクト固有の個人設定ファイル。

- 作成時に Claude Code が自動で git ignore 設定を行う
- Project設定やUser設定を上書きできる
- チームに共有されない個人的なオーバーライドや実験的設定に使用

---

## 4. .claude/rules/

プロジェクトの指示を複数ファイルに分割して管理するディレクトリ。

### 4.1 基本構造

```
.claude/
├── CLAUDE.md
└── rules/
    ├── code-style.md
    ├── testing.md
    └── security.md
```

- `.md` ファイルは再帰的に検出される（サブディレクトリ対応）
- `paths` フロントマターなしのルールは起動時に `.claude/CLAUDE.md` と同じ優先度で読み込まれる

### 4.2 パススコープルール

YAML フロントマターの `paths` フィールドで特定ファイルにスコープを限定できる:

```markdown
---
paths:
  - "src/api/**/*.ts"
---

# API開発ルール
- 全APIエンドポイントに入力バリデーション必須
```

| パターン例 | マッチ対象 |
|:--|:--|
| `**/*.ts` | 全ディレクトリのTypeScriptファイル |
| `src/**/*` | `src/` 配下の全ファイル |
| `*.md` | プロジェクトルートのMarkdownファイル |
| `src/components/*.tsx` | 特定ディレクトリのReactコンポーネント |

ブレース展開もサポート: `"src/**/*.{ts,tsx}"`

### 4.3 ユーザーレベルルール

`~/.claude/rules/` に配置した個人ルールは全プロジェクトに適用される。プロジェクトルールより低い優先度。

### 4.4 シンボリックリンク

`.claude/rules/` はシンボリックリンクをサポートする:

```bash
ln -s ~/shared-claude-rules .claude/rules/shared
ln -s ~/company-standards/security.md .claude/rules/security.md
```

---

## 5. メモリシステム

### 5.1 CLAUDE.md（手動メモリ）

ユーザーが手動で記述・管理する指示ファイル。詳細は上記セクション1を参照。

### 5.2 オートメモリ

Claude が自動的にセッション間の学習を蓄積する仕組み。v2.1.59以降で利用可能。

#### 保存場所

```
~/.claude/projects/<project>/memory/
├── MEMORY.md          # エントリポイント（毎セッション先頭200行を読み込み）
├── debugging.md       # トピック別ノート
├── api-conventions.md
└── ...
```

`<project>` パスは git リポジトリから導出。同一リポジトリの全ワークツリー/サブディレクトリで共有。

#### 仕組み

- `MEMORY.md` の先頭200行が毎セッション開始時に読み込まれる
- 200行超のコンテンツは読み込まれない（Claude が自動的に詳細をトピックファイルへ分離）
- トピックファイル（`debugging.md` 等）は起動時に読み込まれず、必要時にオンデマンドで読む
- セッション中に Claude がメモリファイルを読み書きする

#### 有効化/無効化

- `/memory` コマンドでトグル
- 設定: `"autoMemoryEnabled": false`
- 環境変数: `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1`

#### カスタムディレクトリ

```json
{
  "autoMemoryDirectory": "~/my-custom-memory-dir"
}
```

`autoMemoryDirectory` は policy / local / user 設定から受け付ける。Project 設定（`.claude/settings.json`）からは受け付けない（セキュリティ上の理由）。

### 5.3 `/memory` コマンド

- 現在のセッションで読み込まれている CLAUDE.md とルールファイルを一覧表示
- オートメモリの有効/無効トグル
- オートメモリフォルダへのリンク
- ファイル選択でエディタを開く

### 5.4 サブエージェントメモリ

サブエージェントも `memory` フロントマターフィールドで独自のオートメモリを保持できる。スコープ: `user` / `project` / `local`。

---

## 6. 環境変数

主要な環境変数（`settings.json` の `env` キーまたはシェルで設定）:

| 変数名 | 用途 |
|:--|:--|
| `ANTHROPIC_API_KEY` | APIキー |
| `ANTHROPIC_MODEL` | モデル指定 |
| `CLAUDE_CODE_USE_BEDROCK` | Amazon Bedrock使用 |
| `CLAUDE_CODE_USE_VERTEX` | Google Vertex AI使用 |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | オートメモリ無効化 |
| `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD` | `--add-dir` からCLAUDE.md読み込み |
| `CLAUDE_CODE_NEW_INIT` | `/init` の新しいインタラクティブフロー有効化 |
| `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS` | バックグラウンドタスク無効化 |
| `CLAUDE_CODE_DISABLE_GIT_INSTRUCTIONS` | git指示無効化 |
| `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` | 自動コンパクション閾値（%） |
| `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS` | SessionEndフックタイムアウト |
| `MCP_TIMEOUT` | MCPサーバー起動タイムアウト（ms） |
| `MAX_MCP_OUTPUT_TOKENS` | MCPツール出力トークン上限 |
| `SLASH_COMMAND_TOOL_CHAR_BUDGET` | スキル説明の文字数バジェット |
| `CLAUDE_CODE_REMOTE` | Webリモート環境で `"true"` |
| `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` | `1` でサブプロセス環境から認証情報を除去（v2.1.83） |
| `CLAUDE_CODE_DISABLE_NONSTREAMING_FALLBACK` | 非ストリーミングフォールバック無効化（v2.1.83） |
| `CLAUDE_STREAM_IDLE_TIMEOUT_MS` | ストリーミングアイドルウォッチドッグ閾値（デフォルト90秒）（v2.1.84） |
| `ANTHROPIC_DEFAULT_{OPUS,SONNET,HAIKU}_MODEL_SUPPORTS` | ピンモデルのeffort/thinking検出オーバーライド（v2.1.84） |
| `CLAUDE_CODE_MCP_SERVER_NAME` | MCP `headersHelper` スクリプトに渡されるサーバー名（v2.1.85） |
| `CLAUDE_CODE_MCP_SERVER_URL` | MCP `headersHelper` スクリプトに渡されるサーバーURL（v2.1.85） |
| `CLAUDE_CODE_NO_FLICKER` | `1` でフリッカーフリーのalt-screen描画有効化（リサーチプレビュー）（v2.1.89） |
| `MCP_CONNECTION_NONBLOCKING` | `true` で `-p` モードのMCP接続待機スキップ。`--mcp-config` サーバー接続は5秒上限（v2.1.89） |
| `CLAUDE_CODE_PLUGIN_KEEP_MARKETPLACE_ON_FAILURE` | `1` で `git pull` 失敗時にマーケットプレースキャッシュを保持。オフライン/エアギャップ環境向け（v2.1.90） |
| `CLAUDE_CODE_DISABLE_FAST_MODE` | `1` でFastモードを完全無効化（v2.1.92） |
| `CLAUDE_CODE_PERFORCE_MODE` | Perforce VCS 連携モード（v2.1.98） |
| `ENABLE_PROMPT_CACHING_1H` | `1` でプロンプトキャッシュ TTL を 1 時間化（v2.1.108） |
| `CLAUDE_REMOTE_CONTROL_SESSION_NAME_PREFIX` | Remote Controlセッション名の自動生成プレフィックス（デフォルト: ホスト名）（v2.1.92） |
| `CLAUDE_CODE_FORK_SUBAGENT` | `1` で外部ビルド（サードパーティ）でもフォークサブエージェントを有効化（v2.1.117） |
| `OTEL_LOG_TOOL_DETAILS` | `1` で OpenTelemetry のカスタム/MCP コマンド名の redact を解除（v2.1.117） |
| `DISABLE_UPDATES` | 手動 `claude update` 含む全更新パスをブロック（`DISABLE_AUTOUPDATER` より厳格）（v2.1.118） |
| `CLAUDE_CODE_HIDE_CWD` | 起動ロゴでの作業ディレクトリ表示を隠す（v2.1.119） |

完全な環境変数リファレンス: https://code.claude.com/docs/en/env-vars

---

## 参考リンク

- 設定: https://code.claude.com/docs/en/settings
- メモリ: https://code.claude.com/docs/en/memory
- 環境変数: https://code.claude.com/docs/en/env-vars
- 権限: https://code.claude.com/docs/en/permissions
- サンドボックス: https://code.claude.com/docs/en/sandboxing
