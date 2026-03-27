---
name: "superpowers"
url: "https://github.com/obra/superpowers"
type: framework
tags: [multi-platform, skill-md-standard, claude-code, codex, hook-initialization, tdd]
stars: 115000
license: "MIT"
last_checked: "2026-03-27"
relevance: high
summary: "マルチプラットフォーム対応のエージェンティックスキルフレームワーク。SKILL.mdフロントマター標準を策定"
---

# superpowers 深掘り分析

- URL: https://github.com/obra/superpowers
- 作者: Jesse Vincent (@obra) / Prime Radiant
- ライセンス: MIT
- GitHub Stars: 107,000+（2026年3月時点）
- Anthropic公式Claude Codeプラグインマーケットプレイス掲載（2026年1月15日〜）
- 調査日: 2026-03-23

## 概要

superpowersは「コーディングエージェントのための完全なソフトウェア開発ワークフロー」を提供するエージェンティックスキルフレームワーク。コード生成ツールから「シニアAI開発者」への転換を掲げる。最大の特徴はマルチプラットフォーム対応とSKILL.mdフロントマター標準の策定。

Jesse Vincentは2025年10月のブログ記事「Superpowers: How I'm using coding agents in October 2025」で初期の思想を発表し、以降継続的に進化させている。

## マルチプラットフォームプラグインシステム

### 対応プラットフォーム

superpowersの最大の差別化要因は、単一のスキル定義から複数のAIコーディングプラットフォームをサポートする点:

| ディレクトリ | プラットフォーム | インストール方式 |
|-------------|----------------|----------------|
| `.claude-plugin/` | Claude Code | マーケットプレイス or 手動 |
| `.cursor-plugin/` | Cursor IDE | マーケットプレイス or `/add-plugin` |
| `.codex/` | Codex (OpenAI) | 手動（INSTALL.md参照） |
| `.opencode/` | OpenCode | 手動（リモートURLからフェッチ） |

### プラットフォームごとの統合方式

**Claude Code（主要ターゲット）**:
- 公式プラグインマーケットプレイス経由: `/plugin install superpowers@claude-plugins-official`
- `hooks/session-start` による自動初期化
- ネイティブツール検索によるスキル発見

**Codex**:
- ネイティブスキルディスカバリ: `~/.agents/skills/` を起動時にスキャン
- SKILL.mdフロントマターを解析してオンデマンドロード
- v4.2.0以降はシンボリックリンクベースのアプローチ

**Cursor**:
- プラグインマーケットプレイスまたは `/add-plugin superpowers`
- プラグインディレクトリ構造に準拠

**OpenCode**:
- 手動セットアップ（リモートURLからINSTALL.mdをフェッチ）
- ドキュメントは `docs/README.opencode.md`

## SKILL.md フロントマター標準

superpowersが事実上の標準として普及させたSKILL.mdフォーマット:

### 必須フィールド

```yaml
---
name: skill-name          # kebab-case、ディレクトリ名と一致
description: |            # CSO最適化されたトリガー説明（三人称）
  Describes what this skill does and when it should be invoked
---
```

### Markdown本文の標準セクション

1. **Overview** — 目的の簡潔な説明
2. **The Rule/Process** — ステップバイステップの手順（Mermaidダイアグラム可）
3. **Red Flags** — エージェントがスキルをスキップする際の一般的な合理化
4. **Skill Priority** — 複数スキルが該当する場合の優先度ガイダンス

### 通常ドキュメントとの違い

| 側面 | スキル | 通常ドキュメント |
|------|--------|----------------|
| 発見方式 | ツール検索可能 | 手動ブラウジング |
| 呼び出し | プラットフォームネイティブツール | 直接ファイルアクセス |
| 検証 | TDDで圧力テスト済み | 通常は未テスト |
| 強制力 | 必須チェック（1%ルール） | 任意参照 |

### Claude Search Optimization (CSO)

`description` フィールドはClaudeの意味検索の主要なサーフェス。「トリガーフォーカス」で記述し、ユーザーが検索しそうなキーワードを含める設計。これは通常のドキュメンテーションではなく、AIエージェントによる自動発見を前提とした設計。

## Hook ベース初期化

### session-start フック

superpowersの初期化は `hooks/session-start` スクリプトで行われる:

1. **トリガー**: Claude Codeのセッション開始、`clear`、`compact` イベント
2. **処理内容**:
   - `lib/initialize-skills.sh` を呼び出してスキルリポジトリのライフサイクルを管理（クローン/更新）
   - `skills/using-superpowers/SKILL.md` の内容をエージェントの初期プロンプトに注入
3. **POSIX安全**: シェルスクリプトで実装、依存関係なし

### 初期化フロー

```
セッション開始
  → hooks/session-start 実行
    → lib/initialize-skills.sh（gitリポジトリ更新）
    → using-superpowers SKILL.md を読み込み
      → エージェントにスキル使用方法を注入
```

## シンボリックリンク戦略

### Codexでの実装

```
~/.agents/skills/superpowers/ → ~/.codex/superpowers/skills/
```

- v4.2.0以降、廃止されたブートストラップCLIに代わるアプローチ
- Codexは `~/.agents/skills/` を起動時にスキャンし、SKILL.mdフロントマターに基づいてスキルをロード
- インストールは「クローン + シンボリックリンク」で完了

### 利点

- ファイルの重複なし（単一ソース）
- `git pull` で全プラットフォームのスキルが一括更新
- 集中管理しつつ各プラットフォームのディスカバリ機構に準拠

## ワークフロー7フェーズ

superpowersが定義する開発ワークフロー:

| フェーズ | スキル | 説明 |
|---------|--------|------|
| 1. Brainstorming | brainstorming | 会話を通じて要件を洗練、代替案を探索、セクションごとに検証 |
| 2. Git Worktrees | using-git-worktrees | 隔離された開発ブランチを作成、セットアップ実行、テストベースライン確認 |
| 3. Planning | writing-plans | 作業を小タスク（各2-5分）に分解。正確なファイルパス、コード、検証手順 |
| 4. Execution | （サブエージェント/バッチ処理） | タスク実行 |
| 5. TDD | test-driven-development | RED-GREEN-REFACTORサイクルを強制 |
| 6. Code Review | code-review | 仕様に対する検証 |
| 7. Branch Completion | branch-completion | マージ/PR決定ワークフロー |

## エコシステム

superpowersは複数のリポジトリで構成されるエコシステム:

| リポジトリ | 目的 |
|-----------|------|
| `obra/superpowers` | コアフレームワーク |
| `obra/superpowers-skills` | コミュニティ編集可能なスキル集 |
| `obra/superpowers-marketplace` | キュレーションされたプラグインマーケットプレイス |
| `obra/superpowers-chrome` | ChromeブラウザDevToolsプロトコル制御 |
| `obra/superpowers-developing-for-claude-code` | Claude Code開発用スキル |
| `obra/superpowers-lab` | 実験的スキル（新技術・ツール） |

## 設計哲学

superpowersの基本思想:

1. **テスト駆動開発**: RED-GREEN-REFACTORを最優先
2. **体系的プロセス**: 自由度より一貫性
3. **複雑さの削減**: タスクを2-5分の単位に分解
4. **証拠ベースの検証**: 仮定ではなく実証
5. **段階的精緻化**: Brainstormingから始めて段階的に具体化

## 強みと弱み

### 強み

- **マルチプラットフォーム対応が唯一無二**: Claude Code / Codex / Cursor / OpenCodeの4プラットフォームをネイティブサポート
- **SKILL.mdフロントマター標準**: 事実上の業界標準を策定
- **公式マーケットプレイス掲載**: Anthropic公式の品質保証
- **シンボリックリンク戦略**: 効率的なスキル配布と更新
- **TDDファースト**: コード品質への強いコミットメント
- **エコシステムの分離**: コア/スキル/マーケットプレイス/実験が明確に分離
- **Hookベース初期化**: 宣言的で拡張可能

### 弱み

- **Claude Code偏重**: 他プラットフォームは「も対応」レベルで、深い統合はClaude Code中心
- **スキル数が限定的**: OpenClawの13,700+やgstackの28に比べ、コアスキルは少数精鋭
- **学習曲線**: 7フェーズワークフロー + マルチプラットフォーム設定の理解に時間がかかる
- **シンボリックリンク依存**: Windows環境での互換性に注意が必要
- **エコシステムの分散**: 複数リポジトリの管理が必要

## 参考リンク

- GitHub: https://github.com/obra/superpowers
- ブログ記事: https://blog.fsck.com/2025/10/09/superpowers/
- DeepWiki: https://deepwiki.com/obra/superpowers
- Claude Plugin: https://claude.com/plugins/superpowers
- ガイド: https://www.pasqualepillitteri.it/en/news/215/superpowers-claude-code-complete-guide
