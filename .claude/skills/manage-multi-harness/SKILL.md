---
name: manage-multi-harness
description: |
  マルチハーネス設計書に基づき、ハーネスファイルの生成・検証を行う「施工管理者」スキル。
  design-multi-harnessの設計書を入力に、目的別ハーネスファイルを一括生成・整合性検証する。
  生成（generate）と検証（verify）を実行。目的の追加・削除・更新は実践後に追加。
  「マルチハーネスを生成して」「ハーネスの整合性を検証して」「目的を追加して」で起動。
---

# manage-multi-harness スキル

design-multi-harnessの設計書に基づき、目的別ハーネスファイルの生成・検証を行う。設計書の「何を作るか」を「実際のファイル」に変換する施工管理者スキル。

## 入力形式

```
/path/to/project のマルチハーネスを生成して
```

```
マルチハーネスの整合性を検証して
```

```
データ分析用のハーネスを追加して
```

## 前提

`docs/multi-harness-design.md`（設計書）が対象プロジェクトに存在すること。なければdesign-multi-harnessスキルの先行実行を案内する。

## サブコマンド

### generate — 設計書に基づき全ハーネスファイルを一括生成

#### Phase 1: 設計書読込 & 検証

1. `docs/multi-harness-design.md` を読み込む
2. 設計書の整合性を確認（目的カタログ、技術基盤選定、ファイル構成計画の存在）
3. specs/の最新仕様と設計書の前提が一致するか確認
4. 既存ハーネスファイルとの衝突チェック

#### Phase 2: 共通レイヤー生成

対象プロジェクトでgit worktreeを作成し、以下を生成:

**Claude側共通**:
- `CLAUDE.md`: 200行以内。@importで分割。全目的共通のプロジェクト概要、ビルド/テストコマンド
- `.claude/settings.json`: 共通権限設定
- `.claude/instructions/common.md`: @importされる共通指示（CLAUDE.mdから参照）
- `.claude/rules/common-rules.md`: 全目的共通ルール（pathsなし）

**Codex側共通**:
- `AGENTS.md`: CLAUDE.mdと内容同期しつつCodexネイティブに記述
- `.codex/config.toml`: 共通設定 + 全プロファイル定義

**ソースコードは一切変更しない。**

#### Phase 3: 目的別レイヤー生成

設計書の各目的に対し、技術基盤選定結果に基づきファイルを生成:

**パス依存型の目的**（フロントエンド、バックエンド等）:
- `.claude/rules/{purpose}.md`: paths付きルール
- サブディレクトリ `{dir}/CLAUDE.md`: 領域固有指示（モノレポ時）
- サブディレクトリ `{dir}/AGENTS.md`: 同上

**独立コンテキスト型の目的**（レビュー、分析、リサーチ等）:
- `.claude/agents/{purpose}.md`: エージェント定義

```yaml
---
name: {purpose}
description: {設計書のペルソナ説明}
tools: {設計書のツール制限}
model: {設計書の推奨モデル}
---

{設計書のプロンプト内容}
```

- Codex側: `[agents.{purpose}]` config.tomlセクション、`[profiles.{purpose}]` プロファイル

**タスクトリガー型の目的**（マーケティング、デプロイ等）:
- `.claude/skills/{purpose}/SKILL.md`: スキル定義
- `.agents/skills/{purpose}/SKILL.md`: Codex側スキル（共通フォーマット）

**設定切替型の目的**（CI、テスト等）:
- Codexプロファイル: config.tomlの`[profiles.{purpose}]`セクション

```toml
[profiles.{purpose}]
model = "{設計書の推奨モデル}"
model_reasoning_effort = "{設計書の推論レベル}"
approval_policy = "{設計書の安全度に基づく}"
sandbox_mode = "{設計書の安全度に基づく}"
```

- Claude側: settings.local.jsonの切替パターン（該当する場合）

**CI/CD統合**（ci目的がある場合）:
- GitHub Actionsワークフロー例を生成（`.github/workflows/codex-harness.yml`）

```yaml
# 生成例
jobs:
  code-review:
    steps:
      - run: codex exec -p review --ephemeral "PRの変更をレビューして"
  test-and-fix:
    steps:
      - run: codex exec -p verify --ephemeral "テスト実行し失敗があれば修正して"
```

#### Phase 4: 整合性検証 & ユーザープレビュー

1. **specs/との照合**: 全生成ファイルが最新仕様の制約を満たすか
   - CLAUDE.md: 200行以内
   - AGENTS.md: 32KiB以内
   - SKILL.md: フロントマター形式
   - config.toml: 有効なTOML構文
2. **目的間の矛盾検出**:
   - pathsスコープの重複
   - 権限設定の矛盾
   - Codexプロファイル間の一貫性
3. **mapping/との整合性**: Claude側とCodex側の設定が同等の「意図」を表現しているか
4. **ユーザープレビュー**: 生成ファイル一覧と主要ファイルの内容を提示
5. **Codex検証**（可能な場合）:
   ```bash
   codex exec --ephemeral --cd <worktree-path> \
     "このプロジェクトのAGENTS.md、config.toml、profiles、skillsが正しくロードされるか検証して"
   ```

#### Phase 5: PR作成 & フィードバック

1. featureブランチ `harness/multi-gen-{project-name}` でcommit → push → PR作成
2. PR本文に: 目的一覧、生成ファイル一覧、技術基盤選定の概要を記載
3. **自動マージはしない**（デフォルト）

**フィードバック**（省略厳禁）:

| フィードバック先 | 内容 |
|---|---|
| `templates/`候補（logs/に記録） | 生成パターンのうち汎用性の高いものをテンプレート候補に |
| `cross-project-copy/references/copy-candidates.md` | 他プロジェクトにも有用な目的別ハーネスパターン |
| `mapping/` | Claude/Codex間の新しい対応パターンを発見した場合 |
| `kb/update-history.md` | 生成過程で得た知見 |
| `registry/` | プロジェクトのマルチハーネス状態を記録 |

---

### verify — 既存マルチハーネスの整合性検証

#### Phase 1: 全目的のハーネス読取

対象プロジェクトのハーネスファイルを全て読み取り、設計書（`docs/multi-harness-design.md`）と照合。

#### Phase 2: 検証実行

1. **設計書との乖離**: 設計書に定義されたファイルが全て存在するか。未実装の目的はないか
2. **specs/との突合**: 各ファイルが最新仕様を満たすか（diagnose-harnessと同等）
3. **目的間の整合性**:
   - pathsスコープの重複・漏れ
   - エージェント間のツール制限の矛盾
   - Codexプロファイル間の安全度一貫性
   - Claude/Codex間の意味的同期（mapping/に照らして）
4. **Codex並行監査**（フォールバック付き）:
   ```bash
   codex exec -a never -s read-only --cd <project-path> \
     "このプロジェクトのマルチハーネス設定を監査して。プロファイル間の矛盾、
      AGENTS.md階層の整合性、スキルのロード状態を検証して。"
   ```

#### Phase 3: レポート出力

```
=== マルチハーネス整合性レポート ===

[共通レイヤー]
  CLAUDE.md: 180行 (OK, 200行以内)
  AGENTS.md: 12KB (OK, 32KB以内)
  共通rules: 2ファイル

[目的別レイヤー]
  dev:    ✅ 正常（profiles.dev定義済み、共通CLAUDE.mdでカバー）
  review: ✅ 正常（agents/reviewer.md, profiles.review定義済み）
  test:   ⚠️ agents/test-runner.md のtools制限が緩い（Bash(*)は推奨外）
  ci:     ✅ 正常（profiles.ci定義済み、ephemeral対応）
  analysis: ⚠️ agents/analyst.md 未作成（設計書では定義済み）

[目的間整合性]
  ✅ pathsスコープ: 重複なし
  ⚠️ 安全度: test(standard) と review(strict) の中間が不明確
  ✅ Codexプロファイル: 全プロファイル一貫

[specs/最新仕様との乖離]
  ⚠️ Agent Teams未活用（新機能）
  ⚠️ context:fork未使用（research目的で推奨）

推奨アクション:
1. [test] agents/test-runner.md のtools制限を Bash(npm test *) に限定
2. [analysis] agents/analyst.md を作成（設計書Phase 3参照）
3. [research] context:fork スキルの導入を検討
```

---

### add-purpose — 新しい目的を追加（将来実装）

設計書の更新 → 追加目的のファイル生成 → 既存との整合性確認 → PR。
実践で必要性が確認されてから追加。

### remove-purpose — 目的を削除（将来実装）

影響分析 → 依存関係確認 → 削除 → 整合性再検証 → PR。
実践で必要性が確認されてから追加。

### update — specs/更新に追随（将来実装）

specs/の更新差分を検出 → 全目的に一括適用 → 検証 → PR。
patrol-docsとの連携で実現。

### status — 成熟度ダッシュボード（将来実装）

各目的のハーネス状態（設定完了度、最終更新日、推定利用頻度）をダッシュボード表示。
実践で必要性が確認されてから追加。

## 既存スキルとの連携

- **design-multi-harness**: 設計書を受け取る。設計書がなければdesign-multi-harnessに案内
- **sync-harness**: generate後にClaude⇔Codex間の同期が必要な場合に連携
- **diagnose-harness**: verify結果で個別目的の深い診断が必要な場合に連携
- **cross-project-copy**: 生成した目的別パターンを他プロジェクトに展開する候補として記録
- **patrol-docs**: generate/verify前にspecs/が最新か確認
- **create-harness**: 単一ハーネスからマルチハーネスへの移行時に連携

## 注意事項

- ソースコードは変更しない（ハーネスファイルのみ）
- 設計書なしにいきなり生成しない。設計書がなければdesign-multi-harnessに案内
- フィードバック（Phase 5）は省略厳禁
- プライベートプロジェクト名はPR本文やログに混入させない（匿名化）
- Codex exec失敗時はClaude単独で完遂する（Codex依存にしない）
- 「多様性は善」: 検証レポートでは問題指摘だけでなく、改善の選択肢をpros/cons付きで提示
- MVPとしてgenerate/verifyの2サブコマンドから始める。残りは実践で必要性を確認後に追加（過剰構造化回避）
- 生成されたCLAUDE.mdは200行以内に保つ。超える場合は@importで分割
