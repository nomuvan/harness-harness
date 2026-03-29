---
source_skill: research-theme
theme: ai-image-generation
doc_type: charter
status: published
updated: "2026-03-30"
summary: "AI自律画像生成テーマの調査問い・成功条件・除外範囲を定義するチャーター"
tags: [ai-image-generation, charter, research-design, scope]
---

# AI自律画像生成 — チャーター

## 調査問い（Research Question）

> **Claude/Codexをオーケストレーターとして、どの画像生成モデル/APIを、どの用途に、どう組み合わせるのが最適か？**

### サブ問い

1. **モデル選定**: 各画像生成モデル（Imagen 4, GPT Image 1.5, FLUX.2, Gemini Native, Ideogram, SD, Midjourney）の品質・コスト・API成熟度はどう異なるか？
2. **統合手法**: Claude Code/Codexから画像生成を行う最適なインテグレーション方法は何か？（MCP, 直接API, Agent SDK）
3. **用途別最適化**: サムネ量産、文字入り画像、フォトリアル、芸術表現等の用途ごとに、どのモデル/構成が最適か？
4. **コスト最適化**: 月間生成量に応じたコスト最適な構成はどうなるか？（10枚/月 vs 100枚 vs 1000枚）
5. **品質保証**: 生成画像の品質をClaude Visionで自動評価し、品質を担保できるか？

## 成功条件（Success Criteria）

| # | 条件 | 検証方法 | 状態 |
|---|------|---------|------|
| S1 | 用途別の推奨モデル構成が確立されている | findings.mdの用途別推奨テーブルが完成 | done |
| S2 | 主要モデルの料金比較表が作成されている | findings.mdの料金比較テーブルが完成 | done |
| S3 | Claude/Codexとの統合方法が比較評価されている | findings.mdの統合方法テーブルが完成 | done |
| S4 | ベンチマークで品質を実証している | benchmark-design.mdに基づく実行結果 | designed |
| S5 | harness-harnessへの統合指針が策定されている | harness-implications.mdが完成 | done |
| S6 | 法規制・制約事項が整理されている | findings.mdの制約セクション | done |

## 除外範囲（Out of Scope）

| 項目 | 理由 | 将来の可能性 |
|------|------|-------------|
| 動画生成（Sora, Runway, Kling等） | テーマが拡散しすぎる。別テーマとして独立させるべき | 別テーマ `ai-video-generation` として検討 |
| 3Dモデル生成 | 現時点の用途（サムネ・差込画像）に不要 | 需要が出たら別テーマ化 |
| 音声・音楽生成 | 画像とは全く異なるドメイン | 別テーマ `ai-audio-generation` として検討 |
| 高度な画像編集（inpainting等） | Wave 1ではスコープ外。生成に集中 | Wave 2以降で拡張可能 |
| GUIツール（Canva AI, Adobe Firefly UI等） | API/CLI自動化に焦点。手動UI操作は対象外 | APIがあれば統合可能 |

## Wave計画

| Wave | フォーカス | 期間目安 | 状態 |
|------|----------|---------|------|
| Wave 1 | モデル調査・比較・統合方法確立 | 2026-03 | done |
| Wave 2 | ベンチマーク実行・品質実証 | 2026-04 | planned |
| Wave 3 | 対象プロジェクトへの実装・実運用 | 2026-04-05 | planned |
| Wave 4 | 高度な機能（inpainting, style transfer, A/Bテスト） | 2026-Q2 | idea |

## ステークホルダー

- **ユーザー**: コンテンツ制作者。サムネ・差込画像の自動生成を求める
- **harness-harness**: 管理対象プロジェクトへの画像生成機能の自動提案・注入
- **対象プロジェクト**: 最初の適用先プロジェクト
