---
title: 推薦スキル一覧
last_checked: "2026-04-04"
tier_a_count: 10
tier_b_count: 6
policy: 特定分野に偏らず、多様な分野からバランスよく推薦する
---

# 推薦スキル一覧

harness-harness各機能で活用可能なスキル。分野の偏りを避け、多様なプロジェクト種別に対応できるよう選定。段階的開示: この一覧で概要把握→詳細は公式サイト参照。

## Tier A: 管理対象（積極活用）

| スキル名 | 分野 | 出典 | 活用先 | 概要 |
|----------|------|------|--------|------|
| **skill-creator** | メタ/全般 | anthropics/skills | create-harness, 全般 | スキル作成・改善・評価の起点 |
| **systematic-debugging** | デバッグ | obra/superpowers | diagnose-harness | 仮説→証拠→根本原因の体系的デバッグ |
| **test-driven-development** | テスト | コミュニティ上位 | create-harness, diagnose-harness | Red-Green-Refactorサイクルの強制 |
| **frontend-design** | UI/UX | anthropics/skills (222K installs) | create-harness | 50+視覚スタイル、本番品質UI生成 |
| **security-scan** | セキュリティ | コミュニティ | diagnose-harness | OWASP Top10ベースの脆弱性スキャン |
| **pdf/pptx/xlsx/docx** | ドキュメント | anthropics/skills (公式) | 全般 | Office系ドキュメント生成・解析 |
| **dispatching-parallel-agents** | エージェント協調 | obra/superpowers | research-kb, create-harness | 並列調査・クロスレビューの設計パターン |
| **using-git-worktrees** | Git運用 | obra/superpowers | 全般 | worktree日常運用のベストプラクティス |
| **postgres-best-practices** | データベース | コミュニティ | create-harness | インデックス、クエリ最適化、接続プール |
| **find-skills** | ディスカバリー | vercel-labs (788K installs) | create-harness, patrol-docs | スキル検索・発見ユーティリティ |

## Tier B: ウォッチリスト（条件付き推薦）

| スキル名 | 分野 | 出典 | 概要 | 条件 |
|----------|------|------|------|------|
| **docker-optimize** | DevOps/インフラ | コミュニティ | Dockerfile最適化（サイズ、キャッシュ、セキュリティ） | コンテナ利用プロジェクト |
| **data-pipeline** | データ分析 | コミュニティ | ETL/ELTアーキテクチャ、ソースコネクタ | データ処理プロジェクト |
| **Context7** | ドキュメント追従 | claude.com/plugins上位 | 公式ドキュメント最新版追従 | ドキュメント追従重要なプロジェクト |
| **landing-page-guide** | マーケティング | コミュニティ | 高CVランディングページ、CRO原則 | Webマーケティング系 |
| **deploy-checklist** | DevOps | コミュニティ | デプロイ前検証（環境変数、ロールバック計画） | 本番デプロイがあるプロジェクト |
| **brainstorming** | 企画/設計 | コミュニティ上位 | 構造化アイデーション、制約・エッジケース洗い出し | 設計フェーズ重視 |

## 分野カバレッジ

巡回更新時は以下の分野バランスを意識する。特定分野に偏りすぎないこと。

| 分野 | Tier A | Tier B | 計 |
|------|--------|--------|----|
| メタ/全般 | 2 | 0 | 2 |
| テスト/デバッグ | 2 | 0 | 2 |
| UI/UX | 1 | 1 | 2 |
| セキュリティ | 1 | 0 | 1 |
| ドキュメント | 1 | 1 | 2 |
| エージェント協調 | 1 | 0 | 1 |
| Git運用 | 1 | 0 | 1 |
| データベース | 1 | 1 | 2 |
| DevOps/インフラ | 0 | 2 | 2 |
| マーケティング | 0 | 1 | 1 |

## 昇格/降格ルール

簡易ルーブリック:

| 項目 | スコア |
|------|--------|
| harness-harnessとの関連性 | 0-3 |
| Claude/Codex互換性 | 0-3 |
| 採用・評判シグナル | 0-2 |
| メンテナンス鮮度 | 0-2 |
| セキュリティ/依存リスク | -2〜0 |

- 7点以上: Tier A
- 5-6点: Tier B
- 4点以下: archive or rejected

**巡回時の追加ルール**: 分野カバレッジテーブルを確認し、カバーされていない分野で有力スキルがあれば優先的に検討する。

## harness-harness各機能での参照

| 機能 | 参照タイミング | 参照方法 |
|------|-------------|---------|
| create-harness | Phase 2（方針決定時） | プロジェクト種別に応じてTier A/Bから推薦 |
| diagnose-harness | Phase 1（診断時） | 既存スキル構成とTier A/Bを照合し不足を報告 |
| sync-harness | Phase 3（同期実行時） | SKILL.mdは共通フォーマットなのでそのまま共有可能 |
| research-kb | Phase 1（調査時） | skills.shトレンドで新しい有用スキルを発見 |
| cross-project-copy | Step 3（汎用性判定時） | Tier Aスキルは★★★★★（そのままコピー可） |
