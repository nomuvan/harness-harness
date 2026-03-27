---
name: "autoresearch"
url: "https://github.com/karpathy/autoresearch"
type: tool
tags: [autonomous-loop, ml-training, hill-climbing, experiment-management, program-md, minimalism]
stars: 56900
license: "MIT"
last_checked: "2026-03-27"
relevance: high
summary: "AIエージェントにLLM訓練を自律的に実験させるミニマルなループツール。設計パターンの汎用性が高い"
---

# Karpathy autoresearch 深掘り分析

- URL: https://github.com/karpathy/autoresearch
- 作者: Andrej Karpathy (@karpathy)
- ライセンス: MIT（READMEに明記、ただしGitHub APIではlicense未設定）
- GitHub Stars: 56,900+
- Forks: 7,918
- Open Issues/PRs: 157
- Contributors: 8（Karpathy本人が28コミットで圧倒的、他7名は各1コミット）
- 言語: Python（630行の単一ファイル `train.py` が核心）
- 作成日: 2026-03-06
- 最終更新: 2026-03-26（活発に更新中）
- 調査日: 2026-03-26

## 概要

autoresearchは「AIエージェントに小さいが本物のLLM訓練セットアップを与え、一晩中自律的に実験させる」プロジェクト。エージェントがコードを修正し、5分間訓練し、結果が改善したか確認し、保持or破棄を繰り返す。ユーザーは朝起きると実験ログと（うまくいけば）改善されたモデルを手にする。

Karpathy自身のREADME冒頭の宣言が象徴的:

> *One day, frontier AI research used to be done by meat computers in between eating, sleeping, having other fun... Research is now entirely the domain of autonomous swarms of AI agents running across compute cluster megastructures in the skies.*

2026年3月7日のリリース後、X/Twitterでの告知が860万ビューを獲得。2日で21,000+ Starsに到達し、3週間で56,900+ Starsに成長。Fortune誌が「The Karpathy Loop」と命名して記事化するなど、ML/AIコミュニティで2026年3月最大のバズとなった。

## アーキテクチャ

### 3ファイル構成（意図的にミニマル）

| ファイル | 役割 | 編集者 |
|----------|------|--------|
| `prepare.py` | 固定定数、データ準備（DL・BPEトークナイザ訓練）、ランタイムユーティリティ（データローダ・評価） | 修正不可 |
| `train.py` | GPTモデル、オプティマイザ（Muon + AdamW）、訓練ループ。630行 | **AIエージェントが編集** |
| `program.md` | エージェントへの指示書。超軽量な「スキル」 | **人間が編集** |

### エージェントループの詳細

`program.md` に記述された実験ループは以下の通り:

1. gitブランチを作成（`autoresearch/<tag>`）
2. リポジトリの全ファイルを読み込みコンテキスト理解
3. ベースライン実験を実行（現状の `train.py` をそのまま実行）
4. **LOOP FOREVER**:
   a. `train.py` を実験的アイデアで修正
   b. git commit
   c. `uv run train.py > run.log 2>&1` で実験実行（5分固定）
   d. `grep "^val_bpb:" run.log` で結果抽出
   e. 改善 → ブランチを進める / 悪化 → `git reset` で巻き戻し
   f. `results.tsv` に記録（commit, val_bpb, memory_gb, status, description）
   g. クラッシュ → スタックトレース読んで修正試行、ダメなら次へ
5. **NEVER STOP**: 人間が手動で停止するまで永遠に継続

### 重要な設計制約

- **単一ファイル修正**: エージェントは `train.py` のみ編集。スコープを管理可能に保つ
- **固定時間予算**: 訓練は常に5分（壁時計時間）。プラットフォーム間で比較不能だが、実験間では公平
- **単一メトリクス**: `val_bpb`（validation bits per byte）のみ。低いほど良い。vocab_size非依存
- **自己完結型**: PyTorchと少数パッケージのみ。分散訓練なし、複雑な設定なし。1 GPU、1ファイル、1メトリクス
- **簡潔性基準**: 同等なら単純な方を優先。0.001改善で20行追加はNG。コード削減で同等性能はkeep

### 使用LLM

特定のLLMに依存しない設計。`program.md` を任意のコーディングエージェントに渡す:

- **推奨**: Claude Code CLI、Codex CLI
- **対応可能**: 任意のコーディングエージェント（「disable all permissions」を推奨）
- READMEのクイックスタートでは「Simply spin up your Claude/Codex or whatever you want」と明記

## 主要機能・特徴

### 1. 自律的実験ループ
- 人間不在で一晩100実験を自動実行（12実験/時間 × 8時間）
- 改善のみ保持するhill-climbing方式
- git commitベースの実験管理（巻き戻し可能）

### 2. program.md: 人間が書く「研究組織コード」
- Markdownで研究方針・制約・判断基準を記述
- エージェントの行動をガイドするが、具体的な実装は任せる
- Karpathyは「研究組織コード」として最適化の対象と位置付け

### 3. 結果の転移性
- depth=12モデルで発見した20の改善がdepth=24モデルに全て転移
- Time to GPT-2 ベンチマーク: 2.02h → 1.80h（11%改善）
- 小さいモデルでの高速実験 → 大きいモデルへの転移が成立

### 4. 発見された具体的改善例
- QKnormにscaler multiplierが欠落していた発見
- Value Embeddingsに正則化が必要だった発見
- banded attentionが保守的すぎた発見
- AdamWのbetasが誤設定されていた発見
- weight decayスケジュールの最適化
- ネットワーク初期化の最適化

## 技術スタック

### 依存関係（pyproject.toml）

| パッケージ | バージョン | 用途 |
|-----------|-----------|------|
| torch | 2.9.1 (CUDA 12.8) | PyTorch本体 |
| kernels | >=0.11.7 | Flash Attention 3カーネル |
| numpy | >=2.2.6 | 数値計算 |
| pandas | >=2.3.3 | 結果分析 |
| matplotlib | >=3.10.8 | 可視化 |
| pyarrow | >=21.0.0 | Parquetデータ読み込み |
| rustbpe | >=0.1.0 | Rust実装BPEトークナイザ |
| tiktoken | >=0.11.0 | トークナイザ |
| requests | >=2.32.0 | データダウンロード |

### パッケージ管理

- **uv**: Astral製の高速Pythonパッケージマネージャ
- Python 3.10+

### モデルアーキテクチャ（train.py）

- GPT系アーキテクチャ（`GPTConfig` dataclass）
- Flash Attention 3（Hopper GPU用 `varunneal/flash-attention-3`、非Hopper用 `kernels-community/flash-attn3`）
- RoPE（Rotary Position Embeddings）
- RMSNorm
- Value Embeddings（ResFormer由来、交互レイヤーで適用）
- GQA（Grouped Query Attention）サポート
- Muon + AdamWオプティマイザ（2系統のパラメータグループ）
- 自動Mixed Precision（bfloat16）

### データ

- **訓練データ**: `karpathy/climbmix-400b-shuffle`（HuggingFace Datasets）
- **トークナイザ**: BPE、vocab_size=8192、GPT-4スタイルの分割パターン
- **コンテキスト長**: 2048トークン
- **評価**: 40 × 524,288トークンの検証セット

### プラットフォーム

- **公式対応**: NVIDIA GPU（H100でテスト済み）
- **コミュニティフォーク**: macOS (MLX/MPS)、Windows (RTX)、AMD (ROCm)、Slurm/HPCクラスタ

## インストール・使用方法

```bash
# 1. uvインストール
curl -LsSf https://astral.sh/uv/install.sh | sh

# 2. 依存関係インストール
uv sync

# 3. データ準備（1回のみ、約2分）
uv run prepare.py

# 4. 手動テスト実行（約5分）
uv run train.py

# 5. 自律研究モード: Claude Code等を起動し以下を入力
# "Hi have a look at program.md and let's kick off a new experiment! let's do the setup first."
```

## Web上の評判・反響

### メディア報道

| メディア | タイトル | 論調 |
|---------|---------|------|
| Fortune | 「The Karpathy Loop: 700 experiments, 2 days」 | AI研究の未来を示唆する画期的プロジェクト |
| VentureBeat | 「revolutionary implications」 | 一晩で数百の実験を自動実行する革命的ツール |
| The New Stack | 「630-line Python script ran 50 experiments overnight」 | 技術的ミニマリズムの勝利 |
| DataCamp | チュートリアル記事 | 教育コンテンツ化 |

### X/Twitter

- Karpathyの告知ツイートが**860万ビュー**を記録
- Shopify CEO Tobias Lutkeが自社モデルに適用、**37実験で19%改善**を報告
  - さらにLiquid（Shopifyテンプレートエンジン）に適用: **53%高速化、61%メモリ削減、93コミット自動生成**
- 「SETI@homeスタイルの非同期大規模エージェント協調」がKarpathyの次ステップ構想

### Hacker News

- 複数のフロントページ投稿
- 「エージェントがRLHFの影響で保守的すぎる」問題をKarpathy自身がHNで言及
- 「古典的ブラックボックス最適化の方が優れるケースがある」との指摘も
- 安全に無人実行できる設計パターン（1ファイル、1メトリクス、時間制限、gitチェックポイント）への評価

### YouTube・ブログ

- 24分のウォークスルー動画が公開
- Medium、Substack、DataCampで複数のチュートリアル記事
- 「Autoresearch 101 Builder's Playbook」（応用ガイド）が人気

### コミュニティ派生プロジェクト

| プロジェクト | Stars | 概要 |
|-------------|-------|------|
| VoidLight00/autoimprove-cc | 52 | Claude Code CLAUDE.md自動改善 |
| cavit99/autoresearch-autoresearch | 41 | メタリポジトリ（パターン抽出） |
| HuangShengZeBlueSky/MLP_AutoResearch | 30 | MLP最適化への応用 |
| jung-wan-kim/autoresearch-builder | 19 | Claude Code用汎用実験テンプレート |
| mattlungrenmd/autoresearch-medimage | 5 | 医療画像AI研究への応用 |

## 類似ツールとの比較

### カテゴリの違い

autoresearchは**コード実験ループ**（edit → benchmark → keep/revert）であり、GPT-ResearcherやSTORMなどの**情報合成ツール**（web検索 → 読解 → レポート生成）とは根本的に異なるカテゴリ。

| 観点 | autoresearch | GPT-Researcher | STORM |
|------|-------------|----------------|-------|
| **目的** | コードの自律的改善 | 情報収集・レポート生成 | 知識合成・Wiki生成 |
| **入力** | コード + 評価メトリクス | 自然言語クエリ | 研究トピック |
| **出力** | 改善されたコード + 実験ログ | 構造化レポート | Wiki形式記事 |
| **ループ** | edit→run→eval→keep/discard | search→read→synthesize | multi-agent会話→RAG |
| **必要なもの** | GPU + コーディングエージェント | API key | API key |
| **自律度** | 完全自律（NEVER STOP） | 1回のクエリで完結 | 1回のクエリで完結 |
| **スコアリング** | 定量的（val_bpb） | 定性的 | 定性的 |

### 同カテゴリの比較（自律的コード改善）

| 観点 | autoresearch | AutoKernel | VoidLight00/autoimprove-cc |
|------|-------------|------------|---------------------------|
| **対象** | LLM訓練コード | GPUカーネル | CLAUDE.md |
| **実験速度** | ~12/時間（5分/回） | ~40/時間（90秒/回） | 可変 |
| **メトリクス** | val_bpb | レイテンシ | 定性評価 |

### autoresearchの本質的独自性

autoresearchの核心は**MLでもGPUでもなく、パターンそのもの**にある:

1. **スコア可能な単一メトリクス**があること
2. **人間不在でスコアリングが実行**できること
3. **edit→run→eval→decision**のループが自動化されること

この3条件を満たせば、マーケティング、プロンプトエンジニアリング、トレーディング戦略、テンプレートエンジン最適化など、あらゆるドメインに適用可能。実際にShopify Liquidへの適用で実証済み。

## ソースコード品質評価

### 強み

- **極端なミニマリズム**: 3ファイル、630行。理解・改造が容易
- **明確な責務分離**: prepare.py（不変の基盤）/ train.py（実験対象）/ program.md（指示）
- **堅牢なエラー処理**: NaN/loss爆発の高速フェイル、OOMリカバリ指示
- **GC最適化**: `gc.freeze()` + `gc.disable()` でPythonのGCストールを回避（500ms→0ms）
- **プロダクション品質のML**: Flash Attention 3、RoPE、GQA、Muon optimizer、bfloat16 AMP
- **自己文書化**: `program.md` がエージェントへの完全な行動指示書として機能

### 弱み・制限

- **ライセンスファイル未配置**: READMEにMITと記載あるがLICENSEファイルがない（GitHub APIでもlicense: null）
- **NVIDIA GPU限定**: 公式にはH100向け。他プラットフォームはフォーク任せ
- **hill-climbing only**: 局所最適に陥る可能性。探索戦略の多様化は `program.md` に依存
- **単一エージェント・同期的**: Karpathy自身が「次のステップはSETI@homeスタイルの非同期大規模協調」と言及
- **テストなし**: ユニットテスト・CIは存在しない（意図的にミニマルだが）
- **パッケージ追加不可制約**: `pyproject.toml` の変更禁止により実験の自由度に制限

### コード設計パターンの評価

| パターン | 評価 |
|---------|------|
| 単一ファイル修正 | 優秀。スコープ爆発を防止 |
| 固定時間予算 | 優秀。実験間の公平性を担保 |
| git checkpoint | 優秀。常に巻き戻し可能 |
| TSV結果ログ | 良好。シンプルだが分析には十分 |
| NEVER STOP指示 | 革新的。エージェントの保守的傾向に対抗 |
| 簡潔性基準 | 優秀。複雑性の爆発を防止 |

## harness-harnessへの適用可能性

### 1. patrol-docs スキルへの応用

autoresearchの「LOOP FOREVER + 単一メトリクス + keep/discard」パターンは、ドキュメント巡回に直接応用可能:

- **メトリクス案**: 公式ドキュメントと `specs/` の差分スコア（新規追加項目数、非推奨項目数）
- **ループ**: specs/の各仕様書に対して「公式ドキュメントとの整合性チェック → 差分検出 → 更新提案 → 品質スコア計算」を巡回
- **keep/discard**: 整合性スコアが向上した変更のみマージ

### 2. research-kb プロセスへの応用

現在の手動調査プロセスを autoresearch パターンで自動化:

- **対象**: kb/external/ の各プロジェクト分析
- **メトリクス**: カバレッジスコア（必須セクション充足率）、鮮度スコア（最終更新日との差）
- **ループ**: GitHub API + Web検索で情報収集 → analysis.md更新 → スコア計算 → keep/discard
- **NEVER STOP**: 監視対象プロジェクト全件を巡回し終えるまで停止しない

### 3. 自己改善サイクルへの応用（最大のポテンシャル）

autoresearchの最も強力な知見は「**program.mdこそが最適化対象**」という認識:

- **harness-harness自体のCLAUDE.mdをautoresearchループで改善**
- **メトリクス**: ハーネス生成品質スコア（テンプレート充足率、specs整合性、ユーザー満足度プロキシ）
- **ループ**: CLAUDE.mdを修正 → テストプロジェクトにハーネス生成 → 品質スコア計算 → keep/discard
- 派生プロジェクト `VoidLight00/autoimprove-cc` が既にCLAUDE.md自動改善を実装済み

### 4. テンプレート最適化

- `templates/` 内の各テンプレートをautoresearchパターンで最適化
- メトリクス: 生成されたハーネスの「specs/との整合性スコア」
- Claude⇔Codex変換精度の自動改善も可能

### 5. program.mdパターンのハーネス化

autoresearchの `program.md` 自体が「軽量スキル」のベストプラクティス:

- 明確なセットアップ手順
- CAN/CANNOT の明示
- 評価メトリクスの定義
- NEVER STOPの自律性指示
- keep/discardの判断基準

この構造を harness-harness のスキルテンプレートに取り込むべき。

### 具体的アクションアイテム

1. **即座に可能**: `program.md` のパターンを `templates/` に新テンプレートとして追加
2. **短期**: patrol-docs に autoresearch ループパターンを組み込み
3. **中期**: CLAUDE.md 自動改善ループの構築（autoimprove-cc参考）
4. **長期**: harness-harness 全体の自己改善を autoresearch パターンで自動化

## 参考リンク

- [GitHub: karpathy/autoresearch](https://github.com/karpathy/autoresearch)
- [Karpathy告知ツイート](https://x.com/karpathy/status/2030371219518931079)
- [700実験の結果報告ツイート](https://x.com/karpathy/status/2031135152349524125)
- [次ステップ構想ツイート（SETI@home型協調）](https://x.com/karpathy/status/2030705271627284816)
- [Fortune: The Karpathy Loop](https://fortune.com/2026/03/17/andrej-karpathy-loop-autonomous-ai-agents-future/)
- [VentureBeat: revolutionary implications](https://venturebeat.com/technology/andrej-karpathys-new-open-source-autoresearch-lets-you-run-hundreds-of-ai)
- [DataCamp: Guide to AutoResearch](https://www.datacamp.com/tutorial/guide-to-autoresearch)
- [Autoresearch 101 Builder's Playbook](https://sidsaladi.substack.com/p/autoresearch-101-builders-playbook)
- [MindStudio: AutoResearch Pattern for Claude Code Skills](https://www.mindstudio.ai/blog/karpathy-autoresearch-pattern-claude-code-skills)
- [cavit99/autoresearch-autoresearch（メタリポジトリ）](https://github.com/cavit99/autoresearch-autoresearch)
- [VoidLight00/autoimprove-cc（CLAUDE.md自動改善）](https://github.com/VoidLight00/autoimprove-cc)
