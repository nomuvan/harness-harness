# superpowers からの知見と採用判断

調査日: 2026-03-23
対象: https://github.com/obra/superpowers

## 方針

superpowersはharness-harnessと最も近い問題領域を扱っている（マルチプラットフォームのAIコーディングアシスタント向けスキル/設定管理）。特にSKILL.mdフロントマター標準とマルチプラットフォーム対応は、harness-harnessの `mapping/` 設計に直接的な示唆を与える。ただし、superpowersは「フレームワーク」であり、harness-harnessは「ハーネスの母艦」であるという役割の違いを意識する。

---

## 1. マルチプラットフォームプラグインディレクトリ構造

**判断: 採用**

### 理由
harness-harnessは「Claude Code CLI (.claude), Codex CLI (.codex)」を対象としており、superpowersの `.claude-plugin/` / `.codex/` といったプラットフォーム別ディレクトリ構造は直接的に参考になる。将来的にCursor等への対応も見据えて、この構造を採用すべき。

### 適用方法
- `templates/` の構造をプラットフォーム別に整理:
  ```
  templates/
    claude/    → .claude/ 配下に配置される設定群
    codex/     → .codex/ 配下に配置される設定群
    shared/    → 両プラットフォーム共通のスキル/設定
  ```
- `mapping/` のClaude⇔Codex変換ルールに、ディレクトリ構造の変換も含める
- superpowersの `.cursor-plugin/` / `.opencode/` 構造を将来拡張の参考として記録

### Pros
- プラットフォーム固有の要件に対応しつつ共通部分を共有
- superpowersの実績ある構造に準拠
- 将来のプラットフォーム追加が容易

### Cons
- プラットフォーム数が増えるとディレクトリ構造が肥大化
- プラットフォーム間の差異の管理コスト

---

## 2. SKILL.md フロントマター標準

**判断: 採用**

### 理由
superpowersが策定したSKILL.mdフロントマターは、OpenClaw・gstackとも共通する事実上の標準。harness-harnessが生成するスキルテンプレートもこの標準に準拠すべき。

### 適用方法
- harness-harnessのテンプレートで生成するスキルファイルは全てSKILL.md形式
- 必須フィールド: `name`（kebab-case）、`description`（CSO最適化）
- 推奨セクション: Overview、Process、Red Flags、Skill Priority
- `specs/` にSKILL.mdフォーマット仕様書を追加

### Pros
- 3大プロジェクト（OpenClaw / gstack / superpowers）共通の標準
- AIエージェントによる自動発見に最適化
- 人間にもAIにも読みやすいMarkdown

### Cons
- フロントマターのフィールドがプロジェクトごとに微妙に異なる
- CSO最適化は試行錯誤が必要

---

## 3. Claude Search Optimization (CSO) の概念

**判断: 採用**

### 理由
SKILL.mdの `description` フィールドをAIエージェントの意味検索に最適化するという概念は、harness-harnessが生成するハーネスの品質を直接的に向上させる。

### 適用方法
- テンプレートのSKILL.md生成時に、CSOガイドラインを提供
- description のベストプラクティス:
  - 三人称で記述
  - トリガーフォーカス（「いつ使うか」を明示）
  - ユーザーが検索しそうなキーワードを含める
- `docs/` にCSOガイドラインを記載

### Pros
- AIエージェントがスキルを適切に発見・適用できる
- 人間の明示的なスキル指定が不要になる

### Cons
- 最適なdescriptionの書き方にはノウハウが必要
- プラットフォームごとに検索アルゴリズムが異なる可能性

---

## 4. Hook ベース初期化（session-start）

**判断: 採用**

### 理由
Claude Codeのセッション開始時にハーネスの設定を自動注入する仕組みは、harness-harnessのテンプレートに標準装備すべき。superpowersの `hooks/session-start` はPOSIX安全で依存関係なしの実装であり、参考になる。

### 適用方法
- テンプレートに `hooks/session-start` を含める
- 処理内容:
  1. プロジェクト固有のコンテキスト（AGENTS.md等）の存在確認
  2. スキルディレクトリの最新化（git pull）
  3. 初期プロンプトへのコンテキスト注入
- POSIX準拠シェルスクリプトで実装（Mac/Windows両対応の原則に配慮、Windowsはgit bashを想定）

### Pros
- セッション開始時に自動でハーネスがアクティブになる
- 宣言的で拡張可能
- superpowersの実績あるパターン

### Cons
- Hookの実行オーバーヘッド
- Windows環境でのPOSIXスクリプト互換性
- エラーハンドリングの設計が必要

---

## 5. シンボリックリンク戦略によるスキル配布

**判断: 検討**

### 理由
グローバルにインストールしたスキルをシンボリックリンクで各プラットフォームのディスカバリディレクトリに配置する戦略は効率的。ただし、Windows環境でのシンボリックリンクは管理者権限や設定が必要なため、harness-harnessの「Mac/Windows両対応」原則との兼ね合いを検討する必要がある。

### 適用方法
- macOS/Linux: シンボリックリンクを使用
  ```
  ~/.agents/skills/harness/ → ~/.harness-harness/skills/
  ```
- Windows: ジャンクションまたはコピーによるフォールバック
- `scripts/` にプラットフォーム判定付きのリンク/コピースクリプトを用意

### Pros
- ファイル重複なし、単一ソースで管理
- git pullで全プラットフォームのスキルが一括更新

### Cons
- Windowsでのシンボリックリンク問題
- ユーザーの理解が必要（「なぜリンクなのか」）
- パーミッションの問題が発生しうる

---

## 6. 7フェーズワークフロー（Brainstorming → Branch Completion）

**判断: 検討**

### 理由
superpowersの7フェーズとgstackの7フェーズは類似しているが微妙に異なる。harness-harnessは両方を参考にしつつ、ユーザーが選択可能なワークフローテンプレートとして提供すべき。

### 比較

| superpowers | gstack | 共通点 |
|-------------|--------|--------|
| Brainstorming | Think (Office Hours) | 要件の洗練 |
| Git Worktrees | — | superpowers固有 |
| Planning | Plan (CEO/Eng/Design Review) | 作業分解 |
| Execution | Build | 実装 |
| TDD | Test (QA/Browse) | テスト |
| Code Review | Review | レビュー |
| Branch Completion | Ship/Land/Canary | リリース |

### 適用方法
- 「多様性は善」: 両方のワークフローをテンプレートの選択肢として提供
- superpowers型: TDDファースト、Git Worktreeベースの隔離開発
- gstack型: ロールベース、構造化スプリント
- ユーザーがプロジェクトの性質に応じて選択

### Pros
- 選択肢を提供することでユーザーの多様なニーズに対応
- 両プロジェクトの長所を比較検討できる

### Cons
- 2つのワークフローの管理コスト
- 選択肢が多すぎると混乱を招く

---

## 7. エコシステムの分離（コア / スキル / マーケットプレイス / 実験）

**判断: 採用（設計原則として）**

### 理由
superpowersがコア/スキル/マーケットプレイス/実験を別リポジトリに分離している設計は、harness-harnessの将来的なスケーラビリティに参考になる。

### 適用方法
- 現時点ではモノリポで十分だが、成長に伴い以下の分離を検討:
  - コア（テンプレートエンジン、変換ルール）
  - テンプレート集（コミュニティ貢献可能）
  - 実験的テンプレート
- `kb/` にこの分離戦略を記録しておく

---

## 8. Git Worktree活用

**判断: 検討**

### 理由
superpowersの `using-git-worktrees` スキルは、隔離された開発環境を作成する手法として有用。harness-harnessのテンプレートに「Git Worktreeベース開発」オプションを含められる。

### 適用方法
- 中〜大規模プロジェクト向けテンプレートにGit Worktreeセットアップを含める
- 小規模プロジェクトでは不要（過剰）
- 段階的開示: 必要になったら有効化

### Pros
- ブランチ切り替えなしの並行開発
- テストベースラインの確保

### Cons
- Git Worktreeを理解していないユーザーには混乱
- ディスク容量の消費

---

## まとめ

| 項目 | 判断 | 優先度 |
|------|------|--------|
| マルチプラットフォームディレクトリ構造 | 採用 | 高 |
| SKILL.md フロントマター標準 | 採用 | 高 |
| Claude Search Optimization (CSO) | 採用 | 中 |
| Hook ベース初期化 | 採用 | 高 |
| シンボリックリンク戦略 | 検討 | 中 |
| 7フェーズワークフロー | 検討 | 中 |
| エコシステム分離 | 採用（設計原則） | 低 |
| Git Worktree活用 | 検討 | 低 |

## 3プロジェクト横断比較

| 特性 | OpenClaw | gstack | superpowers | harness-harnessへの示唆 |
|------|---------|--------|-------------|----------------------|
| 主目的 | パーソナルAIアシスタント | 仮想開発チーム | 開発ワークフロー | ハーネス管理の母艦 |
| スキル数 | 53+バンドル、13,700+コミュニティ | 28 | 少数精鋭 | テンプレートとして提供 |
| プラットフォーム | 20+メッセージングチャネル | Claude Code中心 | Claude/Codex/Cursor/OpenCode | Claude Code + Codex |
| スキル形式 | SKILL.md (YAML frontmatter) | SKILL.md (YAML frontmatter) | SKILL.md (YAML frontmatter) | SKILL.md標準を採用 |
| 安全機構 | DMペアリング | /careful, /freeze, /guard | TDD強制 | ガードレール + TDD |
| インストール | npm + daemon | git clone + setup | マーケットプレイス/手動 | 選択可能に |
| 哲学 | ローカルファースト | プロセス駆動 | テスト駆動 | 多様性は善 |
