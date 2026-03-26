---
name: design-multi-harness
description: |
  1プロジェクトに複数の目的別ハーネスを設計する「建築家」スキル。
  目的カタログの洗い出し→技術基盤の選定→整合性設計→設計書出力を行う。
  コーディング系（dev/review/test/CI）から非技術系（分析/マーケティング/自律学習）まで網羅。
  Claude/Codex両プラットフォームのネイティブ機能を最大限活用した設計を行う。
  「マルチハーネスを設計して」「目的別ハーネスを設計して」「複数ハーネスを入れたい」で起動。
---

# design-multi-harness スキル

1つのプロジェクト内で、目的ごとに最適化された複数のハーネスを設計する。「何を作るか」を決める建築家スキル。設計書（`docs/multi-harness-design.md`）を出力し、manage-multi-harnessスキルの入力とする。

## コンセプト

単一ハーネスでは対応しきれない多目的プロジェクトに対し、目的別に最適化されたハーネス群を設計する。

- **コーディング系**: フロントエンド、バックエンド、テスト、CI/CD、リファクタリング、セキュリティ監査
- **技術非コーディング系**: アーキテクチャ設計、ドキュメント生成、依存関係分析
- **非技術系**: データ分析、マーケティングコンテンツ、市場調査、自律学習・研究、プロジェクト管理

## 入力形式

```
/path/to/project にマルチハーネスを設計して
```

```
このプロジェクトにフロントエンド、バックエンド、テスト、データ分析の4目的のハーネスを入れたい
```

## 処理フロー

### Phase 1: 現状分析

1. **プロジェクト構造の把握**: ディレクトリ構成、技術スタック、モノレポかどうか
2. **既存ハーネスの読み取り**: CLAUDE.md, AGENTS.md, settings.json, config.toml, skills, rules, agents の有無と内容
3. **既存設計書の確認**: `docs/multi-harness-design.md` が既にあれば読み込み、差分更新モードに移行
4. **利用パターンの推定**: プロジェクトの性質から、どんな目的でAIが使われるかを推定

Codex並行分析（フォールバック付き）:

```bash
codex exec -a never -s read-only --cd <project-path> \
  "このプロジェクトの技術スタック、ディレクトリ構造、想定される開発ワークフローを分析して。
   どんな目的でAIエージェントを使うのが効果的か提案して。"
```

### Phase 2: 目的カタログ作成（ユーザー対話 -- 核心）

プロジェクトで必要な「目的」を洗い出す。段階的開示で、まずTier 1を提示し、必要に応じてTier 2, 3を展開する。

#### Tier 1: コーディング系（ほぼ全プロジェクトで有用）

| 目的 | 概要 | 想定ペルソナ |
|------|------|------------|
| **dev** | 日常開発。機能実装、バグ修正 | シニアエンジニア |
| **review** | コードレビュー。品質・セキュリティ・保守性の観点 | スタッフエンジニア（読取専用） |
| **test** | テスト作成・実行。カバレッジ向上 | QAエンジニア |
| **ci** | CI/CDバッチ実行。非対話的な自動処理 | リリースエンジニア |

#### Tier 2: 技術非コーディング系（プロジェクト規模に応じて）

| 目的 | 概要 | 想定ペルソナ |
|------|------|------------|
| **architect** | アーキテクチャ設計・レビュー。高品質推論 | ソリューションアーキテクト |
| **security** | セキュリティ監査。OWASP Top 10、STRIDE脅威モデリング | CSO / セキュリティエンジニア |
| **docs** | ドキュメント生成・品質レビュー | テクニカルライター |

#### Tier 3: 非技術系（プロジェクトの目的に応じて）

| 目的 | 概要 | 想定ペルソナ |
|------|------|------------|
| **analysis** | データ分析、SQL、可視化、レポート生成 | データサイエンティスト |
| **marketing** | マーケティングコンテンツ、競合分析、戦略立案 | マーケティングストラテジスト |
| **research** | 自律学習、技術調査、知識ベース構築 | リサーチャー |
| **pm** | プロジェクト管理、タスク整理、スプリント計画 | プロジェクトマネージャー |

**各目的について確認する事項**:

- このプロジェクトで本当に必要か？（不要なら作らない）
- 既存の単一ハーネスでは不十分な理由
- 想定される利用頻度（高/中/低）
- 安全度レベル: strict（読取専用）/ standard（編集可）/ permissive（ほぼ全許可）
- 推奨モデル: opus（深い分析）/ sonnet（日常作業）/ haiku（軽量タスク）

### Phase 3: 技術基盤選定

各目的に対して、Claude Code / Codex CLIのどの技術基盤で実装するかを決定する。

#### 技術基盤選定マトリクス

| 目的の特性 | Claude Code側 | Codex CLI側 |
|-----------|-------------|-------------|
| **パス依存**（モノレポの領域別） | `.claude/rules/`(paths付き) + サブディレクトリCLAUDE.md | サブディレクトリAGENTS.md + `--cd` |
| **独立コンテキスト**（専門エージェント） | `.claude/agents/*.md`（ペルソナ+tools制限+model指定） | `[agents.*]` config.toml |
| **タスクトリガー**（定型作業） | `.claude/skills/`（paths, context:fork対応） | `.agents/skills/` + agents/openai.yaml |
| **設定切替**（安全度・モデル） | `settings.local.json` + シェルエイリアス | `[profiles.*]` config.toml + `--profile` |
| **バッチ/CI** | `claude -p` | `codex exec --ephemeral -p <profile>` |
| **常時適用ルール** | `.claude/rules/`(pathsなし) | AGENTS.mdセクション |

#### 各目的の推奨技術基盤

| 目的 | Claude Code | Codex CLI | 選定理由 |
|------|------------|-----------|---------|
| dev | 共通CLAUDE.md + settings.json | `[profiles.dev]` (workspace-write, on-request) | 日常利用はデフォルト設定ベース |
| review | `.claude/agents/reviewer.md`(Read,Grep,Glob限定) | `[profiles.review]` (read-only, untrusted) | 読取専用。独立ペルソナが有効 |
| test | `.claude/agents/test-runner.md`(haiku, Bash限定) | `[profiles.verify]` (workspace-write, untrusted) | 低コスト高頻度。ツール制限重要 |
| ci | `claude -p` | `[profiles.ci]` (workspace-write, never, ephemeral) | 非対話バッチ |
| architect | `.claude/agents/architect.md`(opus, Read限定) | `[profiles.architect]` (read-only, high reasoning) | 高品質推論。読取専用 |
| security | `.claude/agents/security.md`(context:fork) | `codex exec -p review` | 隔離実行。メインコンテキスト保全 |
| analysis | `.claude/agents/analyst.md`(memory:project) | `[agents.analyst]` | 独立ペルソナ。永続メモリで知識蓄積 |
| marketing | `.claude/skills/marketing/`(context:fork) | `.agents/skills/marketing/` | タスクトリガー。定型プロンプト |
| research | `.claude/agents/researcher.md`(Explore, memory) | `codex exec --ephemeral` | バックグラウンド調査。隔離実行 |

#### Codex固有の安全度マッピング

mapping/shared-concepts.mdの安全度レベルを各プロファイルに展開:

| 目的 | 安全度 | Codex approval_policy | Codex sandbox_mode |
|------|--------|----------------------|-------------------|
| review | strict | untrusted | read-only |
| dev | standard | on-request | workspace-write |
| test | standard | untrusted | workspace-write |
| ci | permissive | never | workspace-write |
| architect | strict | on-request | read-only |
| analysis | standard | on-request | workspace-write |

### Phase 4: 整合性設計 & 設計書出力

1. **共通レイヤーと分離レイヤーの境界決定**:
   - 共通CLAUDE.md（200行以内）: プロジェクト概要、ビルド/テストコマンド、全目的共通のルール
   - 共通AGENTS.md: 同上をCodex/他ツール向けに
   - 分離レイヤー: rules/(paths付き)、agents/、skills/、profiles
   - `docs/shared-instructions.md`パターン（mapping/shared-concepts.md参照）の導入判断

2. **目的間の競合検出**:
   - devとreviewで矛盾する権限設定がないか
   - pathsスコープの重複がないか（テストルールとフロントルールでの重複等）
   - Codexプロファイル間の一貫性

3. **ファイル構成計画の作成**:

```
target-project/
├── CLAUDE.md                          # 共通（200行以内、@import活用）
├── AGENTS.md                          # Codex/他ツール互換の共通指示
├── .claude/
│   ├── settings.json                  # 共通設定（permissions）
│   ├── rules/
│   │   ├── {目的}-rules.md            # 目的別ルール（paths付き）
│   │   └── common-rules.md            # 全目的共通ルール
│   ├── agents/
│   │   ├── {目的}.md                  # 目的別エージェント定義
│   │   └── ...
│   ├── skills/
│   │   ├── {目的}/SKILL.md            # 目的別スキル
│   │   └── ...
│   └── instructions/
│       └── common.md                  # @importされる共通指示
├── .codex/
│   └── config.toml                    # プロファイル定義
├── .agents/
│   └── skills/                        # Codex側スキル
├── {サブディレクトリ}/
│   ├── CLAUDE.md                      # 領域固有指示（モノレポ時）
│   └── AGENTS.md                      # 同上
└── docs/
    └── multi-harness-design.md        # この設計書
```

4. **設計書出力**: `docs/multi-harness-design.md` を生成。内容:
   - 目的カタログ（採用/不採用理由付き）
   - 各目的の技術基盤選定結果と理由
   - ファイル構成計画（manage-multi-harnessへの入力）
   - Claude/Codex間の対応表
   - CI/CDバッチ統合計画（ci目的がある場合）
   - 将来の拡張候補（不採用だが将来検討すべき目的）

## 既存スキルとの連携

- **create-harness**: Phase 2で「multi」選択時にこのスキルに委譲される
- **manage-multi-harness**: 設計書を受け取り、ファイル生成を実行する
- **research-kb**: 未知の技術やドメインが含まれる場合、research-kbでの調査を提案
- **patrol-docs**: 設計前にspecs/が最新か確認。古ければpatrol-docsの先行実行を推奨
- **sync-harness**: 設計にClaude/Codex両方が含まれる場合、sync-harnessとの連携を計画

## 注意事項

- ユーザー対話（Phase 2）は省略しない。全目的をAIが自動判断しない
- 「多様性は善」: 各目的の技術基盤選定でpros/consを明示
- 不要な目的は作らない。「全部入り」より「必要最小限から始めて育てる」
- 設計書は生成計画であり、実行はmanage-multi-harnessに委ねる（設計と実装の分離）
- specs/mapping/kb/は日々進化する。設計書に「根拠となったspecs/のバージョン」を記録
- プライベートプロジェクト名はPR本文やログに混入させない（匿名化）
- Codex exec失敗時はClaude単独で完遂する（Codex依存にしない）
- 非技術ドメインも躊躇なく設計対象にする。AIの活用範囲はコーディングに限らない
