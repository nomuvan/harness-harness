---
name: "AiToEarn"
url: "https://github.com/yikart/AiToEarn"
type: service
tags: [sns-automation, content-monetization, mcp, multi-platform, electron, nestjs]
stars: 12441
license: "MIT"
last_checked: "2026-03-27"
relevance: high
summary: "14プラットフォーム対応のAIコンテンツ自動生成・配信・収益化ツール。MCP対応でClaude連携可"
---

# AiToEarn 徹底調査レポート（再調査版）

調査日: 2026-03-27（初回調査: 2026-03-26）

## 1. 基本情報

| 項目 | 内容 |
|------|------|
| 名称 | AiToEarn |
| キャッチフレーズ | "Let's use AI to Earn!" |
| GitHub | https://github.com/yikart/AiToEarn |
| 公式サイト | https://aitoearn.ai (国際版) / https://aitoearn.cn (中国版) |
| ブログ | https://blog.aitoearn.ai |
| ドキュメント | https://docs.aitoearn.ai |
| ライセンス | MIT |
| 言語 | TypeScript 92.6%, JavaScript 4.7%, SCSS 1.9% |
| Stars | 12,441 |
| Forks | 2,687 |
| コントリビューター | 9名 |
| Open Issues | 65 |
| 作成日 | 2025-02-24 |
| 最終更新 | 2026-03-26（活発に更新中） |
| 組織 | yikart |
| Topics | auto-publish, douyin, douyin-api, electron-app, electron-react, kuaishou, kwai, published, shipinhao, tool, xiaohongshu |

## 2. プロジェクト概要

AiToEarnは、AIを活用したコンテンツマーケティングの全ライフサイクル（企画・制作・配信・収益化）を自動化するフルスタックプラットフォーム。クリエイター、ブランド、企業がSNS上でコンテンツを作成・配信・エンゲージメント獲得・収益化することを一元管理する。

### コアコンセプト: 4つのAgent

1. **Monetize** — コンテンツから収益を得る（CPS/CPE/CPMモデル）。ブランドがタスクを掲出し、クリエイターが受託する双方向マーケットプレイス
2. **Publish** — 14プラットフォームへのワンクリック・バッチ配信。スケジュール配信対応のカレンダーUI
3. **Engage** — ブラウザ拡張によるエンゲージメント自動化（いいね・お気に入り・フォロー・AIコメント返信・ブランドセンチメント追跡）
4. **Create** — AIによるコンテンツ生成（動画: Grok/Veo/Seedance、画像: Nano Banana等）。マルチモーダル理解、翻訳、バッチ並列生成

### 対応プラットフォーム（14種）

| 区分 | プラットフォーム |
|------|--------------|
| 中国系 | Douyin（抖音）, Xiaohongshu（小紅書/Rednote）, Kuaishou（快手）, Bilibili, WeChat Channels（視頻号）, WeChat Official Accounts |
| グローバル | TikTok, YouTube, Facebook, Instagram, Threads, X (Twitter), Pinterest, LinkedIn |

## 3. 技術アーキテクチャ

### リポジトリ構造

```
AiToEarn/
├── .claude/              # Claude Code設定
│   └── launch.json       # MCP起動設定
├── .github/              # GitHub Actions
├── demo/                 # デモファイル
├── nginx/                # リバースプロキシ設定
├── presentation/         # プレゼンテーション資料
├── project/
│   ├── aitoearn-backend/ # バックエンド（Nx monorepo）
│   │   ├── apps/
│   │   │   ├── aitoearn-ai/     # AI処理サービス
│   │   │   └── aitoearn-server/ # メインAPIサーバー
│   │   ├── libs/                # 共有ライブラリ（16モジュール）
│   │   │   ├── aitoearn-ai-client/    # AIサービスクライアント
│   │   │   ├── aitoearn-auth/         # 認証
│   │   │   ├── aitoearn-queue/        # キュー処理
│   │   │   ├── aitoearn-server-client/# サーバークライアント
│   │   │   ├── ali-oss/              # Alibaba OSS
│   │   │   ├── ali-sms/              # Alibaba SMS
│   │   │   ├── assets/               # 静的アセット
│   │   │   ├── aws-s3/               # AWS S3
│   │   │   ├── channel-db/           # チャンネルDB
│   │   │   ├── common/               # 共通ユーティリティ
│   │   │   ├── helpers/              # ヘルパー
│   │   │   ├── mail/                 # メール送信
│   │   │   ├── mongodb/              # MongoDB接続
│   │   │   ├── nest-mcp/             # MCP統合モジュール
│   │   │   ├── redis/                # Redis接続
│   │   │   └── redlock/              # 分散ロック
│   │   ├── CLAUDE.md            # バックエンド用Claude Code設定
│   │   ├── nx.json              # Nxワークスペース設定
│   │   └── Dockerfile
│   ├── aitoearn-electron/ # デスクトップアプリ（Electron + React）※v1.8.0で更新停止
│   └── aitoearn-web/      # Webフロントエンド
├── scripts/              # ユーティリティスクリプト
└── docker-compose.yml    # Docker一括デプロイ
```

### 技術スタック

| レイヤー | 技術 |
|---------|------|
| フロントエンド（Web） | React + TypeScript |
| デスクトップ | Electron + React + Vite（v1.8.0で更新停止） |
| バックエンド | NestJS（Nxモノレポ、2アプリ + 16ライブラリ） |
| データベース | MongoDB（ReplicaSet構成） |
| キャッシュ | Redis（パスワード認証） |
| オブジェクトストレージ | RustFS / Alibaba OSS / AWS S3（三重対応） |
| 分散ロック | Redlock |
| パッケージ管理 | pnpm |
| ビルド/オーケストレーション | Nx |
| テスト | Vitest |
| デプロイ | Docker / Docker Compose |
| 必須Node.js | 20.18.x |

### Docker Compose構成

docker-compose.ymlで以下のサービスを一括起動:
- **mongodb** — MongoDB ReplicaSet（キーファイル認証付き）
- **mongodb-rs-init** — ReplicaSet初期化
- **redis** — Redis（パスワード認証）
- **rustfs** — RustFS オブジェクトストレージ

### バックエンドNxモノレポの特筆事項

libs/配下の16モジュール構成は、NestJSの依存注入と組み合わせた高度なモジュール分離を実現:
- `nest-mcp` — MCPプロトコル統合の専用ライブラリ
- `channel-db` — SNSチャンネル管理の専用DB抽象
- `aitoearn-queue` — 非同期タスクキュー（投稿スケジューリング等）
- `redlock` — 分散ロック（同時投稿の排他制御）
- `ali-oss` / `aws-s3` — マルチクラウド対応のストレージ抽象

### Claude Code統合

バックエンドの`CLAUDE.md`はNx MCP連携の設定ガイド:

```
# Nx MCPツール利用指示
- nx_workspace: ワークスペースアーキテクチャの把握
- nx_project_details: プロジェクト構造・依存関係の分析
- nx_docs: Nx設定のベストプラクティス参照
```

`CLAUDE.md`の内容はNx公式が自動生成するテンプレート（`<!-- nx configuration start/end -->`コメントで囲まれた自動更新領域）。プロジェクト固有のカスタマイズは追加されていない。

## 4. MCP（Model Context Protocol）対応

AiToEarnはv2.1（2026-03-26）でMCPプロトコルをフルサポート。

### MCP統合設定

```json
{
  "mcpServers": {
    "aitoearn": {
      "type": "http",
      "url": "https://aitoearn.ai/api/unified/mcp",
      "headers": {
        "x-api-key": "your-api-key"
      }
    }
  }
}
```

### MCPで提供されるツール（4種）

| ツール | 機能 | 用途 |
|--------|------|------|
| チャンネルアカウント管理 | 認可済みSNSアカウントの一覧取得 | 配信先の確認・選択 |
| 単一投稿タスク | 個別アカウントへのコンテンツ投稿 | 特定プラットフォームへの投稿 |
| 一括投稿 | 複数アカウントへの同時配信・スケジュール配信 | クロスプラットフォーム配信 |
| タスクステータス追跡 | 投稿進捗のモニタリング | 投稿結果の確認・レポート |

### MCPアーキテクチャパターン

AiToEarnのMCP実装は「既存Web APIのMCP化」パターンの好例:
- `libs/nest-mcp/` — NestJSモジュールとしてMCPプロトコルを実装
- `https://aitoearn.ai/api/unified/mcp` — 統一エンドポイントでMCPリクエストを受付
- `"type": "http"` — HTTP/SSEトランスポート（stdioではなくHTTP）
- APIキー認証 — 既存の認証基盤をMCPのヘッダー認証に流用

### 対応AIアシスタント

- Claude Desktop（MCP設定追加のみ）
- Cursor（MCP設定追加のみ）
- Claude Code（.claude/settings.jsonにMCPサーバー追加）
- OpenClaw（mcporter経由）
- Dify（マーケットプレイスからプラグインインストール）
- その他MCP互換エージェント/LLM

## 5. 収益化モデル

### クリエイター向け（稼ぐ側）

| モデル | 正式名称 | 課金基準 | 説明 |
|--------|---------|---------|------|
| CPS | Cost Per Sale | 販売額 | 商品が売れたときに報酬。コミッション率は商品カテゴリにより変動。eコマース・ソフトウェア・デジタル商品で一般的 |
| CPE | Cost Per Engagement | エンゲージメント数 | いいね・コメント・シェア等のインタラクションに対して報酬。Instagram CPE: $0.10〜$2.00（クリエイターティア依存） |
| CPM | Cost Per Mille | 表示1,000回 | コンテンツが1,000回表示されるごとに報酬。YouTube CPM: $0.25〜$4.00（ニッチ・地域依存） |

投稿単位の報酬: $0.50〜$5.00/投稿
インタラクションタスク: $0.01〜$0.50/タスク

### プラットフォーム（AiToEarn側）

- ブランドからのタスク掲載手数料
- プラットフォーム手数料（取引仲介）
- メンバーシップサブスクリプション（v1.4.4で導入）

### 業界トレンドとの関係（2026）

2026年のコンテンツ収益化市場において、CPVのみの報酬モデルは衰退傾向にあり、CPE（成果報酬型）への移行が進んでいる。AiToEarnのCPS/CPE/CPM三本柱はこのトレンドに合致している。ただし、AiToEarnの報酬単価はグローバル水準と比較して低めであり、主に中国市場の価格帯に最適化されている。

## 6. リリース履歴

| バージョン | 日付 | 主要変更 |
|-----------|------|---------|
| v2.1 | 2026-03-26 | MCP対応強化、OpenClaw統合、多数のバグ修正 |
| v1.8.0 | 2026-02-10 | オフライン事業者向けプロモーション（飲食・小売・ホテル・美容・ジム）。**Windows/macOS/Androidクライアント更新停止、Web版に集中** |
| v1.5.0 | 2025-12-30 | タスク共有機能強化、UI最適化、システム安定性改善 |
| v1.4.6 | 2025-12-25 | 安定性最適化、ユーザー収益事前位置決め機能 |
| v1.4.5 | 2025-12-22 | 入力ボックス改善、会話履歴スコアリング、エージェント異常修正 |
| v1.4.4 | 2025-12-19 | マルチモーダル理解強化、エージェント速度改善、メンバーシップサブスクリプション導入 |
| v1.4.3 | 2025-12-15 | "All In Agent"（AIエージェントによるコンテンツ自動生成・投稿） |
| v1.4.1 | 2025-12-05 | 配信ワークフロー大規模リファクタ、AI編集機能拡張 |
| v1.4.0 | 2025-11-28 | MCP拡張、アプリ内更新、出金システム改善 |
| v1.3.3 | 2025-11-20 | 認証問題修正、配信失敗解消、UI最適化 |
| v1.3.2 | 2025-11-13 | 初のオープンソース完全利用可能版 |

### 開発ペースの分析

- v1.3.2（2025-11-13）からv1.8.0（2026-02-10）まで約3ヶ月で12リリース
- v1.4.x台（2025-11〜12月）に集中的な機能追加（Agent, MCP, マルチモーダル, サブスク）
- v1.8.0以降はリリース頻度が低下（Web版への移行期間と推測）
- v2.1（2026-03-26）でMCP対応を大幅強化、現在も活発に開発中

## 7. コミュニティ・評判

### ポジティブな指標

- 約13ヶ月で12,441スター（急成長、GitHub Trendshiftバッジ取得）
- 2,687フォーク（活発なフォーク数）
- 2,576コミット（活発な開発活動）
- SourceForgeミラー存在
- Difyマーケットプレイスにプラグイン掲載

### 懸念事項

- コントリビューター9名と少数（yikart組織内部の開発が中心）
- Open Issues 65件（「出金が機能しない」等の深刻な報告: #488）
- Dockerデプロイの問題報告複数（#484, #485）
- デスクトップクライアント廃止（v1.8.0でWeb集中へ方針転換）
- X (Twitter)での言及は主に中国語圏コミュニティ
- 英語圏でのレビュー記事・Hacker Newsでの言及がほぼ存在しない
- ブログ記事はAI/テック一般ニュースの転載が多く、オリジナルコンテンツが少ない
- CLAUDE.mdがNx公式テンプレートのままでプロジェクト固有カスタマイズなし

## 8. 類似ツールとの比較

| ツール | 種別 | AI生成 | マルチプラットフォーム配信 | 収益化 | OSS | セルフホスト |
|--------|------|--------|------------------------|--------|-----|------------|
| **AiToEarn** | フルスタック | Yes（マルチモーダル） | 14プラットフォーム | Yes (CPS/CPE/CPM) | Yes (MIT) | Yes (Docker) |
| **Postiz** | スケジューラ | Yes | 主要SNS | No | Yes | Yes |
| **Mixpost** | スケジューラ | Limited | 主要SNS | No | Yes | Yes (Docker) |
| **Buffer** | スケジューラ | Yes | 主要SNS | No | No | No |
| **Hootsuite** | 管理ツール | Yes | 多数 | No | No | No |
| **Shoutify** | スケジューラ | No | 主要SNS | No | Yes | Yes |
| **SocialBee** | スケジューラ | Yes (Copilot) | 主要SNS | No | No | No |

### AiToEarnの差別化ポイント

1. **収益化機能の内蔵**: 他のツールが配信のみに特化するのに対し、タスクマーケットプレイスを内蔵
2. **中国プラットフォーム対応**: Douyin/Xiaohongshu/Kuaishou/Bilibili等の中国SNSに対応する唯一のOSSツール
3. **AIエージェント統合**: "All In Agent"でコンテンツ生成から配信までをAIが一貫実行
4. **MCP対応**: Claude/Cursor/Dify等のAIアシスタントから直接操作可能（nest-mcpモジュール）
5. **オフライン事業者対応**: 実店舗向けプロモーション機能（v1.8.0）
6. **マルチクラウドストレージ**: RustFS/Alibaba OSS/AWS S3の三重対応

### AiToEarnの弱点

1. **中国市場中心**: ドキュメント・コミュニティが中国語中心、英語圏での認知度が低い
2. **収益化の信頼性**: 出金問題の報告あり（#488）
3. **デスクトップ廃止**: Electron版の更新停止でオフラインワークフローが失われた
4. **少数の開発チーム**: 9名で14プラットフォーム対応の持続可能性に疑問
5. **ハーネスの未成熟**: CLAUDE.mdがNxテンプレートのまま、プロジェクト固有の指示なし

## 9. ライセンス

**MIT License** — 商用利用・改変・再配布すべて自由。制約なし。

## 10. harness-harnessへの適用評価

### 10.1 MCP HTTP公開パターン（高優先度）

AiToEarnの最大の学びは「既存Web APIのMCP化」パターン:

| 要素 | AiToEarnの実装 | 汎用化ポイント |
|------|---------------|---------------|
| トランスポート | `"type": "http"` | stdio不要、既存HTTP APIをそのままMCP化 |
| エンドポイント | `/api/unified/mcp` | 統一エンドポイントパターン |
| 認証 | `x-api-key` ヘッダー | 既存API認証の流用 |
| NestJSモジュール | `libs/nest-mcp/` | フレームワーク統合ライブラリとしての実装 |
| ツール粒度 | 4ツール（アカウント/単一投稿/一括投稿/ステータス） | CRUD+バッチ操作の典型パターン |

テンプレート化候補: `templates/mcp-http-service/` として、NestJS/Express/FastAPI等のWebフレームワークからMCPサーバーを公開するパターンを整備

### 10.2 Nxモノレポ向けハーネス（中優先度）

| 手法 | AiToEarnでの実装 | harness-harnessへの応用 |
|------|-----------------|----------------------|
| Nx CLAUDE.md | Nx公式テンプレート（自動更新領域） | Nxプロジェクト用CLAUDE.mdテンプレートにカスタマイズガイドを追加 |
| apps/libs分離 | 2アプリ + 16ライブラリ | NestJSモノレポのベストプラクティスとして記録 |
| 共有ライブラリ設計 | 機能別にlibs/を分離（DB, Auth, MCP, Queue等） | ライブラリ境界の設計指針として参考 |

### 10.3 コンテンツ収益化パイプライン（参考）

AiToEarnの4 Agent構成（Create→Publish→Engage→Monetize）は、コンテンツ収益化の完全なパイプラインを表現:

```
[企画] → [AI生成(Create)] → [配信(Publish)] → [エンゲージメント(Engage)] → [収益化(Monetize)]
   ↑                                                                              |
   └──────────────────────── フィードバックループ ──────────────────────────────────┘
```

このパイプライン構造は業務ドメインとして `kb/domains/content-monetization/` に詳述。

### 10.4 Docker Compose構成（参考）

MongoDB ReplicaSet + Redis + RustFSの構成は、セルフホスト型Webサービスの本番構成の好例:
- ReplicaSetの自動初期化パターン
- ヘルスチェック+依存関係の適切な設定
- マルチクラウドストレージ抽象

### 10.5 Claude Code / Codex CLI との連携可能性

| 連携パターン | 実現可能性 | 詳細 |
|-------------|-----------|------|
| Claude Desktop → AiToEarn MCP | **即座に可能** | MCP設定をclaude_desktop_config.jsonに追加するだけ |
| Claude Code → AiToEarn MCP | **可能** | .claude/settings.jsonにMCPサーバーを追加 |
| Codex CLI → AiToEarn MCP | **可能（要検証）** | Codex CLIのMCPサポート範囲による |
| AiToEarnハーネスの作成 | **可能** | project/配下にCLAUDE.md/AGENTS.mdを配置するハーネステンプレートを作成 |
| AiToEarnをスキル化 | **可能** | SNS投稿・スケジュール管理のスキルテンプレートとしてMCP連携を定義 |

### 10.6 総合評価

| 観点 | 評価 | コメント |
|------|------|---------|
| 技術的品質 | B+ | Nx+NestJS+16ライブラリの堅実な構成。nest-mcpモジュールが独自の付加価値 |
| harness-harnessとの関連性 | B- | MCP HTTP公開パターンとNxモノレポハーネスが主な学び。業務ドメインとしてのコンテンツ収益化知見も有用 |
| 採用推奨度 | **中** | パターン抽出+業務ドメイン知見の両面で価値あり |
| 監視継続 | **低頻度** | MCP実装の進化を半年に1回程度チェック |

### 10.7 具体的なアクションアイテム

1. **MCP HTTP公開パターンのテンプレート化**（高優先度）: `templates/mcp-http-service/`を新設。AiToEarnのnest-mcpパターンを参考に、NestJS/Express/FastAPI向けの雛形を作成
2. **Nxモノレポ向けCLAUDE.mdテンプレート**（中優先度）: Nx公式テンプレート+プロジェクト固有カスタマイズの二層構造を推奨するガイドを作成
3. **コンテンツ収益化ドメイン知見**（中優先度）: `kb/domains/content-monetization/overview.md`として業務ドメインを体系化（別ファイルで詳述）
4. **SNS自動化スキルテンプレート**（低優先度）: AiToEarn MCPをツールとして使うClaude Codeスキルの雛形

---

## Sources

- [GitHub - yikart/AiToEarn](https://github.com/yikart/AiToEarn/)
- [AiToEarn Releases](https://github.com/yikart/AiToEarn/releases)
- [AiToEarn公式サイト](https://aitoearn.ai/en)
- [AiToEarn Documentation](https://docs.aitoearn.ai/quickstart)
- [AiToEarn MCP - Dify Marketplace](https://marketplace.dify.ai/plugin/yikart/aitoearn-mcp)
- [AiToEarn SourceForge Mirror](https://sourceforge.net/projects/ai-to-earn.mirror/)
- [AiToEarn Blog](https://blog.aitoearn.ai)
