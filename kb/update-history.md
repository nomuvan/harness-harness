# harness-harness 更新履歴

## 2026-03-28 — スキルエコシステム巡回（初回動作確認）

### 巡回結果
- skills.shトレンド上位10件を確認（find-skills 750K, frontend-design 211K等）
- anthropics/skills: 104,564 stars（安定）
- openai/skills: 15,530 stars（安定）
- agentskills.io: 32プラットフォーム確認（Claude Code, Codex, Gemini CLI, Cursor, VS Code, GitHub Copilot, Kiro, Roo Code, JetBrains Junie, Databricks, Snowflake等）

### 更新ファイル
- kb/skills/_index.md: プラットフォーム数を修正（33→32）

### 知見
- skills.shトレンドはVercel系（find-skills, react-best-practices）とMicrosoft Azure系が上位を占める
- anthropics/skillsの公式スキルは安定。新規追加なし
- Tier A推薦スキル（obra/superpowers系）は引き続き有効

---

## 2026-03-28 — 公式ドキュメント巡回

### 巡回対象URL
- Claude Code: llms.txt（75ページ一覧取得、前回67→8ページ増）、settings, hooks, skills, mcp, plugins, channels, changelog
- Codex CLI: changelog

### 検出された変更と更新内容

#### Claude Code (v2.1.85)

1. **specs/claude/changelog.md** — v2.1.85 追加
   - Hooks `if` 条件フィールド（permission rule構文）
   - MCP OAuth RFC 9728 対応
   - `CLAUDE_CODE_MCP_SERVER_NAME`, `CLAUDE_CODE_MCP_SERVER_URL` 環境変数
   - deep link 5,000文字対応
   - スケジュールタスクのタイムスタンプマーカー

2. **specs/claude/hooks.md** — 2件更新
   - `if` 条件フィールドの仕様追加（v2.1.85）: ツールイベント専用、permission rule構文
   - `TaskCreated` がブロック可能（Yes）に修正

3. **specs/claude/configuration.md** — 環境変数2件追加
   - `CLAUDE_CODE_MCP_SERVER_NAME`, `CLAUDE_CODE_MCP_SERVER_URL`

4. **specs/claude/skills-and-commands.md** — フロントマター1件追加
   - `paths` フィールド: glob パターンでスキル自動適用を限定

5. **specs/claude/mcp.md** — OAuth 1件追加
   - RFC 9728 Protected Resource Metadata ディスカバリ対応

#### Codex CLI

6. **specs/codex/changelog.md** — 2エントリ追加
   - CLI 0.117.0（2026-03-26）: プラグインのファーストクラスワークフロー化、サブエージェントパスベースアドレス等
   - Plugin Support Released（2026-03-25）: プラグインバンドル導入

### llms.txt ページ数変化（67→75）
新規ドキュメントページ検出: channels, channels-reference, checkpointing, chrome, claude-code-on-the-web, discover-plugins, fast-mode, features-overview, keybindings, microsoft-foundry, output-styles, plugin-marketplaces, plugins, plugins-reference, remote-control, scheduled-tasks, server-managed-settings, statusline, voice-dictation, web-scheduled-tasks 等（一部は既存ページのリネーム/リオーガナイズの可能性あり）

### 変更なし（差分なし確認済み）
- specs/claude/agent-teams.md — 公式ドキュメントとの大きな差分なし
- specs/claude/best-practices.md — 公式ドキュメントとの大きな差分なし

---

## 2026-03-27 — AiToEarn 再調査（業務ドメイン深掘り込み）

### 書き直しファイル
- `kb/external/aitoearn/analysis.md` — AiToEarn徹底調査レポート（再調査版）。frontmatter追加、libs/16モジュール詳細分析、CLAUDE.md未成熟事例評価、Docker Compose構成分析、業界トレンド対比
- `kb/external/aitoearn/takeaways.md` — 採用判断（再調査版）。frontmatter追加、法規制リスク（日本/EU/米国）追加、前回調査との差分表追加

### 新規ファイル
- `kb/domains/content-monetization/overview.md` — コンテンツ収益化業務ドメイン深掘り（新規ドメイン）。市場動向（$43.5億→$128.5億）、CPS/CPE/CPM収益モデル、8ステップパイプライン、プラットフォーム別戦略（YouTube/TikTok/Instagram/X/LinkedIn/Threads/ブログ/Substack）、法規制（日本ステマ規制/EU AI Act/米国各州法）、AIエージェント活用指針、ハーネス設計への示唆

### 更新ファイル
- `kb/external/_index.md` — AiToEarnの最終確認日を2026-03-27に更新、説明を拡充
- `kb/domains/_index.md` — content-monetizationドメインを追加

### 主な知見（前回からの追加分）
- AiToEarnのCLAUDE.mdはNx公式テンプレートのまま（未成熟事例）→ 二層構造（公式テンプレート+カスタマイズ層）の推奨に変更
- libs/nest-mcpモジュールが「既存Web APIのMCP化」の具体実装として最も有用なパターン
- コンテンツ収益化市場は2025年$43.5億→2029年$128.5億（CAGR 31.4%）の急成長
- 2026年のトレンド: ハイブリッド（AI+人間）がAI onlyより信頼度+33%、エンゲージメント+23%上回る
- 法規制が急速に整備中: EU AI Act Article 50（2026年8月）、カリフォルニアAI透明性法（2026年1月）、日本ステマ規制（2023年10月施行済み）
- Hub-and-Spokeモデル（1本のハブコンテンツ→10+バリエーション）でリーチ+35%
- 総合評価をC+からB-に上方修正（業務ドメイン知見の価値を考慮）

---

## 2026-03-26 — claude-peers-mcp 調査

### 追加ファイル
- `kb/external/claude-peers/analysis.md` — claude-peers-mcp徹底調査レポート（基本情報、アーキテクチャ、MCPツール4種、セキュリティ評価、公式Agent Teams比較、類似ツール5件比較）
- `kb/external/claude-peers/takeaways.md` — 採用判断（Brokerデーモンパターン、スコープ付きピア発見、自動コンテキストサマリーの3パターン抽出）

### 更新ファイル
- `kb/external/_index.md` — claude-peers-mcpをレジストリに追加（ステータス: reference）
- `kb/update-history.md` — 本エントリを追加

### 主な知見
- Louis Arge作のClaude Code P2Pメッセージング MCPサーバー。GitHub 1,249スター、TypeScript/Bun、ライセンス未明示
- Broker (localhost:7899) + SQLite + MCPチャネルプロトコルによるリアルタイム配信アーキテクチャ
- 公式Agent Teams（実験的）と補完関係にあるが、機能重複が大きい。ライセンス未明示・成熟度不足（Issue 16件中0件クローズ、メッセージロスト問題複数）により統合は不採用
- 設計パターン3件を抽出: (1) Brokerデーモン自動起動パターン、(2) スコープ付きピア発見（machine/directory/repo）、(3) 自動コンテキストサマリー
- マルチエージェント協調の3層分類を整理: ビルトイン層（Agent Teams）/ MCP拡張層（claude-peers等）/ 外部管理層（claude-squad等）。harness-harnessはビルトイン層基本+パターン抽出方針

---

## 2026-03-26 — AiToEarn 調査

### 追加ファイル
- `kb/external/aitoearn/analysis.md` — AiToEarn徹底調査レポート（基本情報、技術アーキテクチャ、MCP対応、収益化モデル、類似ツール比較、harness-harness適用評価）
- `kb/external/aitoearn/takeaways.md` — 採用判断（MCP HTTP公開パターン、Nxモノレポ向けCLAUDE.md等）

### 更新ファイル
- `kb/external/_index.md` — AiToEarnをレジストリに追加（ステータス: reference）

### 主な知見
- AiToEarnはAI活用SNSコンテンツマーケティングの全自動化プラットフォーム（Monetize/Publish/Engage/Createの4Agent構成）
- GitHub 12,431スター、MIT License、TypeScript 92.6%、NestJS+Nx+Electron構成
- MCP HTTP公開パターン（`"type": "http"`でWeb APIをMCPサーバー化）がharness-harnessテンプレートとして有用
- NxモノレポのCLAUDE.md配置パターンが参考になる
- ツール自体の統合・定期監視は不要（ドメイン特化度が高いため）

---

## 2026-03-26 — DeerFlow 2.0 調査（research-kbスキル実行）

### 追加ファイル
- `kb/external/deerflow/analysis.md` — ByteDance製SuperAgentハーネスの深掘り分析
- `kb/external/deerflow/takeaways.md` — 採用判断（Harness/App分離、Progressive Skill Loading等）

### 主な知見
- Harness/App分離（`Harness must never import App`）がharness-harnessの設計原則と完全合致
- Progressive Skill Loading = 段階的開示の具体実装
- skills/public + skills/custom の二層構造 = templates/ + プロジェクト固有の対応
- メモリの信頼度スコア+タイムスタンプはkb/知見管理に応用可能
- LangGraph依存やServer-first構成は不採用（パターンのみ抽出）

---

## 2026-03-26 — マルチハーネスベストプラクティス調査

### 追加ファイル
- `kb/research/2026-03-26-multi-harness-best-practices.md` — 1プロジェクト複数AIハーネスのベストプラクティス調査

### 調査トピック（5分野）
1. Claude Code の目的別ハーネス設計（CLAUDE.md スコープ、rules paths、agents、skills）
2. Codex CLI のプロファイル活用（config.toml profiles、AGENTS.md 階層マージ）
3. モノレポでの AI 設定パターン（Cursor .mdc、Copilot instructions、Windsurf rules）
4. マルチエージェント協調パターン（サブエージェント、Agent Teams、ペルソナ設計）
5. 非技術ドメインのハーネス設計（マーケティング、分析、自律学習）

### 主な知見
- Claude Code は rules(paths指定) + agents/ + skills(paths指定) の3層で目的別ハーネスを最も細かく制御可能
- Codex CLI は profiles で設定セット切替、AGENTS.md 階層マージでディレクトリ別指示を実現
- AGENTS.md がクロスツール標準化（Codex, Copilot, Cursor, Windsurf, Amp, Devin が読み取り）
- Agent Teams（実験的）で複数エージェントが共有タスクリスト+メールボックスで協調可能
- 非技術ドメインもエージェント定義 + 永続メモリで対応可能（data-scientist 公式例あり）

---

## 2026-03-26 — autoresearch調査（research-kbスキル初回実行）

### 追加ファイル
- `kb/external/autoresearch/analysis.md` — Karpathy autoresearchの深掘り分析
- `kb/external/autoresearch/takeaways.md` — 採用判断（Claude/Codexクロスレビュー統合版）

### 調査方法
- Phase 1: Claude徹底調査（GitHub, Web, ソースコード）
- Phase 2: Codex独自調査（codex exec, 325kトークン使用）
- Phase 3: クロスレビュー統合

### 主な知見
- 「bounded autoresearch pattern」: 固定評価器+単一可変面+予算+台帳の6要素をテンプレート化候補
- ML訓練基盤そのものは不採用（GPU依存）。設計パターンのみ取り込む
- 派生プロジェクト`autoimprove-cc`がCLAUDE.md自動改善を既に実装

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
