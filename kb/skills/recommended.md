---
title: 推薦スキル一覧
last_checked: "2026-03-28"
tier_a_count: 6
tier_b_count: 4
---

# 推薦スキル一覧

harness-harness各機能で活用可能なスキル。段階的開示: この一覧で概要把握→詳細は公式サイト参照。

## Tier A: 管理対象（積極活用）

| スキル名 | 出典 | 活用先 | 概要 |
|----------|------|--------|------|
| **skill-creator** | anthropics/skills, skills.sh上位 | create-harness, 全般 | スキル作成・改善・評価の起点。プロジェクトに合ったスキルを生成 |
| **writing-skills** | obra/superpowers | create-harness, diagnose-harness | TDDでスキルを書く手法。ハーネスのスキル品質向上 |
| **systematic-debugging** | obra/superpowers | diagnose-harness | 根本原因志向のデバッグ。ハーネス診断の品質向上 |
| **writing-plans** | obra/superpowers | create-harness, research-kb | 実装計画の粒度を揃える。調査計画にも直結 |
| **using-git-worktrees** | obra/superpowers | 全般 | worktree日常運用の方針と直接一致。並列作業のベストプラクティス |
| **dispatching-parallel-agents** | obra/superpowers | research-kb, create-harness | 並列調査・クロスレビュー・複数実験レーンの設計パターン |

## Tier B: ウォッチリスト（条件付き推薦）

| スキル名 | 出典 | 活用先 | 概要 | 条件 |
|----------|------|--------|------|------|
| **frontend-design** | anthropics/skills | create-harness | 本番品質UI生成。277K installs | フロントエンド系プロジェクト |
| **OWASP-security** | コミュニティ | diagnose-harness | OWASP Top10:2025, ASVS 5.0対応 | セキュリティ重視プロジェクト |
| **Context7** | claude.com/plugins上位 | patrol-docs, research-kb | 公式/最新ドキュメント追従。specs更新と相性良 | ドキュメント追従が重要なプロジェクト |
| **find-skills** | vercel-labs/skills | create-harness | スキル検索・発見。750K installs | ハーネス更新時のスキル発見 |

## 昇格/降格ルール

簡易ルーブリック（Codex提案を採用）:

| 項目 | スコア |
|------|--------|
| harness-harnessとの関連性 | 0-3 |
| Claude/Codex互換性 | 0-3 |
| 採用・評判シグナル | 0-2 |
| メンテナンス鮮度 | 0-2 |
| セキュリティ/依存リスク | -2〜0 |

- 7点以上: Tier A（管理対象）
- 5-6点: Tier B（ウォッチリスト）
- 4点以下: archive or rejected

## harness-harness各機能での参照

| 機能 | 参照タイミング | 参照方法 |
|------|-------------|---------|
| create-harness | Phase 2（方針決定時） | プロジェクト種別に応じてTier A/Bから推薦 |
| diagnose-harness | Phase 1（診断時） | 既存スキル構成とTier A/Bを照合し不足を報告 |
| sync-harness | Phase 3（同期実行時） | SKILL.mdは共通フォーマットなのでそのまま共有可能 |
| research-kb | Phase 1（調査時） | skills.shトレンドで新しい有用スキルを発見 |
| cross-project-copy | Step 3（汎用性判定時） | Tier Aスキルは★★★★★（そのままコピー可） |
