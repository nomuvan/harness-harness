# 規約

## ファイル命名

- ドキュメント: kebab-case（例: `best-practices.md`）
- ディレクトリ: kebab-case（例: `harness-lifecycle/`）
- スクリプト: kebab-case（例: `codex-bridge.sh`）
- テンプレート: 元ファイル名 + `.tmpl`（例: `CLAUDE.md.tmpl`）

## ドキュメント構成

- 各ドキュメントの冒頭に `# タイトル` と1行の概要
- 見出しは `##` から開始（`#` はタイトルのみ）
- 箇条書きで簡潔に。長文よりリスト
- コード例は必要最小限

## kb/ ナレッジベース

- `_index.md`: 調査対象のレジストリ。name, URL, last-checked, status を記録
- `analysis.md`: 生の分析結果。構造、設計原則、パターン
- `takeaways.md`: 行動可能な知見。何を採用/不採用にしたか、理由付き
- `changelog.md`: 日付付きの変更ログ

## specs/ 仕様書

- 公式ドキュメントの端的かつ網羅的な要約
- 本家リンクを併記して詳細参照を可能に
- 更新日を明記

## ADR（設計判断記録）

```
# ADR-NNN: タイトル

## ステータス
承認 / 却下 / 保留

## コンテキスト
何が問題だったか

## 決定
何をどう決めたか

## 理由
なぜその決定をしたか

## 影響
何が変わるか
```

## git worktree

mainは司令塔（統合・監視）。日常の編集作業はworktreeで行う。

### 2つのworktree方式

| 方式 | 作成方法 | パス | 用途 |
|------|---------|------|------|
| Claude Code内 | `EnterWorktree` ツール | `.claude/worktrees/<name>/` | harness-harness自身の作業 |
| 手動/Codex | `git worktree add` | `../<リポジトリ名>-wt-<ブランチ短縮名>/` | 対象プロジェクト変更、Codex実行 |

### Claude Code方式（EnterWorktree）

- harness-harness自身のfeature作業、research-kb調査、patrol-docs更新に使用
- `EnterWorktree(name: "research-deerflow")` → 作業 → `ExitWorktree(action: "remove")`
- サブエージェントは `isolation: "worktree"` で独立worktree実行可能

### Codex CLI方式（外側で作って--cdで対象化）

- Codexにworktreeを「作らせる」のではなく「外側で作ったworktreeを作業場にする」
- Git操作は外側、編集はCodex（`workspace-write`では`.git`が読取専用のため）

```bash
git worktree add ../harnesss-harness-wt-research-xxx -b research/xxx origin/main
git -C ../harnesss-harness-wt-research-xxx submodule update --init --recursive
codex exec --cd ../harnesss-harness-wt-research-xxx --profile author "タスク"
# 完了後
git worktree remove ../harnesss-harness-wt-research-xxx
```

### 運用ルール

- 1タスク1worktreeを原則にする
- `research/*` は1調査テーマ=1worktree
- Claude/Codexクロスレビューは実装worktreeとレビューworktreeを分ける
- mainでは編集しない。worktree管理・比較・最終マージのみ
- worktree作成後、`private/` が必要なら `git submodule update --init --recursive`
- 作業完了後はmainへマージしてworktreeを削除

### 利点

- ブランチ切り替え不要で並列作業可能
- エージェント同士のファイル競合を防止
- Claude/Codex並行作業が自然にできる
- 中断してもmainが常にクリーン

## コミットメッセージ

- 日本語OK
- 1行目: 変更の要約（50文字以内目安）
- 空行
- 本文: 必要に応じて詳細
