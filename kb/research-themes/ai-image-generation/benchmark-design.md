---
source_skill: research-theme
theme: ai-image-generation
doc_type: benchmark-design
status: published
updated: "2026-03-30"
summary: "AI画像生成モデルのベンチマーク設計。3題材×6モデル構成で品質・コスト・テキスト精度を実証評価"
tags: [ai-image-generation, benchmark, evaluation, claude-vision, ocr, quality]
---

# AI自律画像生成 — ベンチマーク設計

## 1. 目的

findings.md で整理したモデル比較・用途別推奨を、実際の画像生成で実証する。主観的な印象ではなく、構造化された評価軸で客観的にスコアリングし、推奨構成の妥当性を検証する。

## 2. テスト題材

### 題材1: テック系記事サムネイル

- **記事タイトル**: 「AIプログラミング入門」
- **要件**:
  - 文字入り: タイトルテキストを画像内に含む
  - テック系: プログラミング・AI関連のビジュアル要素
  - 青基調: 信頼感・技術感を演出する青系カラーパレット
  - サイズ: 1280x670（note推奨サイズ）
- **評価の重点**: 文字可読性、テック感の表現

**プロンプト例**:
```
Professional thumbnail for a tech article titled "AIプログラミング入門".
Blue gradient background with subtle code patterns and AI neural network visual elements.
The title text "AIプログラミング入門" should be prominently displayed in white, clean sans-serif font.
Modern, professional look. 1280x670 aspect ratio.
```

### 題材2: ライフスタイル系差込画像

- **記事タイトル**: 「朝の習慣で人生が変わる」
- **要件**:
  - 差込画像: 記事中間に挿入するイメージ画像
  - ライフスタイル: 朝の清々しさ、前向きなイメージ
  - 暖色系: オレンジ・黄色系の暖かいカラーパレット
  - 人物なし: 肖像権リスク回避、汎用性確保
  - サイズ: 1200x800（記事差込標準）
- **評価の重点**: 視覚的品質、雰囲気の表現

**プロンプト例**:
```
A warm, inviting lifestyle image representing "morning habits that change your life".
Warm color palette (orange, golden yellow). Morning sunlight streaming through a window,
a neatly organized desk with a cup of coffee and a journal. No people in the image.
Clean, aspirational feel. 1200x800 aspect ratio.
```

### 題材3: 金融系見出し画像

- **記事タイトル**: 「投資初心者ガイド」
- **要件**:
  - 見出し画像: noteの記事トップに配置
  - 金融系: 投資・資産運用のビジュアル
  - 信頼感: プロフェッショナルで信頼できる印象
  - グラフ要素: 上昇トレンドのグラフ・チャート要素を含む
  - サイズ: 1280x670（note推奨サイズ）
- **評価の重点**: ブランド信頼感、グラフ要素の適切さ、文字可読性

**プロンプト例**:
```
Professional header image for a beginner's investment guide article titled "投資初心者ガイド".
Include rising trend graph/chart elements, financial icons (coins, growth arrows).
Color scheme: deep blue and gold accents for trustworthiness.
The title "投資初心者ガイド" displayed in clean, readable Japanese font.
1280x670 aspect ratio. Professional, trustworthy look.
```

## 3. 評価軸

各軸は5段階（1-5点）で評価。

| 評価軸 | 1点 | 3点 | 5点 | 評価方法 |
|--------|-----|-----|-----|---------|
| プロンプト追従度 | 指示の半数以上が欠落 | 主要要素は含むが一部欠落 | 全ての指示要素が正確に反映 | Claude Vision で要素チェックリスト照合 |
| 視覚的品質 | アーティファクト多数、不自然 | 実用的だが粗さあり | プロの制作物と遜色なし | Claude Vision で主観+構造評価 |
| 文字可読性 | 文字が読めない/大幅に崩壊 | 一部誤字や歪みがあるが概ね読める | 完全に正確で読みやすい | OCR検証（tesseract等）+ Claude Vision |
| サムネ適性 | 縮小すると何も見えない | 縮小時に主題は認識できる | 縮小時でも内容が明確、CTR高そう | 200x120にリサイズして Claude Vision で評価 |
| ブランド一貫性 | 同一プロンプトで毎回全く異なる | スタイルは似るが細部が大きく変動 | 同一プロンプトで安定した出力 | 同一プロンプト3回生成して差異を評価 |

### 3.1 評価の自動化

評価はClaude Visionを使って半自動化する。

```
評価プロンプト（Claude Visionへの入力）:

以下の画像を評価してください。

題材: [題材名]
プロンプト: [使用したプロンプト]

評価軸（各1-5点）:
1. プロンプト追従度: 指示した要素が全て含まれているか
2. 視覚的品質: 解像度、色彩、構図のプロ感
3. 文字可読性: テキスト要素の正確性と読みやすさ
4. サムネ適性: 縮小表示時の視認性、CTR予測
5. ブランド一貫性: (3回生成時の比較で評価)

各軸のスコアと、具体的な所見を述べてください。
```

## 4. 対象モデル

Wave 1 ベンチマークでは、API経由で即座に利用可能な以下のモデルを対象とする。

| # | モデル | API | 品質設定 | コスト/枚 |
|---|--------|-----|---------|----------|
| 1 | Imagen 4 Fast | Gemini API | fast | $0.02 |
| 2 | Imagen 4 Standard | Gemini API | standard | $0.04 |
| 3 | GPT Image 1.5 Low | OpenAI API | low | $0.009 |
| 4 | GPT Image 1.5 Medium | OpenAI API | medium | $0.034 |
| 5 | GPT Image 1.5 High | OpenAI API | high | $0.133-0.20 |
| 6 | NB2 Gemini Native | Gemini API | default | $0.067 |

### 4.1 Wave 2 追加候補

- FLUX.2 Klein / Pro
- Ideogram V3
- NB Pro Gemini Native
- Imagen 4 Ultra

## 5. 実行計画

### 5.1 生成マトリクス

3題材 x 6モデル = **18枚**（Wave 1）

| | 題材1: テック | 題材2: ライフスタイル | 題材3: 金融 |
|---|---|---|---|
| Imagen 4 Fast | 1枚 | 1枚 | 1枚 |
| Imagen 4 Standard | 1枚 | 1枚 | 1枚 |
| GPT Image 1.5 Low | 1枚 | 1枚 | 1枚 |
| GPT Image 1.5 Med | 1枚 | 1枚 | 1枚 |
| GPT Image 1.5 High | 1枚 | 1枚 | 1枚 |
| NB2 Gemini Native | 1枚 | 1枚 | 1枚 |

ブランド一貫性評価用に追加で各モデル x 1題材 x 3回 = **18枚**

**合計: 36枚（Wave 1）**

### 5.2 推定コスト

| モデル | 枚数 | コスト |
|--------|------|--------|
| Imagen 4 Fast | 3+3 = 6枚 | $0.12 |
| Imagen 4 Standard | 3+3 = 6枚 | $0.24 |
| GPT Image 1.5 Low | 3+3 = 6枚 | $0.054 |
| GPT Image 1.5 Med | 3+3 = 6枚 | $0.204 |
| GPT Image 1.5 High | 3+3 = 6枚 | $0.80-1.20 |
| NB2 Gemini Native | 3+3 = 6枚 | $0.40 |
| **合計** | **36枚** | **$1.82-2.22** |

### 5.3 実行手順

1. **環境準備**: Gemini API Key、OpenAI API Key の設定確認
2. **プロンプト確定**: 3題材のプロンプトを全モデル共通で確定（モデル固有の最適化は別途記録）
3. **画像生成**: 各モデルでAPI呼び出し。生成画像を `benchmark/wave1/[model]/[subject]-[n].png` に保存
4. **評価実行**: Claude Vision で18枚を個別評価。スコアシートに記録
5. **一貫性評価**: 同一プロンプト3回生成の結果を比較評価
6. **レポート作成**: 評価結果を `benchmark-results-wave1.md` にまとめる

### 5.4 評価結果テンプレート

```markdown
## 評価結果: [モデル名] x [題材名]

| 評価軸 | スコア (1-5) | 所見 |
|--------|-------------|------|
| プロンプト追従度 | | |
| 視覚的品質 | | |
| 文字可読性 | | |
| サムネ適性 | | |
| ブランド一貫性 | | |
| **合計** | **/25** | |

### 生成画像
![生成画像](benchmark/wave1/[model]/[subject].png)

### プロンプト
[使用プロンプト]

### 生成時間・コスト
- 生成時間: X秒
- コスト: $X.XXX
```

## 6. 成功基準

| 基準 | 閾値 | 意味 |
|------|------|------|
| 実用最低ライン | 合計15/25以上 | サムネとして最低限使える品質 |
| 推奨ライン | 合計20/25以上 | 手動修正なしで使える品質 |
| 優秀ライン | 合計23/25以上 | プロの制作物と遜色ない品質 |

## 7. 期待される成果

- findings.md の用途別推奨の妥当性を実証データで裏付け
- 各モデルの強み・弱みを具体的な画像で可視化
- コストパフォーマンスの定量的比較
- ベンチマーク手法の確立（Wave 2以降の新モデル追加時に再利用可能）
