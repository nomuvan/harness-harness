---
name: "OpenClaw"
type: takeaways
tags: [skill-md-standard, skill-priority-layers, gating-mechanism, local-first, self-modifying-agent]
last_checked: "2026-03-27"
adoption_summary: "SKILL.mdフォーマット・3層優先順位・ゲーティング機構を採用。マルチチャネル・デーモンモデルは不採用"
top_patterns:
  - "SKILL.md YAML frontmatter + Markdown標準フォーマット"
  - "3層スキル優先順位（ワークスペース > マネージド > バンドル）"
  - "requires.bins/env/configによるゲーティング機構"
---

# OpenClaw からの知見と採用判断

調査日: 2026-03-23
対象: https://github.com/openclaw/openclaw

## 方針

harness-harnessは「ハーネスを作り、育て、壊すハーネスの母艦」であり、OpenClawとは根本目的が異なる（パーソナルAIアシスタント vs 開発ハーネス管理）。しかし、スキルシステムの設計やローカルファースト思想には学ぶべき点が多い。「多様性は善」の原則に従い、一つの正解ではなく選択肢として記録する。

---

## 1. SKILL.md フォーマット標準

**判断: 採用**

### 理由
OpenClawのSKILL.mdは、YAMLフロントマター + Markdown本文という構造で、gstack・superpowersとも共通する事実上の標準になりつつある。harness-harnessのテンプレートもこの形式に準拠すべき。

### 適用方法
- `templates/` 配下のスキルテンプレートをSKILL.md形式で統一
- フロントマターに `name`, `description`, `requires` を必須フィールドとして定義
- `requires.bins`, `requires.env`, `requires.config` のゲーティング機構を参考にする

### Pros
- 3大プロジェクト共通の標準に準拠でき、互換性が高い
- Markdownなので人間にもAIにも読みやすい

### Cons
- YAMLフロントマターの仕様がプロジェクトごとに微妙に異なる（完全互換ではない）

---

## 2. 3層スキル優先順位（ワークスペース > マネージド > バンドル）

**判断: 採用**

### 理由
harness-harnessは「ユーザーの既存・新規プロジェクトのハーネスを作成」するため、プロジェクト固有のカスタマイズがバンドル設定を上書きできる仕組みは必須。

### 適用方法
- テンプレート生成時に3層を明示: プロジェクト固有 > ユーザーグローバル > harness-harnessデフォルト
- `mapping/` のClaude⇔Codex変換ルールにもこの優先順位を適用

### Pros
- ユーザーのカスタマイズを尊重しつつデフォルトを提供できる
- チームでの共有（ワークスペースレベル）にも対応

### Cons
- 3層の競合解決ルールが複雑になりうる

---

## 3. マルチチャネル統合アーキテクチャ

**判断: 不採用**

### 理由
harness-harnessの対象は「Claude Code CLI (.claude), Codex CLI (.codex)」であり、WhatsApp/Slack等のメッセージングチャネルへの対応は範囲外。ただし、「複数のAI実行基盤への統一的なインターフェース」という抽象概念は `mapping/` の設計に活かせる。

### 参考にすべき点
- チャネルアダプターパターン: 各プラットフォーム固有の差異を吸収する抽象層
- ルーティング: エージェント/アカウントごとの隔離ワークスペース

---

## 4. ローカルファースト・デーモンモデル

**判断: 不採用（思想は参考）**

### 理由
常駐デーモンはharness-harnessの「ハーネステンプレート生成・管理」という用途にはオーバーキル。ただし、「データをクラウドにロックしない」「Markdownでメモリを管理」というローカルファースト思想はharness-harnessの設計原則と一致する。

### 適用方法
- ハーネスの状態管理はすべてファイルシステム上のMarkdown/YAML
- 外部サービス依存を最小化する設計を維持
- `registry/` の管理対象プロジェクト一覧もgit管理可能な形式で保持

---

## 5. ClawHubスキルレジストリ

**判断: 検討**

### 理由
harness-harnessがテンプレートのエコシステムを構築する場合、レジストリの概念は有用。ただし、現段階ではエコシステム構築は時期尚早。

### 検討ポイント
- テンプレートが十分に成熟したら、共有可能なレジストリを検討
- まずはGitHubリポジトリ + ディレクトリ構造で十分
- ClawHubの `openclaw skills install` のようなCLI体験は将来の参考に

---

## 6. 自己修正型エージェント（エージェントが自身のコードを書き換える）

**判断: 検討**

### 理由
harness-harnessは「自己改善の対象」と明記されている。OpenClawのエージェントが自身の実装を修正できるという設計は、この文脈で直接的に参考になる。

### 適用方法
- ハーネスの巡回・評価ログ（`logs/`）から改善提案を自動生成する仕組み
- `docs/decisions/` へのADR自動生成を検討
- ただし、無制限の自己修正は危険。変更は必ずgit管理下でレビュー可能にする

### Pros
- harness-harnessの自己改善ループを加速
- AIの優れた提案を活かすという方針に合致

### Cons
- 制御なしの自己修正は予測不能な変更を招く
- 人間のレビューゲートが必須

---

## 7. ゲーティング機構（requires.bins / requires.env / requires.config）

**判断: 採用**

### 理由
harness-harnessはClaude Code / Codex両対応を前提としており、スキルやテンプレートの適用条件をゲーティングする仕組みは実用的。

### 適用方法
- テンプレートのフロントマターに `requires` フィールドを追加
- 例: Claude Code専用テンプレートは `requires.bins: [claude]`、Codex専用は `requires.bins: [codex]`
- `scripts/` に環境チェックユーティリティを用意

---

## まとめ

| 項目 | 判断 | 優先度 |
|------|------|--------|
| SKILL.md フォーマット標準 | 採用 | 高 |
| 3層スキル優先順位 | 採用 | 高 |
| マルチチャネル統合 | 不採用 | — |
| ローカルファースト・デーモン | 不採用（思想は参考） | — |
| ClawHubレジストリ | 検討 | 低 |
| 自己修正型エージェント | 検討 | 中 |
| ゲーティング機構 | 採用 | 中 |
