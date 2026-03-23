# project-alpha Claudeハーネス診断レポート

診断日: 2026-03-23
対象: /Users/nomuvan/IdeaProjects/project-alpha
ハーネスバージョン: 有機的に成長した自作ハーネス（テンプレート非使用）

## 診断サマリー

**総合評価: 非常に成熟したハーネス。改善は「欠落」ではなく「新機能キャッチアップ」が中心**

| カテゴリ | 評価 | コメント |
|---------|------|---------|
| CLAUDE.md | ★★★★☆ | 充実しているが若干長い（127行）。段階的開示の余地あり |
| rules/ | ★★★★★ | no-global-changes等、インシデント駆動の実践的ルール |
| skills/ | ★★★★☆ | autonomous-task, backtest-pdca等は高度。新フロントマター未活用 |
| hooks/ | ★★★☆☆ | 基本的な2種のみ。活用余地が大きい |
| agents/ | ★★★☆☆ | 3エージェント定義あるが、新しいagentフロントマター未活用 |
| commands/ | ★★★☆☆ | 3コマンドのみ。拡張余地あり |
| MCP | ★★★☆☆ | context7, githubの2つのみ |
| settings.json | ★★★☆☆ | hooks設定あるが、permissions重複多数 |

## 詳細診断

### 1. CLAUDE.md

**良い点:**
- プロジェクト概要、コマンド、原則が網羅的
- ドメイン専門知識ベースへのリンクが整理されている
- クリティカルルール（グローバル変更禁止、フォールバック禁止）が直接記載

**改善点:**
- 127行で情報量が多い。CLAUDE.mdは簡潔に保ち、詳細は`.claude/rules/`や別ファイルへ分離が推奨
- 「最新機能」セクション（UI自動化、RssExcelProcessor）はCLAUDE.mdに書くべき内容か要検討。architecture.mdの方が適切
- 重要原則が箇条書きで10個以上並んでおり、優先度が見えにくい

### 2. rules/（7ファイル）

**良い点:**
- `no-global-changes.md` — インシデント駆動で作られた実践的ルール。理由（2026-03-22の事故）が明記
- `coding-standards.md` — Java/Quarkus固有の規約が具体的
- `team-protocol.md` — チーム作業のプロトコルが明文化

**改善点:**
- `paths`フロントマター未使用。例えば`rust-coding-standards.md`は`rust/**`にのみ適用すべき
- `frontend-standards.md`も`**/src/main/resources/META-INF/resources/**`等にスコープ限定可能

### 3. skills/（9スキル）

**良い点:**
- `autonomous-task` — 段階的開示・透過性・自律改善を設計思想として明記。evaluatorサブエージェントで自己改善
- `backtest-strategy-pdca` — PDCAサイクルの自律実行。マシン制約（ai01）も考慮
- `skill-creator` — メタスキル（スキルを作るスキル）

**改善点:**
- 新しいフロントマターフィールド未活用:
  - `context: fork` — サブエージェントで実行（メインコンテキスト汚染防止）
  - `agent: Explore` / `agent: Plan` — 特定エージェントタイプで実行
  - `allowed-tools` — ツールアクセス制限（安全性向上）
  - `disable-model-invocation: true` — ユーザーのみ呼び出し可能
- `pr-review-cycle/skill.md` — ファイル名が`SKILL.md`ではなく`skill.md`（小文字）。動作はするが規約不統一
- バンドルスキル `/batch` `/loop` `/simplify` が未活用

### 4. hooks/（4ファイル）

**良い点:**
- bash/PowerShell両対応は素晴らしい（Mac/Windows対応の実例）
- prompt履歴の自動保存は実用的

**改善点:**
- 2イベント（UserPromptSubmit, Stop）のみ。以下が未活用:
  - `PreToolUse` — 危険コマンドのブロック（no-global-changesルールをhookで強制できる）
  - `PostToolUse` — コード変更後の自動リント
  - `SessionStart` — セッション開始時のコンテキスト注入
- handlerタイプが`command`のみ。`prompt`タイプを使えばClaude自体にガードレール判断させられる

### 5. agents/（3ファイル）

**改善点:**
- agents/ディレクトリに直接.mdファイルを置く旧パターン。新しいagent定義はskills/のフロントマター（`agent:`フィールド）で行う方が統一的
- ただし既存のagent定義は動作しているなら急いで移行する必要なし

### 6. commands/（3ファイル）

**改善点:**
- 便利コマンドが少ない。以下が候補:
  - デプロイステータス確認
  - バックテスト結果の要約表示
  - 本日のprompt履歴表示

### 7. settings.local.json

**問題点:**
- permissions.allowに**重複エントリが多数**:
  - `Bash(mvn clean:*)` × 2
  - `Bash(mvn:*)` × 2
  - `Bash(git commit:*)` × 2
  - `Bash(curl:*)` × 2
  - `Bash(git checkout:*)` × 2
  - `mcp__github__enable_toolset` × 2
  - `mcp__github__get_toolset_tools` × 2
- 有機的に追加された結果、整理されていない

### 8. MCP

- context7とgithubの2サーバーのみ
- serena関連のpermissionがsettings.local.jsonにあるが、.mcp.jsonにserenaの定義がない（削除済み？）

### 9. pbi-instructions/

- 20+ PBIの指示書が蓄積。歴史的アーカイブとして価値あるが、古いPBIがコンテキストノイズになる可能性
- アクティブなPBIとアーカイブの分離がない

## ドメイン非依存パターン（harness-harnessテンプレート候補）

| パターン | ファイル | 汎用性 |
|---------|---------|--------|
| prompt履歴自動保存 | hooks/save-prompt.sh, .ps1 | ★★★★★ |
| グローバル変更禁止ルール | rules/no-global-changes.md | ★★★★★ |
| 完了通知 | hooks/notify-completion.sh, .ps1 | ★★★★★ |
| 自律タスクスキル構造 | skills/autonomous-task/ | ★★★★☆ |
| PRレビューサイクル | skills/pr-review-cycle/ | ★★★★☆ |
| スキルクリエイター | skills/skill-creator/ | ★★★★☆ |
| コーディング規約テンプレート | rules/coding-standards.md | ★★★★☆ |
| worktreeガイド | worktree-guide.md | ★★★★☆ |
| サブエージェントガイドライン | subagent-guidelines.md | ★★★★☆ |
| チームプロトコル | rules/team-protocol.md | ★★★☆☆ |
| bash/PS両対応パターン | hooks/*の構造 | ★★★★★ |

## ドメイン固有（project-alphaにとどめる）

| パターン | ファイル |
|---------|---------|
| MarketSpeed2 RSS知識ベース | marketspeed2-rss-professional.md |
| JACOB COMベストプラクティス | jacob-best-practices.md |
| JPX市場仕様 | jpx-market-specification.md |
| Rundeck運用知識 | rundeck-professional.md |
| バックテストPDCAスキル | skills/backtest-strategy-pdca/ |
| デプロイスキル群 | skills/local-deploy/, copy-deploy/ |
| project-alpha-legacy再起動スキル | skills/project-alpha-legacy-dev-restart/ |
