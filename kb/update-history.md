# harness-harness 更新履歴

## 2026-03-26 — 公式ドキュメント巡回（自律巡回）

### 巡回対象URL
- Claude Code: llms.txt（67ページ一覧取得）、settings, hooks, skills, mcp, agent-teams, best-practices, changelog
- Codex CLI: changelog

### 検出された変更と更新内容

#### Claude Code (v2.1.83〜v2.1.84)

1. **specs/claude/hooks.md** — 新hookイベント3件、フィールド追加
   - `CwdChanged` イベント（v2.1.83）: ワーキングディレクトリ変更時に発火
   - `FileChanged` イベント（v2.1.83）: 監視ファイルのディスク変更時に発火（matcher: ファイル名）
   - `TaskCreated` イベント（v2.1.84）: TaskCreate でタスク作成時に発火
   - Command ハンドラに `shell` フィールド追加（`"bash"` / `"powershell"`）
   - WorktreeCreate の HTTP フック対応（`hookSpecificOutput.worktreePath`）
   - SessionEnd matcher に `bypass_permissions_disabled` 追加
   - StopFailure matcher に `invalid_request` 追加
   - InstructionsLoaded 入力に `parent_file_path` 追加
   - 共通入力に `worktree` フィールド追加

2. **specs/claude/configuration.md** — 新設定キー・環境変数
   - `managed-settings.d/` ドロップインディレクトリ（v2.1.83）
   - `sandbox.failIfUnavailable`, `disableDeepLinkRegistration` 設定（v2.1.83）
   - `allowedChannelPlugins` managed設定（v2.1.84）
   - 環境変数4件: `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB`, `CLAUDE_CODE_DISABLE_NONSTREAMING_FALLBACK`, `CLAUDE_STREAM_IDLE_TIMEOUT_MS`, `ANTHROPIC_DEFAULT_{OPUS,SONNET,HAIKU}_MODEL_SUPPORTS`

3. **specs/claude/skills-and-commands.md** — フロントマター・コマンド追加
   - スキル `shell` フロントマター（`powershell` 対応）
   - エージェント `initialPrompt` フロントマター（v2.1.83）
   - `/color`, `/copy [N]` コマンド追加

4. **specs/claude/mcp.md** — 上限・重複排除
   - MCPツール説明・サーバー指示の2KB上限（v2.1.84）
   - ローカル/claude.aiコネクタ間のMCPサーバー重複排除（v2.1.84）

5. **specs/claude/changelog.md** — 不足バージョン追記
   - v2.1.84, v2.1.83 の詳細追記
   - v2.1.79, v2.1.74, v2.1.73 を新規追加

#### Codex CLI

6. **specs/codex/changelog.md** — 不足エントリ追記
   - アプリ 26.318, 26.317拡充, 26.316, 26.311 を追加

### 変更なし（差分なし確認済み）
- specs/claude/agent-teams.md — 公式ドキュメントとの大きな差分なし
- specs/claude/best-practices.md — 公式ドキュメントとの大きな差分なし
- specs/codex/configuration.md — 新規公式変更なし

---

## 2026-03-23 — 公式ドキュメント巡回（自律巡回）

### 巡回対象URL
- Claude Code: settings, skills, hooks, mcp, agent-teams, best-practices, sub-agents, headless（全8ページ）
- Codex CLI: config-reference, slash-commands, skills, changelog（全4ページ）

### 検出された変更と更新内容

#### Claude Code

1. **specs/claude/configuration.md** — 新設定キー15件追加
   - `respectGitignore`, `includeGitInstructions`, `channelsEnabled`, `allowManagedPermissionRulesOnly`
   - `strictKnownMarketplaces`, `blockedMarketplaces`, `pluginTrustMessage`
   - `awsAuthRefresh`, `awsCredentialExport`, `voiceEnabled`
   - `spinnerTipsEnabled`, `spinnerTipsOverride`, `prefersReducedMotion`
   - `fastModePerSessionOptIn`, `teammateMode`, `feedbackSurveyRate`, `showClearContextOnPlanAccept`
   - `includeCoAuthoredBy` の非推奨化を記録

2. **specs/claude/mcp.md** — 新機能5件追加
   - MCP Tool Search（`ENABLE_TOOL_SEARCH`）
   - MCP Resources（`@` メンション参照）
   - MCP Elicitation（Form/URL モード）
   - `claude mcp serve`（Claude Code を MCP サーバーとして使用）
   - OAuth 詳細（固定コールバックポート、事前設定認証情報、メタデータディスカバリ）
   - Managed MCP の Policy-based Control（`serverName`/`serverCommand`/`serverUrl` マッチング）

3. **specs/claude/skills-and-commands.md** — 3件更新
   - ビルトインサブエージェント追加: `statusline-setup`, `Claude Code Guide`
   - ヘッドレスモード（非対話モード）セクション新規追加: `--bare`, `--output-format`, `--json-schema`, `--allowedTools`, `--continue`/`--resume`

#### Codex CLI

4. **specs/codex/configuration.md** — 大規模更新
   - 新設定キー9件追加: `model_context_window`, `forced_login_method`, `forced_chatgpt_workspace_id`, `cli_auth_credentials_store`, `default_permissions`, `file_opener`, `check_for_update_on_startup`, `allow_login_shell`
   - 新機能フラグ2件: `unified_exec`（stable）, `undo`
   - Agent管理セクション新規追加: `agents.max_threads`, `agents.max_depth`, `agents.<name>.description`
   - UI設定セクション新規追加: `tui.theme`, `tui.animations`, `tui.notifications`, `tui.status_line`
   - 承認粒度セクション新規追加: `approval_policy.granular.*`
   - **Skills パス変更**: `.codex/skills/` → `.agents/skills/`（CWD/親/ルート/ユーザー/管理者/システムの6レベル）
   - `agents/openai.yaml` メタデータ追加: UI設定、`allow_implicit_invocation`ポリシー、ツール依存定義
   - スキルインストーラー（`$skill-installer`）の追加
   - スキル有効化/無効化設定の追加

5. **specs/codex/commands.md** — `/send-feedback` コマンド追加

6. **Codex Changelog 主要項目**:
   - CLI 0.116.0（2026-03-19）: `userpromptsubmit` フック、Realtime セッション改善
   - GPT-5.4 mini（2026-03-17）: 新モデル追加
   - CLI 0.115.0（2026-03-16）: `view_image`, Smart Approvals, Python SDK
   - CLI 0.114.0（2026-03-11）: 実験的Hooks（SessionStart, Stop）、Code Mode

#### Mapping 更新

7. **mapping/claude-to-codex.md** — Skills パスを `.codex/skills/` → `.agents/skills/` に更新
8. **mapping/codex-to-claude.md** — 同上 + 移行ガイド更新
9. **mapping/shared-concepts.md** — Skills パス更新 + `agents/openai.yaml` メタデータ拡張を追記

### 変更なし（差分なし確認済み）
- specs/claude/hooks.md — 既存仕様書が最新の公式ドキュメントと一致
- specs/claude/agent-teams.md — 既存仕様書が最新の公式ドキュメントと一致
- specs/claude/best-practices.md — 軽微な追加（Chrome拡張、プラグイン言及）のみ。仕様影響なし

### 要確認事項
- Codex Skills の `.codex/skills/` → `.agents/skills/` パス変更が正式な移行なのか、並行サポートなのかは公式アナウンスで確認が必要
- Codex CLI 0.116.0 の `userpromptsubmit` フックが Hooks 仕様の正式イベント追加なのか要確認

## 2026-03-23 — 外部プロジェクト初期調査

### 追加ファイル
- `kb/external/_index.md` — 外部プロジェクト調査レジストリ
- `kb/external/openclaw/analysis.md` — OpenClaw深掘り分析
- `kb/external/openclaw/takeaways.md` — OpenClawからの知見と採用判断
- `kb/external/gstack/analysis.md` — gstack深掘り分析
- `kb/external/gstack/takeaways.md` — gstackからの知見と採用判断
- `kb/external/superpowers/analysis.md` — superpowers深掘り分析
- `kb/external/superpowers/takeaways.md` — superpowersからの知見と採用判断

### 削除ファイル
- `kb/external/openclaw/.gitkeep`
- `kb/external/gstack/.gitkeep`
- `kb/external/superpowers/.gitkeep`

### 調査概要

3つの主要な外部プロジェクトを調査:

1. **OpenClaw** (Peter Steinberger) — ローカルファーストの自律AIエージェント。20+チャネル統合、53+バンドルスキル、180,000+ GitHub Stars。パーソナルAIアシスタントとしての方向性はharness-harnessと異なるが、SKILL.mdフォーマット標準・3層スキル優先順位・ゲーティング機構を採用。

2. **gstack** (Garry Tan) — ロールベースの仮想開発チームワークフロー。28スキル、構造化スプリントプロセス。安全ガードレール（/careful, /freeze, /guard）・2層テスティング・グローバル/ローカルインストールモデルを採用。

3. **superpowers** (Jesse Vincent) — マルチプラットフォームスキルフレームワーク。Claude Code/Codex/Cursor/OpenCode対応。SKILL.mdフロントマター標準の策定者。マルチプラットフォームディレクトリ構造・Hookベース初期化・CSO概念を採用。

### 横断的な主要判断

| 判断 | 項目 |
|------|------|
| 採用（高優先度） | SKILL.mdフロントマター標準、マルチプラットフォームディレクトリ構造、安全ガードレール、構造化プロセステンプレート、Hookベース初期化、グローバル/ローカルインストール |
| 採用（中優先度） | 3層スキル優先順位、ゲーティング機構、CSO、2層テスティング、クロスモデル対応 |
| 検討 | シンボリックリンク戦略、ロールベース設計、ワークフロー選択肢、Git Worktree、自己修正型エージェント |
| 不採用 | マルチチャネル統合（範囲外）、常駐デーモンモデル（過剰） |

## 2026-03-23 — project-alpha初回dogfoodingフィードバック

### 追加ファイル
- `logs/evaluations/2026-03-23-project-alpha-diagnosis.md` — project-alphaハーネス診断レポート
- `logs/evaluations/2026-03-23-project-alpha-improvement-proposal.md` — 改善提案書
- `logs/evaluations/2026-03-23-project-alpha-feedback.md` — 改善実施後のフィードバック
- `docs/decisions/ADR-001-harness-improvement-process.md` — 作業プロセス標準化

### 主な学び
- セキュリティhookに `|| true` は禁物（テンプレートに反映要）
- hookのJSONパースはjq必須（テンプレートの前提条件に追加要）
- 診断は推測ではなくファイル内容を実際にパースして判定すべき
- gitignored設定の改善はPR対応不可（手動推奨として別セクション化要）
- claude-pr-reviewの指摘品質が高い（ワークフローテンプレート化候補）

## 2026-03-24 — Codex CLI Skills/Hooks サポート発見・仕様反映

### 発見内容

Codex CLI が以下の機能をサポートしていることを確認:

1. **Skills（stable）**: SKILL.md フロントマター形式で Claude Code と完全互換。`.codex/skills/`（プロジェクト）、`~/.codex/skills/`（グローバル）に配置。バンドルスキル 3 種（`skill-creator`, `skill-installer`, `openai-docs`）。`/skills` コマンド、`$` メンション、暗黙マッチングで起動。`skill_mcp_dependency_install` フラグは stable。

2. **Hooks（実験的）**: `codex_hooks` フラグで有効化（デフォルト無効）。対応イベントは `SessionStart`, `Stop`, `UserPromptSubmit` の 3 種のみ（Claude Code は 17+）。ハンドラは `command` のみ（Claude は command/HTTP/Prompt/Agent の 4 種）。`config.toml` の `[[hooks]]` テーブル配列で設定。終了コード 2 でブロック可能（`UserPromptSubmit`）。

### 更新ファイル

- `specs/codex/configuration.md` — Skills（セクション 6）と Hooks（セクション 7）を追加
- `mapping/claude-to-codex.md` — Skills セクションを「対応なし」→「直接対応」に更新。Hooks セクションを「対応なし」→「部分対応（実験的）」に更新
- `mapping/codex-to-claude.md` — Skills（セクション 5）と Hooks（セクション 6）を新規セクションとして追加。以降のセクション番号を繰り下げ
- `mapping/shared-concepts.md` — Skills（セクション 9）を共通概念として追加。Hooks（セクション 10）を「なし」→「実験的サポート」に更新。機能対応サマリー表を更新
- `docs/codex-plan.md` — 「Hooks 不在はラッパースクリプトで埋める」→「Hooks はネイティブ + ラッパースクリプトの併用で埋める」に更新。Claude 先行領域の記述を修正
- `kb/changelog.md` — 本エントリを追加

### 影響と方針変更

- **Skills は完全な共通概念に昇格**: `.claude/skills/` と `.codex/skills/` で SKILL.md を共有可能。harness-harness のスキルテンプレート戦略を共通化できる
- **Hooks は部分的共通概念**: 3 イベント（SessionStart, Stop, UserPromptSubmit）は両プラットフォームで利用可能。残りは引き続き Claude 固有
- **codex-plan.md の方針修正**: Hooks 代替のラッパースクリプトは引き続き必要だが、共通 3 イベントについてはネイティブ Hooks を優先利用する方針に変更
