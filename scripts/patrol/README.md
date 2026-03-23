# 自律巡回コンテナ（Patrol System）

Claude/Codexの公式ドキュメントを日次で自動巡回し、harness-harnessの仕様書・ナレッジベースを最新に保つ。

## セットアップ

### 前提条件

- Docker または Podman
- `~/.claude.json` にClaude Code認証情報（Max/Proサブスクリプション）
- `~/.config/gh/` にGitHub CLI認証情報
- 追加API課金なし（既存サブスクリプションを使用）

### コンテナ生成

```bash
# ビルド
podman build -t harness-patrol scripts/patrol/

# 起動（cron常駐）
podman run -d --name harness-patrol \
  -e PATROL_BRANCH=main \
  -e PATROL_SKIP_FORCE_MERGE=false \
  -v ~/.claude.json:/root/.claude.json:rw \
  -v ~/.claude:/root/.claude:rw \
  -v ~/.config/gh:/root/.config/gh:ro \
  -v harness-patrol-logs:/patrol-logs \
  -v harness-patrol-cache:/patrol-cache \
  harness-patrol
```

### 即時実行

```bash
podman exec harness-patrol /patrol/patrol-runner.sh
```

### ログ確認

```bash
podman exec harness-patrol ls -la /patrol-logs/
podman exec harness-patrol tail -50 /patrol-logs/cron.log
```

### コンテナ破棄

```bash
podman stop harness-patrol && podman rm harness-patrol
podman rmi harness-patrol  # イメージも削除する場合
```

## 設定

| 環境変数 | デフォルト | 説明 |
|---------|----------|------|
| `PATROL_BRANCH` | `main` | 巡回対象ブランチ |
| `PATROL_SKIP_FORCE_MERGE` | `false` | `true`: PR作成のみ。`false`: 自動マージまで実行 |
| `PATROL_MAX_BUDGET_USD` | `5` | 1回の巡回あたりのClaude利用上限（USD） |

## 効率化（2段階方式）

巡回は2段階で実行される:

1. **Phase 1（軽量ヘッダチェック）**: 各URLにHTTP HEADリクエストを送り、Last-Modified/ETag/Content-Lengthを前回値と比較。変更なしのURLはスキップ。Claude CLIのトークンを消費しない
2. **Phase 2（Claude CLI詳細比較）**: Phase 1で変更検出されたURLのみをClaude CLIに渡す。変更なし日はClaude CLI呼び出し自体をスキップ（コスト0）

キャッシュは`/patrol-cache` ボリュームに保存（`url-metadata.json`）。

## 認証

OAuth tokenの有効期限切れ時はホスト側で `claude` を一度起動して再認証。コンテナはvolumeマウントで認証情報を参照するため、ホスト側の更新が自動反映される。

## カスタマイズ

巡回対象の追加・変更は `patrol-prompt.md` を編集。
