---
name: "claude-peers-mcp"
type: takeaways
tags: [broker-daemon, scoped-peer-discovery, auto-summary, agent-teams]
last_checked: "2026-03-27"
adoption_summary: "ツール統合は不採用、Brokerデーモン・スコープ付きピア発見・自動サマリーの3設計パターンを参考採用"
top_patterns:
  - "Brokerデーモン自動起動パターン"
  - "スコープ付きピア発見（machine/directory/repo）"
  - "自動コンテキストサマリー生成"
---

# claude-peers-mcp — harness-harnessへの採用判断

最終更新: 2026-03-26

---

## 総合判定: reference（参考）

ツール自体の統合は不要。設計パターンを3件抽出して活用する。

---

## 判定理由

### 不採用要素

1. **公式Agent Teamsとの機能重複**: Agent Teams（実験的）が構造化タスク管理+メッセージングを公式に提供。サードパーティMCPに依存する合理性が低い
2. **ライセンス未明示**: LICENSEファイルなし。テンプレートでの推奨・配布に法的リスク
3. **成熟度不足**: 作成から5日、コミット5件、Issue 16件中0件クローズ。メッセージロスト問題が複数報告（Issue #2, #8, #9, #11）
4. **Bun限定**: ランタイムがBun前提。Node.js/npmエコシステムとの互換性なし
5. **Windows未対応**: Issue #1, #13で要望あり。harness-harnessのMac/Windows両対応方針に反する
6. **チャネルフラグ**: `--dangerously-load-development-channels`が必要。プロダクション利用に不適
7. **セキュリティ**: 認証・レート制限なし。ローカル前提とはいえ、メッセージ注入が容易

### 採用する設計パターン（3件）

#### 1. Brokerデーモン自動起動パターン（中優先度）

**概要**: MCPサーバーが共有Brokerをdetachedプロセスとして自動起動し、サーバー終了後も存続させるパターン

**活用先**: harness-harnessのMCPサーバーテンプレート（状態共有が必要なマルチインスタンスMCP向け）

**実装要素**:
- Brokerヘルスチェック -> 不在時に自動spawn
- detachedプロセスとしてバックグラウンド起動
- PIDベースの死活監視（`process.kill(pid, 0)`）
- SQLiteによる軽量永続化

**Pros**: ゼロ設定で分散状態管理が可能。MCPサーバーの制約（stdio接続、ステートレス性）を補完
**Cons**: プロセス管理の複雑さ。ポート競合リスク。Windows対応要追加

#### 2. スコープ付きピア発見パターン（中優先度）

**概要**: machine / directory / git-repository の3レベルスコープでピアをフィルタリングする設計

**活用先**: Agent Teamsやマルチエージェント連携のテンプレート設計。モノレポでのエージェント配置ガイド

**実装要素**:
- `cwd`ベースのディレクトリスコープ
- `git_root`ベースのリポジトリスコープ
- マシン全体の全ピア一覧

**Pros**: モノレポで特定パッケージのエージェントだけを発見可能。Agent Teamsのチーム作成時のスコープ設計に応用可
**Cons**: リモートマシン対応なし（claude-peersの制約であり、パターン自体は拡張可能）

#### 3. 自動コンテキストサマリーパターン（低優先度）

**概要**: エージェント起動時にディレクトリ・gitブランチ・ファイル情報からLLMでコンテキストサマリーを自動生成

**活用先**: Agent Teams/マルチエージェントテンプレートの初期コンテキスト設定。`initialPrompt`フロントマターとの組み合わせ

**Pros**: ピア間のコンテキスト共有が自動化。nanoモデル使用でコスト最小
**Cons**: 外部API依存（OpenAI API Key要求）。harness-harness方針としてはClaude完結が望ましい

---

## Agent Teams連携への示唆

claude-peersの「アドホックP2P」とAgent Teamsの「構造化階層」は補完的。harness-harnessとしては以下の使い分けをテンプレート化すべき:

| シナリオ | 推奨アプローチ |
|----------|---------------|
| 構造化タスク（機能開発、テスト） | Agent Teams（リード+チームメイト） |
| 緩い通知（ファイル変更通知、進捗共有） | MCP P2Pパターン or hooks |
| peer review自動化 | Agent Teams + TeammateTool |
| モノレポ横断作業 | Agent Teams + スコープ付き発見パターン |

## マルチエージェント協調パターンの整理

claude-peers調査を通じて、現時点のClaude Codeマルチエージェント協調は3層に分類できる:

1. **ビルトイン層**: サブエージェント（Agent tool）、Agent Teams（実験的）
2. **MCP拡張層**: claude-peers-mcp、claude-code-by-agents等のサードパーティMCP
3. **外部管理層**: claude-squad（tmux+worktree）、ruflo（スワーム）

harness-harnessとしては**ビルトイン層を基本とし、パターンのみMCP拡張層から抽出**する方針が妥当。

---

## 今後のアクション

| 優先度 | アクション | 対象 |
|--------|-----------|------|
| 中 | Brokerデーモンパターンをテンプレートメモに追加 | templates/ |
| 中 | Agent Teams使い分けガイドの作成検討 | docs/ or kb/ |
| 低 | 自動サマリーパターンの`initialPrompt`活用案の検討 | specs/claude/ |
| 定期 | claude-peers-mcpの成熟度再評価（ライセンス追加、Issue対応状況） | kb/external/ |
