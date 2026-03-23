#!/usr/bin/env bash
set -euo pipefail

# 設定（環境変数で上書き可能）
BRANCH="${PATROL_BRANCH:-main}"
SKIP_FORCE_MERGE="${PATROL_SKIP_FORCE_MERGE:-false}"
REPO_URL="https://github.com/nomuvan/harness-harness.git"
MAX_BUDGET="${PATROL_MAX_BUDGET_USD:-5}"
LOG_DIR="/patrol-logs"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
LOG_FILE="${LOG_DIR}/patrol-${TIMESTAMP}.log"
CACHE_DIR="/patrol-cache"
START_EPOCH=$(date +%s)

mkdir -p "$LOG_DIR" "$CACHE_DIR/pages"
exec > >(stdbuf -oL tee -a "$LOG_FILE") 2>&1

# ログユーティリティ
log() { echo "[$(date -u +%H:%M:%S)] $*"; }
log_phase() { echo ""; echo "========== $* =========="; }
elapsed() { echo "$(( $(date +%s) - START_EPOCH ))s elapsed"; }

# git認証設定
if [ -n "${GH_TOKEN:-}" ]; then
  git config --global url."https://${GH_TOKEN}@github.com/".insteadOf "https://github.com/"
  log "Git auth: GH_TOKEN configured"
else
  gh auth setup-git 2>/dev/null || true
  git config --global credential.helper '!gh auth git-credential' 2>/dev/null || true
  log "Git auth: gh credential helper configured"
fi

log_phase "Patrol Start"
log "Branch: $BRANCH | SkipForceMerge: $SKIP_FORCE_MERGE | MaxBudget: \$$MAX_BUDGET (サブスク内利用量制限。追加課金なし)"
log "Log file: $LOG_FILE"

# ──────────────────────────────────────
# Phase 0: ソース取得
# ──────────────────────────────────────
log_phase "Phase 0: Source Fetch"
if [ -d /workspace/harness-harness ]; then
  cd /workspace/harness-harness
  log "Fetching origin..."
  git fetch origin
  git checkout "$BRANCH"
  git reset --hard "origin/$BRANCH"
  log "Updated to: $(git log --oneline -1)"
else
  log "Cloning $REPO_URL ..."
  git clone -b "$BRANCH" "$REPO_URL" /workspace/harness-harness
  cd /workspace/harness-harness
  log "Cloned: $(git log --oneline -1)"
fi
log "Phase 0 done. ($(elapsed))"

# ──────────────────────────────────────
# Phase 1: 軽量変更チェック
# ──────────────────────────────────────
log_phase "Phase 1: Change Detection (no Claude CLI cost)"
METADATA_FILE="$CACHE_DIR/url-metadata.json"
[ -f "$METADATA_FILE" ] || echo '{}' > "$METADATA_FILE"

# URLリストを外部ファイルから読み込み
URL_FILE="scripts/patrol/patrol-urls.txt"
if [ ! -f "$URL_FILE" ]; then
  URL_FILE="/patrol/patrol-urls.txt"
fi
URLS=()
while IFS= read -r line; do
  line=$(echo "$line" | sed 's/#.*//' | tr -d '[:space:]')
  [ -n "$line" ] && URLS+=("$line")
done < "$URL_FILE"
log "Loaded ${#URLS[@]} URLs from $URL_FILE"

# llms.txt新ページ検出
log "Checking llms.txt for new pages..."
LLMS_TXT=$(curl -sL --max-time 15 "https://code.claude.com/docs/llms.txt" 2>/dev/null || true)
if [ -n "$LLMS_TXT" ]; then
  NEW_PAGES=$(echo "$LLMS_TXT" | grep -Eo 'https://code\.claude\.com/docs/en/[^)]+' | while read -r page_url; do
    # .mdを除去してURLに変換
    clean_url=$(echo "$page_url" | sed 's/\.md$//')
    # patrol-urls.txtに含まれていなければ新ページ
    if ! grep -qF "$clean_url" "$URL_FILE" 2>/dev/null; then
      echo "$clean_url"
    fi
  done || true)
  if [ -n "$NEW_PAGES" ]; then
    NEW_COUNT=$(echo "$NEW_PAGES" | wc -l | tr -d ' ')
    log "  ⚠ $NEW_COUNT new pages detected in llms.txt (not in patrol-urls.txt):"
    echo "$NEW_PAGES" | head -10 | while read -r p; do log "    + $p"; done
  else
    log "  No new pages in llms.txt"
  fi
fi

CHANGED_URLS=()
checked=0
for url in "${URLS[@]}"; do
  checked=$((checked + 1))
  url_key=$(echo "$url" | sed 's/[/:.]/_/g')

  # HTTPヘッダ取得
  headers=$(curl -sI -L --max-time 10 "$url" 2>/dev/null || true)
  last_modified=$(echo "$headers" | grep -i "^last-modified:" | head -1 | sed 's/^[^:]*: //' | tr -d '\r' || true)
  etag=$(echo "$headers" | grep -i "^etag:" | head -1 | sed 's/^[^:]*: //' | tr -d '\r' || true)
  content_length=$(echo "$headers" | grep -i "^content-length:" | head -1 | sed 's/^[^:]*: //' | tr -d '\r' || true)

  # 前回値取得
  prev_modified=$(jq -r ".\"$url_key\".last_modified // \"\"" "$METADATA_FILE" 2>/dev/null || true)
  prev_etag=$(jq -r ".\"$url_key\".etag // \"\"" "$METADATA_FILE" 2>/dev/null || true)
  prev_hash=$(jq -r ".\"$url_key\".content_hash // \"\"" "$METADATA_FILE" 2>/dev/null || true)

  changed=false
  reason=""

  # ヘッダベースの変更検出
  if [ -z "$prev_modified" ] && [ -z "$prev_etag" ] && [ -z "$prev_hash" ]; then
    changed=true
    reason="NEW (first check)"
  elif [ -n "$etag" ] && [ "$etag" != "$prev_etag" ]; then
    changed=true
    reason="ETag changed"
  elif [ -n "$last_modified" ] && [ "$last_modified" != "$prev_modified" ]; then
    changed=true
    reason="Last-Modified changed"
  fi

  # ヘッダで判定できない場合（Next.js SSR等）: ページ本体のハッシュ比較
  if [ "$changed" = false ] && [ -z "$etag" ] && [ -z "$last_modified" ]; then
    current_hash=$(curl -sL --max-time 15 "$url" 2>/dev/null | md5sum | cut -d' ' -f1 || true)
    if [ -n "$current_hash" ] && [ "$current_hash" != "$prev_hash" ]; then
      changed=true
      reason="Content hash changed"
    fi
    # ハッシュをメタデータに保存
    content_length="$current_hash"  # content_lengthフィールドを流用（後でcontent_hashに保存）
  fi

  # メタデータ更新
  hash_val=""
  if [ -z "$etag" ] && [ -z "$last_modified" ]; then
    hash_val="${content_length:-}"
  fi
  tmp=$(mktemp)
  jq --arg key "$url_key" \
     --arg lm "$last_modified" \
     --arg et "$etag" \
     --arg cl "$content_length" \
     --arg ch "$hash_val" \
     --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
     '.[$key] = {"last_modified": $lm, "etag": $et, "content_length": $cl, "content_hash": $ch, "checked_at": $ts}' \
     "$METADATA_FILE" > "$tmp" && mv "$tmp" "$METADATA_FILE"

  if [ "$changed" = true ]; then
    CHANGED_URLS+=("$url")
    log "  [$checked/${#URLS[@]}] CHANGED ($reason): $url"
  else
    log "  [$checked/${#URLS[@]}] unchanged: $url"
  fi
done

log ""
log "Phase 1 summary: ${#CHANGED_URLS[@]} changed / ${#URLS[@]} checked. ($(elapsed))"

# 変更なし → Phase 2スキップ
if [ ${#CHANGED_URLS[@]} -eq 0 ]; then
  log "No URL changes detected. Skipping Claude CLI entirely."
  log_phase "Patrol Complete ($(elapsed))"
  exit 0
fi

# ──────────────────────────────────────
# Phase 2: Claude CLIで詳細比較
# ──────────────────────────────────────
log_phase "Phase 2: Claude CLI Patrol (${#CHANGED_URLS[@]} URLs)"
PHASE2_START=$(date +%s)

CHANGED_LIST=$(printf -- "- %s\n" "${CHANGED_URLS[@]}")
PROMPT=$(cat /patrol/patrol-prompt.md)
PROMPT="${PROMPT}

## 今回変更が検出されたURL（これらのみ巡回してください）

${CHANGED_LIST}

上記以外のURLは変更なしのためスキップしてください。"

log "Starting Claude CLI (サブスク内利用。追加課金なし) ..."
log "Prompt length: $(echo "$PROMPT" | wc -c | tr -d ' ') chars | URLs: ${#CHANGED_URLS[@]}"
log "Waiting for Claude CLI response (this may take several minutes)..."

RESULT=$(claude -p "$PROMPT" \
  --allowedTools "Bash,Read,Edit,Write,Glob,Grep,WebFetch,WebSearch" \
  --max-budget-usd "$MAX_BUDGET" \
  --output-format json 2>&1) || true

FINAL_RESULT=$(echo "$RESULT" | jq -r '.result // "No result"' 2>/dev/null || echo "$RESULT")
COST=$(echo "$RESULT" | jq -r '.total_cost_usd // .cost_usd // "unknown"' 2>/dev/null || echo "unknown")
DURATION_MS=$(echo "$RESULT" | jq -r '.duration_ms // "unknown"' 2>/dev/null || echo "unknown")
SESSION_ID=$(echo "$RESULT" | jq -r '.session_id // "unknown"' 2>/dev/null || echo "unknown")

log "Claude CLI finished. Cost: \$$COST (サブスク内) | Duration: ${DURATION_MS}ms | Session: $SESSION_ID"
log "Phase 2 time: $(( $(date +%s) - PHASE2_START ))s"

if [ -n "$FINAL_RESULT" ]; then
  log ""
  log "--- Claude Result Summary ---"
  echo "$FINAL_RESULT" | head -50
  log "--- End Summary ---"
fi

# ──────────────────────────────────────
# Phase 3: 変更チェック & PR
# ──────────────────────────────────────
log_phase "Phase 3: Git Status & PR"

CHANGES=$(git status --porcelain)
if [ -z "$CHANGES" ]; then
  log "No file changes. Claude CLI found specs are up-to-date."
  log_phase "Patrol Complete ($(elapsed))"
  exit 0
fi

log "Changed files:"
echo "$CHANGES" | while read -r line; do log "  $line"; done

BRANCH_NAME="patrol/auto-$(date +%Y%m%d)"
git checkout -b "$BRANCH_NAME" 2>/dev/null || git checkout "$BRANCH_NAME"
git add -A
git commit -m "patrol: 公式ドキュメント巡回による自動更新 ($(date +%Y-%m-%d))

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>"
log "Committed on $BRANCH_NAME"

git push origin "$BRANCH_NAME"
log "Pushed to origin/$BRANCH_NAME"

PR_URL=$(gh pr create \
  --title "patrol: 公式ドキュメント自動更新 $(date +%Y-%m-%d)" \
  --body "## Summary

自動巡回により検出された公式ドキュメントの変更を反映。

## 変更検出URL
${CHANGED_LIST}

## 巡回統計
- チェック対象: ${#URLS[@]} URLs
- 変更検出: ${#CHANGED_URLS[@]} URLs (Phase 1)
- 未変更スキップ: $((${#URLS[@]} - ${#CHANGED_URLS[@]})) URLs
- Claude CLI利用: サブスク内（追加課金なし）

🤖 Generated by harness-harness patrol system" \
  --base "$BRANCH" 2>&1)

log "PR created: $PR_URL"

# ──────────────────────────────────────
# Phase 4: マージ判断
# ──────────────────────────────────────
log_phase "Phase 4: Merge Decision"

if [ "$SKIP_FORCE_MERGE" = "false" ]; then
  log "Auto-merging PR..."
  sleep 5
  if gh pr merge "$PR_URL" --merge --admin 2>&1; then
    log "PR merged successfully."
  elif gh pr merge "$PR_URL" --merge 2>&1; then
    log "PR merged successfully (without admin)."
  else
    log "WARN: Auto-merge failed. PR remains open for manual review."
  fi
else
  log "SkipForceMerge=true: PR作成のみ。手動マージ待ち。"
fi

log_phase "Patrol Complete ($(elapsed))"
