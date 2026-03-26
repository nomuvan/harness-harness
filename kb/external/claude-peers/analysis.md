# claude-peers-mcp 深掘り分析

最終更新: 2026-03-26

---

## 1. 基本情報

| 項目 | 内容 |
|------|------|
| 正式名称 | claude-peers-mcp |
| URL | https://github.com/louislva/claude-peers-mcp |
| 作者 | Louis Arge (louislva) |
| ライセンス | 明示なし（リポジトリにLICENSEファイルなし） |
| GitHub Stars | 1,249 (2026-03-26時点) |
| Forks | 117 |
| Open Issues | 16 |
| 言語 | TypeScript 100% |
| ランタイム | Bun |
| 作成日 | 2026-03-21 |
| 最終push | 2026-03-21 |
| リポジトリサイズ | 28KB |
| 依存関係 | @modelcontextprotocol/sdk ^1.27.1, @types/bun (dev), TypeScript ^5 (peer) |

## 2. 作者プロフィール

Louis Arge (louislva) はAI/ML系の個人開発者。主要プロジェクトにSkyline（Bluesky用カスタムアルゴリズム、115 Stars）、DeepMind Perceiver実装（63 Stars）がある。claude-peers-mcpが最も注目を集めたプロジェクト。

## 3. 概要

Claude Codeの複数インスタンス間でアドホックなピアツーピアメッセージングを可能にするMCPサーバー。中央オーケストレーターなしで、同一マシン上のClaude Codeセッションが相互発見・直接通信できる。

**コアコンセプト**: 複数のClaude Codeを並行起動して作業すると、エージェントA がインターフェースを変更してもエージェントBは知らない、というコーディネーション問題が発生する。claude-peersはこれを軽量なメッセージバスで解決する。

## 4. アーキテクチャ

### 4.1 コンポーネント構成

```
┌─────────────────────────────────┐
│  Broker (localhost:7899)        │
│  - Bun.serve() HTTP サーバー    │
│  - bun:sqlite 永続化            │
│  - 30秒ごとの死活監視           │
└───────┬──────────┬──────────┬───┘
        │          │          │
   MCP Server A  MCP Server B  MCP Server C
   (stdio)       (stdio)       (stdio)
        │          │          │
   Claude Code A  Claude Code B  Claude Code C
```

### 4.2 データフロー

1. **登録**: 各Claude Codeセッション起動時にMCPサーバーがBrokerに`/register`（8文字ランダムID発行）
2. **発見**: `list_peers`ツールでスコープ指定（machine/directory/repo）してピア一覧取得
3. **送信**: `send_message`でBroker経由でメッセージをキューイング
4. **受信**: 1秒間隔のポーリング + MCPチャネルプロトコルによるプッシュ配信
5. **死活監視**: 15秒間隔のハートビート + Broker側30秒間隔の`process.kill(pid, 0)`チェック

### 4.3 SQLiteスキーマ

**peers テーブル**:
- id (TEXT PK) / pid (INTEGER) / cwd (TEXT) / git_root (TEXT, nullable) / tty (TEXT)
- summary (TEXT) / registered_at (TEXT) / last_seen (TEXT)

**messages テーブル**:
- id (INTEGER PK AUTOINCREMENT) / from_id, to_id (TEXT, FK)
- text (TEXT) / sent_at (TEXT) / delivered (INTEGER, default 0)

### 4.4 チャネルプロトコル

MCPの`notifications/claude/channel`を使用してリアルタイムプッシュ配信:
```typescript
await mcp.notification({
  method: "notifications/claude/channel",
  params: { content, meta: { from_id, from_summary, from_cwd, sent_at } }
})
```

**注意**: チャネル機能には`--dangerously-load-development-channels`フラグが必要。チャネル未使用時は`check_messages`による手動ポーリングにフォールバック。

## 5. 主要機能

### 5.1 MCPツール（4種）

| ツール | 機能 | 引数 |
|--------|------|------|
| `list_peers` | ピア発見（スコープ: machine/directory/repo） | scope, exclude_self |
| `send_message` | メッセージ送信 | to_id, text |
| `set_summary` | 作業コンテキスト設定（1-2文） | summary |
| `check_messages` | 手動メッセージポーリング | なし |

### 5.2 CLIツール（4種）

| コマンド | 機能 |
|----------|------|
| `bun cli.ts status` | Brokerステータス + 全ピア詳細 |
| `bun cli.ts peers` | ピア一覧（簡易版） |
| `bun cli.ts send <id> <msg>` | 外部からメッセージ注入 |
| `bun cli.ts kill-broker` | Brokerプロセス終了 |

### 5.3 自動サマリー

`OPENAI_API_KEY`設定時、起動時にgpt-5.4-nanoでディレクトリ・gitブランチ・ファイルからコンテキストサマリーを自動生成。未設定時は`set_summary`で手動設定。

## 6. セキュリティ評価

| 項目 | 評価 | 備考 |
|------|------|------|
| ネットワーク | localhost限定 | 127.0.0.1バインド |
| 認証 | なし | 同一マシン前提 |
| レート制限 | なし | |
| SQLインジェクション | 対策済み | Prepared statements使用 |
| 入力バリデーション | 最低限 | 型チェックのみ |
| プロセス分離 | あり | Broker detachedプロセス |

**リスク**: 同一マシン上の悪意あるプロセスが任意のメッセージを注入可能。ローカル開発環境では許容範囲だが、共有サーバーでは危険。

## 7. 成熟度評価

| 指標 | 評価 | 理由 |
|------|------|------|
| コード品質 | B | 簡潔で読みやすいが、エラーハンドリングが薄い |
| テスト | D | テストスクリプトはあるが実質的なテストコード不明 |
| ドキュメント | B | READMEは充実。CLAUDE.mdで開発ガイドあり |
| 安定性 | C | 5日間でコミット5件のみ。Issue 16件中0件クローズ |
| Windows対応 | 未対応 | Issue #1, #13で要望あり |
| メッセージ信頼性 | C | チャネル未使用時のメッセージロスト問題（Issue #2, #8, #9, #11） |
| コミュニティ | 初期段階 | PRマージ実績なし。Issue対応遅延 |

## 8. 公式Agent Teamsとの比較

| 観点 | claude-peers-mcp | Agent Teams (公式) |
|------|-----------------|-------------------|
| ステータス | サードパーティMCP | 公式実験的機能 |
| 有効化 | MCP追加 + チャネルフラグ | 環境変数1つ |
| トポロジー | フラット（P2P） | 階層（リード + チームメイト） |
| 発見 | 動的（Broker経由） | 静的（リードが作成） |
| メッセージング | アドホック任意方向 | 構造化（message/broadcast/shutdown） |
| タスク管理 | なし | 共有タスクリスト（依存関係対応） |
| 永続化 | SQLite | ファイルシステム |
| スコープ | マシン/ディレクトリ/リポジトリ | チーム単位 |
| 依存関係 | Bun + MCP SDK | なし（ビルトイン） |
| ユースケース | 緩い協調・通知 | 構造化されたチーム作業 |

**判定**: Agent Teamsが構造化タスク管理を提供するのに対し、claude-peersは軽量なアドホック通信に特化。両者は補完的だが、Agent Teamsの方が公式サポートと成熟度で優位。

## 9. 類似ツール比較

| ツール | Stars | 言語 | アプローチ | 特徴 |
|--------|-------|------|-----------|------|
| **claude-peers-mcp** | 1,249 | TS | MCPメッセージバス | P2Pアドホック通信、Broker+SQLite |
| **claude-squad** | 6,639 | Go | tmux+worktreeマネージャー | 複数エージェントのセッション管理TUI、AGPL-3.0 |
| **Agent Teams (公式)** | - | - | ビルトイン | リード+チームメイト階層、共有タスクリスト |
| **ruflo** | 26,742 | TS | スワームオーケストレーション | 60+エージェント、170+ MCPツール、MIT |
| **claude-code-by-agents** | 816 | TS | デスクトップ+API | @mentionベースの協調、ローカル/リモート対応、MIT |

### ポジショニング

- **claude-peers**: 最も軽量。既存セッション間の「おしゃべり」レイヤー。オーケストレーション不要な場面向き
- **claude-squad**: セッション管理に特化。並行作業のUIマネージャー。メッセージングなし
- **Agent Teams**: 公式の構造化協調。タスク依存関係、品質ゲート付き
- **ruflo**: 最も重厚なフレームワーク。エンタープライズ向けスワーム
- **claude-code-by-agents**: デスクトップGUIアプローチ。@mentionでの直感的協調

## 10. 注目すべき技術的特徴

### 10.1 MCPチャネルプロトコルの活用
公式MCPの`notifications/claude/channel`を使ったリアルタイムプッシュ配信は、MCP拡張の新しいパターン。ただし`--dangerously-load-development-channels`フラグ要求はプロダクション利用の障壁。

### 10.2 Brokerパターン
自動起動・自動クリーンアップのBrokerデーモンは、MCPサーバー間の状態共有パターンとして参考になる。`Bun.spawn`でdetachedプロセスとして起動し、MCPサーバーの終了後も存続する設計。

### 10.3 スコープ付きピア発見
machine/directory/repoの3レベルスコープは、モノレポや複数プロジェクト並行作業での実用性が高い。

### 10.4 OpenAI連携のサマリー自動生成
コンテキスト把握にgpt-5.4-nanoを使うクロスプロバイダー設計。コスト最小化のためにnanoモデルを使用する判断は実用的。
