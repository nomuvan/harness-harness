---
name: research-kb
description: |
  ツール・技術・業務ドメインのナレッジをkb/に追加する調査スキル。
  単体または複数対象を一括でシーケンシャルに調査→PR→マージまで実行。
  公式サイト、GitHub、Web全般を徹底的に調査し、Claude/Codexクロスレビューでアウトプットを作成。
  業務ドメイン（コンテンツ収益化、データ分析等）もユーザー指示に基づき徹底深掘りする。
  「○○を調査して」「kb/に追加して」「以下のリストを調査して」で起動。
---

# research-kb スキル

ツール・技術・業務ドメインのナレッジをkb/に追加する。コストをかけて徹底調査し、harness-harnessへの適用判断まで行う。

## 調査対象の種類

### ツール・技術調査 → kb/external/{name}/
外部プロジェクト、フレームワーク、ライブラリ等の調査。

### 業務ドメイン調査 → kb/domains/{domain}/
ユーザーが指示した業務ドメインの徹底深掘り。対象プロジェクトのハーネスに業務ドメイン知見を反映するための調査。

**判定基準**: ユーザーの指示に業務ドメインの文脈が含まれていれば、ツール調査に加えて業務ドメイン調査も実施する。

## 入力形式

### 単体調査

```
autoresearchを調査して
```

### 複数一括調査

```
以下を順番に調査して:
1. DeerFlow2.0 — マルチエージェントリサーチフレームワーク
2. AiToEarn — AI収益化/自動化
```

### 業務ドメイン深掘り

```
AiToEarnを調査して（コンテンツ収益化の業務ドメインも深掘り）
```

## 実行フロー（複数対象の場合）

```
対象リスト: [A, B, C]

── A の調査開始 ──
  Phase 1: Claude徹底調査（A）
  Phase 2: Codex独自調査（A）
  Phase 3: クロスレビュー統合（A）
  Phase 4: アウトプット作成（A）
  Phase 5: commit → push → PR作成 → マージ（A）
── A 完了 ──

── B, C: 同上（シーケンシャル）──

全対象完了
```

**各対象ごとに独立したPRを作成・マージする。** 1つの巨大PRにまとめない。

## 各対象の調査プロセス

### Phase 1: 徹底調査（Claude主担当）

以下の全てを調査する。コスト度外視で網羅的に。

1. **公式サイト・ドキュメント**: README、ドキュメント、ガイド
2. **GitHubソースコード**: リポジトリ構造、主要ファイル、設計パターン。ソースコードを実際に読む
3. **Web全般**: ブログ記事、X(Twitter)での評判、YouTube動画、Hacker Newsスレッド
4. **評価・人気**: GitHub Stars、フォーク数、コントリビューター数、最終更新日、リリース頻度
5. **類似ツールとの比較**: 競合・代替ツールとのpros/cons
6. **ライセンス**: 商用利用可否
7. **業務ドメイン深掘り**（該当する場合）: ビジネスモデル、業界動向、収益化手法、ワークフロー、KPI、法規制、実践事例

### Phase 2: Codexによる独自調査

```bash
codex exec --full-auto "以下のプロジェクトを徹底調査して、analysis.mdとtakeaways.mdを作成して。
対象: <URL>
GitHubソースコード、Web評判、harness-harnessへの適用可否を評価して。
結果を /tmp/codex-research/<name>/ に出力して。"
```

Codex exec失敗時はClaude単独で完遂する（Codex依存にしない）。

### Phase 3: クロスレビュー

1. **ClaudeがCodexのアウトプットをレビュー**: 見落とし、評価の偏り、追加すべき観点を指摘
2. **レビュー結果を統合**: 双方の指摘を反映した最終版を作成

### Phase 4: アウトプット作成

**全アウトプットにfrontmatterを必須で付与する。** 段階的開示のため、frontmatterだけで概要把握できるようにする。

#### kb/external/{name}/analysis.md

```markdown
---
name: "{name}"
url: "{url}"
type: tool  # tool | framework | library | service | knowledge-collection
tags: [tag1, tag2, tag3]  # 関連キーワード（検索・段階的開示用）
stars: {stars}
license: "{license}"
last_checked: "{today}"
relevance: high  # high | medium | low（harness-harnessとの関連度）
summary: "{一文の要約}"
---

# {name} 深掘り分析

## 概要
## アーキテクチャ・構造
## 主要機能
## 技術スタック
## 評価・人気
## 類似ツールとの比較
## ソースコード品質
```

#### kb/external/{name}/takeaways.md

```markdown
---
name: "{name}"
type: takeaways
tags: [tag1, tag2, tag3]
last_checked: "{today}"
adoption_summary: "{採用判断の一文要約}"
top_patterns:
  - "{最重要パターン1}"
  - "{最重要パターン2}"
  - "{最重要パターン3}"
---

# {name} からの知見と採用判断

## 方針
## 採用判断（テーブル形式: パターン/機能, 判定, 理由, 適用方法）
## harness-harnessへの組み込み指針
### 既存ハーネスへの適用
### 新規ハーネスへの適用
### 組み込むべきでないもの
## Claude/Codexクロスレビュー結果
```

#### kb/domains/{domain}/overview.md（業務ドメイン調査時）

```markdown
---
domain: "{domain-name}"
tags: [tag1, tag2, tag3]
last_checked: "{today}"
summary: "{業務ドメインの一文要約}"
key_concepts:
  - "{重要概念1}"
  - "{重要概念2}"
  - "{重要概念3}"
harness_implications:
  - "{ハーネス設計への影響1}"
  - "{ハーネス設計への影響2}"
---

# {domain} 業務ドメイン知見

## 業界概要・市場動向
## ビジネスモデル・収益構造
## 主要ワークフロー・プロセス
## KPI・成功指標
## 法規制・コンプライアンス
## ツール・プラットフォーム
## AIエージェント活用のポイント
## ハーネス設計への示唆
### CLAUDE.md/AGENTS.mdに含めるべき業務知識
### 業務特化スキルの設計指針
### 業務特化ルール・ガードレール
```

### Phase 5: レジストリ更新 & PR & マージ

1. `kb/external/_index.md` に新エントリ追加（ツール調査時）
2. `kb/domains/_index.md` に新エントリ追加（業務ドメイン調査時）
3. `kb/update-history.md` に調査記録追加
4. featureブランチ `research/{name}` でcommit → push → PR作成
5. **自動マージ**（デフォルト）
6. mainに戻って次の対象へ

## 注意事項

- 「多様性は善」: 一つの正解を押し付けず、pros/consを明示
- プライベートプロジェクト名を混入させない
- 調査コストは惜しまない。網羅的に調べることで価値が生まれる
- 各対象ごとに独立PRを作成・マージ。1つの巨大PRにまとめない
- 前の調査結果は次の調査の参考にできる（累積知識の活用）
- エラーが出ても次の対象に進む（1件の失敗で全体を止めない）
- **全アウトプットにfrontmatterを必須付与**（段階的開示・コンテキスト節約のため）
- **業務ドメイン調査はユーザー指示がある場合のみ実施**（勝手にドメイン深掘りしない）
- 業務ドメイン知見はkb/domains/に格納し、kb/external/（ツール調査）と分離する
- kb/domains/には汎用的な業務知見のみ。プロジェクト固有の機密情報はprivate/に
