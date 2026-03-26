---
name: sync-harness
description: |
  Claude Code⇔Codex CLIのハーネスを双方向同期するスキル。
  翻訳ではなく各プラットフォームのネイティブ最適化を維持した同期を行う。
  mapping/の変換ルールを中核に使用し、変換不可能な項目はネイティブ代替を提案。
  「Claude→Codex変換して」「ハーネス同期して」「Codex対応を追加して」で起動。
---

# sync-harness スキル

Claude Code ⇔ Codex CLI のハーネスを双方向同期する。「翻訳」ではなく、各プラットフォームのネイティブ最適化を維持した同期を行う。mapping/の変換ルールを中核に使用する。

## 入力形式

```
/path/to/project のハーネスをClaude→Codexに同期して
```

```
/path/to/project のハーネスを双方向同期して
```

```
Codex対応を追加して（既存Claudeハーネスから）
```

## 「翻訳より先にネイティブ」原則

このスキルの最重要原則。

- 変換元の**劣化コピー**を作らない
- 各プラットフォームの**固有の強み**を活かした表現にする
- 「AをBに翻訳する」ではなく「AとBが同じ意図を各自のベストな方法で表現する」

例:
- Claude `@import` → Codex AGENTS.mdにインライン展開（`@import`はCodexにない。無理に再現しない）
- Claude `.claude/rules/` → Codex AGENTS.md内セクション（物理分離はClaude固有の強み）
- Codex プロファイル → Claude settings.local.json + シェルエイリアス（プロファイルはCodex固有の強み）
- Codex `shell_environment_policy` → Claude SessionStart Hook（表現は異なるが意図は同じ）

## 処理フロー

### Phase 1: 現状読み取り

1. **変換元ハーネスの全ファイル読み取り**
2. **変換先ハーネスの有無確認**:
   - 変換先なし → 新規生成モード
   - 変換先あり → 差分同期モード
3. **変換元プラットフォーム自動判定**: CLAUDE.mdの有無 / AGENTS.mdの有無
4. **mapping/の3ファイルをロード**:
   - `mapping/shared-concepts.md` — 共通概念対照表
   - `mapping/claude-to-codex.md` — Claude→Codex変換ルール
   - `mapping/codex-to-claude.md` — Codex→Claude変換ルール

### Phase 2: 差分分析 & 方針決定（ユーザー対話）

各機能を4分類する（final-plan.mdのCodex計画から採用）:

| 分類 | 定義 | 変換方法 | 例 |
|------|------|---------|-----|
| **shared** | 両方で等価に表現可能 | 自動同期 | Skills（SKILL.md共通）、基本コマンド、ビルド指示 |
| **claude-native** | Claude固有の価値がある機能 | 変換せずClaude側のみで維持 | .claude/rules/（パススコープ）、@import、auto memory、Agent Teams、17+ Hooks |
| **codex-native** | Codex固有の価値がある機能 | 変換せずCodex側のみで維持 | プロファイル4種、AGENTS.override.md、shell_environment_policy、ephemeral |
| **wrapper-required** | 概念は共通だが表現が異なる | 変換ルール適用 | settings.json⇔config.toml、.mcp.json⇔[mcp_servers]、permissions⇔approval_policy |

**ユーザーに提示する情報**:

```
=== 同期分析結果 ===

[shared — 自動同期] 3件
1. Skills: .claude/skills/ ⇔ .agents/skills/ （ディレクトリ名変更のみ）
2. 基本指示: CLAUDE.md ⇔ AGENTS.md （共通セクション）
3. MCP設定: .mcp.json ⇔ [mcp_servers] （形式変換）

[claude-native — Claude側のみ維持] 2件
1. .claude/rules/frontend.md （パススコープ）→ Codexに該当機能なし
2. Agent Teams設定 → Codex multi_agentは実験的で互換性不明

[codex-native — Codex側のみ維持] 2件
1. プロファイル safe/dev/verify/ci → Claudeにプロファイルなし
2. shell_environment_policy → Claude SessionStartで類似機能は可能（提案する？）

[wrapper-required — 変換ルール適用] 3件
1. permissions → approval_policy（安全度レベルで抽象化）
2. Hooks JSON → Hooks TOML（共通3イベントのみ）
3. sandbox設定 → sandbox_mode

対応なし項目:
- Claude auto memory → Codexに該当なし（AGENTS.mdに知識を直接記述で代替）
```

**ユーザーと決定する事項**:
- claude-native/codex-native項目の扱い（対向プラットフォームで類似機能を生成するか）
- wrapper-required項目の変換方針（特に権限設定の抽象度）

### Phase 3: 同期実行

対象プロジェクトでgit worktreeを作成し、同期を実行する。

#### shared項目の同期

1. **Skills**: `.claude/skills/` ⇔ `.agents/skills/`
   - SKILL.mdはそのままコピー（Agent Skills標準で共通フォーマット）
   - Claude固有フロントマター（`context: fork`, `agent:`, `allowed-tools`等）はCodex側では無視される（互換性あり）
2. **指示ファイル**: CLAUDE.md ⇔ AGENTS.md
   - 共通セクション（プロジェクト概要、ビルド/テストコマンド、規約）を同期
   - プラットフォーム固有セクションは各自で維持
3. **MCP設定**: `.mcp.json` ⇔ `config.toml [mcp_servers]`
   - mapping/のMCPセクションに従いJSON⇔TOML変換

#### wrapper-required項目の変換

mapping/の変換ルールに厳密に従う:

1. **権限設定**: shared-concepts.mdの安全度レベルを介してマッピング
   - Claude `permissions.allow` / `permissions.deny` → Codex `approval_policy` + `sandbox_mode`
   - 逆方向も同様
2. **Hooks**: 共通3イベント（SessionStart, Stop, UserPromptSubmit）のみ同期
   - Claude JSON形式 → Codex TOML `[[hooks]]` 形式
   - Claude固有イベント（PreToolUse等）は同期しない（claude-native扱い）
3. **設定ファイル形式**: settings.json ⇔ config.toml
   - キー名の変換（mapping/参照）
   - 値の型変換（JSON array → TOML array等）

#### claude-native / codex-native項目の扱い

- **変換しない**のが原則
- 対向プラットフォームのハーネスに「この機能は{X}プラットフォーム固有」とコメントで明記
- ユーザーがPhase 2で「類似機能を生成する」と判断した場合のみ、ネイティブ代替を生成:
  - Claude rules/ → Codex AGENTS.md内に対応セクション追加
  - Codex プロファイル → Claude settings.local.json + シェルエイリアススクリプト
  - Codex shell_environment_policy → Claude SessionStart Hook

### Phase 4: 整合性検証

1. **specs/との照合**: 同期後のハーネスがspecs/の制約を満たすか確認
   - CLAUDE.md / AGENTS.md のサイズ制限
   - 設定ファイルの必須キー
   - Hooksの形式
2. **意味的整合性**: 双方のハーネスで同じ「意図」が表現されているか確認
   - 安全度レベルが一致しているか
   - ビルド/テストコマンドが一致しているか
   - 共通指示の内容が一致しているか
3. **Codex検証**（可能な場合）:
   ```bash
   codex exec --ephemeral --cd <worktree-path> \
     "このプロジェクトのAGENTS.md、config.toml、skillsが正しくロードされるか確認して。"
   ```
   失敗時はClaude単独で静的検証

### Phase 5: PR作成 & フィードバック

1. featureブランチ `harness/sync-{direction}-{project-name}` でcommit → push → PR作成
2. PR本文に記載:
   - 同期方向（Claude→Codex / Codex→Claude / 双方向）
   - 4分類の内訳（shared/claude-native/codex-native/wrapper-required件数）
   - wrapper-required項目の変換詳細
   - 対応なし項目と代替策
3. **自動マージはしない**（デフォルト）

**フィードバック**（省略厳禁）:

| フィードバック先 | 内容 |
|---|---|
| `mapping/` | 変換ルールの不足・誤りを発見した場合の修正提案。新たな共通概念や変換パターンの追加候補 |
| `mapping/shared-concepts.md` | 新しいclaude-native/codex-native機能を発見した場合の更新提案 |
| `kb/update-history.md` | 同期過程で得た知見の記録 |
| `logs/syncs/{project-name}-{date}.md` | 同期レポートの完全記録 |

## 既存スキルとの連携

- **create-harness**: 変換元が存在しない場合、まずcreate-harnessで片方を作成することを提案
- **diagnose-harness**: 同期後のハーネスに品質問題がある場合、diagnose-harnessを提案
- **patrol-docs**: mapping/の前提となるspecs/が最新か確認。古ければpatrol-docsの先行実行を推奨
- **cross-project-copy**: 同期で生成した汎用パターンを他プロジェクトにも展開する候補として記録

## 注意事項

- 「翻訳より先にネイティブ」原則を常に意識する。変換元の劣化コピーを作らない
- ソースコードは変更しない（ハーネスファイルのみ）
- mapping/の変換ルールを根拠にする。独自解釈で変換しない
- claude-native/codex-native機能を無理に変換しない（各プラットフォームの強みを削らない）
- プライベートプロジェクト名はPR本文やログに混入させない（匿名化）
- Codex exec失敗時はClaude単独で完遂する（Codex依存にしない）
- mapping/は日々進化する。specs/の更新に伴いmapping/も更新されるため、常に最新のmapping/を参照する
- フィードバック（Phase 5）は省略厳禁。特にmapping/への改善提案は重要
