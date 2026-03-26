---
name: diagnose-harness
description: |
  既存プロジェクトのハーネスを診断し、改善提案→実装→PR→フィードバックまで一貫実行するスキル。
  ADR-001の5ステッププロセスを忠実に実装。specs/との突合、kb/のベストプラクティス照合を行う。
  改善提案はA-D優先度で分類し、ユーザーとの対話で取捨選択する。フィードバック省略厳禁。
  「ハーネス診断して」「ハーネス改善して」「CLAUDE.mdをレビューして」で起動。
---

# diagnose-harness スキル

既存プロジェクトのハーネスを診断し、ADR-001の5ステップ（診断→改善提案→実装→PR→フィードバック）を一貫実行する。specs/の最新仕様との乖離、未活用機能、ベストプラクティス違反を検出し、ユーザーとの対話で改善を進める。

## 入力形式

```
/path/to/project のハーネスを診断して
```

```
ハーネス改善して（カレントディレクトリまたはregistry/のプロジェクトが対象）
```

## 処理フロー（ADR-001準拠 5ステップ）

### Phase 1: 診断（ADR-001 ステップ1）

対象プロジェクトのハーネスファイルを全て読み取り、specs/の最新仕様と突き合わせる。

#### 1.1 ハーネスファイル全読取

| 対象 | ファイル |
|------|---------|
| Claude | `CLAUDE.md`, `.claude/settings.json`, `.claude/settings.local.json`, `.claude/rules/`, `.claude/skills/`, `.claude/agents/`, `.mcp.json`, hooks設定 |
| Codex | `AGENTS.md`, `AGENTS.override.md`, `.codex/config.toml`, `.agents/skills/`, `agents/openai.yaml`, hooks設定 |
| 共通 | `docs/shared-instructions.md`（あれば） |

#### 1.2 specs/との突き合わせ

各ファイルをspecs/の最新仕様と照合し、以下を検出:

**仕様乖離の検出**:
- specs/claude/configuration.md: settings.jsonの設定キーが最新か
- specs/claude/hooks.md: 利用可能なHooksイベントの活用状況
- specs/claude/skills-and-commands.md: SKILL.mdのフロントマター形式、非推奨の.claude/commands/使用
- specs/claude/agent-teams.md: Agent Teams機能の活用状況
- specs/claude/mcp.md: MCP設定の妥当性
- specs/codex/configuration.md: config.tomlの設定キー、プロファイル設定

**未活用機能の特定**:
- `context: fork` 未使用（読み取り専用スキルがあるのに）
- `allowed-tools` 未設定（全スキルでフルアクセス）
- Agent Teams未使用（複雑なタスクがあるのに）
- Hooks未活用（SessionStart以外のイベント）
- `@`インポート未使用（CLAUDE.mdが長大）
- Codexプロファイル未設定

**ベストプラクティス違反の検出**:
- specs/claude/best-practices.md: CLAUDE.md 200行超過、検証不能な曖昧指示、LLMが既知の情報の過剰記述
- specs/codex/best-practices.md: AGENTS.md 32KiB超過

#### 1.3 kb/のベストプラクティスとの照合

kb/external/ の調査済みプロジェクトから採用されたパターンとの差分:
- OpenClaw: 3層スキル優先順位、ゲーティング機構
- gstack: 構造化スプリント、安全ガードレール
- superpowers: マルチプラットフォーム構造、CSO最適化
- autoresearch: bounded autoresearch pattern

#### 1.4 Codex並行監査（フォールバック付き）

```bash
codex exec -a never -s read-only --cd <project-path> \
  "このプロジェクトのハーネス設定（AGENTS.md, config.toml, skills等）を監査して。
   未活用機能、設定の矛盾、セキュリティリスク、改善候補をレポートして。
   結果を /tmp/codex-audit/ に出力して。"
```

Codex exec失敗時はClaude単独で完遂する。

#### 1.5 診断レポート出力

`logs/evaluations/{project-name}-{date}.md` に診断レポートを出力:
- ドメイン非依存パターンとドメイン固有の分離を明記
- Codex監査結果があれば統合

### Phase 2: 改善提案（ADR-001 ステップ2 -- ユーザー対話、このPhaseが核心）

Phase 1の診断結果を基に、優先度A-D分類の改善提案書を作成する。

| 優先度 | 定義 | 例 |
|--------|------|-----|
| **A: 即効改善** | 低リスク・高ROI。すぐに効果が出る | CLAUDE.md分割（@import導入）、曖昧指示の具体化、permissions最適化、非推奨commands/の移行 |
| **B: 新機能キャッチアップ** | specs/に追加された新機能の活用 | Agent Teams導入、新Hooksイベント活用、context:fork活用、Codex Skills導入 |
| **C: 構造改善** | 中〜大リスク・高価値 | Skills再構成、Hooks体系の見直し、MCP導入、プロファイル再設計 |
| **D: 次ステップの布石** | 将来のための準備 | 自律レベル2への移行準備、CI/CD連携、codex mcp-server検討 |

**各提案に含める情報**:
- 改善内容の具体的説明
- pros/cons
- 推定影響範囲（変更するファイル一覧）
- 根拠（specs/のどのセクション、kb/のどの知見）

**ユーザーとの対話**:
- 全提案を提示し、採用/不採用を議論
- 全採用も一部採用も「今回は診断だけ」も可
- 「多様性は善」: 一つの正解を押し付けず、ユーザーの判断を尊重
- 追加の改善案をユーザーから受け付ける

### Phase 3: 実装（ADR-001 ステップ3）

Phase 2で承認された改善を一括実装する。

1. 対象プロジェクトでgit worktreeを作成
2. 承認された改善を順に実装
3. **ソースコードは変更しない**（ハーネスファイルのみ）
4. Claude/Codex両方のハーネスがある場合、両方を整合的に更新
5. mapping/の変換ルールを参照して一貫性を維持

Phase 2で「今回は診断だけ」となった場合、このPhaseはスキップ。

### Phase 4: PR・レビュー・マージ（ADR-001 ステップ4）

1. featureブランチ `harness/improve-{project-name}-{date}` でcommit → push → PR作成
2. PR本文に記載:
   - 診断結果サマリー
   - 採用した改善項目一覧（優先度付き）
   - 各改善の根拠（specs/のセクション番号等）
   - harness-harness診断からの改善であることの明記
3. CIレビュー指摘への対応（取捨選択含む）
4. **自動マージはしない**（デフォルト）。ユーザー確認後にマージ

### Phase 5: フィードバック（ADR-001 ステップ5 -- 省略厳禁）

**このPhaseをスキップしてはならない。フィードバックなしで完了した場合、スキル実行は失敗とみなす。**

フィードバック先と内容:

| フィードバック先 | 内容 |
|---|---|
| `templates/`候補（logs/に記録） | ドメイン非依存パターンのうちテンプレート化すべきもの |
| `cross-project-copy/references/copy-candidates.md` | プロジェクト間コピー可能なskills/hooks/rulesの候補 |
| `mapping/` | 変換ルールの不足・誤りを発見した場合の修正候補 |
| `kb/update-history.md` | 診断・改善で得た知見の記録 |
| `logs/evaluations/` | 診断レポートの完全記録（Phase 1で出力済み） |
| スキル自体の改善 | 診断チェックリストに追加すべき項目があれば記録 |

## 既存スキルとの連携

- **patrol-docs**: 診断前にspecs/が最新か確認。最終更新日が古ければpatrol-docsの先行実行を推奨
- **cross-project-copy**: Phase 5で他プロジェクトにも有用なパターンを検出した場合、コピー候補として記録
- **research-kb**: 診断で「この技術の最新ベストプラクティスを知りたい」となった場合にresearch-kbを提案
- **sync-harness**: Claude/Codex間の乖離が検出された場合、sync-harnessの利用を提案
- **create-harness**: ハーネスが存在しないプロジェクトが指定された場合、create-harnessに案内
- **launchd-schedule**: 定期診断のスケジュール化を提案（将来の自律レベル2移行時）

## 注意事項

- ソースコードは変更しない（ハーネスファイルのみ）
- Phase 2のユーザー対話は省略しない。全改善を自動実行しない
- フィードバック（Phase 5）は省略厳禁
- プライベートプロジェクト名はPR本文やログに混入させない（匿名化）
- Codex exec失敗時はClaude単独で完遂する（Codex依存にしない）
- 「多様性は善」: 改善提案ではpros/consを明示し選択肢を残す
- AIエージェントとして柔軟に判断する。チェックリストの機械的適用ではなく、プロジェクトの文脈を理解した上で提案する
- specs/が更新されていれば新しい診断基準が増える。specs/の進化に自動追随する設計
