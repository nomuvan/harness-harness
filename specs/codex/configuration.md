# OpenAI Codex CLI 設定仕様

最終更新: 2026-03-23（巡回更新）

---

## 1. config.toml

Codex CLI の設定は TOML 形式で管理される。複数レベルの設定ファイルがマージされ、より近いスコープが優先される。

### 1.1 設定ファイルの配置場所

| レベル | パス | 用途 |
|--------|------|------|
| システム | `/etc/codex/config.toml` | 全ユーザー共通（任意） |
| ユーザー | `~/.codex/config.toml` | 個人のデフォルト設定 |
| プロジェクト | `.codex/config.toml`（リポジトリルートから CWD まで複数可） | プロジェクト固有の設定（信頼済みプロジェクトのみ読み込み） |

### 1.2 設定の優先順位（高い順）

1. CLI フラグ / `--config` (`-c`) による上書き
2. プロファイル値（`--profile <name>`）
3. プロジェクト設定（CWD に最も近いファイルが優先）
4. ユーザー設定（`~/.codex/config.toml`）
5. システム設定（`/etc/codex/config.toml`）
6. ビルトインデフォルト

### 1.3 主要キー一覧

#### コア設定

| キー | 型 | デフォルト | 説明 |
|------|------|-----------|------|
| `model` | string | `"o4-mini"` | 使用する AI モデル |
| `model_provider` | string | `"openai"` | モデルプロバイダー ID |
| `approval_policy` | string | `"on-request"` | 承認ポリシー（後述） |
| `sandbox_mode` | string | `"workspace-write"` | サンドボックスモード（後述） |
| `personality` | string | `"friendly"` | 応答スタイル（`none` / `friendly` / `pragmatic`） |
| `service_tier` | string | - | パフォーマンス層（`flex` / `fast`） |
| `web_search` | string | `"cached"` | Web 検索動作（`disabled` / `cached` / `live`） |
| `model_reasoning_effort` | string | `"high"` | 推論レベル（`minimal` 〜 `xhigh`） |
| `model_reasoning_summary` | string | `"auto"` | 推論サマリー（`auto` / `concise` / `detailed` / `none`） |
| `log_dir` | string | - | ログ出力先ディレクトリ |
| `model_context_window` | integer | - | 利用可能なコンテキストトークン数 |
| `forced_login_method` | string | - | 認証方式の制限（ChatGPT / API） |
| `forced_chatgpt_workspace_id` | string | - | 特定ワークスペースへのログイン制限 |
| `cli_auth_credentials_store` | string | - | 認証情報ストア（`file` / OS keychain） |
| `default_permissions` | string | - | デフォルト権限プロファイル名 |
| `file_opener` | string | - | citation用URIスキーム（`vscode`, `cursor`, `windsurf` 等） |
| `check_for_update_on_startup` | bool | `true` | 起動時アップデートチェック |
| `allow_login_shell` | bool | `true` | ログインシェルセマンティクス許可 |

#### プロジェクトドキュメント設定

| キー | 型 | デフォルト | 説明 |
|------|------|-----------|------|
| `project_doc_max_bytes` | integer | `32768` | AGENTS.md の最大読み込みサイズ（バイト） |
| `project_doc_fallback_filenames` | array | - | フォールバックファイル名（例: `["TEAM_GUIDE.md", ".agents.md"]`） |
| `project_root_markers` | array | `[".git", ".hg"]` | プロジェクトルート検出マーカー |

#### 履歴設定

```toml
[history]
persistence = "default"   # "default" / "none"
max_bytes = 1048576       # 最大サイズ（バイト）、超過時は自動コンパクション
```

#### 機能フラグ

```toml
[features]
shell_snapshot = true                    # コマンド実行の高速化
smart_approvals = false                  # ガーディアンレビュアー経由の承認
multi_agent = true                       # サブエージェント機能
unified_exec = true                      # PTY実行（stable、Windows除く）
undo = false                             # Undo 機能
web_search = true                        # Web 検索
skill_mcp_dependency_install = true      # スキル依存MCPサーバーの自動インストール（stable）
codex_hooks = false                      # Hooks システム（実験的、デフォルト無効）
```

#### Agent 管理

```toml
[agents]
max_threads = 6              # 最大同時エージェントスレッド数
max_depth = 3                # エージェントネスト最大深度

[agents.code-reviewer]
description = "コードレビュー担当"   # ロールガイダンス
```

#### UI 設定

```toml
[tui]
theme = "monokai"            # シンタックスハイライトテーマ
animations = true            # ターミナルアニメーション
notifications = true         # 通知の有効化
status_line = ["model", "context", "git"]  # フッターステータスライン項目
```

#### 承認粒度（Granular Approval）

```toml
[approval_policy]
granular.sandbox_approval = true        # サンドボックスエスカレーション表示
granular.rules = true                   # execpolicy プロンプトトリガー承認
granular.mcp_elicitations = true        # MCP elicitation プロンプト表示
granular.request_permissions = true     # request_permissions ツール承認
granular.skill_approval = true          # スキルスクリプト承認
```

#### Windows 固有設定

```toml
[windows]
sandbox = "elevated"       # "elevated"（推奨、管理者権限必要） / "unelevated"
```

> 公式ドキュメント: [Config Basics](https://developers.openai.com/codex/config-basic) / [Config Reference](https://developers.openai.com/codex/config-reference) / [Sample Config](https://developers.openai.com/codex/config-sample)

---

## 2. AGENTS.md

Codex CLI に対するカスタム指示を Markdown 形式で記述するファイル。

### 2.1 3レベル階層と検索順序

1. **グローバルスコープ**（`~/.codex/`）
   - `AGENTS.override.md` → `AGENTS.md` の順に検索
2. **プロジェクトスコープ**（Git ルート → CWD まで各ディレクトリ）
   - 各ディレクトリで `AGENTS.override.md` → `AGENTS.md` → フォールバックファイル名の順に検索
3. **マージ順序**: ルートから CWD に向かって連結。より近いファイルが先の指示を上書き

### 2.2 override の動作

- 同一ディレクトリでは `AGENTS.override.md` が `AGENTS.md` より優先
- ネストされた override はより広いスコープのルールを置換
- グローバル override はグローバルベースファイルを完全に抑制
- `CODEX_HOME` 環境変数でホームディレクトリをリダイレクト可能

### 2.3 サイズ制限

- **デフォルト最大サイズ**: 32 KiB（`project_doc_max_bytes` で変更可能）
- 上限に達した時点でファイルの追加読み込みを停止
- **1ディレクトリにつき最大1ファイル**
- 空ファイルは自動スキップ

### 2.4 無効化

```bash
codex --no-project-doc "タスク"
# または
CODEX_DISABLE_PROJECT_DOC=1 codex "タスク"
```

### 2.5 確認コマンド

```bash
# 現在読み込まれている指示を確認
codex --ask-for-approval never "現在の指示をまとめてください"

# サブディレクトリで有効なファイルを確認
codex --cd subdir --ask-for-approval never "有効な指示ファイルを表示"
```

> 公式ドキュメント: [AGENTS.md Guide](https://developers.openai.com/codex/guides/agents-md)

---

## 3. プロファイル

名前付きの設定セットを定義し、ワークフローに応じて切り替え可能。

### 3.1 定義方法

```toml
# ~/.codex/config.toml

# デフォルトプロファイルの指定（任意）
profile = "default"

[profiles.default]
model = "o4-mini"
approval_policy = "on-request"

[profiles.fast]
model = "gpt-5.4"
service_tier = "fast"
approval_policy = "on-request"

[profiles.autonomous]
model = "gpt-5.4"
approval_policy = "never"
sandbox_mode = "workspace-write"
```

### 3.2 使用方法

```bash
codex --profile fast "コードをリファクタリングして"
codex -p autonomous "テストを全部実行して修正して"
```

---

## 4. 環境変数

### 4.1 認証関連

| 環境変数 | 説明 |
|----------|------|
| `OPENAI_API_KEY` | OpenAI API キー |
| `AZURE_OPENAI_API_KEY` | Azure OpenAI API キー |
| `AZURE_OPENAI_API_VERSION` | Azure API バージョン |
| `OPENROUTER_API_KEY` | OpenRouter API キー |
| `GEMINI_API_KEY` | Gemini API キー |
| `MISTRAL_API_KEY` | Mistral API キー |
| `DEEPSEEK_API_KEY` | DeepSeek API キー |
| `XAI_API_KEY` | xAI API キー |
| `GROQ_API_KEY` | Groq API キー |

### 4.2 動作制御

| 環境変数 | 説明 |
|----------|------|
| `CODEX_HOME` | Codex ホームディレクトリの変更（デフォルト: `~/.codex`） |
| `CODEX_DISABLE_PROJECT_DOC` | `1` に設定すると AGENTS.md を無効化 |
| `CODEX_QUIET_MODE` | `1` に設定するとパイプライン向けサイレントモード |
| `DEBUG` | `true` で詳細ログを有効化 |

### 4.3 シェル環境ポリシー

サブプロセスに渡す環境変数を制御する。

```toml
[shell_environment_policy]
inherit = "core"             # "none" / "core"
include_only = ["PATH", "HOME", "LANG"]
exclude = ["SECRET_*"]       # glob パターン対応
set = { NODE_ENV = "development" }
```

---

## 5. サンドボックスと承認ポリシー

Codex CLI は **OS レベルのサンドボックス** と **承認ポリシー** の2層で安全性を確保する。

### 5.1 サンドボックスモード (`sandbox_mode`)

| モード | ファイルシステム | ネットワーク |
|--------|-----------------|-------------|
| `read-only` | 読み取りのみ | 無効 |
| `workspace-write` | CWD + `/tmp` に書き込み可。`.git`, `.agents/`, `.codex/` は読み取り専用のまま保護 | デフォルト無効 |
| `danger-full-access` | 制限なし | 制限なし |

OS ごとの実装:
- **macOS**: Apple Seatbelt (`sandbox-exec`)
- **Linux**: bubblewrap + seccomp
- **Windows**: WSL またはネイティブサンドボックス

ネットワークアクセスを選択的に有効化:

```toml
[sandbox_workspace_write]
network_access = true
```

### 5.2 承認ポリシー (`approval_policy`)

| ポリシー | 動作 |
|----------|------|
| `untrusted` | 安全な操作は自動実行。状態変更コマンドには承認が必要 |
| `on-request` | ファイル書き込みとシェルコマンドに承認が必要（デフォルト） |
| `never` | 承認プロンプトなし（危険） |

CLI フラグでの指定:

```bash
codex --ask-for-approval untrusted "タスク"
codex -a never "タスク"
codex --full-auto "タスク"                # on-request + 低摩擦モード
codex --yolo "タスク"                     # 承認・サンドボックス完全バイパス（非推奨）
```

### 5.3 権限プロファイル

名前付きのファイルシステム・ネットワークアクセスプロファイルを定義可能。

```toml
default_permissions = "restricted"

[permissions.restricted]
# ファイルシステムとネットワークのアクセスルールを定義
# deny-read グロブで秘密情報を含むパスを読み取り禁止に指定可能（0.122.0+）
# 管理対象 deny-read は強制要件として設定可能
```

隔離 `codex exec` 実行時はユーザー設定の permission プロファイルをバイパスし、ジョブ固有のサンドボックス境界のみ適用される（0.122.0+）。

0.125.0 以降、permission プロファイルは TUI セッション、ユーザーターン、MCP サンドボックス状態、シェルエスカレーション、app-server API を横断して永続化される（プロセスや接続をまたいで設定が保持される）。

### 5.4 OpenTelemetry 監視（オプトイン）

```toml
[otel]
environment = "staging"
exporter = "otlp-http"       # "otlp-http" / "otlp-grpc" / "none"
log_user_prompt = false       # プロンプトのログ記録（デフォルト無効）
```

追跡対象イベント: API リクエスト、ツール呼び出し、ユーザープロンプト（リダクト済み）、承認操作

> 公式ドキュメント: [Agent Approvals & Security](https://developers.openai.com/codex/agent-approvals-security) / [Config Advanced](https://developers.openai.com/codex/config-advanced)

---

## 6. Skills

Codex CLI は Skills システムをサポートする（stable）。Claude Code の Skills と同じ SKILL.md フォーマットを採用している。

### 6.1 Skills の配置場所

> **重要**: Skills のパスが `.codex/skills/` から `.agents/skills/` に変更された（2026-03時点）。

| レベル | パス | 用途 |
|--------|------|------|
| プロジェクト (CWD) | `$CWD/.agents/skills/` | ワーキングフォルダのチームスキル |
| プロジェクト (親) | `$CWD/../.agents/skills/` | リポジトリ内ネストフォルダスキル |
| プロジェクト (ルート) | `$REPO_ROOT/.agents/skills/` | リポジトリルートの組織スキル |
| ユーザー | `$HOME/.agents/skills/` | 全リポジトリ横断の個人スキル |
| 管理者 | `/etc/codex/skills/` | マシン/コンテナ用システムスキル |
| システム | バンドル | デフォルトOpenAIスキル |

CWD からリポジトリルートまで走査。同名スキルは両方表示（マージなし）。シンボリックリンク対応。

### 6.2 SKILL.md フォーマット

Claude Code と同一の SKILL.md フロントマター形式を使用する。YAML フロントマターでメタデータを定義し、本文に指示を記述する。

### 6.3 バンドルスキル

Codex CLI には以下のスキルが組み込まれている:

| スキル名 | 説明 |
|----------|------|
| `skill-creator` | 新しいスキルの作成を支援 |
| `skill-installer` | 外部スキルのインストール |
| `openai-docs` | OpenAI ドキュメント参照 |

### 6.4 スキルの起動方法

- `/skills` コマンドでスキル一覧を表示・選択
- `$` メンションで直接スキルを参照
- 暗黙マッチング（プロンプト内容に基づき自動選択）

### 6.5 `agents/openai.yaml` メタデータ（任意）

スキルディレクトリに `agents/openai.yaml` を配置して UI 表示やポリシーを設定可能:

```yaml
interface:
  display_name: "表示名"
  short_description: "ユーザー向け説明"
  icon_small: "./assets/small-logo.svg"
  icon_large: "./assets/large-logo.png"
  brand_color: "#3B82F6"
  default_prompt: "デフォルトプロンプト"

policy:
  allow_implicit_invocation: false  # false で明示的 $skill 呼び出しのみに制限

dependencies:
  tools:
    - type: "mcp"
      value: "openaiDeveloperDocs"
      description: "OpenAI Docs MCP server"
      transport: "streamable_http"
      url: "https://developers.openai.com/mcp"
```

### 6.6 スキルインストーラー

```
$skill-installer linear
```

外部リポジトリからスキルをダウンロード。自動検出されるが、反映されない場合は再起動。

### 6.7 スキルの有効化/無効化

```toml
[[skills.config]]
path = "/path/to/skill/SKILL.md"
enabled = false
```

### 6.8 関連する機能フラグ

```toml
[features]
skill_mcp_dependency_install = true   # stable — スキルが依存するMCPサーバーの自動インストール
```

---

## 7. Hooks

Codex CLI の Hooks は **0.124.0 で正式化（stable）** された。`config.toml` にインラインで設定可能、管理対象の `requirements.toml` でポリシー配布もできる。Claude Code の Hooks と比べると、対応イベントとハンドラ種別が限定されている点は引き続き同じ。

### 7.1 有効化

0.124.0 以降はデフォルトで有効。旧バージョン（0.123.0 以前）では以下のフィーチャーフラグが必要:

```bash
# 0.123.0 以前のみ必要
codex --enable codex_hooks
# または
[features]
codex_hooks = true
```

### 7.2 設定形式

`config.toml` にインラインで `[[hooks]]` テーブル配列を定義する。管理対象では `requirements.toml` でポリシー配布可:

```toml
[[hooks]]
event = "SessionStart"
command = "echo 'セッション開始'"

[[hooks]]
event = "UserPromptSubmit"
command = "python3 scripts/validate-prompt.py"

[[hooks]]
event = "Stop"
command = "python3 scripts/postflight.py"
```

### 7.3 対応イベント

| イベント | 説明 |
|----------|------|
| `SessionStart` | セッション開始時に実行 |
| `Stop` | セッション終了時に実行 |
| `UserPromptSubmit` | ユーザーのプロンプト送信時に実行 |

> **比較**: Claude Code は 17 以上のイベント（`PreToolUse`, `PostToolUse`, `Notification` 等）をサポート。Codex は現時点で 3 イベントのみ。

### 7.4 ハンドラ種別

| ハンドラ | Codex CLI | Claude Code |
|----------|-----------|-------------|
| Command | サポート | サポート |
| HTTP | **非サポート** | サポート |
| Prompt | **非サポート** | サポート |
| Agent | **非サポート** | サポート |

Codex の Hooks は `command` ハンドラのみをサポートする。

### 7.5 終了コード

| 終了コード | 動作 |
|------------|------|
| `0` | 成功。処理を続行 |
| `2` | ブロック（`UserPromptSubmit` のみ）。プロンプト送信をキャンセル |
| その他 | エラーとして扱われる |
