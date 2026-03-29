---
name: research-theme
description: |
  特定の調査研究テーマを長期的に調査・分析・ベンチマーク・レポートするスキル。
  research-kbが単発調査なのに対し、research-themeは長期テーマをwave単位で継続更新する。
  自律完遂/ユーザー協業の切り替え可能。Claude/Codex各自が成果物を作成→クロスレビュー→統合。
  成果物はkb/research-themes/に格納。多様性は善: 単一winnerを強制せず用途別推奨を出す。
  「○○を研究して」「ベンチマークして」「研究テーマ一覧」で起動。
---

# research-theme スキル

特定の調査研究テーマを長期的に調査・分析・ベンチマーク・レポートする。research-kbが「単発対象の調査→kb/に追加」なのに対し、research-themeは「長期テーマをwave単位で継続更新するliving document」。

## 特徴

- 多種多様なテーマに対応。ルールで縛りすぎない
- 自律完遂/ユーザー協業をテーマごとに切り替え可能
- Claude/Codexが各自成果物を作成→クロスレビュー→最終成果物
- ベンチマーク実行を含む（調査だけでなく実証）
- harness-harnessの各機能・対象プロジェクトで活用可能な知見を生み出す

## Phase構造

Phase 2-6はwave単位で反復する。テーマは育てるもの。

| Phase | 目的 | モード |
|-------|------|--------|
| 0: Intake | テーマ定義、自律/協業モード決定 | 必須対話 |
| 1: Framing | 調査問い、成功条件、対象・除外範囲 | 各自 |
| 2: Evidence | Web徹底調査（複数Agent並列） | 各自 |
| 3: Benchmark Design | 評価軸、シナリオ、判定基準 | Codex強め |
| 4: Wave Execution | ベンチマーク実行、証拠整理 | 各自 |
| 5: Synthesis | 結果統合、用途別推奨 | 各自 |
| 6: Cross Review | Claude/Codex相互レビュー、disagreement明文化 | 両者 |
| 7: Publish | 最終レポート、harness-harness反映 | 両者+ユーザー |

### モード切り替え

- **autonomous**: scope確定後、Phase 5まで自走。停止条件: 情報アクセス不可/評価軸の優先順位不明/high-stakes判断
- **collaborative**: Phase 1,3,5,7でユーザー確認。初回テーマ推奨
- **hybrid**: ベンチマーク実行まで自律、採用判断はユーザー協議

### 成果物格納先

`kb/research-themes/{theme-slug}/`

```
kb/research-themes/
  _index.md                    # テーマ一覧
  {theme-slug}/
    overview.md                # テーマ概要（frontmatter必須）
    charter.md                 # 調査問い・成功条件
    source-map.md              # ソース一覧
    benchmark-design.md        # 評価軸・シナリオ
    benchmark-runs/            # wave別実行結果
      wave-01.md
    findings.md                # 調査結果
    harness-implications.md    # harness-harnessへの適用指針
    cross-reviews/             # Claude/Codex相互レビュー
    final-report.md            # 最終レポート
    assets/                    # 生成物（画像等）
```

### 必須frontmatter

```yaml
---
source_skill: research-theme
theme: {theme-slug}
doc_type: overview|charter|benchmark-design|benchmark-run|finding|cross-review|final-report|harness-implication
status: draft|in-review|published|superseded
updated: "YYYY-MM-DD"
summary: "1行要約"
tags: [tag1, tag2]
---
```

任意: `mode`, `wave`, `review_state`, `related_projects`, `benchmark_suite`, `models`, `confidence`

## 注意事項

- 「多様性は善」: 単一winnerを強制しない。用途別にpros/cons/料金を明示
- ルールで縛りすぎない。テーマごとに最適な進め方が違う
- Claude/Codex各自が成果物を作成→Phase 6で必ずクロスレビュー
- ユーザーの指示実現に必要な情報にアクセスできない場合はヒアリング
- 成果物はharness-harnessの各機能（create-harness, diagnose-harness等）から参照可能にする
- ベンチマーク実行にはAPIキー等が必要。未設定時はユーザーにヒアリング
