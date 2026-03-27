---
name: "claude-subconscious"
url: "https://github.com/letta-ai/claude-subconscious"
type: tool
tags: [memory, hooks, letta, persistent-memory, session-management, context-injection]
stars: 862
license: "MIT"
last_checked: "2026-03-27"
relevance: medium
summary: "Letta AI製のClaude Codeセッション間永続メモリプラグイン、8ブロック構造化メモリが特徴"
---

# claude-subconscious 深掘り分析

## 基本情報

| 項目 | 内容 |
|------|------|
| URL | https://github.com/letta-ai/claude-subconscious |
| 作者/組織 | Letta AI（旧 MemGPT） |
| ライセンス | MIT |
| Stars | 1,722 |
| Forks | 125 |
| 言語 | TypeScript |
| 作成日 | 2026-01-14 |
| 最終更新 | 2026-03-26 |
| Open Issues | 11 |
| 現バージョン | v1.1.0（2026-01-28） |

## 概要

Claude Codeにセッション間の永続メモリを付与するプラグイン。Letta（旧MemGPT）のエージェントフレームワークを活用し、Claude Codeの「裏側」でバックグラウンドエージェントを稼働させる。セッションのトランスクリプトを非同期に処理し、学習した知見を次回のプロンプト前に「ささやき」として注入する。

**コアコンセプト**: 「Claude Code forgets everything between sessions — Sub watches, learns, and whispers back.」

## アーキテクチャ

### システム構成

```
Claude Code Session
  ├── SessionStart hook → Letta Conversation作成、CLAUDE.mdクリーンアップ
  ├── UserPromptSubmit hook → メモリブロック注入（stdout経由）
  ├── PreToolUse hook → ワークフロー中のコンテキスト更新
  └── Stop hook → 非同期トランスクリプト処理（detached worker）

Letta Cloud / Self-hosted Server
  ├── Agent（Subconscious）
  │   ├── 8 Memory Blocks（最大30,000文字、12ブロック上限）
  │   ├── 7 Tools（memory操作、web検索、ファイル読み取り）
  │   └── LLM（GLM-5 / 自動フォールバック）
  └── Conversations API（セッション管理）
```

### Hook構成

| Hook | スクリプト | タイムアウト | 役割 |
|------|-----------|-------------|------|
| SessionStart | session_start.ts | 5s | Conversation作成、CLAUDE.mdクリーンアップ |
| UserPromptSubmit | sync_letta_memory.ts | 10s | メモリ/メッセージ注入（stdout） |
| PreToolUse | pretool_sync.ts | 5s | ワークフロー中のコンテキスト更新 |
| Stop | send_messages_to_letta.ts | 120s | 非同期トランスクリプト処理 |

### メモリアーキテクチャ（8ブロック）

1. **core_directives** — ロール定義・行動指針
2. **guidance** — 次セッションへのアクティブな推奨事項
3. **user_preferences** — 学習したコーディングスタイル
4. **project_context** — アーキテクチャ知識・キーファイル
5. **session_patterns** — 繰り返し行動パターン
6. **pending_items** — 未完了タスク・TODO
7. **self_improvement** — メモリ進化のガイドライン
8. **tool_guidelines** — ツール使用指針

### 動作モード

| モード | 注入内容 | 用途 |
|--------|---------|------|
| whisper（デフォルト） | メッセージのみ | 軽量コンテキスト |
| full | ブロック+メッセージ | 初回フル注入、以降差分 |
| off | なし | 一時無効化 |

### SDK Tools（3段階）

| モード | ツール | 用途 |
|--------|--------|------|
| read-only（デフォルト） | Read, Grep, Glob, web_search, fetch_webpage | 安全なバックグラウンド調査 |
| full | 全ツール（Bash, Edit, Task含む） | フル自律 |
| off | なし | 聴取専用 |

### 状態管理

- **永続**: `~/.letta/claude/` — conversations.json, session-{id}.json
- **一時**: `$TMPDIR/letta-claude-sync-$UID/` — デバッグログ

### マルチプロジェクト構成

単一エージェントが複数プロジェクトを横断。共有メモリでプロジェクト間知識を蓄積。

```
~/.letta/claude-subconscious/config.json → 1 Agent（共有ブレイン）
  ├── project-a/.letta/claude/ → Project A の Conversation スレッド
  └── project-b/.letta/claude/ → Project B の Conversation スレッド
```

`LETTA_AGENT_ID` または direnv でプロジェクト別エージェント割当も可能。

## 主要機能

1. **セッション間永続メモリ** — トランスクリプト分析→メモリブロック更新→次セッション注入
2. **非同期バックグラウンド処理** — Stop hookでdetached workerを起動、メインフローをブロックしない
3. **stdout注入方式** — CLAUDE.mdを直接書き換えず、stdoutで注入（クリーンな設計）
4. **マルチインスタンス対応** — Conversations APIで複数Claude Codeセッションが同一エージェントを共有
5. **自己改善メモリ** — self_improvementブロックによるメモリ構造自体の進化
6. **ファイルシステム読み取り** — Letta Code SDKでRead/Grep/Globツールをバックグラウンドエージェントに提供
7. **Web検索統合** — Exa経由のウェブ検索でコードベース外の情報も取得
8. **ゼロコンフィグセットアップ** — LETTA_API_KEY設定のみで自動構成

## 評価

### Pros

- **設計の洗練度が高い**: stdout注入、非同期処理、detached workerなど、Claude Code Hooksの特性を深く理解した実装
- **メモリブロック設計が秀逸**: 8ブロックの分類（directives/guidance/preferences/context/patterns/pending/self-improvement/tools）は永続メモリの構造化パターンとして参考価値が高い
- **CLAUDE.md非侵襲**: stdoutのみで注入し、CLAUDE.mdを汚染しない
- **マルチプロジェクト共有**: 単一エージェントで複数プロジェクトの知識を横断管理
- **MIT License**: 制約なく参照・流用可能
- **Letta/MemGPTの知見蓄積**: エージェントメモリ研究の最前線にいるチームの実装

### Cons

- **外部依存**: Letta Cloud（またはセルフホスト）への依存が必須。APIキーが必要
- **レイテンシ**: UserPromptSubmit 10s、Stop 120sのタイムアウト。体感的な遅延が発生しうる
- **Stars 1,700**: claude-mem（40.9k）やclaude-cognitive（443）と比較して中規模
- **非同期の限界**: 「1ステップ遅れ」で処理されるため、リアルタイムのコンテキスト反映は不可
- **LLM推論コスト**: バックグラウンドエージェントの推論に追加コスト（Letta Cloud無料枠あり）
- **Linux互換性問題**: CLAUDE_PLUGIN_ROOT未設定でフック失敗する未解決Issue (#34)
- **プロジェクト別スコープ化が手動**: デフォルトは全プロジェクト共有。分離にはdirenv等の設定が必要

### 注目すべきOpen Issues

- #34: Linux環境でCLAUDE_PLUGIN_ROOT空によるhook失敗
- #27: Claude←→Subconscious間の双方向会話の実装
- #11: 非同期hookの改善
- #10: 有用性の評価（チーム自身が効果測定中）

## 類似ツール比較

| 項目 | claude-subconscious | claude-mem | claude-cognitive | Claude Code Native (MEMORY.md) |
|------|-------------------|------------|-----------------|-------------------------------|
| Stars | 1,722 | 40,900 | 443 | N/A（標準機能） |
| ライセンス | MIT | AGPL-3.0 | MIT | N/A |
| メモリ方式 | 構造化ブロック（8種） | SQLite + Chroma VectorDB | 注意力ベース3層（HOT/WARM/COLD） | MEMORY.md（200行上限） |
| 外部依存 | Letta Cloud/Server | ローカルWorkerサービス | なし（純スクリプト） | なし |
| セットアップ | APIキー1つ | npm install + Worker起動 | スクリプトコピー + keywords.json | デフォルト有効 |
| マルチインスタンス | Conversations API | 未対応 | Pool Coordinator（8+並行） | 未対応 |
| コンテキスト効率 | ブロック選択注入 | Progressive Disclosure（10x圧縮） | HOT/WARM/COLD（64-95%削減） | 200行全注入 |
| Web検索 | Exa統合 | なし | なし | なし |
| ファイル読み取り | Letta SDK（Read/Grep/Glob） | PostToolUseで自動キャプチャ | keywords.jsonベースの動的ロード | なし |
| 自己改善 | self_improvementブロック | AI圧縮 | 注意力スコア減衰 | Auto Dream（24h周期） |
| 注入方式 | stdout（非侵襲） | stdout | InstructionsLoaded hook | システムプロンプト直接注入 |
| 追加コスト | Letta Cloud LLM推論 | Claude SDK圧縮コスト | なし | なし |
| プロジェクト分離 | 手動（direnv等） | 自動（プロジェクト別DB） | 自動（.claude/ディレクトリ） | 自動（パスエンコード） |

### 各ツールの位置づけ

- **claude-subconscious**: 「エージェントが別エージェントを監視する」パターン。Letta/MemGPTの研究知見を活用した構造化メモリ。外部依存あり
- **claude-mem**: 「全行動を記録→圧縮→検索」パターン。最大規模のコミュニティ。Vector検索による高精度な関連記憶取得。AGPL注意
- **claude-cognitive**: 「注意力ベースの動的コンテキスト管理」パターン。外部依存ゼロ。大規模コードベースでのトークン削減に特化
- **Claude Code Native**: 「シンプルなメモ帳」パターン。200行上限だがゼロ設定。Auto Dreamで自動整理

## Letta AI / MemGPT について

Letta AIはMemGPTの研究チームが設立した企業。「LLMに自己編集メモリツールを持たせる」というMemGPT論文の知見を商用化。Letta Codeは独立した「メモリファースト」コーディングエージェントとしてTerminalBench #1（モデル非依存部門）。claude-subconsciousはそのメモリ技術をClaude Codeプラグインとして提供するもの。
