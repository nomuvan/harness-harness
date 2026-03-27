---
name: "AiToEarn"
type: takeaways
tags: [mcp-http-pattern, nx-monorepo, content-pipeline, monetization]
last_checked: "2026-03-27"
adoption_summary: "MCP HTTP公開パターン、収益化ワークフローstate machine、Compliance-first設計が高優先。投稿自動化より収益化運用の抽象化を抽出"
top_patterns:
  - "MCP HTTP公開パターン（既存WebサービスのMCP化）"
  - "収益化ワークフローstate machine（brief→proof→review→settlement）"
  - "Compliance-first + Distribution-first のデフォルト構成"
  - "platform-capabilities.yaml（marketing copyではなくmachine-readable registry）"
  - "payout is product（出金信頼性はproduct-critical）"
---

# AiToEarn — harness-harness向け知見・採用判断（再調査版）

調査日: 2026-03-27（初回調査: 2026-03-26）

## 採用（高優先度）

### 1. MCP HTTP公開パターン

AiToEarnは既存Web APIを `"type": "http"` でMCPサーバーとして公開し、Claude Desktop/Cursor/Dify等から直接操作可能にしている。

**パターンの構造:**
```
既存Web API → 統一MCPエンドポイント(/api/unified/mcp) → MCP互換ツール4種
                ↑ NestJSモジュール(libs/nest-mcp/)が変換を担当
```

**harness-harnessへの適用:**
- `templates/mcp-http-service/` として「既存サービスのMCP化」パターンをテンプレート化
- NestJS、Express、FastAPI等のフレームワーク別雛形
- CRUD+バッチ操作をMCPツールにマッピングする設計ガイド
- 認証パターン（APIキーヘッダー、OAuth等）の選択指針

**導入障壁:** 極めて低い。MCP設定は数行のJSONで完結。

### 2. コンテンツ収益化パイプラインの体系化

AiToEarnの4 Agent構成（Create→Publish→Engage→Monetize）は、コンテンツ収益化ワークフローの完全な抽象化。

**パイプライン構造:**
```
企画 → リサーチ → AI生成 → 編集 → 配信 → エンゲージメント → 分析 → 最適化 → 収益化
                     ↑ Create Agent    ↑ Publish Agent    ↑ Engage Agent       ↑ Monetize Agent
```

**harness-harnessへの適用:**
- `kb/domains/content-monetization/` に業務ドメイン知見を集約（別ファイルで詳述）
- コンテンツ生成パイプラインの各ステップをスキル化するテンプレート
- プラットフォーム別の投稿最適化ルール（content format, timing, algorithm）
- CPS/CPE/CPM収益モデルの選択指針とKPI設計

## 採用（中優先度）

### 3. Nxモノレポ向けCLAUDE.md

AiToEarnのバックエンドはNxモノレポ構成で、CLAUDE.mdにNx MCPツール連携を記述。

**現状の問題点:** AiToEarnのCLAUDE.mdはNx公式テンプレートのままで、プロジェクト固有のカスタマイズがない。これは「CLAUDE.mdの未成熟」事例として記録に値する。

**harness-harnessへの適用:**
- Nxプロジェクト向けCLAUDE.mdテンプレートに「公式テンプレート+カスタマイズ層」の二層構造を推奨
- カスタマイズすべき項目: プロジェクト固有のアーキテクチャ、ビジネスロジックの境界、テスト戦略、デプロイ手順

### 4. マルチアプリ構成のハーネス配置

`project/` 配下にbackend/electron/webの3プロジェクトを分離し、バックエンドに独自のCLAUDE.mdを配置する階層設計。

**harness-harnessへの適用:**
- サブディレクトリ別のCLAUDE.md配置パターン
- モノレポ内の複数アプリに対する統一/個別ハーネスの使い分け指針

### 5. CPS/CPE/CPM収益モデルのKPI体系

AIエージェントの作業成果を測定する枠組みとして汎用化の余地あり。

**2026年のトレンドとの関係:**
- CPVのみの報酬は衰退。CPE（成果報酬型）への移行が進行中
- プラットフォームはアテンションよりコンバージョンを重視するアルゴリズムに移行
- クリエイター収益予測にAIを活用: `期待収益 = 需要 x CVR x AOV`

## 検討

### AIエージェント全自動パイプライン（"All In Agent"）

企画→生成→投稿→エンゲージメント→収益化の全ステップをAIエージェントが実行する構想。

**考慮事項:**
- 2026年のベストプラクティスでは「ハイブリッド（AI+人間）」が最適解。AI only コンテンツよりハイブリッドコンテンツが信頼度33%、エンゲージメント23%上回る
- AIが担うべき: ブレスト、下書き、バリエーション生成、技術的実行、分析
- 人間が担うべき: 戦略的方向性、感情的共鳴、文化的コンテキスト、ブランドニュアンス、品質最終判断
- 完全自動化のリスク: ブランド同質化、アルゴリズムペナルティ、法規制違反

### Docker Compose構成パターン

MongoDB ReplicaSet + Redis + RustFSの構成は参考になるが、ハーネスのコア機能ではない。

**参考ポイント:**
- ReplicaSet自動初期化のinitコンテナパターン
- ヘルスチェック+依存関係のサービス起動順序制御
- マルチクラウドストレージ抽象（ali-oss/aws-s3の共存）

## 不採用

### ツール自体の統合

AiToEarnはSNSマーケティングに特化したドメインツールであり、harness-harnessの汎用ハーネスフレームワークとしての統合対象ではない。

### 収益化マーケットプレイス機構

ブランド-クリエイター間のマッチング機構はharness-harnessの範囲外。パターンとしても汎用性が低い。

### エンゲージメント自動化（Engage Agent）

いいね・フォロー・AIコメントの自動化は、プラットフォームのToS違反リスクが高く、法規制（ステマ規制等）との整合性も問題。パターンとしての採用も見送り。

## 要注意

### 法規制リスク

- **日本**: 2023年10月施行のステマ規制（景品表示法）。AI生成コンテンツの広告表示義務。PR表記のルール
- **EU**: AI Act Article 50（2026年8月施行）。AI生成コンテンツの機械可読ラベリング義務。ディープフェイク開示義務
- **米国**: カリフォルニアAI透明性法（2026年1月施行）。ニューヨーク合成パフォーマー開示法（2026年6月施行）。FTCによるAI生成レビュー規制強化
- **影響**: コンテンツ収益化ハーネスには法規制チェックリストを組み込む必要がある

### 出金問題

AiToEarnの出金問題報告（GitHub #488）は、類似プラットフォーム統合時のリスク事例として記録に値する。収益化プラットフォームを統合する際は、出金機能の信頼性検証を必須チェック項目に含めるべき。

### 中国プラットフォーム知見

Douyin/Xiaohongshu/Kuaishou API等の中国SNS対応技術知見は、将来の国際展開ハーネスで参考になる可能性がある。ただし、これらのAPIはグローバルSNSと異なる認証・配信モデルを持つため、別途調査が必要。

## Claude/Codexクロスレビュー結果

### Codex独自調査の追加知見（Claude側に不足していた観点）

1. **「payout is product」**: 出金遅延はtrust崩壊。GitHub Issue #488は単なるバグではなく、monetization platformの最重要リスク。harness-harnessで類似領域を扱うときは出金周りをproduct-criticalと扱うべき
2. **positioning drift**: Help docsとHomepageで製品定義がズレている。marketing copyをsource of truthにしてはいけない → `platform-capabilities.yaml`のようなmachine-readable registryで管理すべき
3. **campaign単位でsettlement modelを1つに固定**: CPM/CPE/CPS混在は運用不安定。キャンペーンごとに一義的に定義する
4. **owned audience必須**: SNSだけに閉じるとアルゴリズム変更で収益が飛ぶ。newsletter/blog/CRM等を混ぜる
5. **Compliance-first + Distribution-first**: 推奨デフォルト構成。Commerce-firstは注文データが揃う案件のみ追加
6. **workflow state machine**: `brief→content_generated→compliance_checked→platform_adapted→scheduled→published→proof_collected→ai_reviewed→human_reviewed→settled→withdrawn` + failure branches（rejected/appealed/refunded/incident_open）
7. **Minimum Artifact Set**: platform-capabilities.yaml, campaign-schema.json, workflow-state-machine.md, compliance-checklist.md, proof-policy.md, settlement-ledger-spec.md, kpi-taxonomy.md

### Claude側の強み
- libs/16モジュール詳細分析、Docker Compose構成分析
- 業界トレンド（市場規模$43.5億→$128.5億）との対比
- リリース履歴の拡充

### 統合判断
- Codexの「投稿自動化より収益化運用の抽象化を抽出」がより本質的な評価 → adoption_summaryに反映
- Codexのworkflow state machine + failure branchesをkb/domains/content-monetization/に統合
- Codexの法規制一次ソース（FTC、EU AI Act Article 50、消費者庁）がより網羅的 → takeawaysの法規制セクションを補強

## 前回調査（2026-03-26）からの差分

| 項目 | 前回 | 今回 |
|------|------|------|
| Stars | 12,431 | 12,441（+10） |
| frontmatter | なし | YAML形式で追加 |
| libs/詳細分析 | なし | 16モジュールの個別分析追加 |
| CLAUDE.md評価 | 「Nx MCP連携の設定ガイド」 | Nx公式テンプレートのまま=未成熟事例として再評価 |
| 収益化モデル | 単価情報のみ | 2026年業界トレンドとの対比追加 |
| 法規制 | 言及なし | 日本・EU・米国の規制動向を追加 |
| 業務ドメイン | 言及なし | kb/domains/content-monetization/として分離・深掘り |
| 監視継続 | 「不要」 | 「低頻度（半年に1回）」に変更 |
| 総合評価 | C+（関連性） | B-に上方修正（業務ドメイン知見の価値を考慮） |
