# OpenAI Codex CLI 設定仕様

最終更新: 2026-03-23

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
shell_snapshot = true      # コマンド実行の高速化
smart_approvals = false    # ガーディアンレビュアー経由の承認
multi_agent = true         # サブエージェント機能
web_search = true          # Web 検索
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
```

### 5.4 OpenTelemetry 監視（オプトイン）

```toml
[otel]
environment = "staging"
exporter = "otlp-http"       # "otlp-http" / "otlp-grpc" / "none"
log_user_prompt = false       # プロンプトのログ記録（デフォルト無効）
```

追跡対象イベント: API リクエスト、ツール呼び出し、ユーザープロンプト（リダクト済み）、承認操作

> 公式ドキュメント: [Agent Approvals & Security](https://developers.openai.com/codex/agent-approvals-security) / [Config Advanced](https://developers.openai.com/codex/config-advanced)
