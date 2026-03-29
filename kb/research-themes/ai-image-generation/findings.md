---
source_skill: research-theme
theme: ai-image-generation
doc_type: findings
status: published
updated: "2026-03-30"
summary: "AI自律画像生成の統合知見レポート。モデル比較・用途別推奨・Claude/Codex統合方法・5Agent構成・法規制を網羅"
tags: [ai-image-generation, findings, model-comparison, pricing, mcp, agent-sdk, compliance]
---

# AI自律画像生成 — 統合知見レポート

> **多様性は善**: 本レポートは単一のwinnerモデルを決定しない。用途・コスト・品質の軸で複数の推奨構成を提示し、選択はユーザーに委ねる。

## 1. モデル比較

### 1.1 コスト・品質マトリクス

| モデル | 最安/枚 | 標準/枚 | 最高品質/枚 | 文字レンダリング | プロンプト追従 | 用途 |
|--------|---------|---------|------------|----------------|-------------|------|
| Imagen 4 Fast | $0.01 (Batch) | $0.02 | - | 高 | 高 | 量産・試作 |
| Imagen 4 Standard | $0.02 (Batch) | $0.04 | - | 非常に高 | 非常に高 | 実務標準 |
| Imagen 4 Ultra | $0.03 (Batch) | $0.06 | - | 最高 | 最高 | 最終仕上げ |
| GPT Image 1.5 Low | $0.009 | - | - | 高 | 最高 | ドラフト |
| GPT Image 1.5 Med | $0.017 (Batch) | $0.034 | - | 高 | 最高 | 実務標準 |
| GPT Image 1.5 High | - | - | $0.133-0.20 | 最高 | 最高 | 最終仕上げ |
| NB2 (Gemini Native) | $0.034 (Batch) | $0.067 | $0.24 (4K) | 中 | 高 | 高速試作+編集 |
| NB Pro (Gemini Native) | $0.067 (Batch) | $0.134 | $0.24 (4K) | 高 | 非常に高 | 高品質+編集 |
| FLUX.2 Klein | $0.014 | - | - | 中 | 高 | フォトリアル |
| FLUX.2 Pro | $0.055 | - | - | 中 | 非常に高 | フォトリアル最高 |
| Ideogram V3 | ~$0.03 | - | - | 最高 (90-95%) | 高 | テキスト重視 |
| SD 3.5 (API) | $0.035 | $0.065 | $0.08 | 中 | 中 | ローカル/カスタム |
| Midjourney V7/V8 | ~$0.02 (Sub) | ~$0.03 | - | 中 | 非常に高 | 芸術的品質 |

### 1.2 コスト注記

- **Batch API**: Google (Imagen 4)、OpenAI (GPT Image 1.5) ともにBatch APIで約50%割引。大量生成時は必須
- **サブスクリプション**: Midjourney は月額課金（Basic $30、Standard $60）。1枚あたりコストは生成量に依存
- **ローカル推論**: SD 3.5 / FLUX.2 schnell はローカルGPUで推論可能。GPU電気代のみで$0/枚（初期投資除く）
- **4K料金**: Gemini Native の 4K 出力は NB2/NB Pro 共通で $0.24/枚。通常解像度の3-7倍

### 1.3 各モデルの特徴詳細

#### Imagen 4（Google / Vertex AI）

- **強み**: 3段階 (Fast/Standard/Ultra) の明確なtier構成。Batch APIで最安クラス。SynthID透かし標準搭載
- **弱み**: Vertex AI / Gemini API 経由のみ。Google Cloud アカウント必要
- **文字レンダリング**: Ultra は業界トップクラス。Fast でも実用的な精度
- **API成熟度**: 高。REST / Python SDK / Node.js SDK 全対応

#### GPT Image 1.5（OpenAI）

- **強み**: プロンプト追従が全モデル中最高。Low品質でも$0.009と最安。OpenAI API経由で導入容易
- **弱み**: High品質は$0.133-0.20と割高。Batch APIのMed以下限定
- **文字レンダリング**: High品質で最高レベル。Low/Medでもかなり正確
- **API成熟度**: 最高。OpenAI SDK は最も普及したAI API

#### Gemini Native Image Generation（NB2 / NB Pro）

- **強み**: 会話型の反復編集が可能（「この画像の背景を青にして」等）。テキスト+画像の同時生成
- **弱み**: 文字レンダリング精度はNB2では中程度。コストが他モデルより割高
- **独自機能**: 会話的な画像編集は他モデルにない強み。プロトタイピングに最適
- **API成熟度**: 高。Gemini API 経由

#### FLUX.2（Black Forest Labs）

- **強み**: フォトリアルな品質が業界最高クラス。Klein は $0.014 と低コスト
- **弱み**: 文字レンダリングは中程度。API は非同期ポーリング方式でやや複雑
- **用途**: 人物写真風、風景、製品写真等のフォトリアル画像に特化
- **API成熟度**: 中。REST API のみ、SDK なし

#### Ideogram V3

- **強み**: テキストレンダリング精度90-95%で業界最高。ロゴ、タイポグラフィ、文字入り画像に最適
- **弱み**: フォトリアル品質は他モデルに劣る。API ドキュメントがやや不足
- **用途**: テキスト正確性が最重要な画像（文字入りサムネ、バナー、ロゴ風画像）
- **API成熟度**: 中

#### Stable Diffusion 3.5

- **強み**: ローカル推論可能。カスタムモデル（LoRA等）で独自スタイル学習可能
- **弱み**: API品質は他モデルに劣る。ローカル推論はGPU必要
- **用途**: カスタマイズが必要なケース、コスト$0を目指すケース
- **API成熟度**: 高（Stability AI API）。ローカルはComfyUI等のエコシステムが充実

#### Midjourney V7/V8

- **強み**: 芸術的品質が業界最高。独特の美的センス。プロンプト追従も非常に高い
- **弱み**: 月額課金モデル。APIは制限的。自動化との親和性が低い
- **用途**: 芸術的表現、コンセプトアート、独特のビジュアルスタイル
- **API成熟度**: 低-中。公式APIは制限あり

---

## 2. 用途別推奨構成

> **多様性は善**: 各用途に対して第1・第2推奨を提示。ユーザーの状況（コスト感度、品質要求、既存API契約）に応じて選択。

| 用途 | 第1推奨 | 第2推奨 | 理由 |
|------|---------|---------|------|
| サムネ量産（コスパ重視） | Imagen 4 Fast ($0.02) | GPT Image 1.5 Low ($0.009) | 最安+実用品質。GPT Image 1.5 LowはOpenAI契約済みなら最安 |
| 文字入りサムネ | Ideogram V3 ($0.03) | GPT Image 1.5 High ($0.133) | テキスト正確性最高。Ideogramは文字特化、GPT Image 1.5 Highは総合品質 |
| 記事差込（標準品質） | Imagen 4 Standard ($0.04) | GPT Image 1.5 Med ($0.034) | バランス最適。どちらもBatch API対応で大量生成可 |
| 最終仕上げ1枚 | Imagen 4 Ultra ($0.06) | GPT Image 1.5 High ($0.20) | 最高品質。コスト差3倍だがどちらもプロ水準 |
| 対話的編集反復 | NB2/NB Pro | GPT Image 1.5 | 会話型で反復可能。NB系は「ここを変えて」が自然言語で可能 |
| フォトリアル | FLUX.2 Pro ($0.055) | Imagen 4 Ultra | 写実性特化。人物・風景・製品写真にFLUX.2が最適 |
| 芸術的表現 | Midjourney ($30/月) | FLUX.2 Pro | 芸術性最高。月間利用量が多ければMidjourneyのサブスクがコスパ良 |
| 大量生成（1000枚/月） | Imagen 4 Fast Batch ($10) | SD ローカル ($0) | コスト最小。1000枚でも$10。ローカルGPUがあればSD/FLUXで$0 |

### 2.1 コストシミュレーション

#### 月間10枚（ライトユーザー）

| 構成 | 月額 |
|------|------|
| GPT Image 1.5 Low x10 | $0.09 |
| Imagen 4 Fast x10 | $0.20 |
| Imagen 4 Standard x10 | $0.40 |

#### 月間100枚（レギュラーユーザー）

| 構成 | 月額 |
|------|------|
| GPT Image 1.5 Low x100 | $0.90 |
| Imagen 4 Fast Batch x100 | $1.00 |
| 混合: Fast x80 + Standard x20 | $1.60 |

#### 月間1000枚（ヘビーユーザー）

| 構成 | 月額 |
|------|------|
| Imagen 4 Fast Batch x1000 | $10.00 |
| GPT Image 1.5 Low x1000 | $9.00 |
| SD ローカル x1000 | $0 (電気代のみ) |
| Midjourney Standard | $60 (無制限relax) |

---

## 3. Claude/Codexとの統合方法

### 3.1 統合方法比較

| 方法 | 対応モデル | 推奨度 | メリット | デメリット |
|------|----------|--------|---------|----------|
| mcp-image (MCP) | Gemini NB2/Pro | 最推奨 | 自動プロンプト最適化、3段階品質切替、Claude Code/Desktopネイティブ統合 | Gemini限定 |
| mcp-imagenate (MCP) | Gemini+OpenAI+FLUX | 推奨 | マルチプロバイダ対応、1ツールで複数モデル | 新しく実績少ない |
| 直接API (Bash/Python) | 全モデル | 汎用 | 最大自由度、全モデル対応、カスタムロジック可 | 実装が必要、各APIの差異を吸収する必要 |
| Agent SDK multi-agent | 全モデル | 本格 | 5Agent構成で品質保証、スケーラブル | 実装コスト高、OpenAI Agent SDK依存 |

### 3.2 mcp-image（最推奨）

```json
{
  "mcpServers": {
    "mcp-image": {
      "command": "npx",
      "args": ["-y", "mcp-image"],
      "env": {
        "GEMINI_API_KEY": "your-key"
      }
    }
  }
}
```

**特徴**:
- Gemini NB2/NB Pro を Claude Code から直接呼び出し
- 3段階品質（draft / standard / premium）
- 自動プロンプト最適化（Claude がプロンプトを改善してから画像生成）
- 会話型編集対応

### 3.3 mcp-imagenate（推奨）

```json
{
  "mcpServers": {
    "mcp-imagenate": {
      "command": "npx",
      "args": ["-y", "mcp-imagenate"],
      "env": {
        "GEMINI_API_KEY": "your-gemini-key",
        "OPENAI_API_KEY": "your-openai-key",
        "BFL_API_KEY": "your-bfl-key"
      }
    }
  }
}
```

**特徴**:
- マルチプロバイダ: Gemini + OpenAI + FLUX.2 を1つのMCPで統合
- モデル切替が容易
- 新しいプロジェクトのため実績は限定的

### 3.4 直接API呼び出し（汎用）

Claude Code / Codex の Bash ツールから直接 API を呼び出す方法。

```bash
# Imagen 4 (Gemini API)
curl -X POST "https://generativelanguage.googleapis.com/v1beta/models/imagen-4-fast:generateImages" \
  -H "x-goog-api-key: $GEMINI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"prompt": "A professional thumbnail for tech blog"}'

# GPT Image 1.5 (OpenAI API)
curl -X POST "https://api.openai.com/v1/images/generations" \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model": "gpt-image-1.5", "prompt": "...", "quality": "medium"}'
```

**特徴**:
- 全モデル対応
- 最大の自由度（パラメータ、後処理、バッチ処理等）
- 各APIの仕様差を自分で吸収する必要がある

### 3.5 Agent SDK multi-agent（本格運用）

OpenAI Agents SDK を使った5Agent構成。大規模・本格的な画像生成パイプラインに適する。

---

## 4. 5 Agent構成（本格運用時）

大量・高品質の画像生成を継続的に行う場合の推奨アーキテクチャ。

```
[ユーザーリクエスト]
        |
        v
  +-----------+
  |  Planner  |  目的・KPI定義
  +-----------+
        |
        v
  +----------------+
  | Brand Guardian |  媒体ルール・禁止事項固定
  +----------------+
        |
        v
  +-----------------+
  | Prompt Composer |  モデル別プロンプト最適化
  +-----------------+
        |
        v
  +----------+
  | Renderer |  モデル打ち分け（Imagen/GPT Image/FLUX）
  +----------+
        |
        v
  +--------+
  | Critic |  Vision評価
  +--------+
        |
        v
  [最終画像出力]
```

### 4.1 各Agentの役割

#### Agent 1: Planner

- **入力**: ユーザーリクエスト（「tech blogのサムネ作って」等）
- **出力**: 構造化された画像仕様（目的、ターゲット読者、KPI、トーン、必須要素）
- **例**: `{ purpose: "thumbnail", platform: "note", kpi: "CTR", tone: "professional", elements: ["title_text", "tech_icons", "blue_gradient"] }`

#### Agent 2: Brand Guardian

- **入力**: Plannerの画像仕様
- **出力**: 媒体ルール適用済み仕様（サイズ、セーフゾーン、禁止事項、ブランドカラー）
- **保持情報**: 各媒体のガイドライン（note: 1280x670、Twitter: 1200x628等）、ブランドカラー、禁止表現リスト
- **例**: サイズ制約追加、ブランドカラー固定、人物使用可否の判定

#### Agent 3: Prompt Composer

- **入力**: Brand Guardian適用済み仕様 + ターゲットモデル
- **出力**: モデル別に最適化されたプロンプト
- **モデル別最適化**:
  - Imagen 4: 簡潔で構造的なプロンプト。ネガティブプロンプト対応
  - GPT Image 1.5: 詳細な自然言語記述。コンテキスト重視
  - FLUX.2: スタイルタグ、品質タグの活用
  - Ideogram: テキスト配置の明示的指定

#### Agent 4: Renderer

- **入力**: モデル別最適化プロンプト + モデル選択
- **出力**: 生成画像（1-4枚）
- **モデル打ち分けロジック**:
  - コスパ重視 → Imagen 4 Fast
  - 文字入り → Ideogram V3 or GPT Image 1.5 High
  - フォトリアル → FLUX.2 Pro
  - 標準品質 → Imagen 4 Standard or GPT Image 1.5 Med
- **Batch対応**: 大量生成時はBatch APIを自動選択

#### Agent 5: Critic

- **入力**: 生成画像 + 元の画像仕様
- **出力**: 評価スコア + 改善提案 or 承認
- **評価項目**:
  - 文字可読性: OCR的検証（テキストが正確に読めるか）
  - 主題明瞭性: 意図した主題が明確に伝わるか
  - プロンプト追従: 指定要素が全て含まれているか
  - CTR予測: サムネとしてのクリック誘引力（縮小表示時の視認性）
  - ブランド一貫性: ブランドガイドラインとの整合性
- **ループ**: スコアが閾値未満なら Prompt Composer に差し戻し（最大3回）

### 4.2 簡易構成（3 Agent）

小規模運用時はPlanner + Renderer + Criticの3Agent構成で十分。

```
[リクエスト] → Planner → Renderer → Critic → [出力]
```

---

## 5. 重要な法規制・制約

### 5.1 OAuth Piggyback禁止

- **事実**: Claude CLI → Gemini CLI の OAuth piggyback（Claudeが裏でGemini CLIのOAuthトークンを使う）は **Google FAQ で明示的に規約違反**
- **正攻法**:
  - Gemini API Key（無料枠あり、有料は従量課金）
  - Vertex AI 経由（Google Cloud アカウント、IAM制御）
- **注意**: Gemini Pro 契約（月額$20等）は手動利用用。自動化・API利用はAPI課金が必要

### 5.2 DALL-E 3 サポート終了

- **期限**: 2026年5月12日
- **影響**: DALL-E 3 API が利用不可に。GPT Image 1.5 への移行が必要
- **対応**: 既存でDALL-E 3を使っているプロジェクトは早急にGPT Image 1.5に移行

### 5.3 AI生成画像の透かし・メタデータ

| プロバイダ | 透かし技術 | 検出方法 |
|----------|----------|---------|
| Google (Imagen 4, Gemini Native) | SynthID（目に見えない電子透かし） | Google SynthID Detector API |
| OpenAI (GPT Image 1.5) | C2PA メタデータ埋込 | C2PA対応ビューアで確認可能 |
| FLUX.2 | なし（オプションでC2PAサポート） | - |
| Midjourney | メタデータ埋込 | Exif情報で確認 |

### 5.4 法的リスク

- **EU AI Act**: AI生成コンテンツの開示義務。商用利用時はAI生成である旨の明示が必要な場合がある
- **著作権**: AI生成画像の著作権は法域により判断が分かれる。米国では「人間の創造的関与」が必要
- **肖像権**: 実在の人物に似た画像の生成は肖像権侵害リスク。各モデルのsafety filterで一定程度防止

---

## 6. 技術的制約・Tips

### 6.1 API共通の注意点

- **レート制限**: 各APIにリクエスト/分の制限あり。大量生成時はBatch APIまたはキューイングが必要
- **画像サイズ**: 各モデルで対応サイズが異なる。サムネ用途では1024x1024以上を推奨
- **非同期処理**: FLUX.2 APIは非同期（ポーリング方式）。Imagen/GPT Imageは同期レスポンス
- **タイムアウト**: 高品質モデルは生成に10-30秒。Claude Code のBashツールでは適切なtimeout設定が必要

### 6.2 プロンプトエンジニアリングのコツ

- **Imagen 4**: 構造的に記述。「A [subject], [style], [color], [composition]」形式が効果的
- **GPT Image 1.5**: 自然言語で詳細に記述。コンテキストや意図を含めると精度向上
- **FLUX.2**: スタイルタグ（`photorealistic`, `cinematic lighting`等）が効果的
- **Ideogram**: テキストは二重引用符で囲む。配置指示を明示（`text "Hello" centered at top`）
- **共通**: ネガティブプロンプト（避けたい要素）の指定で品質向上

### 6.3 後処理パイプライン

生成画像をそのまま使うのではなく、後処理を加えることで品質を安定させる:

1. **リサイズ**: 各媒体の推奨サイズにリサイズ（ImageMagick / sharp）
2. **圧縮**: WebP変換で容量削減（cwebp / sharp）
3. **文字オーバーレイ**: 生成画像上にプログラマティックに文字を配置（Pillow / Canvas API）
4. **品質チェック**: Claude Vision で最終確認
