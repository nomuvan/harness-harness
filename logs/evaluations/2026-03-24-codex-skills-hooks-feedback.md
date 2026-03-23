# Codex Skills/Hooks対応フィードバック

日付: 2026-03-24
対象PR: project-alpha #250, project-beta #2

## 発見の重要性

「Skills/HooksはClaude固有」という前提は**初期調査の不備**。ユーザーの指摘がなければ誤った前提のまま進んでいた。

→ **学び**: specs/の仕様書は定期的に再調査が必須。特に急速に進化するCLIツールは数週間で機能が追加される。`/patrol` スキルの重要性が改めて確認された。

## 実践結果

### Skills
- SKILL.mdフォーマットがClaude/Codex完全互換であることを実証
- `.claude/skills/` → `.codex/skills/` のコピーは微修正のみで済む
- 主な修正点: `context: fork`, `allowed-tools` の除去（Codex未サポート）、環境固有パスの動的化

### Hooks
- `codex_hooks` フィーチャーフラグで有効化が必要
- SessionStartのみ実装。PreToolUseがないためセキュリティhookはCodexでは不可
- config.toml の `[[hooks]]` 形式はsettings.jsonより簡潔

## mapping 4分類の更新

| 分類 | 変更前 | 変更後 |
|------|--------|--------|
| Skills | claude-native | **shared** |
| Hooks (SessionStart, Stop, UserPromptSubmit) | claude-native | **shared（実験的）** |
| Hooks (PreToolUse, PostToolUse等) | claude-native | claude-native（変更なし） |
| context: fork | claude-native | claude-native（変更なし） |
| allowed-tools | claude-native | claude-native（変更なし） |

## claude-pr-reviewの繰り返し指摘

gpt-5.4の「存在しないモデルID」指摘が3回連続で出ている。AIレビューの限界として記録。
→ **学び**: AIレビュー指摘の却下理由を記録し、同じ却下を繰り返す場合はレビュー設定で対応すべき
