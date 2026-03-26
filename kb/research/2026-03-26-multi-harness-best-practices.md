# 1プロジェクト複数AIハーネスのベストプラクティス調査

調査日: 2026-03-26

## 1. Claude Code の目的別ハーネス設計

### 1.1 CLAUDE.md のディレクトリスコープ

Claude Code はワーキングディレクトリから上方向にディレクトリツリーを走査し、各階層の CLAUDE.md を読み込む。サブディレクトリの CLAUDE.md は **遅延読み込み** で、Claude がそのディレクトリのファイルを読んだときに初めてコンテキストに注入される。

**ファイル構成例:**
```
monorepo/
├── CLAUDE.md                    # 全体共通ルール（200行以内推奨）
├── packages/
│   ├── frontend/
│   │   ├── CLAUDE.md            # React/TSX固有ルール（遅延読み込み）
│   │   └── .claude/skills/...
│   ├── backend/
│   │   ├── CLAUDE.md            # API設計ルール（遅延読み込み）
│   │   └── .claude/skills/...
│   └── shared/
│       └── CLAUDE.md            # 共有ライブラリ固有ルール
```

**読み込み優先順位（高→低）:**
1. Managed Policy（`/Library/Application Support/ClaudeCode/CLAUDE.md`）
2. プロジェクトルート `./CLAUDE.md` or `./.claude/CLAUDE.md`
3. ユーザーレベル `~/.claude/CLAUDE.md`
4. サブディレクトリ CLAUDE.md（遅延）

**Pros:**
- モノレポで領域ごとに異なるルールを自然に分離できる
- 遅延読み込みによりコンテキスト消費を最小化
- `@path/to/import` 構文で外部ファイル参照可能（最大5段ネスト）
- `claudeMdExcludes` で他チームの CLAUDE.md を除外可能

**Cons:**
- 200行超でアドヒアランス低下（コンテキスト圧迫）
- 矛盾する指示があると Claude が恣意的に選択
- サブディレクトリ CLAUDE.md はファイル読み込み時のみトリガー（書き込みではトリガーされない問題あり）

### 1.2 .claude/rules/ のパススコープ

`.claude/rules/` にMarkdownファイルを配置し、YAMLフロントマターの `paths` フィールドでglob patternによるスコープ指定が可能。

**ファイル構成例:**
```
.claude/
├── CLAUDE.md
└── rules/
    ├── code-style.md           # paths指定なし → 常時読み込み
    ├── api-design.md           # paths: ["src/api/**/*.ts"]
    ├── react-patterns.md       # paths: ["src/**/*.{tsx,jsx}"]
    ├── migration-safety.md     # paths: ["db/migrations/**"]
    └── testing.md              # paths: ["**/*.test.ts", "**/*.spec.ts"]
```

**フロントマター書式:**
```yaml
---
paths:
  - "src/api/**/*.ts"
  - "lib/**/*.ts"
---
# API Development Rules
...
```

**サポートされるglobパターン:**

| パターン | マッチ対象 |
|---------|-----------|
| `**/*.ts` | 全ディレクトリのTSファイル |
| `src/**/*` | src/以下の全ファイル |
| `*.md` | ルート直下のMarkdown |
| `src/**/*.{ts,tsx}` | ブレース展開で複数拡張子 |

**Pros:**
- 「優先度飽和問題」を回避（無関係なルールがコンテキストを消費しない）
- ファイルタイプ・ディレクトリごとの精密なスコープ制御
- シンボリックリンクでプロジェクト間共有可能
- ユーザーレベル `~/.claude/rules/` も利用可能

**Cons:**
- パス指定ルールは Read 時のみトリガー（Write/Edit 時はトリガーされない既知の問題）
- YAML内のglobパターンでクォートが必要なケースあり（`*`, `{` で始まるパターン）
- ルールファイルが多すぎるとディスカバリ負荷

### 1.3 Agent Teams（.claude/agents/）

`.claude/agents/` にMarkdownファイルを配置し、目的別の専門エージェントを定義。各エージェントは独立したコンテキストウィンドウで動作する。

**ファイル構成例:**
```
.claude/
└── agents/
    ├── code-reviewer.md      # コードレビュー専門（Read-only tools）
    ├── debugger.md           # デバッグ専門（Read + Edit + Bash）
    ├── data-scientist.md     # データ分析専門（Bash + Read + Write）
    ├── db-reader.md          # DB読み取り専門（Bash + PreToolUseフック）
    └── api-developer.md      # API開発専門（skills事前読み込み）
```

**エージェント定義の主要フロントマター:**

| フィールド | 説明 |
|-----------|------|
| `name` | 一意な識別子（必須） |
| `description` | いつ委譲すべきかの説明（必須） |
| `tools` | 利用可能ツール（許可リスト） |
| `disallowedTools` | 除外ツール（拒否リスト） |
| `model` | `sonnet`, `opus`, `haiku`, `inherit` |
| `permissionMode` | `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, `plan` |
| `skills` | 事前読み込みスキル |
| `memory` | `user`, `project`, `local`（永続メモリ） |
| `hooks` | ライフサイクルフック |
| `mcpServers` | MCPサーバー接続 |
| `isolation` | `worktree` で独立git worktreeを利用 |
| `background` | `true` でバックグラウンド実行 |

**スコープ（優先順位高→低）:**
1. `--agents` CLIフラグ（セッション限定）
2. `.claude/agents/`（プロジェクトレベル）
3. `~/.claude/agents/`（ユーザーレベル）
4. プラグインの `agents/` ディレクトリ

**ビルトインエージェント:**
- **Explore**: Haikuモデル、読み取り専用、コードベース探索
- **Plan**: メインモデル継承、読み取り専用、計画モード用
- **general-purpose**: メインモデル継承、全ツール、複合タスク用

**Pros:**
- 各エージェントが独立コンテキストウィンドウ → メインの汚染なし
- ツール制限で安全性確保（読み取り専用エージェント等）
- 永続メモリで会話間の知識蓄積
- フック付きで条件付き検証（SQLのSELECTのみ許可等）
- `@` メンションで明示的に呼び出し可能

**Cons:**
- サブエージェントは他のサブエージェントをスポーン不可（ネスト不可）
- バックグラウンドエージェントは権限の事前承認が必要
- 多数のエージェントの結果がコンテキストを消費

### 1.4 Agent Teams（協調型）

実験的機能。複数のClaude Codeセッションが共有タスクリストとメールボックスで協調動作する。

**有効化:**
```bash
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
```

**アーキテクチャ:**
- **Team Lead**: メインセッション（作業を割り当て・統合）
- **Teammates**: 独立セッション（各自のコンテキストウィンドウ）
- **Shared Task List**: 全エージェントに可視のタスクキュー
- **Mailbox**: ピアツーピアメッセージング

**サブエージェント vs Agent Teams:**

| 観点 | サブエージェント | Agent Teams |
|------|----------------|------------|
| 通信 | 結果のみ（ハブ&スポーク） | 直接メッセージング |
| 調整 | メインが全管理 | 共有タスクリストで自律 |
| コスト | 低トークン | 3-4倍のトークン |
| 適用 | 焦点を絞った孤立タスク | 協調が必要な探索 |

### 1.5 Skills の paths フィールド

スキルのフロントマターに `paths` フィールドを指定すると、マッチするファイルで作業中のみスキルが自動起動する。

**定義例:**
```yaml
---
name: api-conventions
description: API design patterns for this codebase
paths:
  - "src/api/**/*.ts"
  - "src/handlers/**/*.ts"
---
```

**スキルの配置場所とスコープ:**

| 配置場所 | 適用範囲 |
|---------|---------|
| `~/.claude/skills/<name>/SKILL.md` | 全プロジェクト |
| `.claude/skills/<name>/SKILL.md` | 当該プロジェクト |
| プラグイン `skills/<name>/SKILL.md` | プラグイン有効時 |

**起動制御の組み合わせ:**

| 設定 | ユーザー起動 | Claude自動起動 |
|------|------------|---------------|
| デフォルト | Yes | Yes |
| `disable-model-invocation: true` | Yes | No |
| `user-invocable: false` | No | Yes |

**Pros:**
- ルールよりもリッチ（サポートファイル、スクリプト同梱可能）
- `context: fork` でサブエージェント内実行可能
- 動的コンテキスト注入（`` !`command` `` 構文）
- モノレポのパッケージごとにネストした `.claude/skills/` を自動発見

**Cons:**
- 多数のスキルがあるとコンテキスト予算（ウィンドウの2%）を超過
- description の記述品質がマッチング精度に直結


## 2. Codex CLI のプロファイル活用

### 2.1 config.toml の Profiles

`~/.codex/config.toml` でプロファイルを定義し、`--profile` フラグで切り替え。

**設定例:**
```toml
model = "gpt-5-codex"
approval_policy = "on-request"

[profiles.deep-review]
model = "gpt-5-pro"
model_reasoning_effort = "high"
approval_policy = "never"

[profiles.lightweight]
model = "gpt-4.1"
approval_policy = "untrusted"

[profiles.development]
sandbox_mode = "workspace-write"
approval_policy = "never"

[profiles.production]
sandbox_mode = "untrusted"
approval_policy = "on-request"
```

**デフォルトプロファイル設定:**
```toml
profile = "deep-review"  # トップレベルに記述
```

**プロファイルで切替可能な主要項目:**
- `model` / `model_reasoning_effort`
- `approval_policy`（`untrusted`, `on-request`, `never`）
- `sandbox_mode`（`read-only`, `workspace-write`, `danger-full-access`）
- `model_catalog_json`（モデルカタログの差し替え）

**エージェント設定:**
```toml
[agents]
max_threads = 6
max_depth = 1

[agents.security-reviewer]
description = "Security audit specialist"
config_file = "~/.codex/agents/security.toml"
```

**Pros:**
- CLI一発で目的別設定を切替（`codex --profile deep-review`）
- 開発/本番でサンドボックス・承認ポリシーを分離
- モデル・推論effort を目的別に最適化

**Cons:**
- 実験的機能（将来変更の可能性）
- IDE拡張では未サポート
- プロジェクトレベルの `.codex/config.toml` は信頼マーク後のみ有効

### 2.2 AGENTS.md のディレクトリ階層マージ

Codex CLI は3層の優先順位でAGENTS.mdを探索・マージする。

**探索順序:**
1. **グローバル**: `~/.codex/AGENTS.override.md` → `~/.codex/AGENTS.md`（先に見つかった方のみ）
2. **プロジェクト**: ルートから現在ディレクトリまで各階層を走査。各ディレクトリで `AGENTS.override.md` → `AGENTS.md` → フォールバック名の順
3. **マージ**: ルートから下に向かって連結（下位が後に追加され優先）

**構成例:**
```
AGENTS.md                           # リポジトリルート
services/
  payments/
    AGENTS.override.md              # payments固有（ルートをオーバーライド）
  search/
    AGENTS.md                       # search固有のガイダンス
```

`services/payments/` で実行時の命令チェーン: グローバル → ルート → payments override

**カスタマイズ:**
```toml
project_doc_fallback_filenames = ["TEAM_GUIDE.md", ".agents.md"]
project_doc_max_bytes = 65536  # デフォルト32KB
```

**Pros:**
- サブディレクトリごとに段階的な命令追加・オーバーライドが可能
- `AGENTS.override.md` で上位の指示を完全に差し替え可能
- フォールバックファイル名でチーム固有の命名規則に対応
- 空ファイルは自動スキップ

**Cons:**
- `project_doc_max_bytes`（デフォルト32KB）の制限
- Claude Code の遅延読み込みに相当する機能はない（全階層を起動時に連結）
- AGENTS.md はフラットなMarkdownで、YAMLフロントマターのパススコープはなし


## 3. モノレポでのAI設定パターン

### 3.1 Cursor .cursor/rules/*.mdc

**4つのアクティベーションモード:**

| モード | 動作 |
|-------|------|
| **Always On** | 全インタラクションで常時適用 |
| **Auto Attached** | マッチするファイルがエディタで開いている時に自動適用 |
| **Model Decision** | AIがルール説明を見て関連性を自動判断 |
| **Manual** | `@` メンションで明示的に呼び出し |

**ファイル構成例:**
```
.cursor/
└── rules/
    ├── frontend.mdc        # Auto Attached: src/components/**
    ├── backend.mdc         # Auto Attached: src/api/**
    ├── deployment.mdc      # Manual: デプロイ時のみ
    └── code-style.mdc      # Always On: 全コード共通
```

### 3.2 GitHub Copilot .github/instructions/

**2025年7月よりスコープ付き命令をサポート。** YAMLフロントマターの `applyTo` でglobパターン指定。

**ファイル構成例:**
```
.github/
├── copilot-instructions.md           # 全体共通
└── instructions/
    ├── typescript.instructions.md    # applyTo: "**/*.tsx"
    ├── python.instructions.md        # applyTo: "**/*.py"
    └── config.instructions.md        # applyTo: "*.{json,yaml,toml}"
```

**フロントマター例:**
```yaml
---
applyTo: "**/*.tsx"
---
Use functional components with TypeScript interfaces.
```

### 3.3 Windsurf .windsurf/rules/

**3つのアクティベーションモード:** Always On, Manual, Model Decision

**ファイル構成例:**
```
.windsurf/
└── rules/
    ├── always-on.md        # 常時適用
    ├── backend-rules.md    # Model Decision
    └── deployment.md       # Manual
```

**制限:** ルールファイル個別 6,000文字、合計 12,000文字の上限。

### 3.4 ツール横断比較

| 観点 | Claude Code | Codex CLI | Cursor | Copilot | Windsurf |
|------|------------|-----------|--------|---------|----------|
| 設定ディレクトリ | `.claude/rules/` | ディレクトリ階層AGENTS.md | `.cursor/rules/` | `.github/instructions/` | `.windsurf/rules/` |
| ファイル形式 | `.md` + YAML | `.md`（フラット） | `.mdc` | `.instructions.md` | `.md` |
| パススコープ | `paths:` glob | ディレクトリ配置 | Auto Attached | `applyTo:` glob | なし |
| AI自動判断 | skills desc | なし | Model Decision | なし | Model Decision |
| エージェント分離 | agents/ + skills | profiles + agents | なし | なし | なし |
| サイズ制限 | 200行推奨/file | 32KB合計 | 不明 | 不明 | 6KB/file, 12KB合計 |

### 3.5 AGENTS.md 共通標準

AGENTS.md は事実上のクロスツール標準となりつつある。Codex CLI, GitHub Copilot, Cursor, Windsurf, Amp, Devin がネイティブに読み取る。Claude Code は CLAUDE.md を使用するが、`@AGENTS.md` インポートで互換性確保可能。

**推奨パターン:**
```markdown
# CLAUDE.md
@AGENTS.md

## Claude Code 固有設定
- plan モードで src/billing/ の変更を行うこと
```


## 4. マルチエージェント協調パターン

### 4.1 ペルソナベースのエージェント設計

1プロジェクト内で複数の「専門家」エージェントを定義し、タスク特性に応じて自動的または明示的に委譲するパターン。

**実践的なエージェント構成例:**
```
.claude/agents/
├── code-reviewer.md        # 品質・セキュリティ・メンテナビリティ
├── debugger.md             # エラー解析・根本原因特定・修正
├── data-scientist.md       # SQL/BigQuery分析・レポート
├── test-writer.md          # テスト設計・実装・カバレッジ
├── architect.md            # 設計判断・アーキテクチャレビュー
└── security-auditor.md     # 脆弱性スキャン・セキュリティ監査
```

### 4.2 テスト専用エージェント

```yaml
---
name: test-runner
description: Run tests and report failures. Use proactively after code changes.
tools: Bash, Read, Grep, Glob
model: haiku
permissionMode: dontAsk
---
Run the test suite and report only failing tests with error messages.
Focus on:
1. Which tests failed
2. Error messages and stack traces
3. Likely root cause
4. Suggested fix
```

**利点:** テスト出力がメインコンテキストを汚染しない。Haikuモデルで低コスト。

### 4.3 コードレビュー専用エージェント

```yaml
---
name: code-reviewer
description: Expert code review specialist. Use proactively after code changes.
tools: Read, Grep, Glob, Bash
model: inherit
memory: project
---
Review checklist:
- Critical issues (must fix)
- Warnings (should fix)
- Suggestions (consider improving)
```

**永続メモリ** でプロジェクト固有のパターンや過去のレビュー知見を蓄積。

### 4.4 Agent Teams による協調探索

```
3つのteammateを生成:
- Security reviewer: 脆弱性を監査
- Performance analyst: レスポンスタイムをプロファイル
- Test coverage checker: エッジケースを検証
共有タスクリストで連携させること。
```

**適用ケース:**
- 競合する仮説の検証
- クロスレイヤー機能（フロントエンド + バックエンド + テスト）
- アーキテクチャ議論（複数視点の合意形成）

**不適用ケース:**
- 逐次的タスク
- 同一ファイルの編集
- エージェント間の依存がない作業

### 4.5 スキル + サブエージェントの組み合わせパターン

**方向1: スキルをサブエージェント内で実行（`context: fork`）**
```yaml
---
name: deep-research
description: Research a topic thoroughly
context: fork
agent: Explore
---
Research $ARGUMENTS thoroughly...
```

**方向2: サブエージェントにスキルを事前読み込み**
```yaml
---
name: api-developer
description: Implement API endpoints following team conventions
skills:
  - api-conventions
  - error-handling-patterns
---
```

### 4.6 実プロジェクトでの適用事例

- **Anthropic公式 Code Review**: 並列コードレビューエージェントを発送してバグを検出
- **gstack（Garry Tan）**: 28スキルのロールベース仮想開発チーム。安全ガードレール付き
- **wshobson/agents**: Claude Code 向けマルチエージェントオーケストレーション OSS


## 5. 非技術ドメインのハーネス設計

### 5.1 非コーディング用途のエージェント設計

Claude Code のサブエージェント・スキル機構はコーディング以外にも応用可能。公式ドキュメントの data-scientist エージェント例が示すように、ツールをBash + Read + Write に限定し、プロンプトをドメイン特化させることで非技術タスクを実行できる。

**非技術ドメインのエージェント構成例:**
```
.claude/agents/
├── market-researcher.md      # 市場調査・競合分析
├── content-writer.md         # マーケティングコンテンツ作成
├── data-analyst.md           # データ分析・レポート生成
├── strategy-advisor.md       # 戦略立案・意思決定支援
└── document-reviewer.md      # ドキュメント品質レビュー
```

### 5.2 具体的なユースケースと実装パターン

**マーケティング・市場調査:**
```yaml
---
name: market-researcher
description: Conduct market research and competitive analysis
tools: Bash, Read, Write, Grep, Glob
model: opus
memory: project
---
You are a market research analyst. When invoked:
1. Gather data from available sources
2. Analyze competitive landscape
3. Identify trends and opportunities
4. Generate structured reports with recommendations
Update your agent memory with market insights for future reference.
```

**ドキュメント分析:**
```yaml
---
name: document-reviewer
description: Review documents for quality, consistency, and completeness
tools: Read, Grep, Glob
model: sonnet
---
Review documents for:
- Logical consistency
- Completeness of information
- Writing quality and clarity
- Cross-reference accuracy
```

**自律学習・知識蓄積:**
```yaml
---
name: knowledge-builder
description: Research topics and build knowledge base
context: fork
agent: Explore
memory: project
---
Research $ARGUMENTS and update the knowledge base:
1. Search existing knowledge files
2. Identify gaps
3. Research and synthesize new information
4. Update knowledge base with structured findings
```

### 5.3 業界トレンド（2025-2026）

**AIエージェントの主要非コーディング用途（Zapier 2026年調査）:**
- 調査・大量情報の要約: 58%
- ドキュメント分析・要約: 41%
- カスタマーサポート: 41%
- レポート生成: 36%

**エージェントハーネスの概念（Phil Schmid, 2026）:**
- モデル = CPU（処理能力）
- コンテキストウィンドウ = RAM（作業メモリ）
- エージェントハーネス = OS（コンテキスト管理、ブートシーケンス、ツール処理）
- エージェント = アプリケーション（ユーザー固有ロジック）

**2026年のハーネス設計3原則:**
1. **シンプルさ優先**: 複雑な制御フローを避け、原子的なツールを提供してモデルに戦略を委ねる
2. **モジュラーアーキテクチャ**: 新モデル登場時に容易に差し替え可能な設計
3. **データが競争優位**: ハーネスが捕捉する実行軌跡（特に失敗パターン）がトレーニングデータとなり、プロンプトではなく実行データが差別化要因に


## 6. harness-harness への統合提案

### 6.1 推奨パターン: 階層型ハーネス設計

```
target-project/
├── CLAUDE.md                        # L0: プロジェクト共通（200行以内）
├── AGENTS.md                        # L0: Codex/Copilot/他ツール互換
├── .claude/
│   ├── CLAUDE.md                    # L0: Claude固有の追加指示
│   ├── rules/
│   │   ├── code-style.md           # L1: 常時適用ルール
│   │   ├── api-design.md           # L2: paths指定ルール
│   │   ├── react-patterns.md       # L2: paths指定ルール
│   │   └── testing.md              # L2: paths指定ルール
│   ├── skills/
│   │   ├── deploy/SKILL.md         # タスクスキル（手動起動）
│   │   ├── review-pr/SKILL.md      # タスクスキル（手動起動）
│   │   └── api-guide/SKILL.md      # 参照スキル（自動起動）
│   └── agents/
│       ├── code-reviewer.md        # 専門エージェント
│       ├── test-runner.md          # 専門エージェント
│       └── researcher.md           # 専門エージェント
├── .codex/
│   └── config.toml                 # Codexプロファイル定義
├── .cursor/
│   └── rules/
│       ├── frontend.mdc
│       └── backend.mdc
├── .github/
│   └── instructions/
│       ├── typescript.instructions.md
│       └── python.instructions.md
└── .windsurf/
    └── rules/
        └── code-style.md
```

### 6.2 設計判断マトリクス

| 目的 | Claude Code | Codex CLI | 備考 |
|------|------------|-----------|------|
| 常時適用ルール | CLAUDE.md + rules/(pathsなし) | AGENTS.md | 200行以内に保つ |
| パス別ルール | rules/(paths指定) | ディレクトリ別AGENTS.md | Claude優位 |
| 目的別設定切替 | agents/ + skills | profiles | 異なるアプローチ |
| 安全制約 | agents(tools制限) + hooks | sandbox_mode + approval_policy | 両方必要 |
| 知識蓄積 | auto memory + agent memory | なし | Claude固有 |
| マルチエージェント | Agent Teams | agents.max_threads | Claude優位 |

### 6.3 テンプレート化の方針

1. **コーディング用ハーネス**: rules(paths付き) + agents(reviewer, tester, debugger) + skills(deploy, review-pr)
2. **調査用ハーネス**: agents(researcher with memory) + skills(research-kb) + Agent Teams
3. **非技術用ハーネス**: agents(analyst, writer, advisor) + skills(report, analysis)
4. **モノレポ用ハーネス**: サブディレクトリCLAUDE.md + ネストskills + claudeMdExcludes


## Sources

- [Claude Code Skills Documentation](https://code.claude.com/docs/en/skills)
- [Claude Code Subagents Documentation](https://code.claude.com/docs/en/sub-agents)
- [Claude Code Memory Documentation](https://code.claude.com/docs/en/memory)
- [Codex CLI Advanced Configuration](https://developers.openai.com/codex/config-advanced)
- [Codex CLI Configuration Reference](https://developers.openai.com/codex/config-reference)
- [Codex CLI AGENTS.md Guide](https://developers.openai.com/codex/guides/agents-md)
- [Claude Code Rules: Stop Stuffing Everything into One CLAUDE.md](https://medium.com/@richardhightower/claude-code-rules-stop-stuffing-everything-into-one-claude-md-0b3732bca433)
- [CLAUDE.md, AGENTS.md, and Every AI Config File Explained](https://www.deployhq.com/blog/ai-coding-config-files-guide)
- [Claude Code Agent Teams Guide](https://claudefa.st/blog/guide/agents/agent-teams)
- [The Importance of Agent Harness in 2026](https://www.philschmid.de/agent-harness-2026)
- [Claude Code Multiple Agent Systems Guide](https://www.eesel.ai/blog/claude-code-multiple-agent-systems-complete-2026-guide)
- [Agentic Coding 2026: Multi-Agent AI Teams](https://aiautomationglobal.com/blog/agentic-coding-revolution-multi-agent-teams-2026)
- [State of Agentic AI Adoption Survey 2026 (Zapier)](https://zapier.com/blog/ai-agents-survey/)
- [The Complete .claude Directory Guide](https://computingforgeeks.com/claude-code-dot-claude-directory-guide/)
- [Claude Code Path-Specific Rules](https://paddo.dev/blog/claude-rules-path-specific-native/)
- [AI Agent Trends 2026 (Google Cloud)](https://cloud.google.com/resources/content/ai-agent-trends-2026)
