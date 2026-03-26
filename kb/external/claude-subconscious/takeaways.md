# claude-subconscious — harness-harness への採用判断

## 総合判断: パターン採用（ツール統合は不採用）

claude-subconscious自体のインストール・依存追加は不要。ただし、メモリアーキテクチャ設計パターン・Hook活用パターン・コンテキスト注入戦略は harness-harness のテンプレート・知見に大きく貢献する。

## 採用（高優先度）

### 1. 8ブロック構造化メモリパターン → MEMORY.md改善テンプレート

**知見**: claude-subconsciousの8メモリブロック分類は、Claude Code Native の MEMORY.md（フラットなメモ帳）を構造化するパターンとして秀逸。

| ブロック | harness-harnessでの対応 |
|---------|----------------------|
| core_directives | CLAUDE.md（既存） |
| guidance | MEMORY.md の「次セッションへの申し送り」セクション |
| user_preferences | MEMORY.md の user_style.md（既に存在） |
| project_context | CLAUDE.md のプロジェクト概要（既存） |
| session_patterns | MEMORY.md の「繰り返しパターン」セクション（新規提案） |
| pending_items | MEMORY.md の「未完了タスク」セクション（新規提案） |
| self_improvement | MEMORY.md の「メモリ改善メモ」（新規提案） |
| tool_guidelines | CLAUDE.md のツール使用指針（既存） |

**アクション**: MEMORY.md構造化テンプレートを `templates/` に追加。200行上限を意識した「インデックス+分割ファイル」パターンを標準化。

### 2. stdout非侵襲注入パターン → Hook設計のベストプラクティス

**知見**: CLAUDE.mdを直接書き換えずstdoutで注入する設計は、ハーネスの「CLAUDE.md汚染問題」を回避する正攻法。

**アクション**: `specs/claude/hooks.md` にUserPromptSubmit stdout注入のベストプラクティスとして記録。テンプレートのHook例に反映。

### 3. 非同期detached workerパターン → Stop Hookの活用法

**知見**: Stop hookでdetached workerを起動し、メインフローをブロックせずにトランスクリプト処理を行うパターン。120sタイムアウトの中で`spawn`して即returnする実装。

**アクション**: Hook設計テンプレートに「非同期バックグラウンド処理」パターンとして追加。

## 採用（中優先度）

### 4. pending_items / guidance ブロック → セッション間引き継ぎ

**知見**: 「未完了タスク」と「次セッションへのガイダンス」を明示的に分離して管理するパターン。Claude Code Nativeの MEMORY.md ではこの区別が曖昧。

**アクション**: MEMORY.md テンプレートに `## Pending` と `## Guidance` セクションを標準化。Auto Dreamとの共存を考慮。

### 5. self_improvement ブロック → メモリ自己進化の仕組み

**知見**: メモリブロック自体の進化ガイドライン（何を記憶すべきか、何を忘れるべきか）をメモリ内に定義するメタパターン。

**アクション**: MEMORY.md テンプレートの冒頭に「このメモリの管理方針」セクションを追加検討。Auto Dream のconsolidation指示と統合。

### 6. マルチプロジェクト共有メモリ → harness-harness自体の知見管理

**知見**: 単一エージェントが複数プロジェクトの知識を横断管理するパターン。harness-harnessが管理対象プロジェクト間の知見を共有する際の参考。

**アクション**: `kb/` ディレクトリの設計にプロジェクト横断知見の蓄積パターンを反映（既に部分的に実装済み）。

## 検討（要追加調査）

### 7. PreToolUse hookによるワークフロー中コンテキスト更新

**知見**: ツール実行前にコンテキストを追加注入するパターン。長時間セッションでのコンテキストドリフト（話題の逸脱）を防ぐ。

**課題**: PreToolUse hookの `additionalContext` フィールドの実用性を検証する必要あり。パフォーマンス影響も考慮。

### 8. claude-cognitive の注意力ベース3層管理

**知見**: HOT/WARM/COLDの動的コンテキスト管理は大規模コードベースで64-95%のトークン削減を実現。claude-subconsciousとは異なるアプローチだが、外部依存ゼロで実現。

**課題**: keywords.jsonの手動管理コストが高い。自動キーワード抽出との組み合わせが必要。

### 9. claude-mem のProgressive Disclosure検索パターン

**知見**: search→timeline→get_observations の3段階検索は「段階的開示」の原則と合致。10x圧縮による効率的な記憶検索。

**課題**: AGPL-3.0ライセンスのため直接流用は制約あり。パターンのみ参照。

## 不採用

### claude-subconscious 自体のインストール・統合

**理由**:
1. **外部依存**: Letta Cloud/Server への依存はharness-harnessの「自己完結」方針と矛盾
2. **Claude Code Native メモリの進化**: MEMORY.md + Auto Dream（2026-03月展開中）がネイティブで類似機能を提供しつつある
3. **追加コスト**: バックグラウンドLLM推論のコストが発生
4. **Codex CLI非対応**: Claude Code専用プラグインのため、クロスプラットフォーム方針と合わない
5. **レイテンシ**: UserPromptSubmit 10sタイムアウトが体験を損なう可能性

### claude-mem のインストール・統合

**理由**:
1. AGPL-3.0ライセンス（harness-harnessはMIT想定との不整合リスク）
2. Worker常駐+ポート使用のオーバーヘッド
3. SQLite+Chroma依存が重い

### claude-cognitive のインストール・統合

**理由**:
1. keywords.json手動管理の運用コスト
2. Python依存（harness-harness本体はシェルスクリプト/TypeScript寄り）
3. 443スターで成熟度が低い

## harness-harness への具体的アクション

### 即座に実施可能

1. **MEMORY.md構造化テンプレート作成** — 8ブロック分類を参考に、Claude Code Native の200行上限内で最適な構造を設計
2. **Hook設計ベストプラクティス追記** — stdout注入、detached workerパターンを `specs/` or `templates/` に記録
3. **kb/update-history.md 更新** — 本調査の記録

### 中期的に検討

4. **Auto Dream連携テンプレート** — self_improvement的なメモリ管理方針をAuto Dream consolidationと統合
5. **プロジェクト間知見共有パターン** — マルチプロジェクトメモリの構造設計
6. **コンテキスト管理比較表** — 4ツールのアプローチを `kb/research/` に知見として蓄積

## まとめ

claude-subconsciousは「ツールとしての導入」ではなく「設計パターンの宝庫」として最も価値がある。特にメモリブロックの8分類、stdout非侵襲注入、非同期detached worker、self-improvementメタパターンは、harness-harnessのテンプレート設計に直接活かせる。Claude Code NativeのMEMORY.md + Auto Dreamが成熟するにつれ、外部メモリツール自体の必要性は低下するが、その構造化パターンは普遍的に有用。
