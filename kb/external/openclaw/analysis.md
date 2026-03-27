---
name: "OpenClaw"
url: "https://github.com/openclaw/openclaw"
type: tool
tags: [personal-ai-assistant, local-first, multi-channel, skill-system, agent-runtime, community-ecosystem]
stars: 247000
license: "Open Source"
last_checked: "2026-03-27"
relevance: medium
summary: "ローカルファーストのパーソナルAIアシスタント。20+メッセージングチャネル統合とスキルエコシステムが特徴"
---

# OpenClaw 深掘り分析

- URL: https://github.com/openclaw/openclaw
- 作者: Peter Steinberger (@steipete)
- ライセンス: オープンソース
- GitHub Stars: 180,000+ (2026年3月時点)
- 調査日: 2026-03-23

## 概要

OpenClawは「自分のデバイスで動かすパーソナルAIアシスタント」。2025年11月にMoltbotとして公開され、2026年1月にOpenClawに改名。Lex Fridman Podcast #491で取り上げられ、一気に知名度が拡大した。Peter SteinbergerはOpenAIに参加し、OpenClawを財団として独立運営する方針を表明している。

## アーキテクチャ

### ローカルファースト・ゲートウェイモデル

コアアーキテクチャは**ローカルファーストGateway**。WebSocketコントロールプレーン（`ws://127.0.0.1:18789`）が中心となり、以下を接続する:

- 複数のメッセージングチャネル
- Piエージェントランタイム
- CLIツール
- Webインターフェース
- コンパニオンアプリ（macOS / iOS / Android）

```
[チャネル群] ←WebSocket→ [Gateway] ←→ [Pi Agent Runtime]
                              ↕
                    [CLI / WebUI / Companion Apps]
```

### モノレポ構成（pnpm workspace）

| パス | 目的 | npm公開 |
|------|------|---------|
| `/` (root) | メインパッケージ `openclaw` | Yes |
| `extensions/` | バンドルプラグイン（30+） | No（バンドル） |
| `packages/` | サンプルエージェント（clawdbot, moltbot） | No |
| `ui/` | Viteベース WebフロントエンドUI | No（バンドル） |
| `apps/android/` | Androidネイティブアプリ | 別配布 |
| `apps/ios/` | iOS/watchOSアプリ | 別配布 |
| `apps/macos/` | macOSアプリ（メニューバー、Voice Wake） | 別配布 |
| `apps/shared/` | Swift共有ライブラリ（OpenClawKit） | — |
| `skills/` | バンドルスキル | — |
| `src/` | ソースコード | — |

### ビルドシステム

- **tsdown** でコンパイル・バンドル
- TypeScript → `dist/` に出力
- プラグインSDKは `dist/plugin-sdk/` で公開
- バージョニング: CalVer（`YYYY.M.DD`、例: `2026.3.14`）

## マルチチャネル統合（20+サービス）

OpenClawの最大の特徴はメッセージングプラットフォームをUIとして使用する点。対応チャネル:

| カテゴリ | チャネル |
|---------|---------|
| メジャー | WhatsApp, Telegram, Slack, Discord, iMessage（BlueBubbles経由） |
| ビジネス | Google Chat, Microsoft Teams, Feishu, Mattermost |
| プライバシー重視 | Signal, Matrix, Nostr |
| 地域特化 | LINE, Zalo |
| その他 | IRC, Twitch, Nextcloud Talk, Synology Chat, Tlon, WebChat |

設計思想: **ユーザーがいる場所で会う**（専用UIを強制しない）

### セキュリティモデル

- **DMペアリング**（デフォルト）: 承認コードによるデバイス認証
- オープンDMは明示的な許可リストが必要
- エージェントごとに隔離されたワークスペース

## スキルシステム（53+バンドルスキル）

### スキルの3層構造

1. **バンドルスキル** — インストール時に同梱（53+）
2. **マネージドスキル** — `~/.openclaw/skills` に配置
3. **ワークスペーススキル** — `<workspace>/skills` に配置（最優先）

優先順位: ワークスペース > マネージド > バンドル

### SKILL.md フォーマット

```yaml
---
name: skill-name
description: スキルの説明
requires:
  bins: [required-binary]
  env: [REQUIRED_ENV_VAR]
  config: [required.config.key]
---
# スキル本文（Markdown）
```

### ClawHub レジストリ

- 公開レジストリ: `clawhub.com`
- 2026年2月時点で13,729のコミュニティスキル
- `openclaw skills install <skill-slug>` でインストール
- ホットリロード対応

### エクステンション（バンドルプラグイン30+）

| カテゴリ | プラグイン例 |
|---------|------------|
| メッセージング | telegram, discord, slack, signal, whatsapp, line, googlechat, imessage |
| ストレージ | memory-lancedb, memory-core |
| 音声 | voice-call |
| 診断 | diagnostics-otel |
| その他 | open-prose, nostr, tlon, twitch |

## ローカルファースト設計の詳細

### 哲学

Steinbergerの設計原則:
- メモリはシンプルなMarkdownファイルで保持（クラウドにロックしない）
- エージェントは自分のソースコードとランタイム環境を理解できる（自己認識型）
- エージェントが自身の実装を書き換えられる（自己修正コード）
- セキュリティは偽の安全劇場ではなく、透明なリスク開示

### インストールと運用

```bash
npm install -g openclaw@latest
openclaw onboard --install-daemon
```

- Node 24推奨（Node 22.16+必須）
- デーモンサービスとして常駐（launchd / systemd）
- 3つのリリースチャネル: stable / beta / dev

### コンパニオンアプリ

- **macOS**: メニューバー制御、Voice Wake、WebChat
- **iOS**: Canvas、音声トリガー、デバイスペアリング
- **Android**: Connect/Chat/Voiceタブ、スクリーン録画、デバイスコマンド

## Peter Steinbergerの哲学

参考: https://steipete.me/posts/2026/openclaw / Lex Fridman Podcast #491

### 主要な信念

1. **「ビルダーである」こと**: 「I'm a builder at heart」— 企業規模より影響力を重視
2. **民主化**: 「My next mission is to build an agent that even my mum can use」— 非技術者でも使えるAIエージェント
3. **コミュニティ第一**: 「every time someone made the first pull request is a win for our society」— Markdownベースのスキルで参入障壁を低く
4. **オープンソースの堅持**: 「It's always been important to me that OpenClaw stays open source」— 財団化による独立性保証
5. **安全性の透明性**: 偽の安全劇場ではなく、ローカル設定、権限理解、強力なモデル選択を推奨

### OpenAI参加の背景

- Sam Altmanが「genius with amazing ideas about the future of very smart agents」と評価
- SteinbergerはOpenClawを財団として独立させた上でOpenAIに参加
- 動機: 「What I want is to change the world」— エージェントを全ての人に届けるためにはより広い変革が必要

## 強みと弱み

### 強み

- マルチチャネル統合は他に類を見ない規模（20+サービス）
- ローカルファースト哲学がプライバシー懸念に対応
- コミュニティエコシステムが爆発的に成長（13,700+スキル）
- ネイティブアプリによるUX（macOS/iOS/Android）
- 自己修正型エージェントという革新的アプローチ

### 弱み

- 常駐デーモンモデルはコーディングアシスタントとしてはオーバーキル
- Node 24要求は環境制約になりうる
- 巨大モノレポは貢献の敷居を上げる
- 「パーソナルアシスタント」志向とharness-harnessの「開発ハーネス」志向は根本的に異なる
- WebSocketゲートウェイの複雑さ

## 参考リンク

- GitHub: https://github.com/openclaw/openclaw
- ドキュメント: https://docs.openclaw.ai/
- ClawHub: https://clawhub.com
- Peter Steinberger Blog: https://steipete.me/posts/2026/openclaw
- Lex Fridman Podcast: https://lexfridman.com/peter-steinberger-transcript/
- Wikipedia: https://en.wikipedia.org/wiki/OpenClaw
