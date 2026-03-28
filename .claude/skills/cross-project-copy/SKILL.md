---
name: cross-project-copy
description: |
  管理対象プロジェクト間でハーネス設定（skills/hooks/rules）を相互コピー補完するスキル。
  汎用パターンを検出し、未導入プロジェクトへの適用を提案・実行する。
  「プロジェクト間コピーして」「ハーネス補完して」「他のプロジェクトのskillを入れて」で起動。
---

# cross-project-copy スキル

管理対象プロジェクト間で汎用的なハーネス設定を検出・コピー・補完する。

## 概要

各プロジェクトのハーネスには汎用パターン（全プロジェクトで有用）とドメイン固有パターン（特定プロジェクトのみ）が混在する。このスキルは汎用パターンを検出し、未導入のプロジェクトへの適用を提案する。

## 手順

### 1. 管理対象プロジェクトの収集

private/registry/projects.md からプロジェクト一覧を取得。

```bash
cat private/registry/projects.md
```

### 2. 各プロジェクトのハーネス棚卸し

各プロジェクトの以下を列挙:

```bash
PROJECT_PATH="<対象プロジェクトのパス>"
echo "=== Skills ==="
ls "$PROJECT_PATH/.claude/skills/" 2>/dev/null
ls "$PROJECT_PATH/.codex/skills/" 2>/dev/null
echo "=== Hooks ==="
ls "$PROJECT_PATH/.claude/hooks/" 2>/dev/null
echo "=== Rules ==="
ls "$PROJECT_PATH/.claude/rules/" 2>/dev/null
echo "=== Commands ==="
ls "$PROJECT_PATH/.claude/commands/" 2>/dev/null
```

### 3. 汎用性の判定

各ファイルを読み取り、以下の基準で汎用性を判定:

| 汎用性 | 基準 | 例 |
|--------|------|-----|
| ★★★★★ | ドメイン知識ゼロで動作。コピーそのままで機能 | save-prompt hooks, notify-completion, skill-creator |
| ★★★★☆ | 軽微なカスタマイズで動作。パス・ツール名の変更程度 | block-global-changes (ブロック対象変更), pr-review-cycle |
| ★★★☆☆ | 骨格は汎用だが中身のカスタマイズが必要 | autonomous-task (デプロイフェーズ), session-context |
| ★★☆☆☆ | 特定技術スタック依存 | coding-standards (Java/Rust固有) |
| ★☆☆☆☆ | 完全にドメイン固有 | backtest-strategy-pdca, yaml-frontmatter |

### 4. 差分レポート生成

プロジェクト間の比較マトリクスを生成:

```
| パターン              | project-A | project-B | 汎用性 |
|----------------------|-----------|-----------|--------|
| save-prompt hooks    | ✅        | ❌        | ★★★★★  |
| block-global-changes | ✅        | ❌        | ★★★★★  |
| session-context hook | ✅        | ❌        | ★★★★★  |
| pr-review-cycle      | ✅        | ❌        | ★★★★☆  |
| skill-creator        | ✅        | ❌        | ★★★★★  |
| autonomous-task      | ✅        | ❌        | ★★★☆☆  |
```

### 5. コピー提案

★★★★☆以上のパターンで、一方のプロジェクトにあり他方にないものを提案:

```
=== コピー提案 ===
[project-A → project-B]
1. hooks/save-prompt.sh + .ps1 (★★★★★) — そのままコピー
2. hooks/block-global-changes.sh (★★★★★) — ブロック対象リストの調整が必要
3. hooks/session-context.sh (★★★★★) — そのままコピー
4. skills/pr-review-cycle/ (★★★★☆) — GitHub前提。そのままコピー
5. skills/skill-creator/ (★★★★★) — そのままコピー
```

### 6. 実行（ユーザー確認後）

提案をユーザーに提示し、承認されたもののみ実行:

1. ソースプロジェクトからファイルをコピー
2. ★★★★☆のものはカスタマイズポイントを特定し修正
3. .codex/skills/ にも同等のスキルがあれば併せてコピー
4. 対象プロジェクトでworktree作成→コミット→PR作成

### 7. カスタマイズガイド（★★★★☆のパターン）

#### block-global-changes.sh
- ブロック対象コマンドをプロジェクトの技術スタックに合わせる
- 例: Pythonプロジェクト → `pip install --user`, `conda install`を追加
- 例: Node.jsプロジェクト → `npm install -g`, `yarn global add`を追加

#### pr-review-cycle
- GitHub以外のVCS → `gh` コマンドを対応CLIに変更
- claude-pr-review以外のCIレビューbot → コメント解析ロジック変更

#### autonomous-task
- Phase 1.5（デプロイ前検証）: プロジェクトのデプロイ方式に合わせる
- Phase 5（デプロイ）: デプロイスクリプトをプロジェクト固有に変更
- Phase 6（評価）: 評価基準をプロジェクトに合わせる

## 注意事項

- コピー前に必ずソースファイルの最新版を読み取る（古い版のコピーを防ぐ）
- ドメイン固有パターン（★★☆☆☆以下）はコピーしない
- settings.json のpermissionsはgitignored（settings.local.json）のため手動対応をユーザーに案内
- Claude/Codex両方のスキルを同時にコピーする（片方だけにならないよう）
