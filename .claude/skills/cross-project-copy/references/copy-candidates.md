# コピー候補カタログ

実績に基づく汎用パターン一覧。新プロジェクトへのハーネス作成時に参照。

## ★★★★★ そのままコピー

### hooks/save-prompt.sh + save-prompt.ps1
- 機能: UserPromptSubmitでプロンプトをdaily historyに自動保存
- ソース: project-alpha
- 依存: bash/PowerShell
- カスタマイズ: 不要

### hooks/notify-completion.sh + notify-completion.ps1
- 機能: Stop hookで完了通知
- ソース: project-alpha
- 依存: bash/PowerShell
- カスタマイズ: 通知先URL（webhook等）

### hooks/session-context.sh
- 機能: SessionStartで直近git log + open PRを表示
- ソース: project-alpha
- 依存: jq, gh CLI
- カスタマイズ: 不要

### skills/skill-creator/
- 機能: 新スキル作成のガイドライン
- ソース: project-alpha（superpowersから移植）
- 依存: なし
- カスタマイズ: 不要

### rules/no-global-changes.md
- 機能: グローバル環境変更の禁止
- ソース: project-alpha
- 依存: なし
- カスタマイズ: 禁止対象コマンドリスト（技術スタック依存）

### hooks/block-global-changes.sh
- 機能: PreToolUseでグローバル変更コマンドを自動ブロック
- ソース: project-alpha
- 依存: jq
- カスタマイズ: ブロック対象パターン（技術スタック依存）

## ★★★★☆ 軽微カスタマイズ

### skills/pr-review-cycle/
- 機能: PRのCIレビュー結果確認→修正→re-pushサイクル
- ソース: project-alpha
- 依存: gh CLI, GitHub Actions
- カスタマイズ: CIレビューbot名、チェック名

### skills/autonomous-task/
- 機能: 計画→実装→テスト→PR→マージの自律完遂
- ソース: project-alpha
- 依存: gh CLI, git worktree
- カスタマイズ: デプロイフェーズ（Phase 1.5, 5）、ビルドコマンド

### skills/github-force-sync/
- 機能: GitHub同期の強制復旧
- ソース: project-beta
- 依存: git
- カスタマイズ: 不要

## ★★★☆☆ 骨格のみ流用

### rules/coding-standards.md
- 骨格: YAML frontmatter (paths:) + 言語ポリシー + エラー処理 + ログ規約
- カスタマイズ: 言語・フレームワーク固有の規約を全て書き換え

### rules/team-protocol.md
- 骨格: サブエージェント vs チーム判断フロー + リマインダーエージェント
- カスタマイズ: チーム構成、判断基準
