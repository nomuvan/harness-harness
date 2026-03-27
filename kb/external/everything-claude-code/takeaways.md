---
name: "Everything Claude Code"
type: takeaways
tags: [4-layer-architecture, selective-install, security-guardrails, agents-md, rules-separation]
last_checked: "2026-03-27"
adoption_summary: "4層アーキテクチャ・AGENTS.md標準・フック安全3点セット・選択的インストールを高優先度で採用"
top_patterns:
  - "CLAUDE.md簡潔化＋rules/分離"
  - "フックベースのセキュリティガードレール3点セット"
  - "AGENTS.mdクロスツール標準化"
---

# Everything Claude Code — harness-harnessへの採用判断

## 採用判断テーブル

| # | パターン/機能 | 判定 | 理由 | 適用方法 |
|---|-------------|------|------|---------|
| 1 | **4層アーキテクチャ（Interaction/Intelligence/Automation/Learning）** | 採用（高） | harness-harnessのテンプレート設計の参照モデルとして有用。段階的開示と完全に合致する。各層を独立に設計・組合せ可能 | `templates/` の設計原則として4層分離を明文化。テンプレート生成時に「どの層をどこまで含めるか」の選択UIを設計 |
| 2 | **CLAUDE.mdは簡潔に、詳細はrules/に分離** | 採用（高） | ECCのCLAUDE.md自体が約60行と簡潔。ビルド/テスト/アーキテクチャの「地図」に集中し、行動指示はrules/へ。harness-harnessの「段階的開示」原則と一致 | `templates/claude/` のCLAUDE.mdテンプレートを「地図型」（簡潔）に設計。行動ルールは `.claude/rules/` テンプレートとして分離 |
| 3 | **選択的インストール（言語別マニフェスト）** | 採用（高） | 12言語対応を全部入りでなくマニフェスト駆動で選択。harness-harnessの「適切なものだけ選択と集中」原則に合致 | `scripts/` にハーネス生成時の言語/目的選択ロジックを実装。テンプレートのモジュール化を推進 |
| 4 | **フックベースのセキュリティガードレール** | 採用（高） | `--no-verify`ブロック、linter設定変更ブロック、シークレット検出の3点セットは全プロジェクトに推奨すべき基本ガードレール | `templates/claude/hooks/` に安全フック3点セットをデフォルトテンプレートとして追加。`|| true` 禁止のADR-001知見と統合 |
| 5 | **エージェントのYAML frontmatter標準** | 採用（高） | `name`, `description`, `tools`, `model` の4フィールドで必要十分。superpowersのSKILL.md標準と同様、harness-harnessテンプレートの標準形式として採用 | `templates/claude/agents/` テンプレートにfrontmatter標準を組込み。既存プロジェクトの診断時にフォーマット準拠をチェック |
| 6 | **ツール権限の最小化（Read-only reviewerパターン）** | 採用（高） | レビュー系エージェントをRead-onlyに制限する設計は安全で実践的。architect/plannerもRead+Grep+Globのみ | `templates/claude/agents/` のデフォルト権限をRead-only基準で設計。「書込みが必要な場合のみ明示的に追加」パターンを文書化 |
| 7 | **トークン最適化のモデル選択戦略** | 採用（中） | Haiku=探索, Sonnet=コーディング90%, Opus=設計/セキュリティ の使い分けは実用的。ただしモデル進化が速いため固定しすぎない | `docs/` にモデル選択ガイドラインを追加。テンプレートのエージェント定義で `model` フィールドの推奨値を言語化 |
| 8 | **メモリ永続化フック（PreCompact/Stop/SessionStart）** | 採用（中） | セッション間の知見持越しは長時間作業で必須。ただし実装はプロジェクト依存度が高い | `templates/claude/hooks/` にメモリ永続化フック（.tmp保存/読込）のテンプレートを追加。プロジェクトごとのカスタマイズガイド付き |
| 9 | **config-protection（linter設定変更ブロック）** | 採用（中） | エージェントがlinter/formatterの設定を緩めてエラーを「修正」する問題を防止。重要なガードレール | `templates/claude/hooks/` にconfig-protectionフックを追加。保護対象ファイルパターン（.eslintrc, biome.json, .ruff.toml等）をテンプレート化 |
| 10 | **継続学習v2（instinct → skill昇格パイプライン）** | 検討 | 信頼度スコア付きパターン蓄積は魅力的だが、実装が複雑。harness-harnessの範囲としてはパターン概念のみ取り込み、実装はECCに委ねるのが妥当 | `kb/` にinstinctパターンの概念文書を追加。将来的にkb/の知見に信頼度スコアを付与する設計の参考に |
| 11 | **プラグインマーケットプレース** | 検討 | ECCのプラグイン配布インフラは参考になるが、harness-harnessはメタハーネスであり直接プラグイン化する性質ではない | プラグイン配布形式の調査として `kb/` に記録。将来テンプレートをプラグインとして配布する可能性の検討材料 |
| 12 | **2インスタンスキックオフ（Scaffolding + Research同時起動）** | 検討 | 並列化の実践パターンとして面白い。ただし全プロジェクトに適用するほど汎用的ではない | `docs/` に並列ワークフローパターンとして記録。特定の大規模プロジェクトテンプレートに含める候補 |
| 13 | **3部構成ガイド（Shortform/Longform/Security）** | 参考 | ドキュメント構成の参考。段階的開示の具体例。ただしharness-harnessは既にdocs/の構造が確立 | ドキュメント設計の参考として記録。対象プロジェクトのハーネスに「README段階化」パターンを推奨する際の例 |
| 14 | **ECC_HOOK_PROFILE（minimal/standard/strict）** | 採用（中） | フックの強度を環境変数で制御するパターン。開発/CI/本番で使い分け可能 | `templates/claude/hooks/` にプロファイル制御の仕組みをテンプレート化。環境別の推奨プロファイルを文書化 |
| 15 | **MCP制限の明文化（10 MCP / 80ツール上限）** | 採用（中） | 「200kコンテキストが70kになりうる」警告は実践的。テンプレートに明記すべき | CLAUDE.mdテンプレートにMCP制限の推奨値を追記。診断時のチェック項目に「有効MCPツール数」を追加 |
| 16 | **125+スキルの「全部入り」アプローチ** | 不採用 | harness-harnessの方針「適切なものだけ選択と集中」に反する。ECCの選択的インストールはこの問題を緩和するが、根本的に「カタログから選ぶ」モデル | harness-harnessはテンプレートを小さく保ち、プロジェクト固有のスキルを生成・育成する方針を堅持 |
| 17 | **Node.jsフックスクリプト依存** | 不採用 | 非Node.jsプロジェクトでもNode.jsランタイムが必要になる設計は採用しない | harness-harnessのフックテンプレートはbash/node.js/python選択可能に。Mac/Windows両対応はNode.jsが有利だが強制しない |
| 18 | **AgentShield（1,282テスト）** | 参考 | セキュリティテストの規模は参考になるが、ECC固有のインフラに依存。harness-harnessが直接利用するものではない | セキュリティフックの設計パターンのみ参考。harness-harnessのテンプレートには軽量なセキュリティチェックを組込み |
| 19 | **AGENTS.mdクロスツール標準化** | 採用（高） | AGENTS.mdをリポジトリルートに配置することで、Codex, Copilot, Cursor, Windsurf, Amp, Devinが読み取る。最小コストで最大互換性 | `templates/` にAGENTS.mdテンプレートを追加。mapping/shared-concepts.mdにAGENTS.mdの位置づけを明記 |
| 20 | **言語別ルール分離（rules/common + rules/{lang}）** | 採用（高） | 共通ルールと言語固有ルールの分離は、テンプレートのモジュール化に直結 | `templates/claude/rules/` をcommon/ + 言語別に構造化。選択的インストールと組合せ |

## 横断的知見

### ECC最大の教訓: 「設定は微調整であり、アーキテクチャではない」

Shortform Guideの結論「Treat configuration as fine-tuning, not architecture」は重要。harness-harnessにとって:
- テンプレートは「出発点」であり「完成品」ではない
- プロジェクト固有のカスタマイズが常に必要
- テンプレートの価値は「ゼロから考える手間の削減」にある

### ECCから学ぶべき3つの設計原則

1. **コンテキスト予算の意識**: MCP/ツール数の制限、スキルのオンデマンドロード、メモリ永続化フックはすべてコンテキストウィンドウの有限性への対処
2. **安全ガードレールのデフォルト化**: `--no-verify`ブロック、config-protection、シークレット検出をデフォルトにする設計思想
3. **エージェントの最小権限原則**: reviewerはRead-only、plannerはRead+Search。書込み権限は実装エージェントのみ

### harness-harnessとの共存戦略

ECCはharness-harnessの「競合」ではなく「素材」:
- ECCのスキル/エージェント/フックのパターンをテンプレート設計の参考にする
- ECCを直接プラグインとして推奨するプロジェクトもありうる（大規模TypeScriptプロジェクト等）
- harness-harnessの価値は「ECCも含めた選択肢を提示し、プロジェクトに最適なハーネスを設計すること」

## 優先実施項目

1. **即時**: AGENTS.mdテンプレート作成、フック3点セット（no-verify/config-protection/secret-detect）テンプレート作成
2. **短期**: CLAUDE.md「地図型」テンプレート改訂、rules/のcommon+言語別構造化
3. **中期**: 選択的インストールスクリプト、メモリ永続化フックテンプレート、MCP制限ガイドライン
4. **長期**: instinctパターンのkb/知見管理への応用検討
