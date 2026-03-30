# Claude Code Skills & コマンド仕様書

最終更新: 2026-03-29（巡回更新）

公式ドキュメント: https://code.claude.com/docs/en/skills / https://code.claude.com/docs/en/commands / https://code.claude.com/docs/en/sub-agents

---

## 1. Skills

Skills は Claude の能力を拡張する仕組み。`SKILL.md` ファイルに指示を記述し、Claude が自動的に関連性を判断して適用するか、ユーザーが `/skill-name` で直接呼び出す。

[Agent Skills](https://agentskills.io) オープンスタンダードに準拠。

### 1.1 配置場所

| スコープ | パス | 適用範囲 |
|:--|:--|:--|
| Enterprise | Managed settings 経由 | 組織内全ユーザー |
| Personal | `~/.claude/skills/<skill-name>/SKILL.md` | 全プロジェクト |
| Project | `.claude/skills/<skill-name>/SKILL.md` | 当該プロジェクトのみ |
| Plugin | `<plugin>/skills/<skill-name>/SKILL.md` | プラグイン有効時 |

名前が重複する場合の優先度: Enterprise > Personal > Project。Plugin スキルは `plugin-name:skill-name` 名前空間で衝突しない。

`.claude/commands/` も引き続き動作する。同名の場合は Skills が優先。

#### サブディレクトリの自動検出

サブディレクトリのファイルを操作中、そのディレクトリの `.claude/skills/` も自動検出される（モノレポ対応）。

#### `--add-dir` からのスキル

`--add-dir` で追加したディレクトリの `.claude/skills/` は自動読み込みされ、ライブ変更検出も有効。

### 1.2 SKILL.md 構造

```
my-skill/
├── SKILL.md           # メイン指示（必須）
├── template.md        # テンプレート（任意）
├── examples/
│   └── sample.md      # 出力例（任意）
└── scripts/
    └── validate.sh    # 実行スクリプト（任意）
```

`SKILL.md` は YAML フロントマター + Markdown 本文で構成される。

### 1.3 フロントマターフィールド

| フィールド | 必須 | 説明 |
|:--|:--|:--|
| `name` | No | スキル表示名。省略時はディレクトリ名。小文字英数字とハイフンのみ（最大64文字） |
| `description` | 推奨 | スキルの用途と使用タイミング。Claude が自動適用の判断に使用。**250文字上限**（v2.1.86） |
| `argument-hint` | No | 引数ヒント。例: `[issue-number]` |
| `disable-model-invocation` | No | `true` で Claude の自動呼び出しを禁止。手動 `/name` のみ |
| `user-invocable` | No | `false` で `/` メニューから非表示。バックグラウンド知識用 |
| `allowed-tools` | No | スキル有効時に許可なしで使えるツール |
| `model` | No | スキル有効時のモデル指定 |
| `effort` | No | エフォートレベル (`low` / `medium` / `high` / `max`（Opus 4.6のみ）) |
| `context` | No | `fork` でフォークサブエージェントコンテキストで実行 |
| `agent` | No | `context: fork` 時のサブエージェントタイプ指定 |
| `hooks` | No | スキルライフサイクルにスコープされたフック |
| `paths` | No | スキル自動適用を限定するglobパターン。カンマ区切り文字列またはYAMLリスト。パスマッチ時のみ自動読み込み |
| `shell` | No | インライン `` !`command` `` のシェル。`bash`（デフォルト）または `powershell`（Windows、`CLAUDE_CODE_USE_POWERSHELL_TOOL=1` 必要） |

### 1.4 呼び出し制御

| フロントマター | ユーザー呼び出し | Claude 呼び出し | コンテキスト読み込み |
|:--|:--|:--|:--|
| (デフォルト) | Yes | Yes | 説明は常にコンテキスト内、全文は呼び出し時 |
| `disable-model-invocation: true` | Yes | No | 説明はコンテキスト外、全文はユーザー呼び出し時 |
| `user-invocable: false` | No | Yes | 説明は常にコンテキスト内、全文は呼び出し時 |

### 1.5 変数展開

| 変数 | 説明 |
|:--|:--|
| `$ARGUMENTS` | スキル呼び出し時に渡された全引数 |
| `$ARGUMENTS[N]` | N番目の引数（0始まり） |
| `$N` | `$ARGUMENTS[N]` の短縮形 |
| `${CLAUDE_SESSION_ID}` | 現在のセッションID |
| `${CLAUDE_SKILL_DIR}` | スキルの `SKILL.md` があるディレクトリ |

`$ARGUMENTS` がコンテンツに含まれない場合、末尾に `ARGUMENTS: <value>` が追加される。

### 1.6 動的コンテキスト注入

`` !`<command>` `` 構文でシェルコマンドをプリプロセッシングとして実行し、出力をスキルコンテンツに埋め込む:

```yaml
---
name: pr-summary
context: fork
agent: Explore
---

## PRコンテキスト
- PR diff: !`gh pr diff`
- 変更ファイル: !`gh pr diff --name-only`
```

### 1.7 サブエージェントでの実行

`context: fork` で隔離されたサブエージェントコンテキストで実行。会話履歴にアクセスしない:

```yaml
---
name: deep-research
context: fork
agent: Explore
---

$ARGUMENTS を徹底的に調査してください。
```

`agent` フィールドで実行環境を指定: `Explore` / `Plan` / `general-purpose` / カスタムサブエージェント名。

### 1.8 ツールアクセス制限

```yaml
---
name: safe-reader
allowed-tools: Read, Grep, Glob
---
```

### 1.9 スキルのアクセス制御

- **全スキル無効化**: `/permissions` で `Skill` を deny
- **個別許可/拒否**: `Skill(commit)` / `Skill(deploy *)`
- **個別非表示**: `disable-model-invocation: true`

### 1.10 バンドルスキル

Claude Code に同梱されるスキル:

| スキル | 用途 |
|:--|:--|
| `/batch <instruction>` | コードベース全体の大規模変更を並列オーケストレーション。ワークツリーごとにエージェントを起動しPRを作成 |
| `/claude-api` | Claude API リファレンス素材の読み込み（Python/TS/Java等） |
| `/debug [description]` | セッションデバッグログの解析 |
| `/loop [interval] <prompt>` | プロンプトを定期的に繰り返し実行 |
| `/simplify [focus]` | 変更ファイルのコード品質レビューと修正（3エージェント並列） |

---

## 2. 組み込みコマンド（Slash Commands）

`/` を入力して一覧表示。主要なコマンド:

### 2.1 セッション管理

| コマンド | 説明 |
|:--|:--|
| `/clear` (`/reset`, `/new`) | 会話履歴クリア |
| `/compact [instructions]` | 会話コンパクション |
| `/resume [session]` (`/continue`) | セッション再開 |
| `/rename [name]` | セッション名変更 |
| `/rewind` (`/checkpoint`) | 会話/コードを前の状態に巻き戻し |
| `/branch [name]` (`/fork`) | 会話のブランチ作成 |
| `/export [filename]` | 会話をテキストエクスポート |
| `/exit` (`/quit`) | CLI終了 |
| `/btw <question>` | コンテキストに残らないサイドクエスチョン |

### 2.2 設定・情報

| コマンド | 説明 |
|:--|:--|
| `/config` (`/settings`) | 設定インターフェース表示 |
| `/permissions` (`/allowed-tools`) | 権限設定 |
| `/model [model]` | モデル変更 |
| `/effort [level]` | エフォートレベル設定 |
| `/memory` | CLAUDE.md/オートメモリ管理 |
| `/hooks` | フック設定表示 |
| `/mcp` | MCPサーバー管理 |
| `/status` | ステータス表示 |
| `/context` | コンテキスト使用量の可視化 |
| `/cost` | トークン使用統計 |
| `/usage` | プラン使用量・レート制限表示 |

### 2.3 開発ワークフロー

| コマンド | 説明 |
|:--|:--|
| `/init` | CLAUDE.md の自動生成 |
| `/diff` | 差分ビューア |
| `/plan` | プランモード開始 |
| `/pr-comments [PR]` | GitHub PRコメント取得 |
| `/security-review` | セキュリティ脆弱性分析 |
| `/sandbox` | サンドボックスモード切替 |

### 2.4 環境・インテグレーション

| コマンド | 説明 |
|:--|:--|
| `/add-dir <path>` | ワーキングディレクトリ追加 |
| `/agents` | サブエージェント管理 |
| `/skills` | スキル一覧 |
| `/plugin` | プラグイン管理 |
| `/desktop` (`/app`) | デスクトップアプリでセッション継続 |
| `/remote-control` (`/rc`) | リモートコントロール有効化 |
| `/ide` | IDE連携管理 |
| `/chrome` | Chrome設定 |
| `/voice` | 音声入力トグル |
| `/color` | プロンプトバー色変更 |
| `/copy [N]` | レスポンスのコピー（インタラクティブピッカー。Nで直接指定。`w`キーでファイル書き出し） |
| `/login` / `/logout` | 認証 |

### 2.5 MCP プロンプト

MCPサーバーが公開するプロンプトは `/mcp__<server>__<prompt>` 形式でコマンドとして表示される。

---

## 3. Agents / Subagents

### 3.1 概要

サブエージェントは独自のコンテキストウィンドウ、システムプロンプト、ツールアクセスを持つ専門AIアシスタント。メインの会話コンテキストを消費せずにタスクを委譲できる。

### 3.2 ビルトインサブエージェント

| エージェント | モデル | 用途 |
|:--|:--|:--|
| **Explore** | Haiku | 読み取り専用のコードベース探索。quick/medium/very thorough の3段階 |
| **Plan** | 継承 | プランモード時のリサーチ。読み取り専用 |
| **general-purpose** | 継承 | 探索と変更の両方が必要な複雑タスク |
| **Bash** | 継承 | 別コンテキストでのターミナルコマンド実行 |
| **statusline-setup** | 継承 | ステータスライン設定用の専用エージェント |
| **Claude Code Guide** | 継承 | Claude Code の使い方ガイド |

### 3.3 カスタムサブエージェントの作成

Markdown ファイル + YAML フロントマターで定義:

```markdown
---
name: code-reviewer
description: コード品質とベストプラクティスのレビュー
tools: Read, Grep, Glob, Bash
model: sonnet
---

あなたはシニアコードレビュアーです。...
```

### 3.4 サブエージェントのスコープ

| 場所 | スコープ | 優先度 |
|:--|:--|:--|
| `--agents` CLIフラグ | 現在のセッションのみ | 1（最高） |
| `.claude/agents/` | プロジェクト | 2 |
| `~/.claude/agents/` | 全プロジェクト | 3 |
| プラグインの `agents/` | プラグイン有効時 | 4（最低） |

### 3.5 フロントマターフィールド

| フィールド | 必須 | 説明 |
|:--|:--|:--|
| `name` | Yes | 一意識別子（小文字+ハイフン） |
| `description` | Yes | Claude が委譲判断に使用する説明 |
| `tools` | No | 許可ツール。省略時は全ツール継承 |
| `disallowedTools` | No | 拒否ツール |
| `model` | No | `sonnet` / `opus` / `haiku` / `inherit` / フルモデルID |
| `permissionMode` | No | `default` / `acceptEdits` / `dontAsk` / `bypassPermissions` / `plan` |
| `maxTurns` | No | 最大エージェンティックターン数 |
| `skills` | No | 起動時にプリロードするスキル |
| `mcpServers` | No | スコープされたMCPサーバー |
| `hooks` | No | ライフサイクルフック |
| `memory` | No | 永続メモリスコープ (`user` / `project` / `local`) |
| `background` | No | `true` でバックグラウンドタスクとして実行 |
| `effort` | No | エフォートレベル |
| `isolation` | No | `worktree` で一時ワークツリーでの隔離実行 |
| `initialPrompt` | No | 最初のターンで自動送信するプロンプト（v2.1.83） |

### 3.6 呼び出し方法

- **自然言語**: エージェント名をプロンプトに含める
- **@メンション**: `@"code-reviewer (agent)"` でエージェント指定を保証
- **セッション全体**: `claude --agent code-reviewer` または設定 `"agent": "code-reviewer"`

### 3.7 フォアグラウンド/バックグラウンド

- **フォアグラウンド**: メイン会話をブロック。権限プロンプトと質問がパススルー
- **バックグラウンド**: 並行実行。起動前に必要な権限を事前承認。`Ctrl+B` でバックグラウンド化

### 3.8 サブエージェントの再開

完了したサブエージェントは `SendMessage` ツールで再開可能。会話履歴が保持される。

### 3.9 MCPサーバーのスコープ

```yaml
---
name: browser-tester
mcpServers:
  - playwright:
      type: stdio
      command: npx
      args: ["-y", "@playwright/mcp@latest"]
  - github  # 既存サーバー参照
---
```

### 3.10 永続メモリ

| スコープ | 保存先 |
|:--|:--|
| `user` | `~/.claude/agent-memory/<name>/` |
| `project` | `.claude/agent-memory/<name>/` |
| `local` | `.claude/agent-memory-local/<name>/` |

---

## 4. ヘッドレスモード（非対話モード）

公式ドキュメント: https://code.claude.com/docs/en/headless

### 4.1 基本使用法

```bash
# 単発クエリ
claude -p "このプロジェクトが何をするか説明して"

# ベアモード（高速起動、自動検出スキップ）
claude -p --bare "質問"
```

### 4.2 ベアモードのコンテキスト読み込み

`--bare` は自動検出をスキップするが、以下のフラグで選択的にコンテキストを読み込める:

| フラグ | 説明 |
|:--|:--|
| `--append-system-prompt` | システムプロンプトへの追加指示 |
| `--settings` | 設定ファイルの明示的指定 |
| `--mcp-config` | MCP設定ファイルの指定 |
| `--agents` | エージェント定義ディレクトリの指定 |
| `--plugin-dir` | プラグインディレクトリの指定 |

### 4.3 出力フォーマット

| フォーマット | フラグ | 用途 |
|:--|:--|:--|
| テキスト | `--output-format text` | デフォルト。人間向け |
| JSON | `--output-format json` | 最終結果の構造化出力 |
| Stream JSON | `--output-format stream-json` | リアルタイムストリーミング |

#### 型付き出力

`--json-schema` で出力スキーマを指定して構造化データを取得:

```bash
claude -p "全APIエンドポイントを一覧" --output-format json --json-schema schema.json
```

#### ストリーミング

```bash
claude -p "ログを分析" --output-format stream-json --verbose --include-partial-messages
```

`--verbose` でシステムイベント（`system`, `api_retry` 等）も含める。

### 4.4 ツール自動承認

```bash
claude -p "テストを実行して修正" --allowedTools "Edit,Bash(npm test *)"
```

### 4.5 セッション継続

```bash
# 最後のセッションを継続
claude -p --continue "前回の続き"

# 特定セッションIDで再開
claude -p --resume SESSION_ID "追加作業"
```

---

## 参考リンク

- Skills: https://code.claude.com/docs/en/skills
- 組み込みコマンド: https://code.claude.com/docs/en/commands
- サブエージェント: https://code.claude.com/docs/en/sub-agents
- ヘッドレスモード: https://code.claude.com/docs/en/headless
- エージェントチーム: https://code.claude.com/docs/en/agent-teams
- プラグイン: https://code.claude.com/docs/en/plugins
