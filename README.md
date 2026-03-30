# harness-harness

ハーネスを作り、育て、壊して作り直すハーネスの母艦。

## 概要

AI実行基盤（Claude Code CLI, Codex CLI）のハーネス（CLAUDE.md, AGENTS.md, settings, hooks, skills, rules等）を作成・管理するメタプロジェクト。対象プロジェクトに最適化されたハーネスを生成し、継続的に診断・改善する。harness-harness自体も自己改善の対象。

### 対象AI実行基盤

- Claude Code CLI（`.claude/`）
- Codex CLI（`.codex/`, `.agents/`）
- Agent Skillsオープンスタンダード（`SKILL.md`）準拠 — 33+プラットフォーム互換

## スキル一覧（10種）

### ハーネス操作

| スキル | 概要 |
|--------|------|
| `create-harness` | 新規プロジェクトにClaude/Codexハーネスを作成。philosophy.md思想を二層構造（基本思想+行動規則）で注入、推薦スキル選定・注入、Hooks/rules自動生成 |
| `diagnose-harness` | 既存ハーネスの診断→改善提案→実装→PR→フィードバック（ADR-001準拠5ステップ） |
| `sync-harness` | Claude⇔Codex間のハーネス双方向同期。「翻訳より先にネイティブ」原則 |
| `switch-harness` | 目的別ハーネスの切り替え。`.claude-dev/`, `.claude-refactor/`等＋symlink |
| `init-project` | 新規プロジェクトをゼロから立ち上げ。GitHub repo作成→初期ファイル→ハーネス→ドメイン知見→引き継ぎまで一気通貫 |

### 調査・巡回

| スキル | 概要 |
|--------|------|
| `research-kb` | 外部ツール・技術・業務ドメインの徹底調査→kb/に追加。Claude/Codexクロスレビュー。frontmatter必須 |
| `research-theme` | 長期調査研究テーマをwave単位で継続更新。ベンチマーク実行含む。多様性は善（単一winner決めず用途別推奨） |
| `patrol-docs` | Claude Code/Codex CLI公式ドキュメント＋スキルエコシステムの定期巡回。キャッシュベース差分検出 |

### 横断・インフラ

| スキル | 概要 |
|--------|------|
| `cross-project-copy` | 管理対象プロジェクト間でハーネス設定を相互コピー補完。汎用性5段階判定 |
| `launchd-schedule` | macOS launchd+tmuxで定期実行。マルチプロジェクト対応（`SCHEDULE_PROJECT`） |

## ナレッジベース（kb/）

### kb/external/ — 外部プロジェクト調査（9件）

OpenClaw, gstack, superpowers, autoresearch, DeerFlow, everything-claude-code, AiToEarn, claude-peers, claude-subconscious

### kb/domains/ — 業務ドメイン知見

ユーザー指示に基づき徹底調査した業務ドメイン知見。content-monetization等。

### kb/skills/ — スキルエコシステム管理

公式・コミュニティスキルの推薦管理。Tier A（10件）+ Tier B（6件）。週1巡回。

### kb/research-themes/ — 研究テーマ

長期調査研究テーマ。AI自律画像生成（5モデル×3題材=15枚ベンチマーク実証済み）。

### kb/techniques/ — 戦術的知見

Playwright MCPによるSPAページ取得等。

### private/kb/ — ベンダー固有ナレッジ

特定ベンダー固有・機密性のあるナレッジ。vendors/, external/, domains/, intake/。

## 設計思想

`docs/philosophy.md` に詳細。主要原則:

- **段階的開示**: 必要なときに必要なだけ。CLAUDE.md 200行以下、詳細はrules/docs/に分離
- **透過性**: AIの判断をユーザーが検証可能に
- **指示追従 < AI提案**: AIの知識を最大限活用し、より良い代替案を提案
- **自律完遂**: タスク完了まで中断せず。段階的に自律度を高める
- **自己評価**: 作業完了後に自己評価。省略厳禁
- **多様性は善**: 答えを1つに絞らず、pros/consを明示
- **実践先行**: 過剰scaffoldしない。最小限で始めて実践で育てる

## ディレクトリ構成

```
docs/           思想・方針、アーキテクチャ、規約、ADR
specs/          Claude Code / Codex CLIの仕様書（巡回で自動更新）
kb/             外部プロジェクト調査、業務ドメイン知見、スキルエコシステム、研究テーマ
  external/     外部プロジェクト調査（9件）
  domains/      業務ドメイン知見
  skills/       スキルエコシステム管理
  research-themes/  長期研究テーマ
  techniques/   戦術的知見
templates/      ハーネステンプレート（Claude/Codex × 目的別）
mapping/        Claude⇔Codex変換ルール
scripts/        クロスプラットフォームユーティリティ
logs/           巡回・評価ログ（匿名化済み）
private/        git submodule（プロジェクト固有・機密データ）
  registry/     管理対象プロジェクト一覧
  kb/           ベンダー固有ナレッジ
  logs/         プロジェクト固有ログ
```

## 開発プロセス

### ブランチ戦略

- `main`: 安定版。PR必須（軽微な修正を除く）
- `feature/*`: 新機能・改善
- `research/*`: 調査テーマ
- `patrol/*`: 巡回更新

### worktree運用

mainは司令塔。日常の編集作業はworktreeで行う。

- Claude Code: `EnterWorktree`ツールで`.claude/worktrees/`に作成
- Codex CLI: `git worktree add` → `codex exec -C <worktree>`で対象化
- worktreeパス: `../<repo>-wt-<branch-short>/`

### Claude/Codexクロスレビュー

非trivialな作業はClaude/Codex双方が計画策定→クロスレビュー→統合→実装→Codexレビュー。Codex結果なしにPR作成は禁止。

## 管理対象プロジェクト

`private/registry/projects.md`で管理。ハーネス改善・巡回・コピー補完の対象。

## セットアップ

```bash
git clone https://github.com/nomuvan/harness-harness.git
cd harness-harness

# private submoduleが必要な場合
git submodule update --init --recursive

# Claude Code
claude

# Codex CLI
codex
```

## ReadOnlyモード

push権限やprivate submoduleへのアクセスがなくてもReadOnlyで利用可能。AIがspecs/, kb/, mapping/, templates/を参照して対象プロジェクトのハーネスを自動生成できる。MITライセンスなので自由にforkして独自に育ててOK。詳細は[docs/readonly-mode.md](docs/readonly-mode.md)参照。

## ライセンス

MIT
