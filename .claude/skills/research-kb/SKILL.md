---
name: research-kb
description: |
  新しいツール・技術・ナレッジをkb/に追加する調査スキル。
  公式サイト、GitHub、Web全般を徹底的に調査し、Claude/Codexクロスレビューでアウトプットを作成。
  「○○を調査して」「kb/に追加して」「○○をリサーチして」で起動。
---

# research-kb スキル

新しいツール・技術・ナレッジをkb/external/に追加する。コストをかけて徹底調査し、harness-harnessへの適用判断まで行う。

## 調査プロセス

### Phase 1: 徹底調査（Claude主担当）

以下の全てを調査する。コスト度外視で網羅的に。

1. **公式サイト・ドキュメント**: README、ドキュメント、ガイド
2. **GitHubソースコード**: リポジトリ構造、主要ファイル、設計パターン。ソースコードを実際に読む
3. **Web全般**: ブログ記事、X(Twitter)での評判、YouTube動画、Hacker Newsスレッド
4. **評価・人気**: GitHub Stars、フォーク数、コントリビューター数、最終更新日、リリース頻度
5. **類似ツールとの比較**: 競合・代替ツールとのpros/cons
6. **ライセンス**: 商用利用可否

### Phase 2: Codexによる独自調査

Codex CLIに同じ対象の調査を依頼（`codex exec`使用）。

```bash
codex exec --full-auto "以下のプロジェクトを徹底調査して、analysis.mdとtakeaways.mdを作成して。
対象: <URL>
GitHubソースコード、Web評判、harness-harnessへの適用可否を評価して。
結果を /tmp/codex-research/ に出力して。"
```

### Phase 3: クロスレビュー

1. **ClaudeがCodexのアウトプットをレビュー**: 見落とし、評価の偏り、追加すべき観点を指摘
2. **CodexがClaudeのアウトプットをレビュー**: 同上（`codex exec`で実行）
3. **レビュー結果を統合**: 双方の指摘を反映した最終版を作成

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
{1-2段落の概要}

## アーキテクチャ・構造
{ディレクトリ構成、主要コンポーネント}

## 主要機能
{機能一覧と詳細}

## 技術スタック
{使用言語、フレームワーク、依存関係}

## 評価・人気
{GitHub Stats、Web上の評判、コミュニティの活発さ}

## 類似ツールとの比較
{競合・代替ツールとのpros/cons表}

## ソースコード品質
{コード品質、テストカバレッジ、ドキュメント充実度}
```

#### kb/external/{name}/takeaways.md

```markdown
# {name} からの知見と採用判断

調査日: {today}
対象: {url}

## 方針
{harness-harnessとの関係性、採用の基本方針}

## 採用判断

| パターン/機能 | 判定 | 理由 | 適用方法 |
|-------------|------|------|---------|
| {item1} | 採用/不採用/検討 | {理由} | {具体的な適用方法} |

## harness-harnessへの組み込み指針

### 既存ハーネスへの適用
- {既存プロジェクト(project-alpha等)にどう組み込むか}

### 新規ハーネスへの適用
- {テンプレートにどう反映するか}

### 組み込むべきでないもの
- {採用しない理由と根拠}

## Claude/Codexクロスレビュー結果
- Claude評価: {要点}
- Codex評価: {要点}
- 統合判断: {最終判断}
```

### Phase 5: レジストリ更新 & PR

1. `kb/external/_index.md` に新エントリ追加
2. `kb/update-history.md` に調査記録追加
3. featureブランチでcommit → push → PR作成
4. デフォルトで自動マージ

## 注意事項

- 「多様性は善」: 一つの正解を押し付けず、pros/consを明示
- プライベートプロジェクト名を混入させない
- 調査コストは惜しまない。網羅的に調べることで価値が生まれる
- Codex exec失敗時はClaude単独で完遂する（Codex依存にしない）
