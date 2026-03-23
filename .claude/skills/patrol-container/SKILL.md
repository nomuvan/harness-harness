---
name: patrol-container
description: |
  自律巡回コンテナの管理スキル。コンテナの生成、破棄、即時実行、ログ確認を行う。
  「巡回コンテナ作って」「パトロール実行して」「巡回コンテナ削除して」「巡回ログ見せて」で起動。
---

# patrol-container スキル

harness-harnessの自律巡回コンテナを管理する。

## ランタイム検出

```bash
# podman優先、なければdocker
if command -v podman &>/dev/null; then
  RUNTIME=podman
elif command -v docker &>/dev/null; then
  RUNTIME=docker
else
  echo "Error: podman/dockerが見つかりません" && exit 1
fi
```

## 操作

### create — コンテナ生成

引数: `--branch <name>` (デフォルト: main), `--runtime docker|podman`, `--skip-force-merge`

```bash
REPO_ROOT=$(git rev-parse --show-toplevel)
$RUNTIME build -t harness-patrol "$REPO_ROOT/scripts/patrol/"
$RUNTIME run -d --name harness-patrol \
  -e PATROL_BRANCH="${BRANCH:-main}" \
  -e PATROL_SKIP_FORCE_MERGE="${SKIP_FORCE_MERGE:-false}" \
  -v ~/.claude.json:/root/.claude.json:ro \
  -v ~/.claude:/root/.claude:ro \
  -v ~/.config/gh:/root/.config/gh:ro \
  -v harness-patrol-logs:/patrol-logs \
  harness-patrol
```

### destroy — コンテナ破棄

```bash
$RUNTIME stop harness-patrol && $RUNTIME rm harness-patrol
# イメージも削除するか確認
```

### run-now — 即時実行

コンテナが起動中の前提でcronではなく即座に巡回を実行。

```bash
$RUNTIME exec harness-patrol /patrol/patrol-runner.sh
```

### logs — ログ確認

```bash
$RUNTIME exec harness-patrol ls -lt /patrol-logs/ | head -10
# 最新ログを表示
LATEST=$($RUNTIME exec harness-patrol ls -t /patrol-logs/patrol-*.log | head -1)
$RUNTIME exec harness-patrol cat "$LATEST"
```

### status — 状態確認

```bash
$RUNTIME inspect harness-patrol --format '{{.State.Status}}' 2>/dev/null || echo "Not running"
$RUNTIME exec harness-patrol crontab -l 2>/dev/null || echo "No cron configured"
```
