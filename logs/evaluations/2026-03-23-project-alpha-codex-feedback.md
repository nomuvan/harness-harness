# project-alpha Codexハーネス作成フィードバック

日付: 2026-03-23
対象PR: <private-pr-url>

## mapping 4分類の実践結果

| 分類 | 該当項目 | 所感 |
|------|---------|------|
| shared | プロジェクト概要、ビルドコマンド、絶対ルール、コーディング規約 | そのまま変換可能。最も量が多い |
| claude-native | skills/, hooks/, agents/, rules/のpathsフロントマター | Codexに対応なし。AGENTS.mdで代替不可能なものが多い |
| codex-native | profiles（safe/author/ci）、shell_environment_policy | Claudeにない明確な価値。特にプロファイルは自律レベルの実装として有効 |
| wrapper-required | なし | 初期段階ではスクリプト代替は不要だった |

## 学んだこと

### 1. .claude/配下のドキュメントはCodexから直接参照できない
Codexは.claude/配下を自動読込しない。AGENTS.mdにcat参照手順を書く必要あり。
→ **テンプレートに反映**: 共用ドキュメントの参照パターンを標準化

### 2. shell_environment_policy: inherit=noneは非現実的
ビルドツール（mvn, cargo, java等）が多いプロジェクトではPATH制限が厳しすぎる。
→ **テンプレートのデフォルト**: inherit=all、秘匿変数は.envで管理

### 3. AGENTS.mdはCLAUDE.mdより簡潔にすべき
CodexはSkills/Hooksがないため、AGENTS.mdに書ける情報量に限界がある。冗長になると32KiB制限に引っかかる。
→ **テンプレート設計**: AGENTS.mdは必須情報に絞り、詳細は参照ドキュメントに委ねる

### 4. gpt-5.4は実在するモデルだがレビューで誤検出される
claude-pr-reviewが「存在しないモデルID」と指摘。実際にはCodex 0.116.0のデフォルト。
→ **知見**: AIレビューの指摘は全て鵜呑みにせず、事実確認して取捨選択する

## registry更新

project-alphaのCodexハーネスステータスを「あり」に更新すべき。
