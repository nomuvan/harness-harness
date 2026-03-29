---
source_skill: research-theme
theme: ai-image-generation
doc_type: source-map
status: published
updated: "2026-03-30"
summary: "AI自律画像生成テーマの調査済みソース一覧（公式ドキュメント・API仕様・GitHub・料金ページ）"
tags: [ai-image-generation, sources, api, pricing, models]
---

# AI自律画像生成 — ソースマップ

## Google / Imagen 4 / Gemini Native

| ソース | URL | 調査日 | 主な知見 |
|--------|-----|--------|---------|
| Imagen 4 公式発表 | https://deepmind.google/models/imagen-4/ | 2026-03 | Fast/Standard/Ultra 3 tier構成、SynthID透かし |
| Gemini API Imagen ドキュメント | https://ai.google.dev/gemini-api/docs/imagen | 2026-03 | REST/SDK呼び出し方法、safety settings |
| Vertex AI Imagen 4 価格 | https://cloud.google.com/vertex-ai/generative-ai/pricing | 2026-03 | Batch API 50%割引、解像度別料金 |
| Gemini Native Image Generation | https://ai.google.dev/gemini-api/docs/image-generation | 2026-03 | NB2/NB Pro、会話型編集、4K対応 |
| Gemini API 料金ページ | https://ai.google.dev/pricing | 2026-03 | NB2/NB Pro のトークン単価→画像換算 |
| Google FAQ（自動化制約） | https://support.google.com/gemini/ | 2026-03 | OAuth piggyback禁止、API Key/Vertex正攻法 |

## OpenAI / GPT Image 1.5

| ソース | URL | 調査日 | 主な知見 |
|--------|-----|--------|---------|
| GPT Image 1.5 リリースノート | https://openai.com/index/gpt-image-1-5/ | 2026-03 | Low/Med/High 3段階品質、Batch API対応 |
| Images API ドキュメント | https://platform.openai.com/docs/api-reference/images | 2026-03 | generations/edits/variations エンドポイント |
| OpenAI 料金ページ | https://openai.com/api/pricing/ | 2026-03 | 解像度×品質別の料金体系 |
| DALL-E 3 サポート終了通知 | https://platform.openai.com/docs/deprecations | 2026-03 | 2026年5月12日にDALL-E 3 API終了 |
| OpenAI Agents SDK ドキュメント | https://openai.github.io/openai-agents-python/ | 2026-03 | multi-agent構成、handoff、guardrails |

## FLUX.2 / Black Forest Labs

| ソース | URL | 調査日 | 主な知見 |
|--------|-----|--------|---------|
| FLUX.2 公式ページ | https://blackforestlabs.ai/flux-2/ | 2026-03 | Klein/Pro/Ultra階層、フォトリアル特化 |
| BFL API ドキュメント | https://docs.bfl.ml/ | 2026-03 | REST API、非同期ポーリング方式 |
| BFL API 料金 | https://docs.bfl.ml/pricing | 2026-03 | Klein $0.014/枚、Pro $0.055/枚 |

## Ideogram

| ソース | URL | 調査日 | 主な知見 |
|--------|-----|--------|---------|
| Ideogram V3 発表 | https://ideogram.ai/blog | 2026-03 | テキストレンダリング精度90-95%、業界最高 |
| Ideogram API ドキュメント | https://developer.ideogram.ai/docs | 2026-03 | REST API、テキスト埋込特化パラメータ |

## Stable Diffusion

| ソース | URL | 調査日 | 主な知見 |
|--------|-----|--------|---------|
| Stability AI API | https://platform.stability.ai/ | 2026-03 | SD 3.5 API、$0.035-$0.08/枚 |
| ComfyUI ワークフロー | https://github.com/comfyanonymous/ComfyUI | 2026-03 | ローカル推論パイプライン、API化可能 |

## Midjourney

| ソース | URL | 調査日 | 主な知見 |
|--------|-----|--------|---------|
| Midjourney 公式 | https://www.midjourney.com/ | 2026-03 | V7/V8、月額$30 Basic、API（Web API経由） |
| Midjourney API ドキュメント | https://docs.midjourney.com/docs/api | 2026-03 | 公式API利用条件、レート制限 |

## MCP（Model Context Protocol）画像生成ツール

| ソース | URL | 調査日 | 主な知見 |
|--------|-----|--------|---------|
| mcp-image (GitHub) | https://github.com/nicekid1/mcp-image | 2026-03 | Gemini NB2/Pro対応、3段階品質、自動プロンプト最適化 |
| mcp-imagenate (GitHub) | https://github.com/pඛdantic/mcp-imagenate | 2026-03 | マルチプロバイダ（Gemini+OpenAI+FLUX）、新しめ |
| MCP 公式仕様 | https://modelcontextprotocol.io/ | 2026-03 | ツール呼び出し仕様、Claude Desktop/Code対応 |

## 法規制・コンプライアンス

| ソース | URL | 調査日 | 主な知見 |
|--------|-----|--------|---------|
| SynthID 技術解説 | https://deepmind.google/technologies/synthid/ | 2026-03 | Google生成画像の透かし技術 |
| C2PA 仕様 | https://c2pa.org/ | 2026-03 | コンテンツ来歴証明の業界標準 |
| EU AI Act 画像生成条項 | https://artificialintelligenceact.eu/ | 2026-03 | AI生成コンテンツの開示義務 |

## 補足: 未調査・将来ソース

| ソース | 理由 | 優先度 |
|--------|------|--------|
| Leonardo.ai API | Wave 2以降でコスト比較追加 | 中 |
| Adobe Firefly API | エンタープライズ向け、個人利用は限定的 | 低 |
| Recraft V3 API | デザイン特化、Wave 2で評価 | 中 |
