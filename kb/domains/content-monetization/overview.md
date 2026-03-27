---
domain: "content-monetization"
tags: [sns, youtube, blog, affiliate, cps, cpe, cpm, ai-content, monetization, marketing]
last_checked: "2026-03-27"
summary: "AI活用によるマルチプラットフォームコンテンツ制作・配信・収益化の業務知見"
key_concepts:
  - "CPS/CPE/CPM収益モデル（campaign単位で1つに固定）"
  - "brief→proof→review→settlement ワークフローstate machine"
  - "マルチプラットフォーム配信（platform-capabilities registryで管理）"
  - "owned audience必須（SNSだけに閉じない）"
  - "payout is product（出金信頼性はproduct-critical）"
harness_implications:
  - "Compliance-first + Distribution-first をデフォルト構成に"
  - "platform-capabilities.yaml でプラットフォーム対応をmachine-readable管理"
  - "compliance-gateをpublish前に必須化（PR開示、AI開示、権利確認）"
  - "settlement ledgerをcontent DBと分離"
  - "コンテンツ生成パイプラインの各ステップをスキル化"
---

# コンテンツ収益化 業務ドメイン深掘り

調査日: 2026-03-27
調査契機: AiToEarn再調査時に、コンテンツ収益化ドメインの体系的知見がkb/に不足していたため新規作成

## 1. 業界概要・市場動向（2025-2026）

### 市場規模

| 指標 | 数値 | 出典 |
|------|------|------|
| AIクリエイターエコノミー市場（2024） | $33.1億 | GlobeNewswire |
| AIクリエイターエコノミー市場（2025予測） | $43.5億 | GlobeNewswire |
| AIクリエイターエコノミー市場（2029予測） | $128.5億 | GlobeNewswire |
| CAGR（2024-2029） | 31.4% | GlobeNewswire |
| クリエイター収益化プラットフォーム市場（2025） | $115.7億 | GlobeNewswire |
| クリエイター収益化プラットフォーム市場（2026予測） | $139.4億（CAGR 20.5%） | GlobeNewswire |
| クリエイターエコノミー全体（2034予測） | $1兆728億 | 各種レポート |
| 米国クリエイターエコノミー広告費（2025） | $371億 | Digiday |
| 米国クリエイターエコノミー広告費（2026予測） | $439億 | Digiday |

### 2026年の主要トレンド

1. **AIコンテンツへの予算シフト**: マーケターの77%が従来型クリエイターマーケティングからAI生成コンテンツへ予算を移行予定。79%がAI生成コンテンツへの支出をさらに増加予定
2. **成果報酬型への移行**: CPV（視聴回数課金）からCPE（エンゲージメント課金）への移行が加速。アテンションよりコンバージョンを重視
3. **プラットフォーム非依存化**: 単一プラットフォームに依存しない「プラットフォームアグノスティック」な収益化戦略が台頭
4. **コンテンツのリテール化**: SNSが純粋なエンタメから商取引チャネルへ変貌。ショッパブル動画、アフィリエイト統合、商品レコメンドが標準化
5. **ハイブリッドコンテンツの優位性**: AI+人間のハイブリッドコンテンツが、AI onlyコンテンツに対して信頼度+33%、エンゲージメント+23%
6. **マイクロ/ナノインフルエンサーの台頭**: マーケターの92%がマクロ(10万-50万)+マイクロ(5千-10万)の両方と連携予定。58%がナノ(5千以下)との連携も計画

### 2026年の広告費内訳（米国）

| カテゴリ | 金額 | 前年比 |
|---------|------|--------|
| SNS上の有料増幅 | $132億 | +48% |
| SNS外の有料増幅 | $111億 | +56% |
| クリエイター直接提携 | $116億 | +21% |
| クリエイターコンテンツ隣接広告 | $79億 | +33% |

## 2. ビジネスモデル・収益構造

### 2.1 広告・プラットフォーム収益

| モデル | 正式名称 | 課金基準 | 2026年ベンチマーク | 適用場面 |
|--------|---------|---------|------------------|---------|
| CPM | Cost Per Mille | 表示1,000回 | YouTube: $0.25-$4.00, TikTok: $0.02-$0.04/1K | 大量リーチ重視、ブランド認知 |
| CPC | Cost Per Click | クリック1回 | Google Ads: $1.63平均 | トラフィック誘導、LP遷移 |
| CPE | Cost Per Engagement | エンゲージメント1回 | Instagram: $0.10-$2.00 | エンゲージメント重視、コミュニティ育成 |
| CPS | Cost Per Sale | 販売1件 | コミッション率: 商品カテゴリ依存 | Eコマース、アフィリエイト |
| CPA | Cost Per Action | 特定アクション1件 | Google Ads: $53.52平均 | 登録、ダウンロード等 |
| CPV | Cost Per View | 視聴1回 | 衰退傾向（CPEへ移行中） | 動画広告 |

### 2.2 クリエイター直接収益

| 収益源 | 概要 | 収益ポテンシャル | 成功条件 |
|--------|------|---------------|---------|
| **プラットフォーム広告収益分配** | YouTube AdSense、TikTok Creator Fund等 | YouTube: RPM $1-$30（ニッチ依存）| 最低要件（YouTube: 1,000登録+4,000時間） |
| **スポンサーシップ** | ブランドとの直接提携 | TikTok: $200-$400/10Kフォロワー、Instagram: $250-$500/10Kフォロワー、LinkedIn: $300-$1,000/10Kフォロワー | エンゲージメント率、ニッチの親和性 |
| **アフィリエイト** | 商品紹介の成果報酬 | CPS: 商品価格の5-30% | 信頼性の高いオーディエンス |
| **サブスクリプション** | 有料会員制コンテンツ | Substack: 1,000有料購読者x$5/月=$5,000/月（手数料前） | 独自性のある専門知識 |
| **デジタル商品** | eBook、コース、テンプレート販売 | 変動大（$1,000-$100,000+/月） | メーリングリスト、専門性 |
| **ニュースレタースポンサー** | ニュースレターへの広告掲載 | $65,000/7ヶ月の事例あり | 購読者の質と量 |
| **ライブコマース** | ライブ配信中の商品販売 | プラットフォーム依存 | リアルタイムエンゲージメント力 |

### 2.3 収益モデルの選択指針

```
小規模（<1万フォロワー）: アフィリエイト + デジタル商品 → 初期収益の確立
中規模（1万-10万）: スポンサーシップ + サブスクリプション → 安定収益の構築
大規模（10万+）: 広告収益分配 + 複合モデル → スケール収益の最大化
```

**2026年の鉄則**: 「メーリングリスト1万人 > 月間PV10万」。直接的なオーディエンス所有が最も価値の高い資産。

## 3. 主要ワークフロー

### コンテンツ収益化の8ステップパイプライン

```
[1.企画] → [2.リサーチ] → [3.生成] → [4.編集] → [5.投稿] → [6.エンゲージメント] → [7.分析] → [8.最適化]
    ↑                                                                                                |
    └──────────────────────────── フィードバックループ ──────────────────────────────────────────────────┘
```

| ステップ | 内容 | AIの適用度 | 人間の関与度 |
|---------|------|----------|------------|
| 1. 企画 | トピック選定、コンテンツカレンダー作成、トレンド分析 | 高（トレンド分析、競合調査） | 高（戦略的判断、ブランド方向性） |
| 2. リサーチ | キーワード調査、競合分析、オーディエンス分析 | 高（データ収集・分析） | 中（インサイト抽出） |
| 3. 生成 | テキスト、画像、動画、音声の制作 | 高（下書き、バリエーション生成） | 中（品質判断、独自性付加） |
| 4. 編集 | 校正、フォーマット調整、プラットフォーム最適化 | 高（フォーマット変換、校正） | 高（最終品質判断、ブランドトーン） |
| 5. 投稿 | スケジューリング、クロスプラットフォーム配信 | 高（自動化可能） | 低（承認のみ） |
| 6. エンゲージメント | コメント返信、コミュニティ管理 | 中（定型返信） | 高（感情的対応、関係構築） |
| 7. 分析 | KPI追跡、レポート生成 | 高（データ集約・可視化） | 中（意味解釈） |
| 8. 最適化 | A/Bテスト、戦略調整、リパーパス | 中（テスト実行） | 高（戦略的判断） |

### Hub-and-Spokeコンテンツリパーパスモデル

1本の高品質ロングフォームコンテンツ（ハブ）から、プラットフォーム別の複数コンテンツ（スポーク）を生成するモデル。リーチ+35%の効果が報告されている。

**例: 12分の解説動画 → 10+バリエーション**
- 4x Instagram Reels（ハイライトクリップ）
- 3x TikTok動画（フック重視の短尺版）
- 2x LinkedIn投稿（プロフェッショナル向けリフレーミング）
- 1x YouTube Shorts
- ポッドキャスト音声抽出・配信
- ブログ記事（文字起こし+補足）
- ニュースレター要約版

## 4. KPI・成功指標

### プラットフォーム共通KPI

| KPI | 定義 | 良好な水準（2026） |
|-----|------|-------------------|
| CTR（クリック率） | クリック数/表示回数 x 100 | YouTube: 4-5%（2%未満はサムネイル改善要） |
| CVR（コンバージョン率） | コンバージョン数/クリック数 x 100 | 業界平均: 2-5% |
| エンゲージメント率 | (いいね+コメント+シェア)/リーチ x 100 | Instagram Reels: フィード投稿の67%増 |
| RPM（Revenue Per Mille） | 収益/表示1,000回 | YouTube: $1-$30（ニッチ依存） |
| 完視率（Completion Rate） | 最後まで視聴した割合 | TikTok: 最重要指標。アルゴリズムの主要シグナル |
| 保存率（Save Rate） | 保存数/リーチ x 100 | Instagram: アルゴリズムの最重要シグナルの1つ |
| シェア率 | シェア数/リーチ x 100 | 全プラットフォーム: バイラル拡散の鍵 |

### 収益KPI

| KPI | 定義 | 用途 |
|-----|------|------|
| 月間収益 | 全収益源の合計 | 全体的なビジネス健全性 |
| ARPU（ユーザーあたり収益） | 総収益/ユニークオーディエンス数 | オーディエンス価値の測定 |
| LTV（顧客生涯価値） | 顧客1人からの累計収益 | サブスク/リピート購入の価値 |
| 収益多角化率 | 最大収益源/総収益 | 依存度リスクの測定（50%以下が理想） |
| 期待収益 | 需要 x CVR x AOV | AI予測に基づく収益見込み |

### 収益予測フレームワーク（2026ベストプラクティス）

```
期待収益 = 需要(リンククリック・登録数) x CVR(チェックアウト率) x AOV(平均注文額)
```

追跡すべき指標: リンククリック、登録数、チェックアウトコンバージョン、返金率

**月次サイクル**: 1つの商品で価格テスト → 2つの価格帯を比較 → メッセージングは一定に保つ → 収益・返金・満足度を追跡 → 繰り返し

## 5. プラットフォーム別戦略

### YouTube

| 項目 | 詳細 |
|------|------|
| アルゴリズムの重視指標 | 平均視聴時間（AVD）、CTR |
| 推奨フォーマット | ロングフォーム（8分+、16:9）が収益化で25-100x有利。Shortsは補助的 |
| 投稿頻度 | 週1-2本のロングフォーム |
| 収益化要件 | 1,000登録者 + 4,000時間視聴 |
| CPM | $0.25-$4.00/1K views（最高額プラットフォーム） |
| 戦略ポイント | サムネイル/タイトル最適化が最重要。エバーグリーンコンテンツが長期収益を生む |

### TikTok

| 項目 | 詳細 |
|------|------|
| アルゴリズムの重視指標 | 完視率（最重要）、シェア、保存 |
| 推奨フォーマット | 縦型動画（9:16）、最初の3秒がフック |
| 投稿頻度 | 週3-5本（量より質） |
| Creator Fund | $0.02-$0.04/1K views |
| スポンサーシップ | $200-$400/10Kフォロワー |
| 戦略ポイント | 最初の1-2秒でアルゴリズム評価が決まる。ショッピングリンクとの統合で商取引チャネル化 |
| 注意 | 他プラットフォームからのリポスト（ウォーターマーク付き）はアルゴリズムが減点。オリジナル重視 |
| 年齢層 | 25-44歳が32%（2023年の18%から拡大）、13-24歳がエンゲージメントの45% |

### Instagram

| 項目 | 詳細 |
|------|------|
| アルゴリズムの重視指標 | 保存、プロフィールクリック、シェア、完視率 |
| 推奨フォーマット | Reels（9:16〜1:1）が主力。フィード投稿はリーチ激減 |
| 投稿頻度 | Reels: 週4-6本 + テキスト投稿: 日1-2本 |
| Reels Bonus | $0.10-$0.30/1K views（招待制） |
| スポンサーシップ | $250-$500/10Kフォロワー |
| 戦略ポイント | 20秒Reelを100%視聴+20シェア > 90秒Reelの40%完視。Threads返信がエンゲージメントシグナルに寄与 |
| ベストタイム | 平日11-13時、19-21時 |
| 注意 | 他プラットフォームのウォーターマーク付きコンテンツはネガティブシグナル |

### X (Twitter)

| 項目 | 詳細 |
|------|------|
| アルゴリズムの重視指標 | リプライ速度、リポスト率、引用リポスト率 |
| 推奨フォーマット | テキスト主体 + スレッド。動画はReels/TikTokほどの配信力なし |
| 投稿頻度 | 日1-3回 |
| 収益化 | X Premium収益分配、スーパーフォロー |
| 注意 | 2025年6月以降、ハッシュタグ付き投稿は広告配信から除外 |

### LinkedIn

| 項目 | 詳細 |
|------|------|
| アルゴリズムの重視指標 | エンゲージメント品質（バニティメトリクスよりインサイトの深さ） |
| 推奨フォーマット | 横型動画エッセイ（3-5分）、テキストファースト |
| 投稿頻度 | 週2-3本（高品質・低頻度） |
| CPM | $0.50-$2.00（Creator Fund、2026年に本格化） |
| スポンサーシップ | $300-$1,000/10Kフォロワー |
| 戦略ポイント | B2Bアフィリエイトのコンバージョン率が最も高い。プロフェッショナルインサイト重視 |

### Threads

| 項目 | 詳細 |
|------|------|
| アルゴリズムの重視指標 | リプライ速度、リポスト率、引用スレッド率 |
| 推奨フォーマット | カジュアル・リアルタイム・会話型 |
| 投稿頻度 | 日1-3回 |
| スポンサーシップ | $100-$250/10Kフォロワー |
| 位置づけ | 新興プラットフォーム。収益化は未発達だが、Instagramのエンゲージメントシグナルに寄与 |

### ブログ / Medium / note

| 項目 | 詳細 |
|------|------|
| 収益モデル | 広告（AdSense等）、アフィリエイト、スポンサー記事 |
| SEO重視 | エバーグリーンコンテンツが長期的なオーガニックトラフィックを生む |
| 戦略ポイント | 「メーリングリスト1万 > PV10万」。検索流入+メーリングリスト構築が最優先 |

### Substack / ニュースレター

| 項目 | 詳細 |
|------|------|
| 主要収益源 | 有料サブスクリプション（Substack: 10%手数料 + Stripe手数料） |
| 副次的収益 | アフィリエイト、スポンサーシップ、デジタル商品 |
| ベンチマーク | 1,000有料購読者 x $5/月 = $5,000/月（手数料前） |
| 戦略ポイント | 直接的なオーディエンス所有。アルゴリズム変更の影響を受けない |

### クロスプラットフォーム原則

1. **同一コンテンツの使い回しは厳禁**: プラットフォームごとにリフォーマット・リタイトル・リフレーミングが必要
2. **70/30ルール**: 主力2-3プラットフォームに70%の努力、新興プラットフォームのテストに30%
3. **成長タイムライン**: ベースライン確立に6-12週、収益化可能まで3-6ヶ月
4. **ブランドが最も使うプラットフォーム（2026）**: TikTok 26-27% > Instagram 23% > YouTube 16-19% > Facebook 16-18%
5. **クリエイターの拡張計画**: YouTube 45% > Instagram/TikTok 41% > Facebook 35% > Snapchat 25%

## 6. 法規制

### 日本

| 規制 | 施行日 | 内容 | 影響 |
|------|-------|------|------|
| ステマ規制（景品表示法改正） | 2023年10月 | 事業者からの依頼に基づく投稿にPR表記義務 | SNS投稿テンプレートにPR表記ガイドを組み込む必要あり |
| PR表記ルール | 2023年10月 | 「PR」「広告」「プロモーション」等の明示。プラットフォーム別の表記位置指針あり | スキルにPR表記自動付与機能を含めるべき |
| AI生成コンテンツ開示 | 明確な法律なし（2026時点） | 景表法の優良誤認・有利誤認の一般規定で対応 | AI利用の開示は法的義務ではないが推奨 |

### EU

| 規制 | 施行日 | 内容 | 影響 |
|------|-------|------|------|
| AI Act Article 50 | 2026年8月 | AI生成コンテンツの機械可読ラベリング義務 | AI生成コンテンツに自動でメタデータ付与が必要 |
| ディープフェイク開示 | 2026年8月 | AI生成/加工の画像・音声・動画の開示義務 | AI生成動画にラベル必須 |
| AI生成テキスト開示 | 2026年8月 | 公共の利益に関するAI生成テキストの開示義務（人間がレビューし編集責任を負う場合は例外） | ニュース・教育コンテンツに影響大 |
| Code of Practice | 2026年6月最終版予定 | ラベリング・透明性のCode of Practice（第2稿: 2026年3月） | 実装ガイドライン |

### 米国

| 規制 | 施行日 | 内容 | 影響 |
|------|-------|------|------|
| カリフォルニアAI透明性法 (SB 942) | 2026年1月 | AI生成/加工コンテンツの開示・検出ツール義務 | カリフォルニア在住ユーザー向けの特別対応 |
| ニューヨーク合成パフォーマー法 | 2026年6月 | 広告での合成パフォーマーの「目立つ」開示義務。違反: 初回$1,000、再犯$5,000 | 広告コンテンツでのAIアバター使用に影響 |
| FTC AI規制 | 随時 | AI生成レビュー・推薦の規制強化。Rytr社への命令が先例 | AI生成レビューの大量生成は違法リスク |
| 連邦 vs 州の対立 | 進行中 | 大統領令で州レベルのAI規制を停止する動き | 規制の統一化待ち |

### 規制対応のベストプラクティス

1. AI生成コンテンツには常にラベルを付ける（法的義務の有無に関わらず）
2. 広告・PRコンテンツには適切な開示表記を最上部に配置
3. AI生成レビュー・推薦文の大量生成は避ける
4. 各国/地域の規制動向を四半期ごとにチェック
5. コンテンツ生成スキルに法規制チェックリストを組み込む

## 7. AIエージェント活用のポイント

### 自動化すべき領域（AI向き）

| 領域 | 理由 | 推奨AIツール/手法 |
|------|------|-----------------|
| トレンド分析・キーワードリサーチ | 大量データの高速処理 | Web検索API + 分析エージェント |
| コンテンツ下書き・バリエーション生成 | 量産が必要、人間が最終編集 | LLM + プロンプトテンプレート |
| プラットフォーム別フォーマット変換 | 定型的な変換作業 | テンプレート + LLM |
| スケジューリング・配信 | 単純な自動化 | API連携（AiToEarn MCP等） |
| KPIデータ収集・レポート生成 | データ集約の定型作業 | API連携 + 可視化エージェント |
| A/Bテスト実行 | 複数バリエーションの管理 | 自動化ワークフロー |
| 定型コメント返信 | パターンマッチ可能な対応 | LLM + テンプレート |
| SEO最適化（メタデータ、構造化データ） | 技術的な最適化作業 | LLM + ルールベース |

### 人間がやるべき領域

| 領域 | 理由 |
|------|------|
| ブランド戦略・方向性の決定 | 長期的ビジョン、市場ポジショニング |
| 独自の視点・オピニオンの付加 | 差別化の源泉、ブランド同質化の防止 |
| 感情的共鳴の設計 | 文化的コンテキスト、タイミング |
| コミュニティとの深い関係構築 | 信頼、共感、ロイヤリティ |
| 危機対応・センシティブな話題 | 判断力、共感力 |
| 法規制コンプライアンスの最終判断 | 責任の帰属、リスク判断 |
| 収益戦略の決定・価格設定 | ビジネス判断 |
| パートナーシップ・スポンサーシップ交渉 | 対人スキル、交渉力 |

### AIエージェント設計の原則（2026ベストプラクティス）

1. **AI = クリエイティブ・コパイロット**: AIはフレームワーク作成、トーン分析、表現テストを担当。人間がオーディエンス心理とブランドニュアンスに適応
2. **多層品質管理**: 自動バリデーション + 人間のクリエイティブ判断の組み合わせ
3. **フィードバックループ**: AI出力の品質評価 → プロンプト改善 → 精度向上のサイクル
4. **段階的導入**: リサーチ → 下書き → 配信の順に自動化範囲を拡大
5. **ブランド同質化の回避**: AI依存が高まるほど「人間らしさ」が差別化要因になる

## 8. ハーネス設計への示唆

### CLAUDE.mdに含めるべき業務知識

コンテンツ収益化プロジェクトのCLAUDE.mdには、以下のドメイン固有知識を段階的に開示:

```markdown
## ビジネスコンテキスト
- 対象プラットフォーム: [YouTube, TikTok, Instagram, ...]
- 収益モデル: [CPS, CPE, CPM, サブスクリプション, アフィリエイト, ...]
- 主要KPI: [CTR, CVR, エンゲージメント率, RPM, 月間収益, ...]
- コンテンツ戦略: [Hub-and-Spokeモデル, プラットフォーム別最適化, ...]

## 法規制
- ステマ規制（景品表示法）: PR表記必須
- AI生成コンテンツの開示: [各国規制に準拠]
- アフィリエイト開示: [FTC/景表法準拠]

## AI活用方針
- 自動化対象: [リサーチ, 下書き, フォーマット変換, 配信, 分析]
- 人間承認必須: [最終コンテンツ, ブランド戦略, 法規制判断]
```

### 業務特化スキル候補

| スキル名 | 機能 | 入力 | 出力 |
|---------|------|------|------|
| content-ideation | トレンド分析+コンテンツ企画 | ニッチ、プラットフォーム | 企画リスト（タイトル、フック、ハッシュタグ） |
| content-repurpose | Hub-and-Spokeリパーパス | 元コンテンツ、対象プラットフォーム一覧 | プラットフォーム別バリエーション |
| platform-optimize | プラットフォーム別最適化 | コンテンツ、対象プラットフォーム | フォーマット、サイズ、キャプション、ハッシュタグ調整版 |
| compliance-check | 法規制チェック | コンテンツ、対象地域 | 違反リスク指摘、修正提案 |
| kpi-report | KPIレポート生成 | データソース、期間 | 可視化レポート、改善提案 |
| revenue-forecast | 収益予測 | 過去データ、計画 | 期待収益、シナリオ分析 |

### 業務特化ルール候補

| ルール名 | 適用条件 | 内容 |
|---------|---------|------|
| pr-disclosure | コンテンツに広告要素がある場合 | PR表記の自動チェック・提案 |
| ai-label | AI生成コンテンツの場合 | AI生成ラベルの自動付与 |
| platform-format | 投稿コンテンツ生成時 | プラットフォーム別のフォーマット制約チェック |
| brand-voice | コンテンツ生成時 | ブランドトーン・ガイドラインとの整合性チェック |
| watermark-check | クロスプラットフォーム配信時 | 他プラットフォームのウォーターマーク有無チェック |

### 収益KPIモニタリング用エージェント設計

```yaml
# エージェント定義例
name: revenue-monitor
description: "コンテンツ収益化KPIの定期追跡・分析・アラートエージェント"
schedule: weekly
tasks:
  - collect_platform_metrics  # 各プラットフォームからKPI収集
  - calculate_revenue_kpi     # RPM, ARPU, LTV等の計算
  - generate_weekly_report    # 週次レポート生成
  - detect_anomalies          # 異常値検出（急激なエンゲージメント低下等）
  - suggest_optimizations     # 最適化提案（投稿時間、フォーマット変更等）
alerts:
  - engagement_drop: ">20% decrease week-over-week"
  - revenue_target: "<80% of monthly target at midpoint"
  - compliance_issue: "PR disclosure missing"
```

---

## Claude/Codexクロスレビュー統合知見

### Codex独自調査からの追加（Claude側に不足していた観点）

**ワークフローstate machine（Codex提案）:**
```
brief → content_generated → compliance_checked → platform_adapted → scheduled
  → published → proof_collected → ai_reviewed → human_reviewed → settled → withdrawn

failure branches:
  → rejected → appealed → refunded → incident_open
```
多くのチームは`published`でworkflowが終わる前提で設計するが、収益化案件では`published`は中間地点でしかない。

**Minimum Artifact Set（Codex提案）:**
- `platform-capabilities.yaml` — プラットフォーム対応をmarketing copyではなくmachine-readableで管理
- `campaign-schema.json` — キャンペーンメタデータのスキーマ
- `workflow-state-machine.md` — 上記state machineの詳細定義
- `compliance-checklist.md` — publish前の法規制チェックリスト
- `proof-policy.md` — 証跡収集のポリシー（URL, screenshot, API metric, coupon）
- `settlement-ledger-spec.md` — 精算台帳の仕様（content DBと分離）
- `kpi-taxonomy.md` — 収益モデル別のKPI体系

**3つのハーネス戦略オプション（Codex提案）:**

| オプション | 強み | 弱み | 適用場面 |
|-----------|------|------|---------|
| Distribution-first | 立ち上がりが速い | 収益attributionが浅い | 新規メディア立ち上げ |
| Compliance-first | 規制事故を減らせる | 初速が落ちる | 企業案件、越境配信 |
| Commerce-first | 売上と直結する | 実装が重い | affiliate、EC、店舗送客 |

**推奨:** Compliance-firstを常時オンにしたDistribution-firstを基本形。注文データが揃う案件のみCommerce-firstを追加。

**デフォルト運用方針（Codex提案）:**
- AIは「企画/下書き/媒体別変換/集計/一次審査」に使う
- 「法規制判断/ブランド最終責任/支払い承認」は人間が持つ
- Engage automationはhigh-risk featureとして隔離する
- SNSの外にowned audience（newsletter, blog, CRM）を必ず逃がす

## Sources

- [AI in Creator Economy Market Report 2025](https://www.globenewswire.com/news-release/2026/01/07/3214696/28124/en/Artificial-Intelligence-in-Creator-Economy-Global-Market-Report-2025-Growth-Driven-by-Adoption-of-AI-Tools-Personalized-Content-Demand-Influencer-Led-Brand-Collabs-and-Investment-i.html)
- [Creator Monetization Platform Analysis 2026](https://www.globenewswire.com/news-release/2026/02/13/3237923/28124/en/Creator-Monetization-Platform-Analysis-Report-2026-29-07-Bn-Market-Opportunities-Trends-Competitive-Landscape-Strategies-and-Forecasts-2020-2025-2025-2030F-2035F.html)
- [Creator Economy 2026 Outlook - Digiday](https://digiday.com/marketing/in-graphic-detail-heres-what-the-creator-economy-is-expected-to-look-like-in-2026/)
- [2026 Monetization Deep Dive - Logie AI](https://logie.ai/news/the-2026-monetization-deep-dive/)
- [AI Monetization Models 2026 - Logie AI](https://logie.ai/news/what-creators-need-to-know-about-ai-monetization-models-in-2026/)
- [Platform-Specific Creator Strategy 2026 - InfluenceFlow](https://influenceflow.io/resources/platform-specific-creator-strategy-the-complete-2026-guide-to-multi-platform-success/)
- [Multi-Platform Social Media Benchmarks 2026](https://www.podcastvideos.com/articles/cross-platform-social-media-marketing-benchmarks-2026/)
- [AI Content Creation 2026 - Aurora](https://hiaurora.ai/learning-vault/ai-content-creation-2026-and-beyond/)
- [AI + Human Creativity 2026 - Web Marketing Academy](https://www.webmarketingacademy.in/digital-marketing-blogs/ai-human-creativity-what-the-best-marketers-will-do-differently-by-2026/)
- [Which Social Platform Pays Most 2026 - Zeely](https://zeely.ai/blog/which-social-media-platform-pays-the-most/)
- [YouTube CPM 2026 - upGrowth](https://upgrowth.in/youtube-cpm-explained/)
- [Influencer Marketing Benchmarks 2026 - InfluenceFlow](https://influenceflow.io/resources/influencer-marketing-benchmarks-and-industry-comparisons-2026/)
- [EU AI Act Article 50](https://artificialintelligenceact.eu/article/50/)
- [EU Code of Practice on AI-Generated Content](https://digital-strategy.ec.europa.eu/en/policies/code-practice-ai-generated-content)
- [California AI Transparency Act](https://natlawreview.com/article/what-digital-marketers-need-know-about-new-yorks-new-ai-disclosure-law)
- [FTC AI Enforcement](https://www.ftc.gov/industry/technology/artificial-intelligence)
- [Japan ステマ規制 - 消費者庁](https://www.caa.go.jp/policies/policy/representation/fair_labeling/stealth_marketing/)
- [How to Make Money on Substack 2026 - Shopify](https://www.shopify.com/blog/how-to-make-money-on-substack)
- [WordPress Blog Monetization 2026](https://wbcomdesigns.com/wordpress-blog-monetization-revenue-streams/)
- [Meta Creator Pay 2026 - CNBC](https://www.cnbc.com/2026/03/18/meta-creator-pay-instagram-tiktok-youtube-facebook.html)
