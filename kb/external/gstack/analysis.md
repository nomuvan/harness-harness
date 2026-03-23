# gstack 深掘り分析

- URL: https://github.com/garrytan/gstack
- 作者: Garry Tan（Y Combinator CEO）
- ライセンス: MIT
- GitHub Stars: 10,000+（公開48時間で達成、2026年3月時点）
- 調査日: 2026-03-23

## 概要

gstackはClaude Codeを「仮想ソフトウェア開発チーム」に変換するオープンソースツールキット。CEO、エンジニアリングマネージャー、デザイナー、QAリード、リリースエンジニア等のロールを持つスラッシュコマンド群で構成される。Garry Tanは本ツールを使って「YCのフルタイムCEOをしながら週10,000行のコード、100 PR」を達成したと報告している。

TechCrunch（2026年3月17日）で取り上げられ、開発者コミュニティで大きな議論を呼んだ。

## プロセス駆動ワークフロー

gstackの核心は**構造化されたスプリントプロセス**:

```
Think → Plan → Build → Review → Test → Ship → Reflect
```

各フェーズに専門スキルが割り当てられ、出力が下流ステップに送られる。非構造化なAIインタラクションではなく、品質保証のギャップを防ぐプロセス設計。

### フェーズとスキルの対応

| フェーズ | スキル | ロール |
|---------|--------|--------|
| Think | `/office-hours` | YCオフィスアワー: 6つの強制質問でプロダクトを再構成 |
| Plan | `/plan-ceo-review` | CEO: 10スター製品を探す戦略的スコープ評価 |
| Plan | `/plan-eng-review` | エンジニアリングマネージャー: アーキテクチャ確定 |
| Plan | `/plan-design-review` | シニアデザイナー: 0-10評価のデザイン監査 |
| Plan | `/design-consultation` | デザインパートナー: ゼロからデザインシステム構築 |
| Build | （通常のClaude Code作業） | — |
| Review | `/review` | スタッフエンジニア: CIを通るが本番で壊れるバグを発見 |
| Review | `/design-review` | デザイナー-エンジニア: 80項目チェックリストの視覚監査 |
| Review | `/cso` | CSO: OWASP Top 10 + STRIDE脅威モデリング |
| Test | `/qa` | QAリード: 実ブラウザテスト + 回帰テスト自動生成 |
| Test | `/browse` | QAエンジニア: 実Chromium自動操作（コマンドあたり約100ms） |
| Ship | `/ship` | リリースエンジニア: テスト→監査→PR作成を一括 |
| Ship | `/land-and-deploy` | 本番デプロイ + ヘルスチェック |
| Ship | `/canary` | デプロイ後のエラー・リグレッション監視 |
| Reflect | `/retro` | エンジニアリングマネージャー: 週次レトロスペクティブ |

## 28スキル一覧

### プランニング & デザイン（6）
| スキル | ロール | 機能 |
|--------|--------|------|
| `/office-hours` | YCオフィスアワー | 6つの強制質問でプロダクトを再構成 |
| `/plan-ceo-review` | CEO | 拡張/縮小モードの戦略的スコープ評価 |
| `/plan-eng-review` | エンジニアリングマネージャー | アーキテクチャ、データフロー、エッジケース、テスト確定 |
| `/plan-design-review` | シニアデザイナー | インタラクティブなプランモードデザイン監査（0-10評価） |
| `/design-consultation` | デザインパートナー | 完全なデザインシステムをゼロから構築 |
| `/design-review` | デザイナー-エンジニア | ライブサイト視覚監査（80項目チェックリスト + 修正ループ） |

### 実装 & 品質（4）
| スキル | ロール | 機能 |
|--------|--------|------|
| `/review` | スタッフエンジニア | 本番破壊バグの検出（CI通過後） |
| `/investigate` | デバッガー | Iron Law仮説テストによる体系的根本原因デバッグ |
| `/qa` | QAリード | 実Chromiumブラウザテスト + 回帰テスト自動生成 |
| `/cso` | CSO | OWASP Top 10 + STRIDE脅威モデリング監査 |

### チーム & モニタリング（4）
| スキル | ロール | 機能 |
|--------|--------|------|
| `/retro` | エンジニアリングマネージャー | チーム対応週次レトロ（出荷ストリーク、テストヘルス） |
| `/browse` | QAエンジニア | 実Chromiumブラウザ自動操作（約100ms/コマンド） |
| `/benchmark` | パフォーマンスエンジニア | Core Web Vitalsベースライン追跡 |
| `/setup-browser-cookies` | セッションマネージャー | ユーザーブラウザからクッキーをインポート |

### リリース管理（4）
| スキル | ロール | 機能 |
|--------|--------|------|
| `/ship` | リリースエンジニア | テスト同期→監査→カバレッジ→PR作成 |
| `/land-and-deploy` | デプロイエンジニア | 本番デプロイ + ヘルスチェック検証 |
| `/canary` | 監視エンジニア | デプロイ後のエラー・リグレッション監視 |
| `/document-release` | テクニカルライター | リリースに合わせたドキュメント更新 |

### マルチAI & ユーティリティ（4）
| スキル | ロール | 機能 |
|--------|--------|------|
| `/codex` | セカンドオピニオン | クロスモデル分析（レビューゲート/対立/相談の3モード） |
| `/setup-deploy` | デプロイ設定 | デプロイ環境のセットアップ |
| `/gstack-upgrade` | セルフアップデータ | グローバル/ベンダーインストールを検出して更新 |
| `/qa-only` | QAのみ | ブラウザテストのみ実行（修正なし） |

### 安全ガードレール（4）
| スキル | ロール | 機能 |
|--------|--------|------|
| `/careful` | 安全警告 | 破壊的操作（rm -rf, DROP TABLE, force-push等）の前に警告 |
| `/freeze` | 編集ロック | 指定ディレクトリ外への編集をブロック |
| `/guard` | フル安全モード | `/careful` + `/freeze` を同時適用 |
| `/unfreeze` | ロック解除 | `/freeze` の境界を解除 |

## 安全ガードレール詳細

### /careful — 破壊防止

- `rm -rf`, `DROP TABLE`, `git push --force`, `git reset --hard` 等の前に警告
- ビルドクリーンアップ等の一般的な操作は自動でホワイトリスト化
- ユーザーによるオーバーライド可能

### /freeze — 編集境界

- 指定ディレクトリ内のみに編集を制限
- デバッグ中の意図しない変更を防止
- `/guard` で `/careful` と組み合わせて本番作業の安全性を最大化

## 2層テスティング（Free + Paid Evals）

GitHub Issue #24「Proposal: Automated Evals for Skills」で提案された評価アーキテクチャ:

### Phase 1: 構造的アサーション（無料・決定論的）

- 出力フォーマットと必須セクションの検証
- APIコストなし
- 例: `/review` がCRITICAL/INFORMATIONALセクションを分離しているか、`/retro` にメトリクステーブルがあるか

### Phase 2: LLM-as-Judge評価（有料・意味論的）

- 2回目のClaude呼び出しで出力が主張された動作を実際に示しているか評価
- 「文字ではなく精神を捉える」
- `EVAL_JUDGE_TIER` 環境変数で制御

### CLI対応

```bash
--judge-tier quick   # 構造チェックのみ（Phase 1）
--judge-tier full    # 構造 + LLM-as-Judge（Phase 1 + 2）
```

`/ship` スキルにはすでに `EVAL_JUDGE_TIER=full` の参照が含まれている。

## インストールモデル

### グローバルインストール（全プロジェクト共有）

```bash
git clone https://github.com/garrytan/gstack.git ~/.claude/skills/gstack
cd ~/.claude/skills/gstack && ./setup
```

### リポジトリローカル（チーム共有）

```bash
cp -Rf ~/.claude/skills/gstack .claude/skills/gstack
cd .claude/skills/gstack && ./setup
```

- PATHの変更なし、バックグラウンドサービスなし
- すべてのファイルは `.claude/` または `.agents/` 配下
- Bun v1.0+推奨（Node.jsフォールバック）

## テレメトリ & プライバシー

- **デフォルトオフ**（オプトイン）
- 収集データ: スキル名、所要時間、成功/失敗、バージョン、OSのみ
- **送信しない**: コード、ファイルパス、プロンプト、ユーザーコンテンツ
- ローカル分析: `gstack-analytics` コマンドでダッシュボード表示
- ストレージ: Supabase（オープンソース）、スキーマはリポジトリで検証可能

## クロスモデル対応

- Claude Code（主要ターゲット）
- Codex（OpenAI）— `/codex` スキルで統合
- Gemini CLI
- Cursor
- SKILL.md標準による互換性

## 強みと弱み

### 強み

- **プロセス駆動**: 非構造化AI利用の混乱を防ぐ明確なフレームワーク
- **ロールベース設計**: 各スキルが専門家の役割を持ち、責任が明確
- **安全ガードレール**: `/careful`, `/freeze`, `/guard` は実用的で即座に採用可能
- **実ブラウザテスト**: ヘッドレスChromium統合によるE2Eテスト
- **ゼロ偽陽性**: セキュリティ監査に17の除外パターンと8/10+信頼度ゲート
- **MIT License、プレミアム層なし**: 完全にオープン
- **Garry TanのYCブランド**: 採用の心理的安全性

### 弱み

- **強い意見（opinionated）**: 柔軟性より一貫性を重視。カスタマイズ余地が限定的
- **YCスタートアップ偏重**: エンタープライズやOSS開発には合わない面も
- **28スキルの認知負荷**: 全スキルを把握するまでの学習コスト
- **個人ワークフローの普遍化リスク**: Garry Tan個人の開発スタイルが万人に合うとは限らない
- **TechCrunch記事でも批判**: 「love and hate」両方の反応

## 参考リンク

- GitHub: https://github.com/garrytan/gstack
- TechCrunch記事: https://techcrunch.com/2026/03/17/why-garry-tans-claude-code-setup-has-gotten-so-much-love-and-hate/
- Product Hunt: https://www.producthunt.com/products/gstack
- Skills一覧: https://github.com/garrytan/gstack/blob/main/docs/skills.md
- SitePoint Tutorial: https://www.sitepoint.com/gstack-garry-tan-claude-code/
