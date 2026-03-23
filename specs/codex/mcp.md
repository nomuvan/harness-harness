# OpenAI Codex CLI MCP（Model Context Protocol）仕様

最終更新: 2026-03-23

---

## 1. 概要

MCP（Model Context Protocol）は、外部ツールやサービスを Codex CLI に統合するためのプロトコル。MCP サーバーを登録することで、Codex エージェントがビルトインツール以外の機能にアクセスできるようになる。

設定は `config.toml` の `[mcp_servers]` セクションに記述し、CLI と IDE 拡張で共有される。

> 公式ドキュメント: [MCP](https://developers.openai.com/codex/mcp)

---

## 2. サポートされるトランスポート

### 2.1 STDIO（ローカルプロセス）

ローカルでプロセスを起動し、標準入出力で通信する方式。

```toml
[mcp_servers.context7]
command = "npx"
args = ["-y", "@upstash/context7-mcp"]

[mcp_servers.context7.env]
MY_ENV_VAR = "MY_ENV_VALUE"
```

### 2.2 Streamable HTTP（リモートアクセス）

HTTP エンドポイントに接続する方式。Bearer トークン認証や OAuth をサポート。

```toml
[mcp_servers.figma]
url = "https://mcp.figma.com/mcp"
bearer_token_env_var = "FIGMA_OAUTH_TOKEN"
http_headers = { "X-Figma-Region" = "us-east-1" }
```

---

## 3. サーバー登録

### 3.1 config.toml による登録

#### STDIO サーバー

```toml
[mcp_servers.<サーバー名>]
command = "コマンド名"
args = ["引数1", "引数2"]
# cwd = "/path/to/working/dir"    # 作業ディレクトリ（任意）

[mcp_servers.<サーバー名>.env]
API_KEY = "your-key"
```

#### HTTP サーバー

```toml
[mcp_servers.<サーバー名>]
url = "https://example.com/mcp"
bearer_token_env_var = "ENV_VAR_NAME"       # 環境変数からトークン取得

# 静的 HTTP ヘッダー
http_headers = { "X-Custom-Header" = "value" }

# 環境変数から取得する HTTP ヘッダー
env_http_headers = { "Authorization" = "AUTH_TOKEN_ENV" }
```

### 3.2 CLI コマンドによる登録

```bash
# STDIO サーバーの追加
codex mcp add my-server -- npx -y @example/mcp-server

# HTTP サーバーの追加
codex mcp add my-remote-server --url https://example.com/mcp
```

### 3.3 オプションパラメータ

| パラメータ | デフォルト | 説明 |
|-----------|-----------|------|
| `startup_timeout_sec` | `10` | サーバー起動タイムアウト（秒） |
| `tool_timeout_sec` | `60` | ツール呼び出しタイムアウト（秒） |
| `enabled` | `true` | サーバーの有効/無効 |
| `required` | `false` | `true` の場合、サーバー起動失敗時に Codex も起動失敗 |
| `enabled_tools` | 全ツール | 使用可能なツールのホワイトリスト |
| `disabled_tools` | なし | 無効化するツールのブラックリスト |
| `mcp_oauth_callback_port` | 自動 | OAuth コールバックポート |
| `mcp_oauth_callback_url` | 自動 | OAuth コールバック URL |

### 3.4 設定ファイルの配置

| スコープ | パス | 用途 |
|---------|------|------|
| グローバル | `~/.codex/config.toml` | 全プロジェクト共通の MCP サーバー |
| プロジェクト | `.codex/config.toml` | プロジェクト固有の MCP サーバー（信頼済みプロジェクトのみ） |

---

## 4. MCP サーバー管理コマンド

```bash
# サーバー一覧
codex mcp list
codex mcp list --json

# サーバー情報の取得
codex mcp get <name>
codex mcp get <name> --json

# サーバーの追加
codex mcp add <name> -- <command> [args...]
codex mcp add <name> --url <https://...>

# OAuth ログイン（HTTP サーバー向け）
codex mcp login <name> --scopes <scope1,scope2>

# OAuth ログアウト
codex mcp logout <name>

# サーバーの削除
codex mcp remove <name>
```

TUI 内では `/mcp` スラッシュコマンドで設定済みサーバーとツール一覧を確認可能。

---

## 5. MCP サーバーモード

Codex 自体を MCP サーバーとして起動し、他のエージェントから利用することも可能。

```bash
codex mcp-server
```

これにより、別のエージェントが Codex の機能を MCP ツールとして消費できる。

---

## 6. Claude Code との主な違い

| 項目 | Codex CLI | Claude Code |
|------|-----------|-------------|
| **設定形式** | TOML（`config.toml` 内 `[mcp_servers]`） | JSON（`~/.claude/claude_desktop_config.json` 内 `mcpServers`） |
| **設定スコープ** | グローバル + プロジェクトレベル（`.codex/config.toml`）。IDE と CLI で設定共有 | グローバル設定のみ（`~/.claude/`）。プロジェクトレベルは `.mcp.json` で別管理 |
| **トランスポート** | STDIO + Streamable HTTP | STDIO + SSE（Server-Sent Events） |
| **認証** | Bearer トークン（環境変数）+ OAuth（`codex mcp login`） | 環境変数による API キー設定が主 |
| **ツールフィルタリング** | `enabled_tools` / `disabled_tools` で制御可能 | サーバー単位での有効/無効のみ |
| **タイムアウト設定** | `startup_timeout_sec` / `tool_timeout_sec` で個別設定 | 設定なし（固定タイムアウト） |
| **CLI 管理** | `codex mcp add/remove/list/get` コマンド | 手動で JSON 編集、または `claude mcp add` |
| **サーバーモード** | `codex mcp-server` で Codex 自体を MCP サーバー化可能 | 非対応 |
| **必須指定** | `required = true` でサーバー起動失敗時に CLI も失敗させる設定が可能 | 非対応 |

### 6.1 移行のポイント

Claude Code から Codex CLI に MCP 設定を移行する場合:

1. JSON 形式の `mcpServers` を TOML 形式の `[mcp_servers]` に変換
2. `command` / `args` はそのまま移行可能
3. `env` セクションも同様の構造で移行可能
4. SSE トランスポートを使用している場合は Streamable HTTP に対応しているか確認
5. プロジェクト固有の設定は `.codex/config.toml` に配置

> 公式ドキュメント: [MCP](https://developers.openai.com/codex/mcp)
