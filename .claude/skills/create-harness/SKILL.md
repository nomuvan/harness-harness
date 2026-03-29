---
name: create-harness
description: |
  新規プロジェクトにClaude Code / Codex CLIのハーネスを作成するスキル。
  harness-harnessの全知識資産（philosophy/specs/kb/推薦スキル）を毎回解析し、
  思想を行動規則に、知見をHooks/rules/スキルに変換して注入する。
  「ハーネス作って」「新規プロジェクトにハーネスを設定して」「CLAUDE.mdを作って」で起動。
---

# create-harness スキル

新規プロジェクトにClaude Code / Codex CLIのハーネスを作成する。philosophy.mdの思想を行動規則に変換し、specs/kb/推薦スキルを蒸留して注入する。毎回harness-harnessの最新知識資産を読み込む。

## 処理フロー

### Phase 1: プロジェクト分析

対象プロジェクトの技術スタック、ディレクトリ構造、既存設定を徹底分析。
既にハーネスがある場合 → diagnose-harnessに案内して終了。

Codex並行分析（フォールバック付き）:
```bash
codex exec -a never -s read-only --cd <project-path> \
  "技術スタック、ディレクトリ構造、開発フローを分析して。JSON形式で出力。"
```

### Phase 1.5: harness-harness知識資産の読み込み（必須・省略厳禁）

**init-project経由の場合はPhase 0.5の結果を受け取る。単独実行時は以下を自前で実行。**

harness-harnessは動的に変更される前提。毎回最新を読み込む。

#### Step A: philosophy.md → 基本思想の注入 + 行動規則への変換

docs/philosophy.mdを読み込み、**二層構造**で対象プロジェクトのCLAUDE.md/AGENTS.mdに注入する。

**第1層: 基本思想そのもの（なぜそうするか）**

CLAUDE.md/AGENTS.mdに「基本思想」セクションを設け、各原則の意味・意図を端的に記載する。AIがこの思想を深く理解した上で行動規則に従えるようにする。行動規則だけでは「なぜ」が伝わらない。

注入する基本思想:
- **段階的開示**: 必要なときに必要なだけ情報を見せる。コンテキスト節約とユーザー認知負荷の最小化
- **透過性**: AIが何をしているか、どれくらい信用できるかをユーザーが判断できる状態にする
- **指示追従性よりAIの優れた提案を重視**: AIはユーザーを超える知識を持つ。指示に従うだけでなく、より良いアイデアを提示する
- **自律完遂・ロングラン**: AIが単独でタスクを完遂し、段階的に自律度を高める
- **自己評価・自律改善**: 作業結果を自己評価し、改善サイクルを自律的に回す
- **多様性は善**: 答えを1つに絞らず、各案のメリット・デメリットを明示して選択肢を残す
- **実践先行・過剰構造化の回避**: 完璧な設計より先に動くものを作り、実践のフィードバックで改善する
- **暗黙知と漸進的指示**: 初回で全てを網羅しない。対話で補完し、知見をハーネスに蓄積する

**第2層: 行動規則（具体的に何をするか）**

基本思想から導出される検証可能な行動規則を記載する:

- 段階的開示 → 「CLAUDE.md 200行以下。詳細はrules/docs/に分離。@importで参照」
- 透過性 → 「判断根拠を明示。却下した選択肢と理由もコメントに残す」
- 指示追従<AI提案 → 「優れた代替案があればpros/cons付きで提案せよ」
- 自律完遂 → 「タスク完了まで中断せず進め。不明点はサブエージェントで調査」
- 自己評価 → 「作業完了後に自己評価。省略厳禁。keep/discard台帳で改善」
- 多様性は善 → 「選択肢は1つに絞らない。各案のメリット・デメリットを提示」
- 実践先行 → 「過剰scaffoldしない。最小限で始めて実践で育てる」
- 暗黙知と漸進的指示 → 「追加指示はハーネス自体にフィードバック」

#### Step B: specs/ → ベストプラクティス

- CLAUDE.md「地図型」（簡潔。詳細はrules/分離。ECC知見）
- Hooksパターン:
  - minimal: SessionStart（コンテキスト注入）
  - standard: + PreToolUse（破壊的コマンドブロック）+ PostToolUse（自動フォーマット）
  - full: + ECC安全3点セット（no-verify/config-protection/secret-detect）
- スキル: context:fork + allowed-tools + pathsフロントマター（superpowers知見）
- rules/: pathsスコープ分離（ECC知見: common + 言語別）
- @import: 100行超見込み時にファイル分割

#### Step C: kb/ → 外部知見

プロジェクト種別に応じて適用:
- **全プロジェクト**: AGENTS.mdルート配置（ECC: クロスツール標準）
- **開発プロセスあり**: 軽量スプリント Think→Build→Review→Ship→Reflect（gstack）
- **自律改善あり**: bounded autoresearch pattern（autoresearch: 不変judge+可変面+台帳）
- **テスト重視**: TDDサイクル強制（superpowers）
- **安全性重視**: /careful /freeze相当のガードレール（gstack）

#### Step D: 推薦スキル選定

kb/skills/recommended.mdから技術スタック・プロジェクト目的に応じて選定:
- 全プロジェクト: skill-creator, systematic-debugging, brainstorming
- テストあり: test-driven-development
- Git運用: using-git-worktrees
- 並列: dispatching-parallel-agents
- 条件付きTier B候補もマッチすれば提案

### Phase 2: 方針決定（ユーザー対話）

分析結果+Phase 1.5の知見をユーザーに提示し対話で決定。

**必須**: 対象プラットフォーム、安全度レベル
**詳細**: Hooks方針、MCP、Skills初期セット、Codexプロファイル

**AIは方針提案時にPhase 1.5の知見を根拠として明示する。** 「gstackの軽量スプリントを採用しますか？理由は...」のように。

### Phase 3: ハーネス生成

worktreeを作成し、Phase 1.5の全解析結果を反映してハーネスを生成。

**Step 3-A: CLAUDE.md/AGENTS.mdの生成**

必須セクション（Step Aの二層構造を必ず含めること）:
- プロジェクト概要、技術スタック、ビルド/テストコマンド
- **基本思想**（Step A第1層: philosophy.mdの各原則の意味・意図を端的に記載）
- **AI行動規則**（Step Aで変換したphilosophy行動規則）
- **自律レベル定義**（L1協業→L2半自律→L3自律。現在地と昇格条件）
- **Read Order**（段階的開示の実装: CLAUDE.md→docs/→rules→skills→対象ファイル）
- 推薦スキル一覧（Step Dで選定したもの）
- **開発ワークフロー**（ユーザーから特に指示がない場合、harness-harness標準を適用）:
  - mainは司令塔。日常の編集作業はworktreeで行う
  - 複数ファイル変更はfeatureブランチ→PR→マージ。軽微な修正のみmain直接push
  - Claude Code: EnterWorktreeで作業→完了→PR→マージ→ExitWorktree
  - Codex: 外側でworktree作成→`codex exec --cd <worktree> --profile author`→完了→PR→worktree削除
  - 1タスク1worktree。worktreeパスは`../<repo>-wt-<branch-short>/`
  - 詳細はdocs/conventions.mdに委譲（8-12行の要約のみCLAUDE.md/AGENTS.mdに記載）

**Step 3-A2: docs/conventions.mdの生成**

対象プロジェクトにdocs/conventions.mdを生成し、harness-harness docs/conventions.mdの以下を端的に移植:
- git worktree運用ルール（Claude方式/Codex方式）
- ブランチ命名規約（feature/*, review/*, fix/*）
- PR必須の線引き（複数ファイル→PR、軽微→main直接push可）
- コミットメッセージ規約
- 完了条件（commit+push≠完了。PR→マージ→worktree削除までが1サイクル）

**Step 3-B: Hooks/settings.jsonの生成**

Phase 2で決定したHooks方針に基づき生成:
```json
{
  "hooks": {
    "SessionStart": [{"hooks": [{"type": "command", "command": ".claude/hooks/session-context.sh"}]}],
    "PreToolUse": [{"matcher": "Bash", "hooks": [{"type": "command", "command": ".claude/hooks/block-destructive.sh"}]}]
  }
}
```

**Step 3-C: rules/の生成**

pathsフロントマター付きでスコープ分離:
- common-rules.md（pathsなし、全体適用）
- 技術スタック固有rules（paths付き）

**Step 3-D: 推薦スキルの注入**

選定されたスキルをCLAUDE.mdに記載し、利用可能なものは.claude/skills/に配置。
SKILL.mdフロントマター: CSO最適化済みdescription、context:fork（調査系）、allowed-tools。

**Step 3-E: 出典記録**

docs/harness-sources.md を生成。どの知見がどこから来たかを記録（透過性の実装）。

**Step 3-F: Codex側生成**（Both選択時）

AGENTS.md, .codex/config.toml（プロファイル4種）, .agents/skills/

**鉄則**: ソースコードは一切変更しない。

### Phase 4: Codexレビュー（必須・省略厳禁）

**生成されたハーネス全体をCodexにレビューさせる。**

```bash
codex exec -a never -s read-only --cd <worktree-path> \
  "このプロジェクトのハーネスをレビューして。
   1. philosophy行動規則が具体的に記述されているか（スローガンになっていないか）
   2. 推薦スキルが適切に注入されているか
   3. Hooks/rulesのスコープ設定が正しいか
   4. 生成物が浅くありきたりでないか、プロジェクト固有の深い設計になっているか
   5. specs/のベストプラクティスに準拠しているか
   findingsをseverity順で報告して。"
```

Codexフィードバックに基づき修正。**レビューなしにPR作成は禁止。**

### Phase 5: PR作成 & フィードバック

1. featureブランチでcommit → push → PR作成
2. PR本文: 技術スタック、方針、Phase 1.5の知見適用内容、Codexレビュー結果
3. **フィードバック**（省略厳禁）:
   - templates/改善候補をログに記録
   - registry/にプロジェクト登録
   - kb/update-history.mdに知見記録
   - cross-project-copy候補特定

## 注意事項

- **Phase 1.5は省略厳禁。harness-harnessの知識資産を読まずに生成しない**
- **Phase 4のCodexレビューも省略厳禁。レビューなしにPR作成しない**
- philosophy行動規則は「スローガン」ではなく「検証可能な具体指示」として注入
- 生成物が浅くありきたりなら失格。AIの知識を最大限活用した深い設計を行う
- harness-harnessは動的に変更される。毎回最新を読む
- ソースコードは変更しない（ハーネスファイルのみ）
- CLAUDE.mdは200行以下。超える場合は@importで分割
- **ユーザーの指示を実現するために必要な情報にアクセスできない場合は、勝手にスキップせずユーザーにヒアリングする**
