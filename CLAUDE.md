# harness-harness

ハーネスを作り、育て、壊して作り直すハーネスの母艦。

## プロジェクト概要

- 対象AI実行基盤: Claude Code CLI (.claude), Codex CLI (.codex)
- ユーザーの既存・新規プロジェクトのハーネスを作成・育成・診断・破壊再構築する
- harness-harness自体も自己改善の対象

## ディレクトリ構成

- `docs/` — 思想・方針、アーキテクチャ、規約
- `specs/` — Claude Code, Codex CLIの仕様書
- `kb/` — 外部プロジェクト調査、業務ドメイン知見、戦術的知見
- `templates/` — ハーネステンプレート（Claude/Codex × 目的別）
- `mapping/` — Claude⇔Codex変換ルール
- `registry/` — 管理対象プロジェクト一覧（テンプレート。実データはprivate/）
- `scripts/` — クロスプラットフォームユーティリティ
- `logs/` — 巡回・評価ログ（匿名化済み。原本はprivate/）
- `private/` — git submodule（harness-harness-private）。プロジェクト固有情報

## 重要方針

- `docs/philosophy.md` を必ず参照すること
- 多様性は善：答えを一つに絞らず、pros/consを明示して選択肢を残す
- 段階的開示：必要なときに必要なだけ情報を提示
- AIの優れた提案を優先：指示追従より良いアイデアの提示を重視
- Mac/Windows両対応を前提とする
- 業務ドメイン知見はユーザー指示に基づきkb/domains/に蓄積（段階的開示で管理）

## 提供機能

- ハーネス作成: 新規プロジェクトにClaude/Codexハーネスを作成
- ハーネス診断: 既存ハーネスの妥当性・改善ポイントを診断
- ハーネス改善: 新機能のキャッチアップ、ベストプラクティス適用
- ハーネス破壊再構築: 陳腐化したハーネスを削除して作り直す
- Claude⇔Codex変換: 片方のハーネスからもう片方を生成
- プロジェクト間コピー補完: 汎用的なskill/rules/hooksを他プロジェクトにコピー・提案
- 外部調査・巡回: 公式ドキュメント・外部プロジェクトの更新キャッチアップ
- 自己評価・改善: harness-harness自体の自律的成長

## ハーネス設計原則

- ドメイン非依存な構造パターンとドメイン固有の専門知識を明確に分離する
- ユーザーの思想・方針（docs/philosophy.md）は全プロジェクト共通で適用する
- 機能ラインナップは省略せず網羅的に保持。コンテキスト過多は段階的開示で防ぐ
- 対象プロジェクトに適切なものだけ選択と集中でいいとこ取りする

## 開発プロセス

### ブランチ戦略
- `main`: 安定版。原則PR経由でマージ
- `feature/*`: 新機能・改善
- `plan/*`: 計画策定用（Claude/Codex計画等）
- private submoduleは本体と独立してmainに直接push可

### PR推奨
- 変更はfeature/ブランチで作業し、PR経由でmainにマージする
- 軽微な自己改善（typo修正、コメント追加等）のみmainに直接push可

### プライベート情報の分離
- プロジェクト固有の情報（プロジェクト名、パス、PR URL等）はprivate/ submoduleに格納
- public側のログ・registryは匿名化（project-alpha, project-beta等）
- private/ submoduleへのアクセス権がなくてもReadOnlyモードで利用可能（docs/readonly-mode.md参照）

## 作業時の注意

- specs/ の仕様書を根拠にハーネスを生成すること
- テンプレートの変更時は mapping/ の整合性も確認
- kb/ の更新時は kb/update-history.md に記録
- 自己改善時は docs/decisions/ にADRを残す
- 実験的機能は積極利用（docs/philosophy.md参照）
