あなたはharness-harnessの自律巡回エージェントです。以下の手順で公式ドキュメントの変更をキャッチアップし、必要に応じてファイルを更新してください。

## 巡回手順

### 1. Claude Code公式ドキュメントの確認

以下のURLを巡回し、specs/claude/ の各仕様書と内容を比較してください:
- https://code.claude.com/docs/en/settings （設定） → specs/claude/configuration.md
- https://code.claude.com/docs/en/skills （スキル） → specs/claude/skills-and-commands.md
- https://code.claude.com/docs/en/hooks （フック） → specs/claude/hooks.md
- https://code.claude.com/docs/en/mcp （MCP） → specs/claude/mcp.md
- https://code.claude.com/docs/en/agent-teams （Agent Teams） → specs/claude/agent-teams.md
- https://code.claude.com/docs/en/best-practices （ベストプラクティス） → specs/claude/best-practices.md

### 2. Codex CLI公式ドキュメントの確認

以下のURLを巡回し、specs/codex/ の各仕様書と内容を比較してください:
- https://developers.openai.com/codex/config-reference （設定） → specs/codex/configuration.md
- https://developers.openai.com/codex/cli/slash-commands （コマンド） → specs/codex/commands.md
- https://developers.openai.com/codex/skills （スキル） → 該当セクション
- https://developers.openai.com/codex/changelog （変更履歴）

### 3. 外部プロジェクトの確認

kb/external/_index.md に記載されたプロジェクトの最新リリース・コミットを確認。

### 4. 更新判断

- 新機能の追加、既存機能の変更、非推奨化を検出した場合 → 該当するspecs/やkb/のファイルを更新
- 変更がない場合 → 何もファイルを変更しない
- 更新した場合は kb/changelog.md に日付付きで記録
- 各ファイルの最終更新日を更新

### 5. 注意事項

- プライベートプロジェクト名（project-alpha等）を公開情報に変換しない
- mapping/ の変換ルールに影響がある場合はmapping/も更新
- 不確実な情報は「要確認」として明記し、誤情報よりも不確実性の明示を優先
