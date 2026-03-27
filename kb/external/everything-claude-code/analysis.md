---
name: "Everything Claude Code"
url: "https://github.com/affaan-m/everything-claude-code"
type: knowledge-collection
tags: [harness, skills, hooks, agents, security, cross-platform]
stars: 108000
license: "MIT"
last_checked: "2026-03-27"
relevance: high
summary: "AIコーディングエージェント向け全方位パフォーマンス最適化ハーネスシステム、125+スキル・28エージェント"
---

# Everything Claude Code (ECC) — 深掘り分析

## 基本情報

| 項目 | 詳細 |
|------|------|
| 名前 | Everything Claude Code (ECC) |
| URL | https://github.com/affaan-m/everything-claude-code |
| 作者 | Affaan Mustafa (@affaanmustafa) |
| ライセンス | MIT |
| GitHub Stars | 109,700+ (2026-03-26時点) |
| Forks | 14,300+ |
| Contributors | 113+ |
| 言語 | JavaScript (Node.js) |
| 作成日 | 2026-01-18 |
| 最新バージョン | v1.9.0 (2026-03) |
| 対応プラットフォーム | Claude Code, Codex CLI, Cursor, OpenCode, Kiro |
| 対応OS | Windows (PowerShell), macOS, Linux |

## 背景・経緯

- 2025年9月: Anthropic x Forum Ventures ハッカソン（NYC）で優勝。$15,000のAPIクレジット獲得。zenith.chatを8時間でClaude Codeのみで構築
- 10ヶ月以上のClaude Code日常使用から蒸留された実戦的設定集
- 2026年1月にGitHub公開、3月に100K Stars突破
- 「Context Rot Kills Long Sessions」問題への体系的解答

## 概要

AIコーディングエージェント向けの**パフォーマンス最適化ハーネスシステム**。単なる設定ファイル集ではなく、スキル・エージェント・フック・ルール・メモリ永続化・セキュリティスキャン・継続学習を統合したフレームワーク。

「.editorconfigのAIコーディングツール版」として、単一リポジトリから複数プラットフォームに統一的な設定を配布する。

## アーキテクチャ

### 4層構造

```
┌─────────────────────────────────────────┐
│ Layer 1: User Interaction               │
│   32 Commands + Rules (always-follow)   │
├─────────────────────────────────────────┤
│ Layer 2: Intelligence                   │
│   28 Agents + 125+ Skills (on-demand)   │
├─────────────────────────────────────────┤
│ Layer 3: Automation                     │
│   Hooks (PreToolUse, PostToolUse, etc.) │
├─────────────────────────────────────────┤
│ Layer 4: Learning                       │
│   Continuous Learning v1/v2 + Memory    │
└─────────────────────────────────────────┘
```

### ディレクトリ構成

```
everything-claude-code/
├── .claude-plugin/      # プラグインマニフェスト
├── agents/              # 28 特化エージェント（Markdown + YAML frontmatter）
├── skills/              # 125+ ワークフロー定義（SKILL.md形式）
├── commands/            # 60+ スラッシュコマンド（Markdown）
├── rules/               # 言語別ルール
│   ├── common/          #   共通ルール
│   ├── typescript/      #   TypeScript固有
│   ├── python/          #   Python固有
│   ├── golang/          #   Go固有
│   └── ...              #   12言語対応
├── hooks/               # hooks.json + スクリプト群
├── scripts/             # クロスプラットフォームNode.jsユーティリティ
├── contexts/            # 動的システムプロンプト注入
├── examples/            # プロジェクト設定テンプレート（SaaS, Go, Django, Rust）
├── mcp-configs/         # MCP設定テンプレート
├── manifests/           # 選択的インストール用マニフェスト
├── schemas/             # JSONスキーマ
├── tests/               # 997+テスト
├── ecc2/                # 次世代アーキテクチャ（開発中）
├── plugins/             # プラグインサポート
├── the-shortform-guide.md  # 入門ガイド
├── the-longform-guide.md   # 上級者ガイド
├── the-security-guide.md   # セキュリティガイド
└── CLAUDE.md            # ECC自体のハーネス設定
```

### プラットフォーム別ディレクトリ

```
├── .claude/             # Claude Code用
├── .codex/              # Codex CLI用
├── .cursor/             # Cursor用
├── .opencode/           # OpenCode用
├── .kiro/               # Kiro用
└── AGENTS.md            # クロスツール標準（Codex, Copilot, Cursor等が読取）
```

## 主要機能

### 1. エージェント群（28体）

| カテゴリ | エージェント | ツール権限 | モデル |
|----------|-------------|-----------|--------|
| 計画 | planner | Read, Grep, Glob | Opus |
| 設計 | architect | Read, Grep, Glob | Opus |
| TDD | tdd-guide | Code + Test | Sonnet |
| レビュー | code-reviewer | Read-only | Sonnet |
| セキュリティ | security-reviewer | Read-only | Opus |
| ビルド修復 | build-error-resolver | Build tools | Sonnet |
| 言語別レビュー | typescript/python/go/java/kotlin/rust/cpp/flutter-reviewer | Read-only | Sonnet |
| 言語別ビルド | go/java/kotlin/rust/cpp/pytorch-build-resolver | Build tools | Sonnet |
| E2E | e2e-runner | Test execution | Sonnet |
| リファクタ | refactor-cleaner | Code editing | Sonnet |
| ドキュメント | doc-updater | Doc editing | Sonnet |
| ドキュメント検索 | docs-lookup | Read | Haiku |
| ハーネス最適化 | harness-optimizer | Read, Glob | Opus |
| ループ制御 | loop-operator | All | Sonnet |
| 統括 | chief-of-staff | Read | Opus |

**設計原則**: 階層的委任。オーケストレータが特化エージェントにツール権限を制限して委任。

### 2. スキル群（125+カテゴリ）

主要カテゴリ:
- **バックエンド**: API設計, データベース, キャッシング, マイグレーション
- **フロントエンド**: React, Next.js, Nuxt, デザインシステム
- **言語特化**: Django, Spring Boot, Laravel, Go, Rust, C++, Swift, Kotlin, Perl
- **テスト**: TDDワークフロー, E2E, 言語別テスト
- **AI/ML**: PyTorchパターン, LLMパイプライン, プロンプト最適化
- **DevOps**: Docker, デプロイ, PM2
- **セキュリティ**: セキュリティスキャン, セキュリティレビュー
- **継続学習**: continuous-learning v1/v2, instinct管理
- **自律**: autonomous-loops, continuous-agent-loop
- **ビジネス**: 記事執筆, 市場調査, 投資家資料
- **ハーネス**: agent-harness-construction, eval-harness, agent-eval

**SKILL.mdフォーマット例**:
```markdown
---
name: tdd-workflow
description: TDDワークフロー。新機能/バグ修正/リファクタ時に使用。
origin: ECC
---
# Test-Driven Development Workflow
## When to Activate
## Core Principles
## TDD Workflow Steps
## Testing Patterns
```

### 3. フックシステム

| イベント | 用途 | 例 |
|----------|------|-----|
| PreToolUse(Bash) | git --no-verify ブロック | block-no-verify |
| PreToolUse(Bash) | tmuxリマインダー | pre-bash-tmux-reminder |
| PreToolUse(Write/Edit) | linter設定変更ブロック | config-protection |
| PreToolUse(*) | 継続学習観察 | observe (async) |
| PreToolUse(*) | MCPヘルスチェック | mcp-health-check |
| PreCompact | コンパクション前の状態保存 | pre-compact |
| SessionStart | 前回コンテキスト読込 | session-start |
| Stop | セッション終了時の学習保存 | stop |

**プロファイル制御**: `ECC_HOOK_PROFILE=minimal|standard|strict` で重み付け。

### 4. ルールシステム

```
rules/
├── common/       # 全言語共通（コーディングスタイル, Git, テスト, セキュリティ, パフォーマンス）
├── typescript/   # TypeScript固有
├── python/       # Python固有
├── golang/       # Go固有
└── ...           # 12言語対応
```

### 5. セキュリティ機能（AgentShield）

- 102 AgentShield静的解析ルール
- 1,282セキュリティテスト
- 7層オブザーバーループ防止
- シークレット検出パターン（sk-, ghp_, AKIA）
- メモリ爆発防止スロットリング
- サンドボックスアクセス強化

### 6. 継続学習システム

- **v1**: セッションからパターンを抽出しスキル化
- **v2**: イベントフックで100%カバレッジ。「instinct」（信頼度スコア付き）としてパターン蓄積。import/export対応。成熟したinstinctはスキルに昇格

### 7. インストールアーキテクチャ（v1.9.0）

- **選択的インストール**: `./install.sh python` で言語別にインストール
- **マニフェスト駆動**: install-plan.js + install-apply.js でインクリメンタル更新
- **SQLite状態ストア**: インストール済みコンポーネント追跡
- **クロスプラットフォーム**: install.sh (macOS/Linux) + install.ps1 (Windows) + npx ecc-install
- **プラグインマーケットプレース**: `/plugin marketplace add affaan-m/everything-claude-code`

## ガイド（3部構成）

### Shortform Guide（入門）
- スキル/コマンドの基礎
- フック設計パターン
- サブエージェント原則
- ルールとメモリ
- MCP設定最適化（「200kコンテキストが70kになりうる」警告）
- CLAUDE.mdベストプラクティス

### Longform Guide（上級者）
- **トークン最適化**: タスク別モデル選択（Haiku=探索, Sonnet=コーディング90%, Opus=設計/セキュリティ）
- **メモリ永続化**: .tmpファイルに検証済み知見/失敗/未試行を記録。PreCompact/Stop/SessionStartフックで自動管理
- **動的プロンプト注入**: `claude --system-prompt "$(cat memory.md)"` で権限階層を活用
- **評価方法**: pass@k（k=3で91%成功率）vs pass^k（一貫性検証）
- **並列化**: Git Worktree + Cascade Method（3-4タスク上限、左→右処理）
- **2インスタンスキックオフ**: Scaffolding Agent + Research Agent 同時起動

### Security Guide
- 攻撃ベクトル分析
- サンドボックス設定
- 入力サニタイゼーション
- CVE対応
- AgentShield設定

## CLAUDE.md設計

ECC自体のCLAUDE.mdは以下を含む:
- Project Overview（プラグインであることの明示）
- Running Tests（テストコマンド）
- Architecture（コンポーネント一覧と責務）
- Key Commands（主要スラッシュコマンド）
- Development Notes（フォーマット規約、パッケージマネージャ検出、ファイル命名）
- Contributing（エージェント/スキル/コマンド/フックの書式）

**特徴**: 簡潔（約60行）。プロジェクト固有のビルド/テスト/アーキテクチャ情報に集中。冗長な指示は rules/ に分離。

## 評価

### 強み

1. **実戦由来**: 10ヶ月の日常使用から蒸留。理論的でなく実用的
2. **規模と網羅性**: 28エージェント, 125+スキル, 60+コマンド, 12言語対応。「全部入り」
3. **セキュリティファースト**: AgentShield, フックベースのガードレール, config-protection
4. **クロスプラットフォーム**: 単一設定で5ツール対応。AGENTS.mdによるクロスツール標準化
5. **選択的インストール**: 言語/目的別に必要なものだけインストール可能
6. **継続学習**: セッション間でパターン蓄積。instinct → skill 昇格パイプライン
7. **ドキュメント充実**: 3部構成ガイド + 7言語翻訳
8. **テスト充実**: 997+テスト、CI整備
9. **コミュニティ**: 113+コントリビュータ、活発な開発

### 弱み

1. **肥大化リスク**: 125+スキルは多くのプロジェクトで過剰。選択的インストールで緩和されるが複雑さは残る
2. **JavaScript依存**: フックスクリプトがNode.js前提。非Node.jsプロジェクトでもNode.jsランタイムが必要
3. **学習曲線**: 32コマンド + 28エージェント + 125+スキルの全容把握は困難
4. **Codex CLIサポートの非対称性**: AGENTS.md経由のinstruction-basedのみ。ネイティブフック非対応
5. **v2(ecc2)への移行不確実性**: 次世代アーキテクチャが開発中だが、v1との互換性は不明
6. **過度のnpmパッケージ依存**: block-no-verify等の外部パッケージ呼出しがフックに含まれる
7. **プラグイン配布制限**: ルールはプラグイン経由で配布不可。手動インストール必要

### 品質評価

| 観点 | 評価 | 備考 |
|------|------|------|
| コード品質 | B+ | Node.jsスクリプトは整理されているが、フックの複雑なラッパー構造がやや冗長 |
| テスト | A | 997+テスト。CI/CD整備済み |
| ドキュメント | A | 3部ガイド + CONTRIBUTING.md + 7言語翻訳 |
| アーキテクチャ | A- | 4層構造は明快。ただし125+スキルの管理は今後課題 |
| セキュリティ | A | AgentShield + 1,282テスト + フックガードレール |
| 保守性 | B | 活発だが規模拡大に伴う複雑性増大リスク |
| 汎用性 | A- | 12言語・5プラットフォーム対応。ただしNode.js依存 |

## 類似ツール比較

| 観点 | Everything Claude Code | OpenClaw | superpowers | gstack | SuperClaude Framework |
|------|----------------------|----------|-------------|--------|----------------------|
| Stars | 109K | 180K | 107K | 不明 | 不明 |
| スキル数 | 125+ | 53+バンドル / 13,700+ハブ | フレームワーク型 | 28 | 不明 |
| エージェント数 | 28 | チャネル統合型 | N/A | ロールベース | ペルソナベース |
| フック | 充実(8+イベント) | ゲーティング | Hookベース初期化 | ガードレール | 不明 |
| プラットフォーム | 5ツール | 独自基盤 | 4ツール | Claude Code | Claude Code |
| インストール | 選択的/マニフェスト | パッケージマネージャ | シンボリックリンク | npm | 不明 |
| 焦点 | 全方位パフォーマンス最適化 | パーソナルAI | スキルフレームワーク標準 | チームワークフロー | 認知ペルソナ |
| 継続学習 | v2(instinct) | メモリ永続化 | なし | なし | なし |
| セキュリティ | AgentShield(1,282テスト) | 基本 | なし | ガードレール | なし |

### ECC vs harness-harness のポジション差

| 観点 | ECC | harness-harness |
|------|-----|-----------------|
| 性質 | プラグイン/設定フレームワーク | メタハーネス（ハーネスを作るハーネス） |
| 対象 | エンドユーザー開発者 | ハーネス設計者 |
| 出力 | 直接使える設定 | テンプレート + 設計判断 |
| 多様性 | 「ECC方式」に統一 | 多様性は善（選択肢提示） |
| 自己改善 | 継続学習v2 | 自己評価 + ADR |
| 規模 | 大（全部入り） | 小（必要なだけ） |

## 参考リンク

- メインリポジトリ: https://github.com/affaan-m/everything-claude-code
- Augment Code 分析: https://www.augmentcode.com/learn/everything-claude-code-github
- Apiyi 分析: https://help.apiyi.com/en/everything-claude-code-plugin-guide-en.html
- Medium 記事: https://medium.com/@joe.njenga/everything-claude-code-the-repo-that-won-anthropic-hackathon-33b040ba62f3
- SkillsLLM: https://skillsllm.com/skill/everything-claude-code
