---
name: create-harness
description: |
  新規プロジェクトにClaude Code / Codex CLIのハーネスを作成するスキル。
  プロジェクト分析→方針決定→ハーネス生成→検証→PR&フィードバックを実行。
  specs/の最新仕様とkb/のベストプラクティスを根拠に、プロジェクト特性に合わせたハーネスを生成。
  「ハーネス作って」「新規プロジェクトにハーネスを設定して」「CLAUDE.mdを作って」で起動。
---

# create-harness スキル

新規プロジェクトにClaude Code / Codex CLIのハーネスを作成する。specs/を根拠に、対象プロジェクトの特性に最適化されたハーネスファイル一式を生成する。

## 入力形式

```
/path/to/project にハーネスを作って
```

```
以下のプロジェクトにClaude/Codex両方のハーネスを作成して:
/path/to/project
```

## 処理フロー

### Phase 1: プロジェクト分析

対象プロジェクトを徹底的に分析する。

1. **ディレクトリ構造の読み取り**: `ls`, `tree`（浅い階層）で全体構造を把握
2. **技術スタックの自動検出**:
   - マニフェストファイル: `package.json`, `Cargo.toml`, `pyproject.toml`, `go.mod`, `pom.xml`, `build.gradle` 等
   - テストフレームワーク: Jest, pytest, cargo test, go test 等
   - リンター/フォーマッター: ESLint, Prettier, rustfmt, black, gofmt 等
   - CI/CD設定: `.github/workflows/`, `.gitlab-ci.yml`, `Makefile` 等
3. **既存ハーネスの有無チェック**: CLAUDE.md, AGENTS.md, .claude/, .codex/, .cursor/ 等
   - 既にハーネスがある場合 → diagnose-harnessスキルの利用を案内して終了
4. **モノレポ判定**: workspaces設定、複数のマニフェストファイルの存在
5. **README・ドキュメントの確認**: プロジェクトの目的・概要を把握

**Codex並行分析**（フォールバック付き）:

```bash
codex exec -a never -s read-only --cd <project-path> \
  "このプロジェクトの技術スタック、ディレクトリ構造、開発フローを分析して。
   ビルドコマンド、テストコマンド、デプロイ方法を特定して。結果をJSON形式で出力して。"
```

Codex exec失敗時はClaude単独で完遂する。

### Phase 2: 方針決定（ユーザー対話 -- 必須）

Phase 1の分析結果をユーザーに提示し、以下を対話で決定する。段階的開示で最初は必須項目のみ提示。

**必須決定事項**:

1. **対象プラットフォーム**: Claude only / Codex only / Both
2. **安全度レベル**: mapping/shared-concepts.md の安全度レベルに基づく
   - **strict**: 全ツール事前承認。初回・評価用
   - **standard**: ファイル操作は許可、外部通信は承認。日常開発用（推奨）
   - **permissive**: ほぼ全許可、破壊操作のみ承認。経験者向け

**詳細決定事項**（ユーザーが求めた場合に展開）:

3. **Hooks方針**:
   - minimal: SessionStartのみ（デフォルト）
   - standard: + PreToolUse, PostToolUse
   - full: 全イベント活用
4. **MCP**: 使用するMCPサーバーがあるか
5. **Skills初期セット**: cross-project-copyで他プロジェクトから移植するか、最小限から始めるか
6. **Codex生成時（Bothの場合）**: プロファイル設計
   - safe: read-only + on-request（コードレビュー用）
   - dev: workspace-write + on-request（日常開発用）
   - verify: workspace-write + untrusted（テスト実行用）
   - ci: workspace-write + never + ephemeral（CI/CD用）
各選択肢にpros/consを明示し、ユーザーの判断材料を提供する。

目的別に複数ハーネスを使い分けたい場合は、switch-harnessスキルを案内する。

### Phase 3: ハーネス生成

対象プロジェクトでgit worktreeを作成し、ハーネスファイルを生成する。

**テンプレート戦略**:
- `templates/{platform}/{type}/` にテンプレートがあれば使用
- なければ（現状）specs/ + kb/ + mapping/ から動的生成

**Claude向け生成物**:

| ファイル | 根拠 | 内容 |
|----------|------|------|
| `CLAUDE.md` | specs/claude/best-practices.md | 200行以下。プロジェクト概要、ビルド/テストコマンド、コーディング規約。大規模時は`@`インポートで分割 |
| `.claude/settings.json` | specs/claude/configuration.md | permissions, sandbox設定。Phase 2の安全度レベルに基づく |
| `.claude/rules/` | specs/claude/configuration.md | パススコープのルール（モノレポ時） |
| `.claude/skills/` | specs/claude/skills-and-commands.md | プロジェクトに適した初期スキル |
| `.mcp.json` | specs/claude/mcp.md | MCP設定（Phase 2で決定した場合） |
| `.claude/agents/` | specs/claude/agent-teams.md | カスタムサブエージェント（該当する場合） |

**Codex向け生成物**（Bothの場合）:

| ファイル | 根拠 | 内容 |
|----------|------|------|
| `AGENTS.md` | specs/codex/configuration.md | CLAUDE.mdと内容同期しつつCodexネイティブに記述 |
| `.codex/config.toml` | specs/codex/configuration.md | approval_policy, sandbox_mode, プロファイル4種 |
| `.agents/skills/` | .claude/skills/からコピー。ディレクトリ名のみ変更 |
| `agents/openai.yaml` | specs/codex/configuration.md | スキルUI表示・ポリシー設定 |

**Both生成時の共通指示**:
- `docs/shared-instructions.md`パターン（mapping/shared-concepts.md 1.1参照）の導入を検討
- 共通の指示はCLAUDE.md/AGENTS.md両方に記述し、プラットフォーム固有部分のみ分離

**鉄則**: ソースコードは一切変更しない。ハーネスファイルのみを生成する。

### Phase 4: 検証

1. **構造チェック**: 生成されたファイルがspecs/の制約を満たすか確認
   - CLAUDE.md/AGENTS.mdのサイズ制限
   - settings.json/config.tomlの必須キー
   - SKILL.mdのフロントマター形式
2. **一貫性チェック（Both生成時）**: Claude側とCodex側の設定が矛盾しないか、mapping/に照らして確認
3. **ユーザープレビュー**: 生成されたファイル一覧と主要ファイルの内容をユーザーに提示
4. **Codex検証**（可能な場合）:
   ```bash
   codex exec --ephemeral --cd <worktree-path> "このプロジェクトのハーネス設定を確認して。
   AGENTS.md、config.toml、skillsが正しくロードされるか検証して。"
   ```

### Phase 5: PR作成 & フィードバック

1. featureブランチ `harness/init-{project-name}` でcommit → push → PR作成
2. PR本文に記載:
   - 検出した技術スタック
   - 選択した方針（安全度レベル、Hooks方針等）
   - 生成したファイル一覧
   - harness-harness由来であることの明記
3. **自動マージはしない**（デフォルト）。ユーザー確認後にマージ

**フィードバック**（省略厳禁）:

- templates/の改善候補: 動的生成した結果のうち汎用性の高いパターンをログに記録
- registry/の更新: 管理対象プロジェクトにエントリ追加
- kb/update-history.md: 生成過程で得た知見を記録
- cross-project-copy候補: 他プロジェクトにも有用なスキル/hooks/rulesを特定

## 既存スキルとの連携

- **patrol-docs**: Phase 1の前にspecs/が最新か確認。古ければpatrol-docsの実行を推奨
- **cross-project-copy**: Phase 2で「他プロジェクトからスキルを移植するか」を提案
- **research-kb**: 対象プロジェクトで未知の技術が検出された場合、research-kbでの調査を提案
- **diagnose-harness**: 既存ハーネスがある場合はdiagnose-harnessに案内

## 注意事項

- ソースコードは変更しない（ハーネスファイルのみ）
- Phase 2のユーザー対話は省略しない。自動判断で全てを決定しない
- 生成するCLAUDE.mdは200行以下。超える場合は@importで分割
- プライベートプロジェクト名はPR本文やログに混入させない（匿名化）
- テンプレートがなくても動作する。テンプレートの存在は品質向上だが必須ではない
- Codex exec失敗時はClaude単独で完遂する（Codex依存にしない）
- 「多様性は善」: 方針決定時にpros/consを明示し選択肢を残す
