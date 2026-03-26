# autoresearch からの知見と採用判断

調査日: 2026-03-26
対象: https://github.com/karpathy/autoresearch

## 方針

autoresearchはML訓練の自律最適化ツールだが、その本質は**「良い自律ループは可変面を狭くし、評価器を固定し、改善だけ進め、失敗を安く捨てる」という設計原則**にある。harness-harnessにはML部分ではなく、この設計パターンを取り込む。

## 採用判断

| パターン/機能 | 判定 | 理由 | 適用方法 |
|-------------|------|------|---------|
| 固定評価器 + 単一可変面の分離 | **採用** | 透過性と安全性の両方に効く。何が変わり何が不変かが明確 | スキル設計で「不変の判定基準」と「可変の編集対象」を明示分離 |
| program.md（Markdownで研究方向を指示） | **採用** | harness-harnessの「スキルは宣言的」「Markdownベース」と同型 | SKILL.mdのフォーマットとして既に実現済み。CAN/CANNOTの明示を強化 |
| keep/discard/crashの台帳記録 | **採用** | 自律改善サイクルの監査性を高める | logs/evaluations/に実験結果のkeep/discard記録パターンを追加 |
| gitブランチ=実験ログ | **採用** | ブランチ履歴が「勝ち筋の累積」になる | worktree+featureブランチの既存パターンと整合 |
| 5分固定の時間予算 | **検討** | 時間予算による公平比較は有用。ただし巡回等は時間予算が不適切な場合あり | タスク種別に応じて予算（時間/コスト/イテレーション）を選択 |
| NEVER STOP（無限ループ） | **不採用** | 母艦ハーネスには強すぎる。複数プロジェクト管理で無限ループは危険 | 明示的な停止条件（イテレーション数、コスト上限、改善なしN回で終了）を設ける |
| 単一メトリクス（val_bpb） | **不採用** | 実プロジェクトの改善は多目的（正しさ、保守性、テスト、速度） | 複数指標の重み付けか、AIエージェントの総合判断に委ねる |
| results.tsv（untracked） | **不採用** | 個人実験には軽いが母艦の知識蓄積には弱い | git管理するか、private submoduleに保存 |
| NVIDIA/H100依存 | **不採用** | Mac/Windows両対応方針と正面衝突 | autoresearchのML部分は対象外。設計パターンのみ取り込む |

## harness-harnessへの組み込み指針

### bounded autoresearch pattern（Codex提案、Claude同意）

autoresearchを一般化した「制約付き自律改善パターン」として以下の6要素をテンプレート化:

1. **不変の評価器（immutable judge）**: 何をもって「改善」とするかの基準を固定
2. **可変対象の明示（mutable allowlist）**: エージェントが編集してよいファイル/範囲を限定
3. **明示的な予算（budget）**: 時間/コスト/イテレーション数の上限
4. **台帳記録（ledger）**: keep/discard/crashを記録。失敗も資産
5. **ブランチ命名規約**: 実験ブランチの命名で追跡可能性を確保
6. **運用プロファイル**: safe/author/ciに応じた自律度の切り替え

### 既存スキルへの適用

- **patrol-docs**: 「specs/と公式ドキュメントの整合性」を評価器とした巡回ループ
- **self-eval**: keep/discard台帳パターンで改善履歴を蓄積
- **autonomous-task（project-alpha）**: 可変面の明示（SKILL.mdで編集対象を限定）

### 新規テンプレート候補

- `templates/research-loop/`: program.md相当のMarkdown、評価基準、許可された編集面、停止条件、ログ保存先を生成するテンプレート

### 組み込むべきでないもの

- **ML訓練基盤そのもの**: autoresearchのtrain.py/prepare.pyは対象外。GPU依存でMac/Windows非対応
- **NEVER STOP**: 母艦には明示的な停止条件が必須
- **単一メトリクス固定**: 実プロジェクトは多目的

## Claude/Codexクロスレビュー結果

### Claude評価
- アーキテクチャの3ファイル構成、program.mdパターン、派生プロジェクト（autoimprove-cc等）の調査が充実
- Fortune誌「The Karpathy Loop」命名やWeb評判の広さを網羅
- harness-harnessへの適用としてCLAUDE.md自動改善、patrol-docsへのループパターン組み込みを具体提案

### Codex評価
- train.pyのアーキテクチャ詳細（value embedding, rotary, relu², MuonAdamW等）まで深掘り。Claudeより技術的に深い
- Web評判でseed hacking批判、OAuth outage、「Claude always ask questions」問題まで拾っている
- **「bounded autoresearch pattern」として6要素をテンプレート化する提案**が秀逸。母艦設計に直結する抽象化
- Mac/Windows両対応の観点でfork生態系のportability signalを読んでいる

### 統合判断
- Codexの「bounded autoresearch pattern」概念を採用し、harness-harnessの設計原則に組み込む
- Claudeの派生プロジェクト調査（autoimprove-cc）は具体的な適用先として有用
- 両者とも「そのまま移植ではなく設計パターンの抽出」で一致。これが正しい方向
