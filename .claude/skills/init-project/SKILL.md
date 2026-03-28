---
name: init-project
description: |
  新規プロジェクトをゼロから立ち上げるオーケストレーションスキル。
  要件対話→GitHubリポジトリ作成→初期ファイル生成→ハーネス作成→業務ドメイン知見反映→引き継ぎまでを一気通貫で実行。
  create-harnessスキルを内部で呼び出す。harness-harnessの基本方針を新規プロジェクトに踏襲する。
  「新しいプロジェクトを作って」「プロジェクトを立ち上げて」「ハーネス込みで初期化して」で起動。
---

# init-project スキル

新規プロジェクトをゼロから立ち上げるオーケストレーター。要件定義からGitHubリポジトリ作成、初期ファイル、Claude/Codexハーネス、業務ドメイン知見反映、引き継ぎ文書までを一気通貫で実行する。

## 基本方針

- harness-harnessのphilosophy.md（自律完遂、段階的開示、多様性は善、実践先行）を新規プロジェクトに踏襲する（ユーザーの明示指示がない限り暗黙の了解）
- ハーネス生成ロジックはcreate-harnessに委譲。二重実装しない
- 過剰scaffoldしない。最小限の骨格を作り、プロジェクト開始後にAIと協業で育てる

## 処理フロー

### Phase 0: 要件対話（必須）

ユーザーと対話して以下を確定する。段階的開示で最初は必須4項目のみ。

**必須項目**:
1. **プロジェクト名**（kebab-case推奨）
2. **プロジェクト目的**（1-2文）
3. **技術スタック**（言語、フレームワーク、DB等）
4. **リポジトリ可視性**: private（デフォルト） / public

**詳細項目**（ユーザーが求めた場合に展開）:
- 業務ドメイン（kb/domains/やprivate/kb/に既存知見があるか自動検索）
- ハーネス対象: Claude only / Codex only / Both（デフォルト: Both）
- 安全度レベル: strict / standard / permissive（デフォルト: standard）
- CI/CD方針
- ライセンス

**業務ドメイン知見の自動検索**:
- kb/domains/_index.mdとprivate/kb/domains/_index.mdを検索
- 該当する知見がある場合: 「{domain}の知見が蓄積済みです。ハーネスに反映しますか?」と提案
- ない場合: 「ドメイン知見はまだありません。research-kbで調査しますか?」と提案

### Phase 1: GitHubリポジトリ作成

```bash
gh repo create {owner}/{project-name} --private --clone
cd {project-name}
```

可視性はPhase 0の決定に従う。`.gitignore`は技術スタックに応じたテンプレートで生成。

### Phase 2: 初期ファイル群の生成

技術スタックに応じた最小構成を生成する。

1. **公式generatorがあればそれを使う**（`npm init`, `cargo init`, `uv init`等）
2. **ない場合は最小scaffold**（src/, docs/, README.md等）
3. `docs/project-brief.md` を生成（Phase 0の要件対話結果を記録）
4. 初期commit

**project-brief.md**:
```markdown
# {project-name} プロジェクト概要

## 目的
{Phase 0で確定した目的}

## 技術スタック
{Phase 0で確定した技術スタック}

## 業務ドメイン
{該当する場合。ドメイン知見の蓄積状況も記載}

## 決定事項
{Phase 0の対話で決定した方針と、却下した選択肢の理由}
```

### Phase 3: ハーネス生成（create-harnessに委譲）

create-harnessスキルの手順に従ってClaude/Codexハーネスを生成する。

**委譲時に渡す情報（create-harnessのPhase 1-2を短縮）**:
- Phase 0で確定した要件（プラットフォーム、安全度レベル等）
- Phase 2で生成した技術スタック情報

**create-harnessが生成するもの**:
- CLAUDE.md, .claude/settings.json, .claude/skills/, .claude/rules/
- AGENTS.md, .codex/config.toml, .agents/skills/（Both選択時）

### Phase 4: 業務ドメイン知見の反映

Phase 0で業務ドメインが特定されている場合、kb/やprivate/kb/の知見をハーネスに反映する。

**蒸留ルール**（32KiB制約を意識。全文埋め込みしない）:
- frontmatterの`summary`, `key_concepts`, `harness_implications`を優先抽出
- CLAUDE.md/AGENTS.mdに3-7個の短いoperational bulletsとして反映
- 詳細は`docs/domain-context.md`に記載し、ハーネスからは参照で誘導
- private/kb/の内容は抽象化したguardrailのみ投入（原文コピー禁止）

**domain-context.md**:
```markdown
# 業務ドメインコンテキスト

## 反映元
- {harness-harnessのkb/パス}

## 重要概念
{key_conceptsから蒸留}

## ハーネス設計への示唆
{harness_implicationsから蒸留}

## 詳細参照先
harness-harnessのkb/を参照: {パス}
```

### Phase 5: 引き継ぎ・完了

プロジェクトの初期セットアップ完了後、以後の作業計画を整理してリポジトリとユーザーに残す。

1. **docs/handoff.md** を生成（以後の作業計画）:

```markdown
# 引き継ぎ

作成日: {date}
作成元: harness-harness init-project スキル

## 初期セットアップ完了状態
- リポジトリ: {URL}
- 技術スタック: {stack}
- ハーネス: Claude {あり/なし} / Codex {あり/なし}
- 業務ドメイン知見: {反映済み/未適用}

## 以後の作業計画

### 即時（次回セッションで着手可能）
- [ ] {具体的なタスク}

### 短期（1-2週間）
- [ ] {タスク}

### ハーネス改善候補
- [ ] {例: 業務ドメイン知見の追加調査}
- [ ] {例: CI/CDワークフロー追加}

## harness-harnessへのフィードバック体制
このプロジェクトの運用で得た知見は以下にフィードバック:
- init-projectスキルの改善提案 → harness-harness
- ドメイン知見の追加 → harness-harness kb/ or private/kb/
- ハーネス改善パターン → harness-harness templates/候補
```

2. 最終commit + push
3. harness-harness側の更新:
   - `private/registry/projects.md` にプロジェクトエントリ追加
4. ユーザーへのサマリー報告

## 既存スキルとの連携

| スキル | 連携タイミング | 役割 |
|--------|-------------|------|
| create-harness | Phase 3 | ハーネス生成を委譲 |
| research-kb | Phase 0（知見不足時） | 業務ドメイン追加調査を提案 |
| diagnose-harness | 将来（改善時） | 生成ハーネスの品質診断 |
| cross-project-copy | 将来（横展開時） | 汎用パターンの他プロジェクトへの展開 |

## 注意事項

- Phase 0のユーザー対話は省略しない。全てをAI自動判断しない
- 過剰scaffoldしない。最小限の骨格を作り、実践で育てる
- ハーネス生成ロジックはcreate-harnessに委譲。二重実装しない
- private/kb/の原文を新規リポジトリに直接コピーしない。抽象化guardrailのみ
- harness-harnessのpublic領域に、新規プロジェクトのドメイン固有情報を残さない
- Codex exec失敗時はClaude単独で完遂する
- 「多様性は善」: 要件対話でpros/consを明示し選択肢を残す
