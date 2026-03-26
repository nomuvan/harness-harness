# AiToEarn 徹底調査レポート

調査日: 2026-03-26

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
| Stars | 12,431 |
| Forks | 2,686 |
| コントリビューター | 9名 |
| Open Issues | 65 |
| 作成日 | 2025-02-24 |
| 最終更新 | 2026-03-26（活発に更新中） |
| 組織 | yikart |

## 2. プロジェクト概要

AiToEarnは、AIを活用したコンテンツマーケティングの全ライフサイクル（企画・制作・配信・収益化）を自動化するフルスタックプラットフォーム。クリエイター、ブランド、企業がSNS上でコンテンツを作成・配信・エンゲージメント獲得・収益化することを一元管理する。

### コアコンセプト: 4つのAgent

1. **Monetize** — コンテンツから収益を得る（CPS/CPE/CPMモデル）
2. **Publish** — 10+プラットフォームへのワンクリック配信
3. **Engage** — ブラウザ拡張によるエンゲージメント自動化（いいね・フォロー・AIコメント返信）
4. **Create** — AIによるコンテンツ生成（動画: Grok/Veo/Seedance、画像: Nano Banana等）

### 対応プラットフォーム

- 中国系: Douyin（抖音）, Xiaohongshu（小紅書/Rednote）, Kuaishou（快手）, Bilibili, WeChat Channels, WeChat Official Accounts
- グローバル: TikTok, YouTube, Facebook, Instagram, Threads, X (Twitter), Pinterest, LinkedIn

## 3. 技術アーキテクチャ

### リポジトリ構造

```
AiToEarn/
├── .claude/              # Claude Code設定（launch.json）
├── .github/              # GitHub Actions等
├── project/
│   ├── aitoearn-backend/ # バックエンド（Nx monorepo）
│   │   ├── apps/
│   │   │   ├── aitoearn-ai/     # AI処理サービス
│   │   │   └── aitoearn-server/ # メインAPIサーバー
│   │   ├── libs/                # 共有ライブラリ
│   │   ├── CLAUDE.md            # バックエンド用Claude Code設定
│   │   ├── nx.json              # Nxワークスペース設定
│   │   └── Dockerfile
│   ├── aitoearn-electron/ # デスクトップアプリ（Electron + React）
│   │   ├── electron/      # Electronメインプロセス
│   │   ├── src/           # Reactフロントエンド
│   │   ├── server/        # ローカルサーバー
│   │   └── vite.config.ts
│   └── aitoearn-web/      # Webフロントエンド
├── scripts/              # ユーティリティスクリプト
├── docker-compose.yml    # Docker一括デプロイ
└── nginx/                # リバースプロキシ設定
```

### 技術スタック

| レイヤー | 技術 |
|---------|------|
| フロントエンド（Web） | React + TypeScript |
| デスクトップ | Electron + React + Vite |
| バックエンド | NestJS（Nxモノレポ） |
| データベース | MongoDB |
| キャッシュ | Redis |
| パッケージ管理 | pnpm |
| ビルド/オーケストレーション | Nx |
| テスト | Vitest |
| デプロイ | Docker / Docker Compose |
| 必須Node.js | 20.18.x |

### 特筆: Claude Code統合

- バックエンドに `CLAUDE.md` と `.claude/` ディレクトリが存在
- CLAUDE.mdの内容はNx MCP連携の設定ガイド
- Nxのワークスペースツール（`nx_workspace`, `nx_project_details`, `nx_docs`）をClaude Codeから呼び出す設計

## 4. MCP（Model Context Protocol）対応

AiToEarnはv2.1（2026-03-26）でMCPプロトコルをサポート。

### MCP統合方法

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

### MCPで提供されるツール（Dify Marketplace確認）

1. **チャンネルアカウント管理** — 認可済みSNSアカウントの取得
2. **単一投稿タスク** — 個別アカウントへのコンテンツ投稿
3. **一括投稿** — 複数アカウントへの同時配信・スケジュール配信
4. **タスクステータス追跡** — 投稿進捗のモニタリング

### 対応AIアシスタント

- Claude Desktop
- Cursor
- OpenClaw（mcporter経由）
- その他MCP互換エージェント/LLM

## 5. 収益化モデル

### クリエイター向け（稼ぐ側）

| モデル | 正式名称 | 課金基準 | 単価例 |
|--------|---------|---------|--------|
| CPS | Cost Per Sale | 販売額 | 変動 |
| CPE | Cost Per Engagement | エンゲージメント数 | $1.00/1K engagements |
| CPM | Cost Per Mille | 表示回数 | $0.10/1K views |

投稿単位の報酬: $0.50〜$5.00/投稿
インタラクションタスク: $0.01〜$0.50/タスク

### プラットフォーム（AiToEarn側）

- ブランドからのタスク掲載手数料
- プラットフォーム手数料（取引仲介）
- メンバーシップサブスクリプション

## 6. リリース履歴

| バージョン | 日付 | 主要変更 |
|-----------|------|---------|
| v2.1 | 2026-03-26 | MCP対応、OpenClaw統合、多数のバグ修正 |
| v1.8.0 | 2025-02-07 | オフライン事業者向けプロモーション（飲食・小売・ホテル・美容・ジム） |
| v1.5.3 | 2025-01-06 | 既知問題の大量修正 |
| v1.5.0 | 2024-12-30 | タスク共有機能強化 |
| v1.4.3 | 2024-12-15 | "All In Agent"（AIエージェントによるコンテンツ自動生成・投稿） |
| v1.4.0 | 2024-11-28 | MCP拡張、アプリ内更新、AI機能（要約・拡張・画像/動画生成・タグ生成） |
| v1.3.2 | 2024-11-12 | 初のオープンソース完全利用可能版 |

注: v1.8.0以降、Windows/macOS/Androidクライアントの更新を停止し、Webバージョンに集中。

## 7. コミュニティ・評判

### ポジティブな指標

- 約1年で12,431スター（急成長）
- GitHub Trendshiftバッジ取得
- 2,686フォーク（アクティブなフォーク数）
- SourceForgeミラーも存在

### 懸念事項

- コントリビューター9名と少数（主にyikart組織内部の開発）
- Open Issues 65件（一部は「出金が機能しない」等の深刻な報告あり: #488）
- Dockerデプロイの問題報告複数（#484, #485）
- デスクトップクライアント廃止（Web集中への方針転換）
- X (Twitter)での言及は主に中国語圏コミュニティ
- Hacker Newsでの言及なし
- 英語圏でのレビュー記事がほぼ存在しない
- ブログ記事はAI/テック一般ニュースの転載が多く、オリジナルコンテンツが少ない

## 8. 類似ツールとの比較

| ツール | 種別 | AI生成 | マルチプラットフォーム配信 | 収益化 | OSS | セルフホスト |
|--------|------|--------|------------------------|--------|-----|------------|
| **AiToEarn** | フルスタック | Yes | 14プラットフォーム | Yes (CPS/CPE/CPM) | Yes (MIT) | Yes (Docker) |
| **Postiz** | スケジューラ | Yes | 主要SNS | No | Yes | Yes |
| **Mixpost** | スケジューラ | Limited | 主要SNS | No | Yes | Yes (Docker) |
| **Buffer** | スケジューラ | Yes | 主要SNS | No | No | No |
| **Hootsuite** | 管理ツール | Yes | 多数 | No | No | No |
| **Shoutify** | スケジューラ | No | 主要SNS | No | Yes | Yes |
| **SocialBee** | スケジューラ | Yes (Copilot) | 主要SNS | No | No | No |

### AiToEarnの差別化ポイント

1. **収益化機能の内蔵**: 他のツールが配信のみに特化するのに対し、AiToEarnはブランドタスクマーケットプレイスを内蔵
2. **中国プラットフォーム対応**: Douyin/Xiaohongshu/Kuaishou/Bilibili等の中国SNSに対応する唯一のOSSツール
3. **AIエージェント統合**: コンテンツ生成から配信までをAIエージェントが一貫して実行
4. **MCP対応**: Claude/Cursor等のAIアシスタントから直接操作可能
5. **オフライン事業者対応**: 実店舗向けのプロモーション機能

### AiToEarnの弱点

1. **中国市場中心**: ドキュメント・コミュニティが中国語中心で英語圏での認知度が低い
2. **収益化の信頼性**: 出金問題の報告あり（#488）
3. **デスクトップ廃止**: Electron版の更新停止はユーザー体験の変化を意味する
4. **少数の開発チーム**: 9名のコントリビューターで14プラットフォーム対応は持続可能性に疑問

## 9. ライセンス

**MIT License** — 商用利用・改変・再配布すべて自由。制約なし。

## 10. harness-harnessへの適用評価

### 10.1 AIエージェントの収益化パターン

AiToEarnの収益化アプローチからharness-harnessに取り込める設計パターン:

| パターン | 内容 | 採用判断 |
|---------|------|---------|
| タスクマーケットプレイス | ブランドがタスクを掲出し、クリエイターが受託する双方向市場 | **参考のみ** — harness-harnessの範囲外だが、AIエージェントが「仕事を受ける」パターンは汎用化可能 |
| 成果報酬モデル（CPS/CPE/CPM） | 配信結果に基づく課金 | **参考のみ** — AIエージェントの作業成果を測定する指標体系として参考になる |
| "All In Agent" | 企画→生成→投稿→エンゲージメントの全自動パイプライン | **検討** — ハーネスの「自動化ワークフロー」テンプレートとして構造を参考にできる |

### 10.2 自動化ワークフローのハーネス化手法

AiToEarnの技術アーキテクチャから学べるハーネス設計パターン:

| 手法 | AiToEarnでの実装 | harness-harnessへの応用 |
|------|-----------------|----------------------|
| Nxモノレポ + CLAUDE.md | バックエンドがNx構成でCLAUDE.mdにNx MCP連携を記述 | **採用（中優先度）** — Nxモノレポ向けのCLAUDE.mdテンプレートを作成可能 |
| MCP as API | 自社APIをMCPプロトコルで公開し、Claude/Cursor等から操作 | **採用（高優先度）** — 「既存WebサービスをMCPで公開する」パターンをテンプレート化 |
| Docker一括デプロイ | docker-compose.ymlでフロント・バック・DB・キャッシュを一括起動 | **参考** — ハーネスのセットアップスクリプトテンプレートに取り込める |
| マルチプロジェクト構成 | project/配下にbackend/electron/webを分離 | **既存と合致** — harness-harnessのディレクトリ分離方針と一致 |

### 10.3 Claude Code / Codex CLI との連携可能性

| 連携パターン | 実現可能性 | 詳細 |
|-------------|-----------|------|
| Claude Desktop → AiToEarn MCP | **即座に可能** | MCP設定をclaude_desktop_config.jsonに追加するだけ |
| Claude Code → AiToEarn MCP | **可能** | .claude/settings.jsonにMCPサーバーを追加 |
| Codex CLI → AiToEarn MCP | **可能（要検証）** | Codex CLIのMCPサポート範囲による |
| AiToEarnハーネスの作成 | **可能** | AiToEarnのproject/配下にCLAUDE.md/AGENTS.mdを配置するハーネステンプレートを作成 |
| AiToEarnをスキル化 | **可能** | SNS投稿・スケジュール管理のスキルテンプレートとしてMCP連携を定義 |

### 10.4 総合評価

| 観点 | 評価 | コメント |
|------|------|---------|
| 技術的品質 | B | Nx+NestJS+Electron構成は堅実。TypeScript中心で型安全 |
| harness-harnessとの関連性 | C+ | 直接的な適用範囲は限定的。MCPパターンとNxモノレポハーネスが主な学び |
| 採用推奨度 | **低〜中** | パターン抽出のみ。ツール自体の統合は範囲外 |
| 監視継続 | **不要** | 定期巡回対象にする必要はない |

### 10.5 具体的なアクションアイテム

1. **MCP公開パターンのテンプレート化**（高優先度）: 既存WebサービスをMCPで公開して、Claude/Cursor等から操作可能にする設定テンプレートを `templates/` に追加。AiToEarnの `"type": "http"` パターンが好例
2. **Nxモノレポ向けCLAUDE.mdテンプレート**（中優先度）: AiToEarnのbackend CLAUDE.mdを参考に、Nxプロジェクト向けのCLAUDE.md雛形を作成
3. **SNS自動化スキルテンプレート**（低優先度）: AiToEarn MCPをツールとして使うClaude Codeスキルの雛形。ただしドメイン特化のため優先度は低い

---

## Sources

- [GitHub - yikart/AiToEarn](https://github.com/yikart/AiToEarn/)
- [AiToEarn公式サイト](https://aitoearn.ai/en)
- [AiToEarn Releases](https://github.com/yikart/AiToEarn/releases)
- [AiToEarn Documentation](https://docs.aitoearn.ai/quickstart)
- [AiToEarn MCP - Dify Marketplace](https://marketplace.dify.ai/plugin/yikart/aitoearn-mcp)
- [AiToEarn SourceForge Mirror](https://sourceforge.net/projects/ai-to-earn.mirror/)
- [AiToEarn Blog](https://blog.aitoearn.ai)
- [MAGI Archive - AiToEarn](https://tom-doerr.github.io/repo_posts/2025/10/08/yikart-AiToEarn.html)
- [X: FFEE知識分享 on AiToEarn](https://x.com/FFEE_2025/status/2030975516212375900)
- [X: Harry W on AiToEarn v1.2](https://x.com/0xDaoo/status/1983505280819499230)
