# kb/ 変更履歴

## 2026-03-23 — 外部プロジェクト初期調査

### 追加ファイル
- `kb/external/_index.md` — 外部プロジェクト調査レジストリ
- `kb/external/openclaw/analysis.md` — OpenClaw深掘り分析
- `kb/external/openclaw/takeaways.md` — OpenClawからの知見と採用判断
- `kb/external/gstack/analysis.md` — gstack深掘り分析
- `kb/external/gstack/takeaways.md` — gstackからの知見と採用判断
- `kb/external/superpowers/analysis.md` — superpowers深掘り分析
- `kb/external/superpowers/takeaways.md` — superpowersからの知見と採用判断

### 削除ファイル
- `kb/external/openclaw/.gitkeep`
- `kb/external/gstack/.gitkeep`
- `kb/external/superpowers/.gitkeep`

### 調査概要

3つの主要な外部プロジェクトを調査:

1. **OpenClaw** (Peter Steinberger) — ローカルファーストの自律AIエージェント。20+チャネル統合、53+バンドルスキル、180,000+ GitHub Stars。パーソナルAIアシスタントとしての方向性はharness-harnessと異なるが、SKILL.mdフォーマット標準・3層スキル優先順位・ゲーティング機構を採用。

2. **gstack** (Garry Tan) — ロールベースの仮想開発チームワークフロー。28スキル、構造化スプリントプロセス。安全ガードレール（/careful, /freeze, /guard）・2層テスティング・グローバル/ローカルインストールモデルを採用。

3. **superpowers** (Jesse Vincent) — マルチプラットフォームスキルフレームワーク。Claude Code/Codex/Cursor/OpenCode対応。SKILL.mdフロントマター標準の策定者。マルチプラットフォームディレクトリ構造・Hookベース初期化・CSO概念を採用。

### 横断的な主要判断

| 判断 | 項目 |
|------|------|
| 採用（高優先度） | SKILL.mdフロントマター標準、マルチプラットフォームディレクトリ構造、安全ガードレール、構造化プロセステンプレート、Hookベース初期化、グローバル/ローカルインストール |
| 採用（中優先度） | 3層スキル優先順位、ゲーティング機構、CSO、2層テスティング、クロスモデル対応 |
| 検討 | シンボリックリンク戦略、ロールベース設計、ワークフロー選択肢、Git Worktree、自己修正型エージェント |
| 不採用 | マルチチャネル統合（範囲外）、常駐デーモンモデル（過剰） |

## 2026-03-23 — project-alpha初回dogfoodingフィードバック

### 追加ファイル
- `logs/evaluations/2026-03-23-project-alpha-diagnosis.md` — project-alphaハーネス診断レポート
- `logs/evaluations/2026-03-23-project-alpha-improvement-proposal.md` — 改善提案書
- `logs/evaluations/2026-03-23-project-alpha-feedback.md` — 改善実施後のフィードバック
- `docs/decisions/ADR-001-harness-improvement-process.md` — 作業プロセス標準化

### 主な学び
- セキュリティhookに `|| true` は禁物（テンプレートに反映要）
- hookのJSONパースはjq必須（テンプレートの前提条件に追加要）
- 診断は推測ではなくファイル内容を実際にパースして判定すべき
- gitignored設定の改善はPR対応不可（手動推奨として別セクション化要）
- claude-pr-reviewの指摘品質が高い（ワークフローテンプレート化候補）

## 2026-03-24 — Codex CLI Skills/Hooks サポート発見・仕様反映

### 発見内容

Codex CLI が以下の機能をサポートしていることを確認:

1. **Skills（stable）**: SKILL.md フロントマター形式で Claude Code と完全互換。`.codex/skills/`（プロジェクト）、`~/.codex/skills/`（グローバル）に配置。バンドルスキル 3 種（`skill-creator`, `skill-installer`, `openai-docs`）。`/skills` コマンド、`$` メンション、暗黙マッチングで起動。`skill_mcp_dependency_install` フラグは stable。

2. **Hooks（実験的）**: `codex_hooks` フラグで有効化（デフォルト無効）。対応イベントは `SessionStart`, `Stop`, `UserPromptSubmit` の 3 種のみ（Claude Code は 17+）。ハンドラは `command` のみ（Claude は command/HTTP/Prompt/Agent の 4 種）。`config.toml` の `[[hooks]]` テーブル配列で設定。終了コード 2 でブロック可能（`UserPromptSubmit`）。

### 更新ファイル

- `specs/codex/configuration.md` — Skills（セクション 6）と Hooks（セクション 7）を追加
- `mapping/claude-to-codex.md` — Skills セクションを「対応なし」→「直接対応」に更新。Hooks セクションを「対応なし」→「部分対応（実験的）」に更新
- `mapping/codex-to-claude.md` — Skills（セクション 5）と Hooks（セクション 6）を新規セクションとして追加。以降のセクション番号を繰り下げ
- `mapping/shared-concepts.md` — Skills（セクション 9）を共通概念として追加。Hooks（セクション 10）を「なし」→「実験的サポート」に更新。機能対応サマリー表を更新
- `docs/codex-plan.md` — 「Hooks 不在はラッパースクリプトで埋める」→「Hooks はネイティブ + ラッパースクリプトの併用で埋める」に更新。Claude 先行領域の記述を修正
- `kb/changelog.md` — 本エントリを追加

### 影響と方針変更

- **Skills は完全な共通概念に昇格**: `.claude/skills/` と `.codex/skills/` で SKILL.md を共有可能。harness-harness のスキルテンプレート戦略を共通化できる
- **Hooks は部分的共通概念**: 3 イベント（SessionStart, Stop, UserPromptSubmit）は両プラットフォームで利用可能。残りは引き続き Claude 固有
- **codex-plan.md の方針修正**: Hooks 代替のラッパースクリプトは引き続き必要だが、共通 3 イベントについてはネイティブ Hooks を優先利用する方針に変更
