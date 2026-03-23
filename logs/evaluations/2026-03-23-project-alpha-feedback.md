# project-alpha改善からのフィードバック

日付: 2026-03-23
対象PR: https://github.com/nomuvan/project-alpha/pull/248

## 学んだこと

### 1. セキュリティhookに `|| true` は禁物
PreToolUseのようなセキュリティ目的のhookに `|| true` をつけると、スクリプト失敗時にブロックがサイレント無効化される。claude-pr-reviewが指摘。
→ **テンプレートのhookパターンに反映**: セキュリティhookは `|| true` なし、情報系hookは `|| true` あり

### 2. hookスクリプトのJSONパースはjqを使う
grepベースのJSONパースはエスケープ文字で壊れる。jqが必須依存。
→ **テンプレートの前提条件にjqを追加**

### 3. 診断の精度を上げる必要がある
rules/のpathsフロントマターは既に対応済みだった（診断で「未対応」と誤判定）。実ファイルを読んでから判定すべき。
→ **diagnose-harnessスキルの設計に反映**: 推測ではなくファイル内容を実際にパースして判定

### 4. settings.local.json（gitignored）の改善はPRでは対応不可
重複permissionの整理はユーザーに直接伝える必要がある。
→ **診断レポートにgitignored項目は「ユーザーへの手動対応推奨」として別セクション化**

### 5. claude-pr-reviewの指摘品質が高い
5件中5件が妥当な指摘。自動レビューワークフローはハーネス改善プロセスに必須。
→ **GitHub Actionsのclaude-pr-reviewワークフローをテンプレート化候補に**

## プロジェクト間コピー候補として確定したもの

| ファイル | 汎用性 | 備考 |
|---------|--------|------|
| hooks/block-global-changes.sh | ★★★★★ | jq依存。パターンはプロジェクトごとにカスタマイズ |
| hooks/session-context.sh | ★★★★★ | ほぼそのまま流用可能 |
| hooks/save-prompt.sh + .ps1 | ★★★★★ | bash/PS両対応パターンの模範 |
| hooks/notify-completion.sh + .ps1 | ★★★★★ | そのまま流用可能 |
| rules/no-global-changes.md | ★★★★★ | プロジェクトごとに禁止対象をカスタマイズ |
| skills/autonomous-task/ | ★★★★☆ | 骨格は汎用。フェーズ詳細はプロジェクト固有 |
| skills/pr-review-cycle/ | ★★★★☆ | gh CLI依存。そのまま流用可能 |
| skills/skill-creator/ | ★★★★★ | 完全汎用 |
