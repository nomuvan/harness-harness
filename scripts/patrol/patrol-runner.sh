#!/usr/bin/env bash
set -euo pipefail

# 設定（環境変数で上書き可能）
BRANCH="${PATROL_BRANCH:-main}"
SKIP_FORCE_MERGE="${PATROL_SKIP_FORCE_MERGE:-false}"
REPO_URL="https://github.com/nomuvan/harness-harness.git"
MAX_BUDGET="${PATROL_MAX_BUDGET_USD:-5}"
LOG_DIR="/patrol-logs"
LOG_FILE="${LOG_DIR}/patrol-$(date +%Y%m%d-%H%M%S).log"
CACHE_DIR="/patrol-cache"

mkdir -p "$LOG_DIR" "$CACHE_DIR/pages"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=== Patrol Start: $(date -u +%Y-%m-%dT%H:%M:%SZ) ==="
echo "Branch: $BRANCH | SkipForceMerge: $SKIP_FORCE_MERGE | MaxBudget: \$$MAX_BUDGET"

# 1. ソース取得
if [ -d /workspace/harness-harness ]; then
  cd /workspace/harness-harness
  git fetch origin
  git checkout "$BRANCH"
  git reset --hard "origin/$BRANCH"
else
  git clone -b "$BRANCH" "$REPO_URL" /workspace/harness-harness
  cd /workspace/harness-harness
fi

echo "HEAD: $(git log --oneline -1)"

# 2. Phase 1: 軽量ヘッダチェック（Claude CLIを使わない）
echo "--- Phase 1: Header check ---"
METADATA_FILE="$CACHE_DIR/url-metadata.json"
[ -f "$METADATA_FILE" ] || echo '{}' > "$METADATA_FILE"

# 巡回対象URLリスト
URLS=(
  "https://code.claude.com/docs/en/settings"
  "https://code.claude.com/docs/en/skills"
  "https://code.claude.com/docs/en/hooks"
  "https://code.claude.com/docs/en/mcp"
  "https://code.claude.com/docs/en/agent-teams"
  "https://code.claude.com/docs/en/best-practices"
  "https://code.claude.com/docs/en/sub-agents"
  "https://code.claude.com/docs/en/headless"
  "https://developers.openai.com/codex/config-reference"
  "https://developers.openai.com/codex/cli/slash-commands"
  "https://developers.openai.com/codex/skills"
  "https://developers.openai.com/codex/changelog"
)

CHANGED_URLS=()
for url in "${URLS[@]}"; do
  # URLをキーに変換（/と:を_に）
  url_key=$(echo "$url" | sed 's/[/:.]/_/g')

  # HTTPヘッダ取得
  headers=$(curl -sI -L --max-time 10 "$url" 2>/dev/null || echo "")
  last_modified=$(echo "$headers" | grep -i "^last-modified:" | head -1 | sed 's/^[^:]*: //' | tr -d '\r')
  etag=$(echo "$headers" | grep -i "^etag:" | head -1 | sed 's/^[^:]*: //' | tr -d '\r')
  content_length=$(echo "$headers" | grep -i "^content-length:" | head -1 | sed 's/^[^:]*: //' | tr -d '\r')

  # 前回の値と比較
  prev_modified=$(jq -r ".\"$url_key\".last_modified // \"\"" "$METADATA_FILE" 2>/dev/null)
  prev_etag=$(jq -r ".\"$url_key\".etag // \"\"" "$METADATA_FILE" 2>/dev/null)
  prev_length=$(jq -r ".\"$url_key\".content_length // \"\"" "$METADATA_FILE" 2>/dev/null)

  changed=false
  if [ -z "$prev_modified" ] && [ -z "$prev_etag" ]; then
    # 初回（キャッシュなし）→ 変更扱い
    changed=true
    echo "  NEW: $url"
  elif [ -n "$etag" ] && [ "$etag" != "$prev_etag" ]; then
    changed=true
    echo "  CHANGED (etag): $url"
  elif [ -n "$last_modified" ] && [ "$last_modified" != "$prev_modified" ]; then
    changed=true
    echo "  CHANGED (modified): $url"
  elif [ -n "$content_length" ] && [ "$content_length" != "$prev_length" ]; then
    changed=true
    echo "  CHANGED (size): $url"
  else
    echo "  UNCHANGED: $url"
  fi

  # メタデータ更新
  tmp=$(mktemp)
  jq --arg key "$url_key" \
     --arg lm "$last_modified" \
     --arg et "$etag" \
     --arg cl "$content_length" \
     --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
     '.[$key] = {"last_modified": $lm, "etag": $et, "content_length": $cl, "checked_at": $ts}' \
     "$METADATA_FILE" > "$tmp" && mv "$tmp" "$METADATA_FILE"

  if [ "$changed" = true ]; then
    CHANGED_URLS+=("$url")
  fi
done

echo "Phase 1 result: ${#CHANGED_URLS[@]}/${#URLS[@]} URLs changed"

# 変更なし → 終了
if [ ${#CHANGED_URLS[@]} -eq 0 ]; then
  echo "No URL changes detected. Skipping Claude CLI. Patrol complete."
  echo "=== Patrol End: $(date -u +%Y-%m-%dT%H:%M:%SZ) ==="
  exit 0
fi

# 3. Phase 2: 変更URLのみClaude CLIで詳細比較
echo "--- Phase 2: Claude CLI patrol (${#CHANGED_URLS[@]} URLs) ---"

# 変更URLリストをプロンプトに組み込み
CHANGED_LIST=$(printf "- %s\n" "${CHANGED_URLS[@]}")
PROMPT=$(cat /patrol/patrol-prompt.md)
PROMPT="${PROMPT}

## 今回変更が検出されたURL（これらのみ巡回してください）

${CHANGED_LIST}

上記以外のURLは変更なしのためスキップしてください。"

RESULT=$(claude -p "$PROMPT" \
  --allowedTools "Bash,Read,Edit,Write,Glob,Grep,WebFetch,WebSearch" \
  --max-budget-usd "$MAX_BUDGET" \
  --output-format json 2>&1) || true

echo "$RESULT" | jq -r '.result // "No result"' 2>/dev/null || echo "$RESULT"
echo "--- Claude CLI patrol end ---"

# 4. 変更チェック
if [ -z "$(git status --porcelain)" ]; then
  echo "Claude CLI found no spec updates needed. Patrol complete."
  echo "=== Patrol End: $(date -u +%Y-%m-%dT%H:%M:%SZ) ==="
  exit 0
fi

# 5. PR作成
BRANCH_NAME="patrol/auto-$(date +%Y%m%d)"
git checkout -b "$BRANCH_NAME" 2>/dev/null || git checkout "$BRANCH_NAME"
git add -A
git commit -m "patrol: 公式ドキュメント巡回による自動更新 ($(date +%Y-%m-%d))

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>"
git push origin "$BRANCH_NAME"

PR_URL=$(gh pr create \
  --title "patrol: 公式ドキュメント自動更新 $(date +%Y-%m-%d)" \
  --body "## Summary

自動巡回により検出された公式ドキュメントの変更を反映。

## 変更検出URL
${CHANGED_LIST}

## 巡回統計
- チェック対象: ${#URLS[@]} URLs
- 変更検出: ${#CHANGED_URLS[@]} URLs
- 未変更（スキップ）: $((${#URLS[@]} - ${#CHANGED_URLS[@]})) URLs

🤖 Generated by harness-harness patrol system" \
  --base "$BRANCH" 2>&1)

echo "PR created: $PR_URL"

# 6. マージ判断
if [ "$SKIP_FORCE_MERGE" = "false" ]; then
  echo "Auto-merging PR..."
  sleep 5
  gh pr merge "$PR_URL" --merge --admin 2>&1 || \
    gh pr merge "$PR_URL" --merge 2>&1 || \
    echo "WARN: Auto-merge failed. PR remains open for manual review."
else
  echo "SkipForceMerge=true: PR作成のみ。手動マージ待ち。"
fi

echo "=== Patrol End: $(date -u +%Y-%m-%dT%H:%M:%SZ) ==="
