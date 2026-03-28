---
name: init-project
description: |
  新規プロジェクトをゼロから立ち上げるオーケストレーションスキル。
  harness-harnessの全知識資産（philosophy/specs/kb/推薦スキル）を毎回解析し、
  思想を行動規則に変換して注入する。浅い生成物ではなく、AIの知識を最大限活用した深い設計を行う。
  「新しいプロジェクトを作って」「プロジェクトを立ち上げて」「ハーネス込みで初期化して」で起動。
---

# init-project スキル

新規プロジェクトをゼロから立ち上げるオーケストレーター。harness-harnessの全知識資産を毎回読み込み、philosophy.mdの思想を行動規則に変換し、specs/kb/推薦スキルを蒸留して注入する。ありきたりではない、AIの知識を最大限活用した深いプロジェクト設計を行う。

## 核心原則

- **harness-harnessは動的に変更される前提。Phase 0.5で毎回最新を読み込む（キャッシュ不可）**
- philosophy.mdの思想はスローガンではなく行動規則に変換して注入する
- specs/kb/の知見は「参照リンク」ではなく「蒸留した行動規則」として埋め込む
- ユーザーの期待を超える深い設計をAIが自律的に行う（指示追従<AI提案）
- harness-harnessの基本方針を踏襲（ユーザーの明示指示がない限り暗黙の了解）

## 処理フロー

### Phase 0: 要件対話（必須）

ユーザーと対話して確定。段階的開示で最初は必須4項目のみ。

**必須**: プロジェクト名、目的、技術スタック、リポジトリ可視性
**詳細（展開時）**: 業務ドメイン、ハーネス対象、安全度レベル、CI/CD、ライセンス

業務ドメイン: kb/domains/とprivate/kb/domains/を自動検索し知見の有無を報告。

### Phase 0.5: harness-harness全知識資産の読み込み（必須・省略厳禁）

**Phase 0完了後、Phase 1の前に必ず実行。harness-harnessのリポジトリから最新を読む。**

#### Step 1: philosophy.md → 基本思想の注入 + 行動規則への変換

docs/philosophy.mdを読み込み、**二層構造**で対象プロジェクトのCLAUDE.md/AGENTS.mdに注入する。philosophy.mdは動的に変更される可能性があるため、ここに固定値を書かず**毎回最新のphilosophy.mdから読み取って変換する**。

**第1層: 基本思想そのもの（なぜそうするか）**
CLAUDE.md/AGENTS.mdに「基本思想」セクションを設け、docs/philosophy.mdの各原則の意味・意図を端的に記載する。AIがこの思想を深く理解した上で行動規則に従えるようにする。

**第2層: 行動規則（具体的に何をするか）**
基本思想から導出される検証可能な行動規則を記載する。

**以下はあくまで現時点の例。実行時はphilosophy.mdの最新内容から動的に変換すること**:

| 原則 | 基本思想（第1層） | 行動規則（第2層） |
|------|----------------|-----------------|
| 段階的開示 | 必要なときに必要なだけ情報を見せる | CLAUDE.md 200行以下。詳細はrules/docs/に分離 |
| 透過性 | AIの判断をユーザーが検証できる状態にする | 判断根拠と却下理由をコメントに残す |
| 指示追従<AI提案 | AIはユーザーを超える知識を活かす | 優れた代替案があればpros/cons付きで提案 |
| 自律完遂 | AIが単独でタスクを完遂する | 不明点はサブエージェントで調査し自己解決 |
| 自己評価 | 作業結果を自己評価し改善サイクルを回す | 作業完了後に自己評価。省略厳禁 |
| 多様性は善 | 答えを1つに絞らず選択肢を残す | 各案のメリット・デメリットを提示 |
| 実践先行 | 完璧な設計より動くものを先に | 最小限で始めて実践で育てる |

#### Step 2: specs/ → 適用すべきベストプラクティスの抽出

specs/claude/best-practices.md, hooks.md, skills-and-commands.md, configuration.mdから:
- CLAUDE.md「地図型」設計（簡潔に、詳細はrules/分離）
- Hooks設定パターン（SessionStart注入、PreToolUse破壊的コマンドブロック、PostToolUseフォーマット）
- スキルのcontext:fork + allowed-tools + pathsフロントマター
- @importによるファイル分割戦略
- rules/のpathsスコープ

#### Step 3: kb/ → 外部知見の蒸留

kb/external/の各takeaways.mdのtop_patternsを読み、プロジェクトに適用:
- **ECC**: フック安全3点セット、CLAUDE.md地図型、rules/common+言語別分離
- **gstack**: 軽量スプリント（Think→Build→Review→Ship→Reflect）、安全ガードレール
- **superpowers**: SKILL.mdフロントマター標準、CSO、Hook初期化
- **autoresearch**: bounded pattern（不変の評価器、可変面限定、予算、台帳、ブランチ命名）

#### Step 4: 推薦スキルの選定

kb/skills/recommended.mdを読み、プロジェクト種別に応じて選定:
- 全プロジェクト共通: skill-creator, systematic-debugging, brainstorming
- テストあり: test-driven-development
- Git運用: using-git-worktrees
- 並列調査: dispatching-parallel-agents
- プロジェクト種別に応じたTier B候補も条件付きで提案

### Phase 1: GitHubリポジトリ作成

`gh repo create` で作成。.gitignoreは技術スタックに応じたテンプレート。

### Phase 2: 初期ファイル群の生成

公式generatorがあればそれを使用。なければ最小scaffold。
docs/project-brief.md（Phase 0の要件記録）を生成。

### Phase 3: ハーネス生成（create-harnessに委譲）

**委譲時に渡す情報**:
- Phase 0の要件
- **Phase 0.5の全解析結果**（行動規則、ベストプラクティス、外部知見、推薦スキル）
- Phase 2の技術スタック情報

create-harnessはPhase 0.5の解析結果を受け取り、再解析せずに適用する。

### Phase 4: 業務ドメイン知見の反映

kb/domains/やprivate/kb/のfrontmatter（summary, key_concepts, harness_implications）を蒸留し、CLAUDE.md/AGENTS.mdに3-7個のoperational bulletsとして反映。詳細はdocs/domain-context.mdに記載。

### Phase 5: Codexレビュー（必須）

**生成されたプロジェクト全体をCodexにレビューさせる。**

```bash
codex exec -a never -s read-only --cd <project-path> \
  "このプロジェクトの初期セットアップをレビューして。
   CLAUDE.md/AGENTS.mdにphilosophy.mdの思想が行動規則として反映されているか、
   推薦スキルが適切に注入されているか、Hooks/rules/のスコープ設定が正しいか、
   生成物が浅くありきたりでないか、AIの知識を活かした深い設計になっているか評価して。"
```

Codexのフィードバックに基づき修正。Codex exec失敗時はClaude単独で自己レビュー。

### Phase 6: 引き継ぎ・完了

1. docs/handoff.md 生成（作業計画、harness-harnessフィードバック体制）
2. docs/harness-sources.md 生成（どの知見がどこから来たか。透過性の実装）
3. 最終commit + push
4. harness-harness private/registry/にプロジェクト登録
5. ユーザーへのサマリー報告

## 注意事項

- **Phase 0.5は省略厳禁。harness-harnessの知識資産を読まずに生成しない**
- **Phase 5のCodexレビューも省略厳禁。レビューなしにPR作成しない**
- 過剰scaffoldしない。最小限の骨格を作り実践で育てる
- ハーネス生成ロジックはcreate-harnessに委譲。二重実装しない
- private/kb/の原文を新規リポジトリに直接コピーしない。抽象化guardrailのみ
- harness-harnessのpublic領域に新規プロジェクトのドメイン固有情報を残さない
- AIの知識を最大限活用した深い設計を行う。浅くありきたりな生成物は失格
