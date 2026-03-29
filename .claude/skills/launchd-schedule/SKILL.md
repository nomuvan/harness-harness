---
name: launchd-schedule
description: |
  macOSのlaunchd + tmuxで定期的にClaudeプロンプトを実行するスケジューラ。
  tmuxセッション作成→Claude起動→準備完了検出→プロンプト送信を自動化。
  「スケジュール登録して」「スケジュール一覧」「スケジュール変更」「スケジュール削除」「今すぐ実行」で起動。
  「巡回スケジュール作って」「定期実行を設定して」でも起動。
---

# launchd-schedule スキル

macOSのlaunchd + tmuxでClaudeプロンプトを定期実行する。podmanコンテナ不要。

## 操作

### create — スケジュール登録

```bash
SKILL_DIR=$(find .claude/skills/launchd-schedule -name manage-schedule.sh -exec dirname {} \; | head -1)/..
bash "$SKILL_DIR/scripts/manage-schedule.sh" create \
  "<name>" \
  "<cron-expr>" \
  "<tmux-session>" \
  "<workdir>" \
  "<claude-cmd>" \
  "<prompt>"
```

引数:
- `name`: スケジュール名（英数字ハイフン）
- `cron-expr`: cron式（分 時 日 月 曜日）。例: `0 3 * * *` = 毎日3:00
- `tmux-session`: tmuxセッション名。デフォルト推奨: `harness-{name}`
- `workdir`: ワークディレクトリ。未指定時は現在のワークディレクトリを使う
- `claude-cmd`: claudeコマンドライン。デフォルト: `claude --dangerously-skip-permissions`
- `prompt`: 実行するプロンプト文字列

例:
```bash
bash "$SKILL_DIR/scripts/manage-schedule.sh" create \
  "daily-patrol" \
  "0 3 * * *" \
  "harness-patrol" \
  "/Users/nomuvan/work/harnesss-harness" \
  "claude --dangerously-skip-permissions" \
  "specs/とkb/を公式ドキュメントと照合して最新化して。変更があればPR作成して"
```

### list — スケジュール一覧

```bash
# 現在のプロジェクトのスケジュールのみ表示（デフォルト）
bash "$SKILL_DIR/scripts/manage-schedule.sh" list

# 全プロジェクトのスケジュールを表示
bash "$SKILL_DIR/scripts/manage-schedule.sh" list --all

# 特定プロジェクトのスケジュールを表示
bash "$SKILL_DIR/scripts/manage-schedule.sh" list <project-name>
```

デフォルトではカレントディレクトリ名でフィルタし、自プロジェクトのスケジュールのみ表示。
各スケジュールにはProject名が表示される（plistのHARNESS_PROJECT環境変数から取得）。

### update — スケジュール変更

```bash
bash "$SKILL_DIR/scripts/manage-schedule.sh" update "<name>" "<new-cron-expr>"
```

例: 毎日3:00 → 毎日6:00に変更
```bash
bash "$SKILL_DIR/scripts/manage-schedule.sh" update "daily-patrol" "0 6 * * *"
```

### run — 即時実行

登録済みスケジュールをスケジュール時刻を待たずに今すぐ実行する。

```bash
bash "$SKILL_DIR/scripts/manage-schedule.sh" run "<name>"
```

例:
```bash
bash "$SKILL_DIR/scripts/manage-schedule.sh" run "daily-patrol"
```

### delete — スケジュール削除

```bash
bash "$SKILL_DIR/scripts/manage-schedule.sh" delete "<name>"
```

## 動作の仕組み

1. launchdがcron式に従い `run-scheduled-prompt.sh` を起動
2. tmuxセッションの存在を確認
   - 存在しない → 新規作成 → Claude CLI起動
   - 存在するがClaude死亡 → セッション再作成 → Claude CLI起動
   - 存在してClaude稼働中 → そのまま使用
3. Claude起動時は**pane出力を監視して準備完了を自動検出**（最大60秒待機）
   - project trust確認が出たら自動で `y` を送信
4. `/clear` → プロンプト送信

## ファイル配置

| パス | 用途 |
|------|------|
| `~/Library/LaunchAgents/com.harness-schedule.*.plist` | launchdジョブ定義 |
| `~/.local/share/harness-schedule/logs/` | 実行ログ |
| `~/.local/share/harness-schedule/prompts/` | プロンプト保存 |

## 識別キーワード

全てのlaunchdジョブは `com.harness-schedule.` プレフィックス付き。
`launchctl list | grep harness-schedule` で一覧取得可能。

## 注意事項

- macOS専用（launchd依存）
- Mac起動中のみ実行。スリープ復帰時は未実行分を実行
- tmuxが必要（`brew install tmux`）
- 初回Claude起動時にログインが必要な場合あり（手動対応）
