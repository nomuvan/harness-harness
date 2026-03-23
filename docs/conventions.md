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

並列ブランチ作業にはgit worktreeを活用する。

- 独立したブランチ作業（Claude計画/Codex計画の並列策定等）ではworktreeで分離
- worktreeのパスは `../<リポジトリ名>-wt-<ブランチ短縮名>/` とする
  - 例: `../harnesss-harness-wt-codex-plan/`
- worktree内の作業完了後、mainへマージしてworktreeを削除
- Claude Codeのエージェントも `isolation: "worktree"` で独立worktreeを活用可能

### 利点

- ブランチ切り替え不要で並列作業可能
- エージェント同士のファイル競合を防止
- Claude計画とCodex計画を同時進行できる

## コミットメッセージ

- 日本語OK
- 1行目: 変更の要約（50文字以内目安）
- 空行
- 本文: 必要に応じて詳細
