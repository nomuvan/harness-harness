---
source_skill: research-theme
theme: ai-image-generation
doc_type: overview
status: published
updated: "2026-03-30"
summary: "Claude/Codexをオーケストレーターとして画像生成APIを活用し、SNS/記事のサムネ・差込画像を自律生成する研究テーマの全体像"
tags: [ai-image-generation, overview, claude, codex, mcp, thumbnail, automation]
---

# AI自律画像生成 — 研究テーマ概要

## テーマの背景

コンテンツ制作において、サムネイル画像や記事内の差込画像は読者のクリック率・読了率に直結する重要要素である。しかし、画像の選定・生成・最適化は手動で行うと時間がかかり、クリエイティブの一貫性を保つのも難しい。

2025-2026年にかけて、画像生成AIは劇的に進化した。Imagen 4、GPT Image 1.5、FLUX.2、Gemini Native Image Generationなど、API経由で高品質な画像を生成できるモデルが複数登場し、コスト面でも実用的な水準に到達している。

## テーマの目的

**Claude Code / Codex CLIをオーケストレーターとして、画像生成APIを統合し、SNS投稿・note記事・ブログのサムネイル/差込画像を自律的に生成するパイプラインを確立する。**

具体的には:

1. **モデル選定の最適化**: 用途・品質・コストに応じて最適なモデルを選択する指針を確立
2. **統合手法の確立**: MCP（mcp-image, mcp-imagenate）/ 直接API / Agent SDK multi-agentの比較評価
3. **自動化パイプラインの設計**: プロンプト生成→画像生成→品質評価→最終選定の自動化
4. **harness-harnessへの統合**: 管理対象プロジェクトへの画像生成機能の自動提案・注入

## スコープ

### 対象

- 静止画像の生成（PNG/JPEG/WebP）
- テキスト入り画像（サムネイル、見出し画像）
- イラスト・写真風・フォトリアル各スタイル
- API経由の画像生成（クラウド）
- ローカル推論（Stable Diffusion系、FLUX.2 schnell）
- 画像の評価・選定の自動化（Claude Vision利用）

### 対象外

- 動画生成（Sora, Runway等）
- 3Dモデル生成
- 音声・音楽生成
- 画像編集の高度な操作（inpainting, outpainting等は将来wave）

## テーマの構成

| ファイル | 内容 |
|---------|------|
| [charter.md](charter.md) | 調査問い・成功条件・除外範囲 |
| [source-map.md](source-map.md) | 調査済みソース一覧 |
| [findings.md](findings.md) | 統合知見レポート（モデル比較・用途別推奨・統合方法） |
| [benchmark-design.md](benchmark-design.md) | ベンチマーク設計 |
| [harness-implications.md](harness-implications.md) | harness-harness各機能への適用指針 |

## 関連プロジェクト

- **対象プロジェクト**: 記事サムネイル・差込画像の自動生成パイプラインの最初の適用先
- **harness-harness**: create-harness / init-project での画像生成MCP自動提案

## 運用方針

- **多様性は善**: 単一のwinnerモデルを決めず、用途・コスト・品質の軸で複数の推奨構成を維持
- **段階的開示**: 全モデルの詳細を一度に提示せず、用途に応じて最適な選択肢を提示
- **継続的更新**: モデルのリリース・価格改定・API変更に追従してwave単位で更新
