# Claude Code Hooks 仕様書

最終更新: 2026-03-23

公式ドキュメント: https://code.claude.com/docs/en/hooks

---

## 1. 概要

Hooks はユーザー定義のシェルコマンド・HTTPエンドポイント・LLMプロンプト・エージェントを、Claude Code のライフサイクルの特定ポイントで自動実行する仕組み。バリデーション、自動化、カスタムワークフロー制御に使用する。

CLAUDE.md の指示は助言的だが、Hooks は**決定論的**であり確実に実行される。

---

## 2. イベント一覧

### 2.1 メインイベント

| イベント | 発火タイミング | ブロック可能 | matcher対象 |
|:--|:--|:--|:--|
| `SessionStart` | セッション開始/再開 | No | `startup`, `resume`, `clear`, `compact` |
| `UserPromptSubmit` | ユーザープロンプト送信後、処理前 | Yes | - |
| `PreToolUse` | ツール実行前 | Yes | ツール名 (`Bash`, `Edit`, `Write` 等) |
| `PermissionRequest` | 権限ダイアログ表示時 | Yes | ツール名 |
| `PostToolUse` | ツール成功後 | No | ツール名 |
| `PostToolUseFailure` | ツール失敗後 | No | ツール名 |
| `Stop` | Claude の応答完了時 | Yes | - |
| `StopFailure` | APIエラー発生時 | No | `rate_limit`, `authentication_failed`, `billing_error`, `server_error`, `max_output_tokens`, `unknown` |
| `SessionEnd` | セッション終了時 | No | `clear`, `resume`, `logout`, `prompt_input_exit`, `other` |

### 2.2 サブエージェントイベント

| イベント | 発火タイミング | ブロック可能 | matcher対象 |
|:--|:--|:--|:--|
| `SubagentStart` | サブエージェント起動時 | No | エージェントタイプ名 |
| `SubagentStop` | サブエージェント完了時 | Yes | エージェントタイプ名 |
| `TeammateIdle` | チームメイトがアイドル状態になる直前 | Yes | matcherなし |
| `TaskCompleted` | タスク完了マーク時 | Yes | matcherなし |

### 2.3 通知・設定イベント

| イベント | 発火タイミング | ブロック可能 | matcher対象 |
|:--|:--|:--|:--|
| `Notification` | 通知送信時 | No | `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog` |
| `ConfigChange` | 設定ファイル変更時 | Yes | `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` |
| `InstructionsLoaded` | CLAUDE.md/rules読み込み時 | No | `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact` |

### 2.4 ワークツリー・コンパクションイベント

| イベント | 発火タイミング | ブロック可能 | matcher対象 |
|:--|:--|:--|:--|
| `WorktreeCreate` | ワークツリー作成時 | Yes | - |
| `WorktreeRemove` | ワークツリー削除時 | No | - |
| `PreCompact` | コンパクション前 | No | `manual`, `auto` |
| `PostCompact` | コンパクション後 | No | `manual`, `auto` |

### 2.5 MCP Elicitation イベント

| イベント | 発火タイミング | ブロック可能 | matcher対象 |
|:--|:--|:--|:--|
| `Elicitation` | MCPサーバーがユーザー入力を要求 | Yes | MCPサーバー名 |
| `ElicitationResult` | ユーザーがMCP入力に回答 | Yes | MCPサーバー名 |

---

## 3. ハンドラタイプ

### 3.1 Command ハンドラ

シェルコマンドを実行。JSON を stdin で受け取り、終了コードと stdout で結果を返す。

```json
{
  "type": "command",
  "command": ".claude/hooks/script.sh",
  "async": false,
  "timeout": 600
}
```

**終了コード**:
- `0`: 成功（stdout の JSON をパース）
- `2`: ブロッキングエラー（stderr がエラーメッセージ）
- その他: 非ブロッキングエラー

### 3.2 HTTP ハンドラ

JSON POST リクエストをURLエンドポイントに送信。

```json
{
  "type": "http",
  "url": "http://localhost:8080/hooks/validate",
  "timeout": 30,
  "headers": {
    "Authorization": "Bearer $MY_TOKEN"
  },
  "allowedEnvVars": ["MY_TOKEN"]
}
```

**レスポンス処理**:
- `2xx` 空ボディ: 成功
- `2xx` テキストボディ: 成功 + コンテキスト
- `2xx` JSONボディ: 判定としてパース
- 非2xx: 非ブロッキングエラー

### 3.3 Prompt ハンドラ

Claude モデルにプロンプトを送信して評価。

```json
{
  "type": "prompt",
  "prompt": "これを承認すべきか？ $ARGUMENTS",
  "model": "model-name",
  "timeout": 30
}
```

### 3.4 Agent ハンドラ

サブエージェントを起動して条件を検証。

```json
{
  "type": "agent",
  "prompt": "この設定を検証してください。$ARGUMENTS",
  "timeout": 60
}
```

---

## 4. 設定方法

### 4.1 設定場所

| 場所 | スコープ | 共有可能 |
|:--|:--|:--|
| `~/.claude/settings.json` | 全プロジェクト | No |
| `.claude/settings.json` | プロジェクト | Yes |
| `.claude/settings.local.json` | プロジェクト（個人） | No |
| プラグイン `hooks/hooks.json` | プラグイン有効時 | Yes |
| スキル/エージェントフロントマター | コンポーネントのライフタイム | Yes |
| Managed policy settings | 組織全体 | Yes |

### 4.2 設定構造

```json
{
  "hooks": {
    "EventName": [
      {
        "matcher": "regex_pattern",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/script.sh",
            "timeout": 600,
            "statusMessage": "処理中..."
          }
        ]
      }
    ]
  }
}
```

### 4.3 フック無効化

```json
{
  "disableAllHooks": true
}
```

Managed フックはユーザー/プロジェクト/ローカル設定からは無効化できない。

---

## 5. Matcher

Matcher はフック発火条件をフィルタリングする正規表現文字列。省略または `"*"` で全対象。

### 5.1 MCPツールマッチング

MCPツールは `mcp__<server>__<tool>` パターンに従う:

```json
{
  "matcher": "mcp__memory__.*"
}
```

### 5.2 複数ツールのマッチング

```json
{
  "matcher": "Edit|Write"
}
```

---

## 6. 入出力フォーマット

### 6.1 共通入力フィールド

全フックが受け取る共通 JSON:

```json
{
  "session_id": "abc123",
  "transcript_path": "/path/to/transcript.jsonl",
  "cwd": "/current/working/directory",
  "permission_mode": "default",
  "hook_event_name": "EventName"
}
```

サブエージェント内では追加:

```json
{
  "agent_id": "unique-id",
  "agent_type": "AgentName"
}
```

### 6.2 イベント固有の入力フィールド

| イベント | 追加入力フィールド |
|:--|:--|
| `SessionStart` | `source`, `model`, `agent_type`(opt) |
| `UserPromptSubmit` | `prompt` |
| `PreToolUse` | `tool_name`, `tool_input`, `tool_use_id` |
| `PermissionRequest` | `tool_name`, `tool_input`, `permission_suggestions`(opt) |
| `PostToolUse` | `tool_name`, `tool_input`, `tool_response`, `tool_use_id` |
| `PostToolUseFailure` | `tool_name`, `tool_input`, `tool_use_id`, `error`, `is_interrupt` |
| `Stop` | `stop_hook_active`, `last_assistant_message` |
| `StopFailure` | `error`, `error_details`, `last_assistant_message` |
| `Notification` | `message`, `title`, `notification_type` |
| `SubagentStart` | `agent_id`, `agent_type` |
| `SubagentStop` | `stop_hook_active`, `agent_id`, `agent_type`, `agent_transcript_path`, `last_assistant_message` |
| `InstructionsLoaded` | `file_path`, `memory_type`, `load_reason`, `globs`(opt), `trigger_file_path`(opt) |
| `ConfigChange` | `source`, `file_path` |
| `WorktreeCreate` | `name` |
| `WorktreeRemove` | `worktree_path` |
| `PreCompact` | `trigger`, `custom_instructions` |
| `PostCompact` | `trigger`, `compact_summary` |
| `Elicitation` | `mcp_server_name`, `message`, `mode`(opt), `url`(opt), `elicitation_id`, `requested_schema` |
| `TeammateIdle` | `teammate_name`, `team_name` |
| `TaskCompleted` | `task_id`, `task_subject`, `task_description`(opt), `teammate_name`, `team_name` |

### 6.3 JSON 出力フォーマット

終了コード 0 でパースされる JSON 構造:

```json
{
  "continue": true,
  "stopReason": "message",
  "suppressOutput": false,
  "systemMessage": "warning",
  "decision": "block|allow|deny",
  "reason": "explanation",
  "hookSpecificOutput": {
    "hookEventName": "EventName",
    "additionalContext": "string",
    "permissionDecision": "allow|deny|ask",
    "permissionDecisionReason": "string",
    "updatedInput": {},
    "updatedPermissions": [],
    "action": "accept|decline|cancel",
    "content": {}
  }
}
```

### 6.4 主要イベントの出力詳細

#### PreToolUse

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow|deny|ask",
    "permissionDecisionReason": "理由",
    "updatedInput": { "command": "npm run safe-lint" },
    "additionalContext": "追加コンテキスト"
  }
}
```

#### Stop

`stop_hook_active` を確認して無限ループを防止:

```json
{
  "decision": "block",
  "reason": "テストが未通過です"
}
```

#### SessionStart

環境変数の永続化に `CLAUDE_ENV_FILE` を使用:

```bash
#!/bin/bash
if [ -n "$CLAUDE_ENV_FILE" ]; then
  echo 'export NODE_ENV=production' >> "$CLAUDE_ENV_FILE"
fi
exit 0
```

#### WorktreeCreate

標準JSON出力ではなく、stdout にワークツリーの絶対パスを出力:

```bash
#!/bin/bash
NAME=$(jq -r .name)
DIR="$HOME/.claude/worktrees/$NAME"
mkdir -p "$DIR"
echo "$DIR"
```

---

## 7. スクリプトパス参照

`command` フィールドで使用可能な変数:

| 変数 | 説明 |
|:--|:--|
| `$CLAUDE_PROJECT_DIR` | プロジェクトルート |
| `${CLAUDE_PLUGIN_ROOT}` | プラグインインストールディレクトリ |
| `${CLAUDE_PLUGIN_DATA}` | プラグイン永続データディレクトリ |
| `$CLAUDE_CODE_REMOTE` | Web環境で `"true"` |

---

## 8. 共通フィールド

| フィールド | 説明 | デフォルト |
|:--|:--|:--|
| `timeout` | タイムアウト（秒） | command: 600, http: 30, prompt: 30, agent: 60 |
| `async` | バックグラウンド実行（command のみ） | `false` |
| `once` | スキル内でセッション中1回のみ実行 | `false` |
| `statusMessage` | スピナーメッセージ | - |

---

## 9. フックの重複排除

- Command フック: command 文字列で重複排除
- HTTP フック: URL で重複排除
- 複数設定箇所にまたがる同一ハンドラは1回のみ実行

---

## 10. 実用例

### 10.1 破壊的コマンドのブロック

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/block-rm.sh"
          }
        ]
      }
    ]
  }
}
```

### 10.2 ファイル編集後のリンティング

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "npx eslint --fix"
          }
        ]
      }
    ]
  }
}
```

### 10.3 セッション開始時のコンテキスト追加

```bash
#!/bin/bash
jq -n '{
  hookSpecificOutput: {
    hookEventName: "SessionStart",
    additionalContext: "本番モードで動作中"
  }
}'
```

---

## 参考リンク

- Hooks: https://code.claude.com/docs/en/hooks
- Hooks ガイド: https://code.claude.com/docs/en/hooks-guide
- 権限: https://code.claude.com/docs/en/permissions
