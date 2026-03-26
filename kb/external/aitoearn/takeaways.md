# AiToEarn — harness-harness向け知見・採用判断

調査日: 2026-03-26

## 採用（高優先度）

### MCP HTTP公開パターン
- AiToEarnは既存Web APIを `"type": "http"` でMCPサーバーとして公開し、Claude Desktop/Cursor等から直接操作可能にしている
- harness-harnessのテンプレートとして「既存サービスのMCP化」パターンを追加すべき
- 設定は数行のJSONで完結し、導入障壁が極めて低い

## 採用（中優先度）

### Nxモノレポ向けCLAUDE.md
- AiToEarnのバックエンドはNxモノレポ構成で、CLAUDE.mdにNx MCPツール連携を記述
- `nx_workspace`, `nx_project_details`, `nx_docs` ツールの活用指示を含む
- Nxプロジェクト向けCLAUDE.mdテンプレートの参考になる

### マルチアプリ構成のハーネス配置
- `project/` 配下にbackend/electron/webの3プロジェクトを分離
- バックエンドに独自のCLAUDE.mdを配置する階層設計
- サブディレクトリ別のCLAUDE.md配置パターンとして参考になる

## 検討

### AIエージェント全自動パイプライン
- 企画→生成→投稿→エンゲージメント→収益化の全ステップをAIエージェントが実行
- 「自動化ワークフロー」をハーネスで定義するパターンの参考になるが、ドメイン特化度が高い

### 成果報酬型指標体系
- CPS/CPE/CPMモデルはAIエージェントの作業成果を測定する枠組みとして汎用化の余地あり
- ただしharness-harnessの現在のスコープとは距離がある

## 不採用

### ツール自体の統合
- AiToEarnはSNSマーケティングに特化したドメインツールであり、harness-harnessの汎用ハーネスフレームワークとしての統合対象ではない

### 収益化マーケットプレイス機構
- ブランド-クリエイター間のマッチング機構はharness-harnessの範囲外

### 定期監視
- harness-harnessのコア技術（Claude Code/Codex CLI仕様）への影響が薄いため、定期巡回対象には含めない

## 要注意

- AiToEarnの出金問題報告（GitHub #488）は、類似プラットフォーム統合時のリスク事例として記録に値する
- 中国プラットフォーム対応の技術知見（Douyin/Xiaohongshu API等）は、将来の国際展開ハーネスで参考になる可能性がある
