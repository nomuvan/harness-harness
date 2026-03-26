# DeerFlow 2.0 深掘り分析

- URL: https://github.com/bytedance/deer-flow
- 作者: ByteDance（TikTok親会社）
- ライセンス: MIT License（商用利用可）
- GitHub Stars: ~47,900
- 最終更新: 2026-03（活発に開発中）
- 調査日: 2026-03-26

## 概要

DeerFlow (Deep Exploration and Efficient Research Flow) は、ByteDanceが開発したオープンソースのマルチエージェントフレームワーク。v2.0で「Deep Researchツール」から「フルスタックSuperAgentハーネス」に進化。v1とコード共有なし（完全書き直し）。

v2のコンセプト: コミュニティが「検索ツール」ではなく「実行エンジン」を求めたことが契機。

## アーキテクチャ・構造

### 三層アーキテクチャ

```
Client Layer     : ブラウザ / IM (Slack, Telegram, Feishu) / 組み込みSDK
Service Layer    : Nginx → Frontend(Next.js) / Gateway API(FastAPI) / LangGraph Server
Execution Layer  : Sandbox Provider (Local / Docker / Kubernetes)
```

### Harness/App分離（最重要の設計判断）

`App may import Harness, but Harness must never import App`

- **Harness** (`deerflow-harness`): コアオーケストレーション。独立パッケージとして公開可能
- **App**: FastAPI Gateway + IMチャネル統合
- CIテスト (`tests/test_harness_boundary.py`) でこの境界を強制

### ミドルウェアパイプライン（12段階）

Lead Agentへの全リクエストは以下を順次通過:

1. ThreadDataMiddleware — スレッド別ワークスペース隔離
2. UploadsMiddleware — アップロードファイルのコンテキスト注入
3. SandboxMiddleware — 実行環境の取得
4. SummarizationMiddleware — トークン上限接近時のコンテキスト圧縮
5. TodoListMiddleware — マルチステップタスク追跡
6. TitleMiddleware — 会話タイトル自動生成
7. MemoryMiddleware — 非同期メモリ抽出のキューイング
8. ViewImageMiddleware — マルチモーダル対応
9. ClarificationMiddleware — 明確化リクエストの割り込み
10-12. 特化ハンドラ

### マルチエージェントオーケストレーション

- **Lead Agent**: 全体のオーケストレータ。`make_lead_agent(config)` で動的生成
- **SubAgent**: `SubagentExecutor` がバックグラウンド実行。`AgentRegistry` で追跡
- タスク分解: Lead → 構造化サブタスク → 並行可能性判定 → スコープ付きSubAgent生成 → 結果統合
- 各SubAgent: 独自のスコープドコンテキスト、ツール、終了条件

### スキルシステム

- スキル = **Markdownファイル** (`SKILL.md`)
- **Progressive Skill Loading**: タスクが必要とするスキルだけをコンテキストに注入（段階的開示）
- `skills/public/` と `skills/custom/` の二層構造
- 組み込みスキル: リサーチ、レポート生成、スライド作成、Webページ生成、画像/動画生成

### メモリシステム

- `memory.json` に構造化保存
- 3セクション: ユーザーコンテキスト / 履歴 / 離散的事実（信頼度スコア + タイムスタンプ付き）
- 非同期・デバウンスド更新（ノンブロッキング）
- エージェントプロンプトに自動注入

### サンドボックス

- LocalSandboxProvider: ホストファイルシステム上で直接実行
- AioSandboxProvider: Docker隔離実行
- Kubernetes Provisioner: エンタープライズ向け

## 主要機能

- マルチプロバイダ対応（OpenAI/Claude/DeepSeek/Ollama等）
- Deep Research（Web検索→クロール→レポート合成）
- コード実行（サンドボックス内）
- スライド・Webページ生成
- IM統合（Slack, Telegram, Feishu）
- 永続メモリ（会話間の知識蓄積）

## 技術スタック

| 層 | 技術 |
|----|------|
| バックエンド | Python 3.12+, FastAPI, LangGraph, LangChain |
| フロントエンド | Next.js 15+, React 19, Tailwind CSS 4.0 |
| パッケージ管理 | uv (Python), pnpm (Node.js) |
| インフラ | Docker, Docker Compose, Nginx, Kubernetes(オプション) |

## 評価・人気

- GitHub Trending #1（v2リリース翌日）
- 30日で39K+ Stars
- Andrew Ng関連メディア(deeplearning.ai)で取り上げ
- 「2026年初頭で最も重要なオープンソースエージェントリリースの一つ」との評価

### 批判的指摘

- LangChain/LangGraphへの完全依存（軽量志向のチームにはトレードオフ大）
- BytePlus InfoQuest: OSSインフラ→補完サービスで収益化。ベンダーロックイン懸念
- プロダクション信頼性はまだ発展途上
- ByteDanceオーナーシップ: 一部でデータガバナンス・セキュリティ懸念

## 類似ツールとの比較

| 観点 | DeerFlow 2.0 | GPT Researcher | autoresearch |
|------|-------------|----------------|-------------|
| 目的 | 汎用SuperAgent | Webリサーチ特化 | コード最適化ループ |
| アーキテクチャ | 階層的マルチエージェント | 軽量プランナー | 単一エージェント反復 |
| 実行環境 | Docker隔離 | なし | ローカル |
| スキル拡張 | Markdownスキル | なし | なし |
| メモリ | 永続（信頼度スコア付き） | セッション内のみ | なし |

## ソースコード品質

- v2はゼロから書き直し。コードベースが整然
- Harness/App境界をCIテストで強制（`test_harness_boundary.py`）
- ミドルウェアパイプラインは関心の分離が明確
- テストカバレッジは発展途上（コミュニティ拡大中）
