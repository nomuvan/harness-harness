# project-alpha Claudeハーネス改善提案

## 優先度A（高ROI・低リスク）

### A1. settings.local.json のクリーンアップ
重複permissionを除去。整理するだけで可読性向上。

### A2. rules/ に paths フロントマターを追加
Rust固有ルールをRustファイルにのみ適用、frontend固有ルールをフロントエンドにのみ適用。
無関係な作業時のコンテキスト消費を削減。

```yaml
---
paths: "rust/**"
---
```

### A3. PreToolUse hookで危険コマンドを自動ブロック
no-global-changesルールをhookで**強制**する。現在はルール文書のみで、AIの判断に依存。

```json
{
  "PreToolUse": [{
    "matcher": "Bash",
    "hooks": [{
      "type": "command",
      "command": ".claude/hooks/block-global-changes.sh"
    }]
  }]
}
```

### A4. skills/ の新フロントマター活用
既存スキルに以下を追加:
- `autonomous-task`: `context: fork`（メインコンテキスト汚染防止）
- `pr-review-cycle`: `allowed-tools: Bash, Read, Grep, Glob`（不要ツール制限）
- `skill.md` → `SKILL.md` にリネーム（pr-review-cycle）

## 優先度B（新機能キャッチアップ）

### B1. /loop スキルの活用
定期監視タスクに適用可能:
- バックテスト実行中の進捗チェック
- デプロイ後のヘルスチェック
- PR CIの完了待ち

### B2. /batch スキルの活用
大量ファイルの一括変更に:
- 全モジュールのpom.xmlバージョン一括更新
- Quarkusバージョンアップ時の一括対応

### B3. /simplify によるコード品質チェック
変更後に自動でコード品質レビュー。

### B4. SessionStart hookでのコンテキスト注入
セッション開始時に最新のプロジェクト状態を注入:
- 直近のgit log 5件
- 未マージPR一覧
- 今日のprompt履歴の要約

## 優先度C（構造改善）

### C1. CLAUDE.mdのスリム化
現在127行。以下を分離して50-60行に:
- 「最新機能」→ architecture.mdへ
- 重要原則の詳細 → rules/ の各ファイルへ（CLAUDE.mdには要約1行のみ）
- WSL環境詳細 → development.mdへ（既にある程度重複）

### C2. pbi-instructions/ のアーカイブ分離
完了済みPBIを `pbi-instructions/archive/` に移動。
アクティブなPBIのみがトップレベルに残る。

### C3. MCP設定の見直し
- serena関連permissionが残っているが.mcp.jsonに定義なし → 削除
- 追加候補MCP: Sentry（エラー監視）、Slack（通知強化）等

## 優先度D（Codexハーネス作成の布石）

### D1. ドメイン非依存パターンの抽出
以下をharness-harnessのtemplates/に移植可能な形に整理:
- save-prompt hooks（bash/PS両対応）
- no-global-changes ルール
- autonomous-task スキル骨格
- pr-review-cycle スキル
- skill-creator スキル

### D2. AGENTS.md + .codex/config.toml の作成
Claude→Codex変換の試金石。mapping/の4分類を実践適用。
