# Claude Code → Codex CLI 変換ルール

最終更新: 2026-03-24

本ドキュメントは Claude Code の各機能が Codex CLI でどのように対応するかを定義する。対応なしの場合は代替策を記載する。

---

## 1. 設定ファイル

| Claude Code | Codex CLI | 備考 |
|:--|:--|:--|
| `CLAUDE.md` | `AGENTS.md` | 指示ファイル名が異なる。内容は Markdown で共通 |
| `.claude/CLAUDE.md` | `AGENTS.md`（プロジェクトルート） | Codex は `.codex/` 配下ではなくディレクトリ直下に配置 |
| `~/.claude/CLAUDE.md` | `~/.codex/AGENTS.md` | グローバルスコープの指示 |
| `settings.json` | `config.toml` | JSON → TOML 形式変換が必要 |
| `~/.claude/settings.json` | `~/.codex/config.toml` | ユーザーレベル設定 |
| `.claude/settings.json` | `.codex/config.toml` | プロジェクトレベル設定 |
| `.claude/settings.local.json` | **対応なし** | 代替: `.codex/config.toml` をプロファイルで分離し `.gitignore` に追加 |
| `~/.claude.json` | `~/.codex/config.toml` | Codex は全設定を `config.toml` に集約 |
| `.mcp.json` | `.codex/config.toml` の `[mcp_servers]` | MCP設定はメイン設定ファイルに統合 |

### 1.1 変換ガイド: CLAUDE.md → AGENTS.md

- ファイル名を `CLAUDE.md` から `AGENTS.md` に変更する
- `@path/to/import` インポート構文は Codex に存在しない。インポート先の内容を直接記述するか、AGENTS.md にまとめる
- `.claude/rules/` のパススコープルール（YAML フロントマター `paths:`）は対応なし。AGENTS.md 本文に条件付き指示として記述する
- サイズ制限: Claude は200行目安、Codex は32 KiB（`project_doc_max_bytes` で変更可能）

### 1.2 変換ガイド: settings.json → config.toml

```
# Claude Code (JSON)
{
  "model": "sonnet",
  "permissions.allow": ["Bash(npm test)"],
  "effortLevel": "high"
}

# Codex CLI (TOML)
model = "o4-mini"
approval_policy = "on-request"
model_reasoning_effort = "high"
```

---

## 2. 指示ファイルの階層構造

| Claude Code | Codex CLI | 備考 |
|:--|:--|:--|
| Managed Policy CLAUDE.md | **対応なし** | 代替: `/etc/codex/config.toml` のシステム設定で部分的に代替 |
| Project CLAUDE.md | `AGENTS.md`（Git ルート〜CWD の各階層） | 同等。Codex もディレクトリ走査で読み込む |
| User CLAUDE.md | `~/.codex/AGENTS.md` | 同等 |
| `.claude/rules/*.md` | **対応なし** | 代替: AGENTS.md 内にセクション分けして記述 |
| パススコープルール（`paths:` フロントマター） | **対応なし** | 代替: AGENTS.md 本文中に「このルールは `src/api/**` に適用」と記述 |
| `AGENTS.override.md` | Claude に対応なし → **Codex 固有** | Codex のみの機能。override が必要な場合は Codex のみに設定 |
| `claudeMdExcludes` | **対応なし** | 代替: ディレクトリ構成で回避 |

---

## 3. 権限・サンドボックス

| Claude Code | Codex CLI | 備考 |
|:--|:--|:--|
| `permissions.allow` | `approval_policy` + 個別設定 | Claude は細粒度（ツール単位）、Codex はポリシーベース |
| `permissions.deny` | **対応なし（ポリシーで制御）** | Codex は `approval_policy` で全体制御 |
| `permissions.ask` | `approval_policy = "on-request"` | デフォルトの承認モードで近い動作 |
| `permissions.defaultMode` | `approval_policy` | 直接対応 |
| `bypassPermissions` モード | `--yolo` フラグ | 両方とも非推奨の全バイパス |
| サンドボックス設定 (`sandbox.*`) | `sandbox_mode` | Claude は詳細設定、Codex は3段階モード |

### 3.1 権限モード対応表

| Claude Code | Codex CLI | 説明 |
|:--|:--|:--|
| `permissions.allow: ["Bash(*)"]` | `approval_policy = "never"` | 全コマンド許可（危険） |
| `permissions.allow: ["Bash(npm test)"]` | `/permissions` で個別設定 | Codex も個別コマンド許可が可能 |
| デフォルト（確認あり） | `approval_policy = "on-request"` | 標準的な動作 |
| `permissions.deny: ["Bash(rm *)"]` | **対応なし** | 代替: AGENTS.md に「`rm` コマンドを使用しないこと」と記述 |

### 3.2 サンドボックスモード対応表

| Claude Code | Codex CLI |
|:--|:--|
| サンドボックス無効 | `sandbox_mode = "danger-full-access"` |
| 読み取り専用 | `sandbox_mode = "read-only"` |
| ワークスペース書き込み可 | `sandbox_mode = "workspace-write"` |

---

## 4. Skills / Commands

| Claude Code | Codex CLI | 備考 |
|:--|:--|:--|
| Skills (`SKILL.md`) | Skills (`SKILL.md`) | **直接対応**。SKILL.md フロントマター形式は同一 |
| `.claude/skills/<name>/SKILL.md` | `.codex/skills/<name>/SKILL.md` | ディレクトリ構造が同一（`.claude/` → `.codex/`） |
| `~/.claude/skills/` | `~/.codex/skills/` | グローバルスキルも同一構造 |
| `/skills` コマンド | `/skills` コマンド | 同等。スキル一覧表示と選択 |
| `$` メンションでスキル参照 | `$` メンションでスキル参照 | 同等 |
| `$ARGUMENTS` 変数展開 | **対応なし** | 代替: プロンプトで直接指示を渡す |
| `context: fork` サブエージェント実行 | サブエージェント機能（実験的） | `[features] multi_agent = true` で有効化 |
| `allowed-tools` フロントマター | **対応なし** | 代替: `approval_policy` で全体制御 |
| 動的コンテキスト注入 (`` !`command` ``) | **対応なし** | 代替: シェルスクリプトで事前にコンテキストを生成し、プロンプトに含める |
| バンドルスキル多数 | バンドル3種（`skill-creator`, `skill-installer`, `openai-docs`） | Claude の方がバンドルスキルは豊富 |

---

## 5. コマンド（Slash Commands）

| Claude Code | Codex CLI | 備考 |
|:--|:--|:--|
| `/clear` | `/clear`, `/new` | 同等 |
| `/compact` | `/compact` | 同等 |
| `/resume` | `/resume` | 同等。Codex は CLI サブコマンドとしても利用可能 |
| `/branch` (`/fork`) | `/fork` | 同等 |
| `/diff` | `/diff` | 同等 |
| `/model` | `/model` | 同等 |
| `/config` | `/debug-config` | Codex は診断寄り |
| `/permissions` | `/permissions` | 同等 |
| `/mcp` | `/mcp` | 同等 |
| `/status` | `/status` | 同等 |
| `/init` | `/init` | Claude は CLAUDE.md 生成、Codex は AGENTS.md 生成 |
| `/plan` | `/plan` | 同等 |
| `/export` | **対応なし** | 代替: `codex exec --output-last-message` で最終出力を保存 |
| `/memory` | **対応なし** | Codex にオートメモリ機能なし |
| `/effort` | **対応なし** | 代替: `config.toml` の `model_reasoning_effort` で設定 |
| `/cost` | `/status` | Codex の `/status` にトークン使用量が含まれる |
| `/context` | `/status` | 同上 |
| `/pr-comments` | **対応なし** | 代替: GitHub MCP サーバー経由でPRコメントを取得 |
| `/security-review` | `/review` | Codex の `/review` はセキュリティ含む汎用レビュー |
| `/sandbox` | **対応なし** | 代替: `--sandbox` CLI フラグ |
| `/add-dir` | `--add-dir` CLI フラグ | Claude はコマンド、Codex はフラグのみ |
| `/agents` | `/agent` | 同等（名称が微妙に異なる） |
| `/skills` | `/skills` | 同等。両方ともスキル一覧を表示 |
| `/batch` | **対応なし** | 代替: `codex exec` をシェルスクリプトで並列実行 |
| `/btw` | **対応なし** | 代替: 通常のプロンプトで質問 |
| `/rewind` | **対応なし** | Codex にチェックポイント機能なし |
| `/voice` | **対応なし** | Codex に音声入力なし |

---

## 6. Hooks

> **2026-03-24 更新**: Codex CLI が Hooks を実験的にサポート開始。ただし対応イベントは 3 種、ハンドラは command のみと、Claude Code（17+ イベント、4 ハンドラ種別）に比べ限定的。

| Claude Code | Codex CLI | 備考 |
|:--|:--|:--|
| Hooks システム全体 | **部分対応**（実験的） | `codex_hooks` フラグで有効化。`config.toml` の `[[hooks]]` で設定 |
| `SessionStart` | `SessionStart` | **直接対応**。command ハンドラのみ |
| `Stop` フック | `Stop` | **直接対応**。command ハンドラのみ |
| `UserPromptSubmit` | `UserPromptSubmit` | **直接対応**。終了コード 2 でブロック可能。command ハンドラのみ |
| `PreToolUse` | **対応なし** | 代替: `approval_policy` と AGENTS.md の指示で制御 |
| `PostToolUse` | **対応なし** | 代替: AGENTS.md に「編集後は lint を実行」と記述 |
| `SessionEnd` | **対応なし** | `Stop` で部分的に代替可能 |
| `Notification` 他 14+ イベント | **対応なし** | Codex は 3 イベントのみ |
| HTTP ハンドラ | **対応なし** | 代替: MCP サーバーとして Webhook 連携を実装 |
| Prompt ハンドラ | **対応なし** | 代替: AGENTS.md に判断基準を記述 |
| Agent ハンドラ | **対応なし** | 代替: サブエージェント機能（実験的）で部分的に代替 |

### 6.1 設定形式の違い

```
# Claude Code (settings.json)
{
  "hooks": {
    "SessionStart": [
      { "type": "command", "command": "echo 'start'" }
    ]
  }
}

# Codex CLI (config.toml)
[features]
codex_hooks = true

[[hooks]]
event = "SessionStart"
command = "echo 'start'"
```

### 6.2 Hooks の代替パターン（対応なしイベント向け）

Codex の Hooks では賄えない Claude イベント（`PreToolUse`, `PostToolUse` 等）には、引き続き以下のパターンで代替する:

1. **ツール実行前バリデーション** → `approval_policy = "on-request"` + AGENTS.md に制約を記述
2. **ファイル編集後の自動処理** → AGENTS.md に「ファイル編集後は必ず lint/format を実行」と記述
3. **セッション制御** → `SessionStart` / `Stop` フックを活用（ラッパースクリプトとの併用も可能）
4. **外部通知** → MCP サーバーで Webhook 送信機能を提供

---

## 7. MCP

| Claude Code | Codex CLI | 備考 |
|:--|:--|:--|
| `.mcp.json` | `.codex/config.toml` の `[mcp_servers]` | JSON → TOML 変換が必要 |
| `claude mcp add` | `codex mcp add` | ほぼ同等の CLI |
| `--transport http` | `--url` | HTTP サーバーの追加方法が異なる |
| `--transport sse` | **対応なし** | Codex は SSE 非サポート。Streamable HTTP に移行 |
| `--transport stdio` | デフォルト | Codex のデフォルトは stdio |
| `--scope local/project/user` | グローバル or プロジェクト | Codex は2スコープのみ |
| `enableAllProjectMcpServers` | プロジェクト信頼設定 | Codex は信頼済みプロジェクトのみ読み込み |
| `allowManagedMcpServersOnly` | **対応なし** | Codex に Managed MCP 概念なし |
| Managed MCP (`managed-mcp.json`) | **対応なし** | 代替: `/etc/codex/config.toml` のシステム設定 |
| MCPチャンネル（プッシュメッセージ） | **対応なし** | Codex はプッシュ通知非対応 |
| プラグイン提供 MCP | **対応なし** | Codex にプラグインシステムなし |

### 7.1 MCP 設定変換例

```
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

# Codex CLI (config.toml)
[mcp_servers.github]
url = "https://api.githubcopilot.com/mcp/"
bearer_token_env_var = "GITHUB_TOKEN"

[mcp_servers.playwright]
command = "npx"
args = ["-y", "@playwright/mcp@latest"]
```

---

## 8. サブエージェント

| Claude Code | Codex CLI | 備考 |
|:--|:--|:--|
| ビルトインサブエージェント（Explore, Plan, Bash等） | **対応なし（実験的）** | `[features] multi_agent = true` で実験的サポート |
| カスタムサブエージェント (`.claude/agents/`) | **対応なし** | 代替: AGENTS.md に役割別の指示セクションを記述 |
| サブエージェントのモデル指定 | **対応なし** | Codex はセッション全体で単一モデル |
| サブエージェントの永続メモリ | **対応なし** | Codex にメモリシステムなし |
| `background: true` バックグラウンド実行 | `/ps` で確認可能な実験的機能 | Codex もバックグラウンドターミナルを実験的にサポート |
| ワークツリー隔離 (`isolation: worktree`) | **対応なし** | 代替: 別ディレクトリで `codex exec` を実行 |

---

## 9. メモリシステム

| Claude Code | Codex CLI | 備考 |
|:--|:--|:--|
| オートメモリ | **対応なし** | Codex にセッション間学習機能なし |
| `MEMORY.md` | **対応なし** | 代替: AGENTS.md にプロジェクト知識を手動記述 |
| `/memory` コマンド | **対応なし** | - |
| サブエージェントメモリ | **対応なし** | - |

### 9.1 メモリの代替策

Codex にはオートメモリがないため、以下のアプローチで代替する:

1. `AGENTS.md` にプロジェクト固有の知識・慣習を詳細に記述
2. セッション履歴の `resume` 機能でコンテキストを引き継ぐ
3. `/compact` でコンテキストを圧縮しつつ重要情報を保持

---

## 10. 環境変数

| Claude Code | Codex CLI | 備考 |
|:--|:--|:--|
| `ANTHROPIC_API_KEY` | `OPENAI_API_KEY` | プロバイダーが異なる |
| `ANTHROPIC_MODEL` | `--model` フラグ or `config.toml` | Codex は環境変数でのモデル指定なし |
| `CLAUDE_CODE_USE_BEDROCK` | `model_provider` 設定 | Codex は `model_provider` で統一管理 |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | **対応なし** | Codex にメモリなし |
| `MCP_TIMEOUT` | `startup_timeout_sec` / `tool_timeout_sec` | Codex は TOML 設定で個別制御 |
| `MAX_MCP_OUTPUT_TOKENS` | **対応なし** | Codex に相当設定なし |

---

## 11. その他の機能

| Claude Code | Codex CLI | 備考 |
|:--|:--|:--|
| プロファイル | プロファイル (`[profiles.*]`) | 同等。Codex は `--profile` フラグで切替 |
| プラグインシステム | **対応なし** | Codex にプラグイン概念なし |
| デスクトップアプリ連携 (`/desktop`) | `codex app`（macOS のみ） | 部分的対応 |
| IDE連携 (`/ide`) | IDE拡張（設定共有） | Codex は IDE と設定ファイルを共有 |
| Web検索 | `web_search` 設定 | Codex は `cached`/`live`/`disabled` の3段階 |
| `codex exec`（非対話モード） | Claude は `claude -p` | 両方ともパイプライン実行をサポート |
| Codex Cloud | Claude にはなし → **Codex 固有** | `codex cloud` でリモートタスク実行 |
| OpenTelemetry 監視 | Claude にはなし → **Codex 固有** | `[otel]` セクションで設定 |
| シェル環境ポリシー | Claude にはなし → **Codex 固有** | `[shell_environment_policy]` で環境変数フィルタリング |
