# Codex CLI → Claude Code 変換ルール

最終更新: 2026-03-24

本ドキュメントは Codex CLI の各機能が Claude Code でどのように対応するかを定義する。

---

## 1. 設定ファイル

| Codex CLI | Claude Code | 備考 |
|:--|:--|:--|
| `config.toml` | `settings.json` | TOML → JSON 形式変換が必要 |
| `~/.codex/config.toml` | `~/.claude/settings.json` | ユーザーレベル設定 |
| `.codex/config.toml` | `.claude/settings.json` | プロジェクトレベル設定 |
| `/etc/codex/config.toml` | Managed Policy settings | システムレベル設定 |
| `AGENTS.md` | `CLAUDE.md` | 指示ファイル。名称が異なる |
| `~/.codex/AGENTS.md` | `~/.claude/CLAUDE.md` | グローバル指示 |
| `AGENTS.override.md` | **対応なし** | 代替: CLAUDE.md の階層構造で優先度を制御。より具体的なスコープの CLAUDE.md が優先される |
| `project_doc_fallback_filenames` | **対応なし** | Claude は `CLAUDE.md` 固定。フォールバック名の設定なし |

### 1.1 変換ガイド: AGENTS.md → CLAUDE.md

- ファイル名を `AGENTS.md` から `CLAUDE.md` に変更する
- Claude は `@path/to/file` インポート構文をサポートするため、大きな AGENTS.md は分割して `@` で参照可能
- Claude の `.claude/rules/` ディレクトリを活用し、トピック別にルールファイルを分離できる
- サイズ制限: Codex は 32 KiB、Claude は 200行目安（ただしハード制限ではない）

### 1.2 変換ガイド: config.toml → settings.json

```
# Codex CLI (TOML)
model = "o4-mini"
approval_policy = "on-request"
model_reasoning_effort = "high"

# Claude Code (JSON)
{
  "model": "sonnet",
  "permissions.defaultMode": "default",
  "effortLevel": "high"
}
```

### 1.3 AGENTS.override.md の移行

Codex の `AGENTS.override.md` は同一ディレクトリの `AGENTS.md` を完全に上書きする機能。Claude Code には直接対応がないため:

1. override の内容を CLAUDE.md に統合する
2. `.claude/rules/` のパススコープルールで条件付き上書きを実現する
3. `.claude/settings.local.json` で個人レベルの上書きを行う

---

## 2. プロファイル

| Codex CLI | Claude Code | 備考 |
|:--|:--|:--|
| `[profiles.*]` セクション | **直接対応なし** | 代替: 複数の `settings.local.json` を切り替えるスクリプト、または CLI フラグで個別指定 |
| `--profile fast` | `--model <model>` + 個別フラグ | Claude は個別パラメータをフラグで指定 |
| `profile = "default"` | **対応なし** | Claude はデフォルトプロファイル概念なし |

### 2.1 プロファイルの代替策

Claude Code にはプロファイル機能がないため、以下で代替する:

```bash
# シェルエイリアスで疑似プロファイルを実現
alias claude-fast="ANTHROPIC_MODEL=haiku claude"
alias claude-careful="claude"  # デフォルト設定を使用

# または settings.local.json を切り替えるスクリプト
#!/bin/bash
cp .claude/profiles/$1.json .claude/settings.local.json
echo "プロファイル '$1' を有効化しました"
```

---

## 3. 承認ポリシー・権限

| Codex CLI | Claude Code | 備考 |
|:--|:--|:--|
| `approval_policy = "on-request"` | `permissions.defaultMode` + `permissions.ask` | デフォルトの確認付き実行 |
| `approval_policy = "never"` | `bypassPermissions` モード | 両方とも非推奨 |
| `approval_policy = "untrusted"` | `permissions.allow`（安全なもののみ） + `permissions.deny`（危険なもの） | Claude の方が細粒度で制御可能 |
| `--full-auto` | **対応なし** | 代替: `permissions.allow` で必要なツールを個別許可 |
| `--yolo` | `bypassPermissions` | 両方とも全バイパス（非推奨） |
| `/permissions` | `/permissions` | 同等 |

### 3.1 承認ポリシー詳細変換

| Codex CLI | Claude Code 設定 |
|:--|:--|
| `approval_policy = "untrusted"` | `"permissions.allow": ["Read", "Grep", "Glob"]` で安全なツールのみ許可 |
| `approval_policy = "on-request"` | デフォルト動作。必要に応じて `"permissions.allow": ["Bash(npm test)"]` で個別許可 |
| `approval_policy = "never"` | `"permissions.allow": ["Bash(*)", "Edit(*)", "Write(*)"]` で全許可（非推奨） |

---

## 4. サンドボックス

| Codex CLI | Claude Code | 備考 |
|:--|:--|:--|
| `sandbox_mode = "read-only"` | `sandbox.*` 設定 | Claude もサンドボックスをサポート |
| `sandbox_mode = "workspace-write"` | デフォルト動作 | Claude はプロジェクトディレクトリへの書き込みをデフォルト許可 |
| `sandbox_mode = "danger-full-access"` | `/sandbox` でサンドボックス無効化 | 両方とも非推奨 |
| `[sandbox_workspace_write] network_access = true` | **対応なし** | Claude はサンドボックス内ネットワーク制御の細かい設定なし |
| macOS: Apple Seatbelt | macOS: Apple Seatbelt | 同じ OS 機構を使用 |
| Linux: bubblewrap + seccomp | Linux: 同様のサンドボックス | プラットフォーム依存 |

---

## 5. Skills

> **2026-03-24 追加**: Codex CLI が Skills を正式サポート（stable）。

| Codex CLI | Claude Code | 備考 |
|:--|:--|:--|
| Skills (`SKILL.md`) | Skills (`SKILL.md`) | **直接対応**。フロントマター形式は同一 |
| `.codex/skills/<name>/SKILL.md` | `.claude/skills/<name>/SKILL.md` | ディレクトリ構造が同一（`.codex/` → `.claude/`） |
| `~/.codex/skills/` | `~/.claude/skills/` | グローバルスキルも同一構造 |
| `/skills` コマンド | `/skills` コマンド | 同等 |
| `$` メンションでスキル参照 | `$` メンションでスキル参照 | 同等 |
| 暗黙マッチング | 暗黙マッチング | 同等 |
| バンドル: `skill-creator` | バンドル: `skill-creator` 相当 | 両方ともスキル作成を支援 |
| バンドル: `skill-installer` | バンドル: `skill-installer` 相当 | 両方ともスキルインストールを支援 |
| バンドル: `openai-docs` | **対応なし** | Codex 固有。代替: MCP 経由でドキュメント参照 |
| `skill_mcp_dependency_install` フラグ | デフォルト有効 | Claude はスキル依存 MCP の自動インストールがデフォルト |

### 5.1 Skills 移行ガイド

Codex と Claude の Skills は SKILL.md フォーマットが共通のため、移行は容易:

1. `.codex/skills/` を `.claude/skills/` にコピー
2. `$ARGUMENTS` 変数展開は Claude でもサポート
3. Claude は `allowed-tools`, `context: fork`, 動的コンテキスト注入 (`` !`command` ``) など追加機能あり

---

## 6. Hooks

> **2026-03-24 追加**: Codex CLI が Hooks を実験的サポート開始。

| Codex CLI | Claude Code | 備考 |
|:--|:--|:--|
| `[[hooks]]` (TOML) | `"hooks"` (JSON) | 設定形式が異なる（TOML テーブル配列 vs JSON） |
| `codex_hooks` フラグで有効化 | デフォルト有効 | Claude は Hooks がデフォルト利用可能 |
| `SessionStart` イベント | `SessionStart` イベント | **直接対応** |
| `Stop` イベント | `Stop` イベント | **直接対応** |
| `UserPromptSubmit` イベント | `UserPromptSubmit` イベント | **直接対応** |
| 3 イベントのみ | 17+ イベント | Claude は `PreToolUse`, `PostToolUse`, `Notification` 等を追加サポート |
| command ハンドラのみ | command / HTTP / Prompt / Agent | Claude の方がハンドラ種別が豊富 |
| 終了コード 2 でブロック | 終了コード 2 でブロック | 同等（`UserPromptSubmit` 等） |

### 6.1 Hooks 移行ガイド

Codex の Hooks は Claude に移行可能だが、設定形式の変換が必要:

```
# Codex CLI (config.toml)
[[hooks]]
event = "SessionStart"
command = "echo 'start'"

# Claude Code (settings.json)
{
  "hooks": {
    "SessionStart": [
      { "type": "command", "command": "echo 'start'" }
    ]
  }
}
```

Claude では以下の追加機能が利用可能:
- HTTP ハンドラで外部サービスとの連携
- Prompt ハンドラで LLM による判断
- Agent ハンドラでサブエージェント起動
- `PreToolUse` / `PostToolUse` でツール実行の前後処理

---

## 7. コマンド（Slash Commands）

| Codex CLI | Claude Code | 備考 |
|:--|:--|:--|
| `/model` | `/model` | 同等 |
| `/plan` | `/plan` | 同等 |
| `/fast` | **対応なし** | Claude に Fast モード切替なし。`/effort` で推論レベルを調整 |
| `/personality` | **対応なし** | 代替: CLAUDE.md に応答スタイル指示を記述 |
| `/diff` | `/diff` | 同等 |
| `/review` | `/security-review` | Claude はセキュリティ特化。汎用レビューは手動指示 |
| `/copy` | **対応なし** | 代替: `/export` でテキスト出力 |
| `/mention <path>` | `@file` 構文 | Claude は `@` でファイル参照 |
| `/permissions` | `/permissions` | 同等 |
| `/sandbox-add-read-dir` | **対応なし** | Claude に動的サンドボックスディレクトリ追加なし |
| `/resume` | `/resume` | 同等 |
| `/fork` | `/branch` (`/fork`) | 同等 |
| `/new` | `/clear` (`/new`) | 同等 |
| `/clear` | `/clear` | 同等 |
| `/compact` | `/compact` | 同等 |
| `/status` | `/status`, `/cost`, `/context` | Claude は情報を複数コマンドに分散 |
| `/debug-config` | `/config` | Claude は設定表示、Codex は診断出力 |
| `/ps` | **対応なし** | 代替: サブエージェントは `/agents` で管理 |
| `/mcp` | `/mcp` | 同等 |
| `/statusline` | **対応なし** | Claude に動的ステータスライン設定なし（`statusLine` 設定で静的に設定可能） |
| `/agent` | `/agents` | 同等（名称が微妙に異なる） |
| `/apps` | **対応なし** | Claude にアプリ/コネクタ概念なし |
| `/init` | `/init` | Codex は AGENTS.md 生成、Claude は CLAUDE.md 生成 |
| `/feedback` | **対応なし** | Claude にフィードバック送信機能なし |
| `/experimental` | **対応なし** | Claude は機能フラグを設定ファイルで管理 |

---

## 8. 非対話モード（codex exec）

| Codex CLI | Claude Code | 備考 |
|:--|:--|:--|
| `codex exec "タスク"` | `claude -p "タスク"` | 非対話実行 |
| `codex exec --json` | `claude -p --output-format json` | JSON 出力 |
| `codex exec --ephemeral` | **対応なし** | Claude はセッションを常に保存 |
| `codex exec --output-last-message result.md` | `claude -p "..." > result.md` | 出力のファイル保存 |
| `codex exec --output-schema <path>` | **対応なし** | Claude に出力スキーマ検証なし |
| `codex exec --skip-git-repo-check` | **対応なし** | Claude は Git リポジトリ外でも動作 |
| `echo "..." \| codex exec -` | `echo "..." \| claude -p -` | stdin からのプロンプト |
| `codex exec resume --last` | `claude --resume` | セッション再開の非対話実行 |

---

## 9. MCP

| Codex CLI | Claude Code | 備考 |
|:--|:--|:--|
| `[mcp_servers.*]` (TOML) | `.mcp.json` または `~/.claude.json` (JSON) | 形式が異なる |
| `codex mcp add` | `claude mcp add` | ほぼ同等 |
| `codex mcp add --url <URL>` | `claude mcp add --transport http <name> <URL>` | HTTP サーバー追加の構文が異なる |
| `bearer_token_env_var` | `--header "Authorization: Bearer ..."` | 認証方法が異なる |
| `enabled_tools` / `disabled_tools` | **対応なし** | Claude はサーバー単位の有効/無効のみ |
| `startup_timeout_sec` | `MCP_TIMEOUT` 環境変数 | Claude は環境変数で制御 |
| `tool_timeout_sec` | **対応なし** | Claude にツール個別タイムアウトなし |
| `required = true` | **対応なし** | Claude にサーバー必須指定なし |
| `codex mcp-server` | **対応なし** | Claude 自体を MCP サーバーにする機能なし |
| `codex mcp login` | `/mcp` で OAuth フロー | Claude は対話 UI 経由 |
| グローバル + プロジェクト | Local + Project + User + Managed | Claude の方がスコープが多い |

### 7.1 MCP 設定変換例

```
# Codex CLI (config.toml)
[mcp_servers.github]
url = "https://api.githubcopilot.com/mcp/"
bearer_token_env_var = "GITHUB_TOKEN"

[mcp_servers.playwright]
command = "npx"
args = ["-y", "@playwright/mcp@latest"]

# Claude Code (.mcp.json)
{
  "mcpServers": {
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp/",
      "headers": {
        "Authorization": "Bearer ${GITHUB_TOKEN}"
      }
    },
    "playwright": {
      "command": "npx",
      "args": ["-y", "@playwright/mcp@latest"]
    }
  }
}
```

---

## 10. セッション管理

| Codex CLI | Claude Code | 備考 |
|:--|:--|:--|
| `codex resume` | `claude --resume` | セッション再開 |
| `codex resume --last` | `claude --resume` で最新を選択 | 同等 |
| `codex resume --all` | `/resume` で全セッション表示 | 同等 |
| `codex fork` | `/branch` | セッション分岐 |
| `codex fork --last` | `/branch` | 同等 |
| `[history] persistence = "none"` | `cleanupPeriodDays` | Claude は保持期間で制御（完全無効化は設定なし） |
| `[history] max_bytes` | `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` | 自動コンパクションの閾値制御 |

---

## 11. 機能フラグ

| Codex CLI | Claude Code | 備考 |
|:--|:--|:--|
| `[features] shell_snapshot = true` | **対応なし** | Claude にシェルスナップショット概念なし |
| `[features] smart_approvals = false` | **対応なし** | Claude にガーディアンレビュアー概念なし |
| `[features] multi_agent = true` | デフォルト有効 | Claude はサブエージェントがデフォルト利用可能 |
| `[features] web_search = true` | **対応なし** | Claude Code に Web 検索機能なし（MCP で代替可能） |
| `[features] codex_hooks = true` | デフォルト有効 | Claude は Hooks がデフォルト利用可能。有効化フラグ不要 |
| `[features] skill_mcp_dependency_install = true` | デフォルト有効 | Claude はスキル依存 MCP の自動インストールがデフォルト |
| `codex features list` | **対応なし** | Claude に機能フラグ管理コマンドなし |
| `codex features enable/disable` | 設定ファイルで管理 | Claude は `settings.json` で直接設定 |

---

## 12. Codex 固有機能の移行

以下は Codex 固有の機能で、Claude Code に直接対応がないもの:

### 12.1 Codex Cloud

`codex cloud` はリモート環境でタスクを実行する機能。Claude Code には対応なし。

代替策:
- GitHub Actions と連携し、CI/CD パイプラインで `claude -p` を実行
- リモートサーバーに Claude Code をインストールして SSH 経由で利用

### 12.2 OpenTelemetry 監視

Codex の `[otel]` セクションで設定可能な監視機能。Claude Code には対応なし。

代替策:
- Claude Code の Hooks (`PostToolUse`, `Stop` 等) で外部監視システムに通知を送信
- HTTP ハンドラを使って OpenTelemetry エンドポイントにイベントを送信

### 12.3 シェル環境ポリシー

Codex の `[shell_environment_policy]` はサブプロセスの環境変数を制御する。Claude Code には対応なし。

代替策:
- `settings.json` の `env` キーで環境変数を設定
- Hooks の `SessionStart` でシェル環境をカスタマイズ

### 12.4 応答スタイル（personality）

Codex の `personality` 設定（`none`/`friendly`/`pragmatic`）。Claude Code には対応なし。

代替策:
- CLAUDE.md に応答スタイルの指示を記述（例: 「簡潔で実用的な応答を心がけること」）
- `settings.json` の `outputStyle` で出力スタイルを設定

### 12.5 codex mcp-server

Codex 自体を MCP サーバーとして起動する機能。Claude Code には対応なし。

代替策:
- Claude Code の API を直接呼び出す
- カスタム MCP サーバーで Claude API をラップ

---

## 13. 環境変数

| Codex CLI | Claude Code | 備考 |
|:--|:--|:--|
| `OPENAI_API_KEY` | `ANTHROPIC_API_KEY` | プロバイダーが異なる |
| `AZURE_OPENAI_API_KEY` | `CLAUDE_CODE_USE_BEDROCK` / `CLAUDE_CODE_USE_VERTEX` | クラウドプロバイダー経由 |
| `CODEX_HOME` | `~/.claude/` (固定) | Claude はホームディレクトリ変更不可 |
| `CODEX_DISABLE_PROJECT_DOC` | **対応なし** | Claude に CLAUDE.md 無効化の環境変数なし。`claudeMdExcludes` で除外 |
| `CODEX_QUIET_MODE` | `claude -p` | 非対話モードで静かに実行 |
| `DEBUG` | **対応なし** | Claude にデバッグモード環境変数なし。`/debug` スキルを使用 |
| `OPENROUTER_API_KEY` 等 | **対応なし** | Claude は Anthropic API / Bedrock / Vertex のみサポート |
