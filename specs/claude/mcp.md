# Claude Code MCP 仕様書

最終更新: 2026-03-26（巡回更新）

公式ドキュメント: https://code.claude.com/docs/en/mcp

---

## 1. MCP の概要

**Model Context Protocol (MCP)** は AI ツールと外部データソースを接続するためのオープンソース標準。Claude Code は MCP サーバーを通じて数百の外部ツール・データベース・API に接続できる。

### 1.1 できること

- **イシュートラッカーからの機能実装**: 「JIRA の ENG-4521 に記載された機能を実装して PR を作成」
- **モニタリングデータの分析**: 「Sentry と Statsig を確認」
- **データベースクエリ**: 「PostgreSQL から該当ユーザーを検索」
- **デザイン統合**: 「Figma のデザインに基づいてテンプレートを更新」
- **ワークフロー自動化**: 「Gmail の下書きを作成」
- **外部イベントへの反応**: チャンネル機能で Telegram / Discord / webhook イベントを受信

---

## 2. トランスポートタイプ

| タイプ | 説明 | 推奨度 |
|:--|:--|:--|
| **HTTP** (streamable-http) | リモートHTTPサーバー。クラウドサービス向け推奨 | 推奨 |
| **SSE** (Server-Sent Events) | リモートSSEサーバー。非推奨 | 非推奨（HTTP を使用） |
| **stdio** | ローカルプロセス。直接システムアクセスが必要な場合 | ローカル用 |
| **WebSocket** (`ws`) | WebSocket接続 | 特定用途 |

---

## 3. 設定方法

### 3.1 CLI による追加

#### HTTP サーバー（推奨）

```bash
# 基本構文
claude mcp add --transport http <name> <url>

# 例: Notion
claude mcp add --transport http notion https://mcp.notion.com/mcp

# Bearer トークン付き
claude mcp add --transport http secure-api https://api.example.com/mcp \
  --header "Authorization: Bearer your-token"
```

#### SSE サーバー（非推奨）

```bash
claude mcp add --transport sse asana https://mcp.asana.com/sse

# 認証ヘッダー付き
claude mcp add --transport sse private-api https://api.company.com/sse \
  --header "X-API-Key: your-key-here"
```

#### stdio サーバー

```bash
# 基本構文
claude mcp add [options] <name> -- <command> [args...]

# 例: Airtable
claude mcp add --transport stdio --env AIRTABLE_API_KEY=YOUR_KEY airtable \
  -- npx -y airtable-mcp-server
```

**重要**: オプション（`--transport`, `--env`, `--scope`, `--header`）はサーバー名の**前**に配置。`--` でサーバー名とコマンド/引数を分離。

#### Windows での注意

Windows（WSL除く）で `npx` を使用するローカルサーバーは `cmd /c` ラッパーが必要:

```bash
claude mcp add --transport stdio my-server -- cmd /c npx -y @some/package
```

### 3.2 管理コマンド

```bash
# サーバー一覧
claude mcp list

# サーバー詳細
claude mcp get github

# サーバー削除
claude mcp remove github

# プロジェクトMCPの承認リセット
claude mcp reset-project-choices

# セッション内でステータス確認・OAuth認証
/mcp
```

### 3.3 JSON ファイルによる設定

#### `.mcp.json`（プロジェクトスコープ）

プロジェクトルートに配置、バージョン管理にコミット:

```json
{
  "mcpServers": {
    "shared-server": {
      "command": "/path/to/server",
      "args": [],
      "env": {}
    }
  }
}
```

#### 環境変数展開

`.mcp.json` 内で環境変数を展開可能:

- `${VAR}` -- 環境変数 VAR の値
- `${VAR:-default}` -- VAR が未設定時はデフォルト値

展開可能な箇所: `command`, `args`, `env`, `url`, `headers`

```json
{
  "mcpServers": {
    "api-server": {
      "type": "http",
      "url": "${API_BASE_URL:-https://api.example.com}/mcp",
      "headers": {
        "Authorization": "Bearer ${API_KEY}"
      }
    }
  }
}
```

### 3.4 settings.json 関連キー

| キー | 説明 |
|:--|:--|
| `enableAllProjectMcpServers` | プロジェクト `.mcp.json` の全サーバーを自動承認 |
| `enabledMcpjsonServers` | 承認するサーバーリスト |
| `disabledMcpjsonServers` | 拒否するサーバーリスト |

---

## 4. MCP インストールスコープ

| スコープ | 保存先 | 用途 | コマンド |
|:--|:--|:--|:--|
| **Local**（デフォルト） | `~/.claude.json` 内のプロジェクトパス配下 | 個人・プロジェクト固有 | `claude mcp add --scope local` |
| **Project** | `.mcp.json`（プロジェクトルート） | チーム共有 | `claude mcp add --scope project` |
| **User** | `~/.claude.json` | 全プロジェクト横断 | `claude mcp add --scope user` |
| **Managed** | `managed-mcp.json`（システムディレクトリ） | 組織全体 | IT配布 |

### 4.1 スコープ優先順位

同名サーバーが複数スコープに存在する場合: Local > Project > User

---

## 5. Managed MCP 設定

組織向けの管理設定:

```json
{
  "allowManagedMcpServersOnly": true,
  "allowedMcpServers": [
    { "serverName": "github" }
  ],
  "deniedMcpServers": [
    { "serverName": "filesystem" }
  ]
}
```

- `allowManagedMcpServersOnly`: Managed 設定のみから許可リストを適用
- `allowedMcpServers`: 許可するMCPサーバーのホワイトリスト
- `deniedMcpServers`: 拒否するMCPサーバーのブラックリスト（許可リストより優先）

`managed-mcp.json` の配置先:
- macOS: `/Library/Application Support/ClaudeCode/`
- Linux/WSL: `/etc/claude-code/`
- Windows: `C:\Program Files\ClaudeCode\`

---

## 6. MCPレジストリ

Anthropic が公開する MCP サーバーレジストリ:

- エンドポイント: `https://api.anthropic.com/mcp-registry/v0/servers`
- ドキュメント: `https://api.anthropic.com/mcp-registry/docs`
- 各サーバーには `worksWith` フィールドで対応プラットフォーム（`claude-code`, `claude-api`, `claude-desktop`）が記載

---

## 7. 主要 MCP サーバー例

> サードパーティ MCP サーバーは Anthropic が正確性やセキュリティを全て検証していない点に注意。

### 7.1 よく使われるサーバー

| サーバー | 用途 | 追加コマンド例 |
|:--|:--|:--|
| **GitHub** | コードレビュー、PR管理 | `claude mcp add --transport http github https://api.githubcopilot.com/mcp/` |
| **Sentry** | エラーモニタリング | `claude mcp add --transport http sentry https://mcp.sentry.dev/mcp` |
| **Notion** | ドキュメント管理 | `claude mcp add --transport http notion https://mcp.notion.com/mcp` |
| **Stripe** | 決済 | `claude mcp add --transport http stripe https://mcp.stripe.com` |
| **PayPal** | 決済 | `claude mcp add --transport http paypal https://mcp.paypal.com/mcp` |
| **HubSpot** | CRM | `claude mcp add --transport http hubspot https://mcp.hubspot.com/anthropic` |
| **Playwright** | ブラウザテスト | `claude mcp add --transport stdio playwright -- npx -y @playwright/mcp@latest` |

### 7.2 その他のサーバー

GitHub で数百以上の MCP サーバーが公開されている: https://github.com/modelcontextprotocol/servers

MCP SDK で独自サーバーを構築可能: https://modelcontextprotocol.io/quickstart/server

---

## 8. 高度な機能

### 8.1 動的ツール更新

MCP `list_changed` 通知により、サーバーが利用可能なツール・プロンプト・リソースを動的に更新可能。再接続不要。

### 8.2 チャンネル（プッシュメッセージ）

MCP サーバーが `claude/channel` ケーパビリティを宣言し、`--channels` フラグでオプトインすると、外部イベント（CI結果、モニタリングアラート、チャットメッセージ等）をセッションにプッシュ可能。

### 8.3 MCP プロンプト

MCPサーバーが公開するプロンプトはコマンドとして表示: `/mcp__<server>__<prompt>`

### 8.4 OAuth 認証

リモートサーバーが OAuth 2.0 認証を要求する場合、`/mcp` コマンドで認証フローを開始できる。

### 8.5 プラグイン提供 MCP サーバー

プラグインが MCP サーバーをバンドル可能:

```json
{
  "database-tools": {
    "command": "${CLAUDE_PLUGIN_ROOT}/servers/db-server",
    "args": ["--config", "${CLAUDE_PLUGIN_ROOT}/config.json"],
    "env": { "DB_URL": "${DB_URL}" }
  }
}
```

### 8.6 サブエージェントへの MCP スコープ

サブエージェントのフロントマターで MCP サーバーをスコープ可能（メイン会話のコンテキストを消費しない）:

```yaml
---
name: browser-tester
mcpServers:
  - playwright:
      type: stdio
      command: npx
      args: ["-y", "@playwright/mcp@latest"]
---
```

### 8.7 Claude Code を MCP サーバーとして使用

`claude mcp serve` コマンドで Claude Code 自体を MCP サーバーとして起動可能。他のエージェントやツールから Claude Code の機能を利用できる。

### 8.8 ツール説明とサーバー指示の上限

MCP ツール説明およびサーバー指示は **2KB** に制限される（v2.1.84）。超過分は切り詰められる。

### 8.9 claude.ai コネクタの重複排除

ローカル設定と claude.ai コネクタの両方で同じ MCP サーバーが設定されている場合、自動的に重複排除される（v2.1.84）。プラグイン提供の MCP サーバーが組織管理コネクタと重複する場合は、プラグイン側が抑制される。

### 8.10 MCP Tool Search

多数の MCP ツールがある環境で、Claude が最も関連性の高いツールを自動的に見つける機能。

- **仕組み**: 全ツールのメタデータをインデックス化し、タスクに応じて関連ツールを検索
- **設定**: `ENABLE_TOOL_SEARCH` 環境変数で有効化

### 8.11 MCP リソース

MCP サーバーが公開するリソース（ドキュメント、データ等）を `@` メンションで参照可能。

### 8.12 MCP Elicitation（ユーザー入力要求）

MCP サーバーがセッション中にユーザー入力を要求する仕組み:

- **Form モード**: フォームフィールドで構造化入力を要求
- **URL モード**: URLを開いて認証等を完了させる

### 8.13 OAuth 認証の詳細

- **固定コールバックポート**: `--oauth-port` で OAuth コールバックポートを固定
- **事前設定 OAuth 認証情報**: `.mcp.json` にクライアントID/シークレットを記載可能
- **OAuth メタデータディスカバリのオーバーライド**: カスタムメタデータURLの指定

---

## 9. Managed MCP の Policy-based Control

サーバー名だけでなく、コマンドやURLでのマッチングも可能:

```json
{
  "allowedMcpServers": [
    { "serverName": "github" },
    { "serverCommand": "npx @company/*" },
    { "serverUrl": "https://*.company.com/*" }
  ],
  "deniedMcpServers": [
    { "serverName": "filesystem" }
  ]
}
```

マッチングフィールド: `serverName`, `serverCommand`, `serverUrl`

---

## 10. 環境変数

| 変数 | 説明 |
|:--|:--|
| `MCP_TIMEOUT` | MCPサーバー起動タイムアウト（ms）。例: `MCP_TIMEOUT=10000` |
| `MAX_MCP_OUTPUT_TOKENS` | MCPツール出力の警告閾値。デフォルト10,000トークン |
| `ENABLE_TOOL_SEARCH` | MCP Tool Search 機能の有効化 |

---

## 参考リンク

- MCP: https://code.claude.com/docs/en/mcp
- MCP プロトコル仕様: https://modelcontextprotocol.io/introduction
- MCP サーバー一覧: https://github.com/modelcontextprotocol/servers
- チャンネル: https://code.claude.com/docs/en/channels
- Managed MCP: https://code.claude.com/docs/en/permissions#managed-only-settings
