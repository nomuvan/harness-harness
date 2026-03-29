#!/usr/bin/env bash
set -euo pipefail

# manage-schedule.sh — launchdスケジュールの登録・一覧・変更・削除
#
# Usage:
#   manage-schedule.sh create <name> <cron-expr> <session> <workdir> <claude-cmd> <prompt>
#   manage-schedule.sh list
#   manage-schedule.sh update <name> <cron-expr>
#   manage-schedule.sh delete <name>

PLIST_DIR="$HOME/Library/LaunchAgents"
LABEL_PREFIX="com.harness-schedule"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RUNNER="$SCRIPT_DIR/run-scheduled-prompt.sh"

# cron式(m h dom mon dow)をlaunchdのStartCalendarIntervalに変換
cron_to_plist_interval() {
  local cron_expr="$1"
  local minute hour day month weekday
  read -r minute hour day month weekday <<< "$cron_expr"

  echo "    <key>StartCalendarInterval</key>"

  # 複数エントリが必要な場合(カンマ区切り)は配列にする
  if [[ "$minute" == *","* ]] || [[ "$hour" == *","* ]]; then
    echo "    <array>"
    # 簡易実装: 単一値のみ対応
    echo "    <dict>"
    [ "$minute" != "*" ] && echo "        <key>Minute</key><integer>$minute</integer>"
    [ "$hour" != "*" ] && echo "        <key>Hour</key><integer>$hour</integer>"
    [ "$day" != "*" ] && echo "        <key>Day</key><integer>$day</integer>"
    [ "$month" != "*" ] && echo "        <key>Month</key><integer>$month</integer>"
    [ "$weekday" != "*" ] && echo "        <key>Weekday</key><integer>$weekday</integer>"
    echo "    </dict>"
    echo "    </array>"
  else
    echo "    <dict>"
    [ "$minute" != "*" ] && echo "        <key>Minute</key><integer>$minute</integer>"
    [ "$hour" != "*" ] && echo "        <key>Hour</key><integer>$hour</integer>"
    [ "$day" != "*" ] && echo "        <key>Day</key><integer>$day</integer>"
    [ "$month" != "*" ] && echo "        <key>Month</key><integer>$month</integer>"
    [ "$weekday" != "*" ] && echo "        <key>Weekday</key><integer>$weekday</integer>"
    echo "    </dict>"
  fi
}

create_schedule() {
  local name="$1"
  local cron_expr="$2"
  local session="$3"
  local workdir="$4"
  local claude_cmd="$5"
  local prompt="$6"

  local label="${LABEL_PREFIX}.${name}"
  local plist_file="${PLIST_DIR}/${label}.plist"
  local log_dir="$HOME/.local/share/harness-schedule/logs"

  mkdir -p "$log_dir"

  if [ -f "$plist_file" ]; then
    echo "ERROR: Schedule '$name' already exists. Use 'update' or 'delete' first."
    return 1
  fi

  # プロンプトをファイルに保存（plistのエスケープ問題回避）
  local prompt_dir="$HOME/.local/share/harness-schedule/prompts"
  mkdir -p "$prompt_dir"
  echo "$prompt" > "$prompt_dir/${name}.txt"

  local interval
  interval=$(cron_to_plist_interval "$cron_expr")

  # プロジェクト名をworkdirから自動取得
  local project_name
  project_name=$(basename "$workdir")

  cat > "$plist_file" << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>${label}</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>${RUNNER}</string>
        <string>${session}</string>
        <string>${workdir}</string>
        <string>${claude_cmd}</string>
        <string>${prompt}</string>
    </array>
${interval}
    <key>StandardOutPath</key>
    <string>${log_dir}/${name}-stdout.log</string>
    <key>StandardErrorPath</key>
    <string>${log_dir}/${name}-stderr.log</string>
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/usr/local/bin:/usr/bin:/bin:/opt/homebrew/bin:$HOME/.local/bin:$HOME/.nodenv/shims</string>
        <key>HOME</key>
        <string>$HOME</string>
        <key>HARNESS_PROJECT</key>
        <string>${project_name}</string>
    </dict>
</dict>
</plist>
PLIST

  launchctl load "$plist_file"
  echo "Created schedule '$name' ($cron_expr)"
  echo "  Label: $label"
  echo "  Plist: $plist_file"
  echo "  Session: $session | Workdir: $workdir"
}

list_schedules() {
  local filter_project="${1:-}"
  local current_project
  current_project=$(basename "$(pwd)")

  if [ "$filter_project" = "--all" ]; then
    echo "=== harness-schedule 一覧（全プロジェクト） ==="
    filter_project=""
  elif [ -z "$filter_project" ]; then
    echo "=== harness-schedule 一覧（${current_project}） ==="
    filter_project="$current_project"
  else
    echo "=== harness-schedule 一覧（${filter_project}） ==="
  fi

  local found=false
  for plist in "$PLIST_DIR"/${LABEL_PREFIX}.*.plist; do
    [ -f "$plist" ] || continue

    local label
    label=$(defaults read "$plist" Label 2>/dev/null)
    local name="${label#${LABEL_PREFIX}.}"

    # プロジェクト名を取得
    local project
    project=$(defaults read "$plist" EnvironmentVariables 2>/dev/null | grep -A1 "HARNESS_PROJECT" | tail -1 | tr -d ' ";' || echo "unknown")

    # フィルタ適用
    if [ -n "$filter_project" ] && [ "$project" != "$filter_project" ]; then
      continue
    fi

    found=true

    local status
    if launchctl list "$label" >/dev/null 2>&1; then
      status="active"
    else
      status="inactive"
    fi

    echo ""
    echo "  Name: $name"
    echo "  Project: $project"
    echo "  Status: $status"
    echo "  Label: $label"
    echo "  Plist: $plist"
  done

  if [ "$found" = false ]; then
    if [ -n "$filter_project" ]; then
      echo "  (${filter_project}のスケジュールなし。--all で全プロジェクト表示)"
    else
      echo "  (スケジュールなし)"
    fi
  fi
}

update_schedule() {
  local name="$1"
  local cron_expr="$2"

  local label="${LABEL_PREFIX}.${name}"
  local plist_file="${PLIST_DIR}/${label}.plist"

  if [ ! -f "$plist_file" ]; then
    echo "ERROR: Schedule '$name' not found."
    return 1
  fi

  # unload → plist書き換え → reload
  launchctl unload "$plist_file" 2>/dev/null || true

  # StartCalendarIntervalを置換
  local interval
  interval=$(cron_to_plist_interval "$cron_expr")

  # pythonでplist編集（sedでXML編集は危険）
  python3 << PYEOF
import plistlib, sys

with open("$plist_file", "rb") as f:
    plist = plistlib.load(f)

parts = "$cron_expr".split()
cal = {}
if parts[0] != "*": cal["Minute"] = int(parts[0])
if parts[1] != "*": cal["Hour"] = int(parts[1])
if parts[2] != "*": cal["Day"] = int(parts[2])
if parts[3] != "*": cal["Month"] = int(parts[3])
if parts[4] != "*": cal["Weekday"] = int(parts[4])

plist["StartCalendarInterval"] = cal

with open("$plist_file", "wb") as f:
    plistlib.dump(plist, f)
PYEOF

  launchctl load "$plist_file"
  echo "Updated schedule '$name' to: $cron_expr"
}

delete_schedule() {
  local name="$1"
  local label="${LABEL_PREFIX}.${name}"
  local plist_file="${PLIST_DIR}/${label}.plist"

  if [ ! -f "$plist_file" ]; then
    echo "ERROR: Schedule '$name' not found."
    return 1
  fi

  launchctl unload "$plist_file" 2>/dev/null || true
  rm -f "$plist_file"

  # プロンプトファイルも削除
  rm -f "$HOME/.local/share/harness-schedule/prompts/${name}.txt"

  echo "Deleted schedule '$name'"
}

run_now() {
  local name="$1"
  local label="${LABEL_PREFIX}.${name}"
  local plist_file="${PLIST_DIR}/${label}.plist"

  if [ ! -f "$plist_file" ]; then
    echo "ERROR: Schedule '$name' not found."
    return 1
  fi

  # plistからProgramArgumentsを読み取って実行
  echo "Running schedule '$name' immediately..."
  local args
  args=$(python3 << PYEOF
import plistlib
with open("$plist_file", "rb") as f:
    plist = plistlib.load(f)
args = plist["ProgramArguments"]
# 最初の /bin/bash を除いたスクリプトと引数を出力
for a in args[1:]:
    print(a)
PYEOF
  )

  # 引数を配列に読み込み
  local script_args=()
  while IFS= read -r line; do
    script_args+=("$line")
  done <<< "$args"

  echo "  Script: ${script_args[0]}"
  echo "  Session: ${script_args[1]:-}"
  echo ""

  # 実行（バックグラウンドではなくフォアグラウンドで結果を表示）
  bash "${script_args[@]}"
}

# メインディスパッチ
case "${1:-help}" in
  create)
    shift
    create_schedule "$@"
    ;;
  list)
    shift
    list_schedules "${1:-}"
    ;;
  update)
    shift
    update_schedule "$@"
    ;;
  delete)
    shift
    delete_schedule "$@"
    ;;
  run)
    shift
    run_now "$@"
    ;;
  *)
    echo "Usage:"
    echo "  $0 create <name> <cron-expr> <session> <workdir> <claude-cmd> <prompt>"
    echo "  $0 list"
    echo "  $0 update <name> <cron-expr>"
    echo "  $0 delete <name>"
    echo "  $0 run <name>"
    echo ""
    echo "Example:"
    echo "  $0 create daily-patrol '0 3 * * *' harness-patrol /path/to/harness 'claude --dangerously-skip-permissions' '巡回して'"
    echo "  $0 run daily-patrol"
    ;;
esac
