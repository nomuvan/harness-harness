---
name: research-kb
description: |
  新しいツール・技術・ナレッジをkb/に追加する調査スキル。
  単体または複数対象を一括でシーケンシャルに調査→PR→マージまで実行。
  公式サイト、GitHub、Web全般を徹底的に調査し、Claude/Codexクロスレビューでアウトプットを作成。
  「○○を調査して」「kb/に追加して」「以下のリストを調査して」で起動。
---

# research-kb スキル

新しいツール・技術・ナレッジをkb/external/に追加する。コストをかけて徹底調査し、harness-harnessへの適用判断まで行う。

## 入力形式

### 単体調査

```
autoresearchを調査して
```

### 複数一括調査

調査対象のリストを渡すと、上から順にシーケンシャルに調査→PR→マージを繰り返す。

```
以下を順番に調査して:
- https://github.com/karpathy/autoresearch
- https://github.com/anthropics/claude-agent-sdk-python
- https://github.com/microsoft/markitdown
```

または:

```
以下を順番に調査して:
1. Karpathy autoresearch — 自律研究ループ
2. Claude Agent SDK Python — Claude Code SDK
3. markitdown — ドキュメント変換ツール
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

── B の調査開始 ──
  Phase 1〜5: 同上（B）
── B 完了 ──

── C の調査開始 ──
  Phase 1〜5: 同上（C）
── C 完了 ──

全対象完了
```

**各対象ごとに独立したPRを作成・マージする。** 1つの巨大PRにまとめない。
前の対象の調査結果が次の対象の参考になる場合がある（累積知識）。

## 各対象の調査プロセス

### Phase 1: 徹底調査（Claude主担当）

以下の全てを調査する。コスト度外視で網羅的に。

1. **公式サイト・ドキュメント**: README、ドキュメント、ガイド
2. **GitHubソースコード**: リポジトリ構造、主要ファイル、設計パターン。ソースコードを実際に読む
3. **Web全般**: ブログ記事、X(Twitter)での評判、YouTube動画、Hacker Newsスレッド
4. **評価・人気**: GitHub Stars、フォーク数、コントリビューター数、最終更新日、リリース頻度
5. **類似ツールとの比較**: 競合・代替ツールとのpros/cons
6. **ライセンス**: 商用利用可否

### Phase 2: Codexによる独自調査

Codex CLIに同じ対象の調査を依頼（`codex exec`使用）。Claude Phase 1と並列実行可。

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

以下のファイルを作成:

#### kb/external/{name}/analysis.md

```markdown
# {name} 深掘り分析

- URL: {url}
- 作者: {author}
- ライセンス: {license}
- GitHub Stars: {stars}
- 最終更新: {date}
- 調査日: {today}

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
# {name} からの知見と採用判断

調査日: {today}
対象: {url}

## 方針
## 採用判断（テーブル形式: パターン/機能, 判定, 理由, 適用方法）
## harness-harnessへの組み込み指針
### 既存ハーネスへの適用
### 新規ハーネスへの適用
### 組み込むべきでないもの
## Claude/Codexクロスレビュー結果
```

### Phase 5: レジストリ更新 & PR & マージ

1. `kb/external/_index.md` に新エントリ追加
2. `kb/update-history.md` に調査記録追加
3. featureブランチ `research/{name}` でcommit → push → PR作成
4. **自動マージ**（デフォルト）
5. mainに戻って次の対象へ

## 注意事項

- 「多様性は善」: 一つの正解を押し付けず、pros/consを明示
- プライベートプロジェクト名を混入させない
- 調査コストは惜しまない。網羅的に調べることで価値が生まれる
- 各対象ごとに独立PRを作成・マージ。1つの巨大PRにまとめない
- 前の調査結果は次の調査の参考にできる（累積知識の活用）
- エラーが出ても次の対象に進む（1件の失敗で全体を止めない）
