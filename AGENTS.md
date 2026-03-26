# harness-harness

ハーネスを作り、育て、壊して作り直すハーネスの母艦。

## プロジェクト概要

- 対象AI実行基盤: Claude Code CLI (.claude), Codex CLI (.codex)
- ユーザーの既存・新規プロジェクトのハーネスを作成・育成・診断・破壊再構築する
- harness-harness自体も自己改善の対象

## ディレクトリ構成

- `docs/` — 思想・方針、アーキテクチャ、規約
- `specs/` — Claude Code, Codex CLIの仕様書
- `kb/` — 外部プロジェクト調査、戦術的知見
- `templates/` — ハーネステンプレート（Claude/Codex × 目的別）
- `mapping/` — Claude⇔Codex変換ルール
- `registry/` — 管理対象プロジェクト一覧
- `scripts/` — クロスプラットフォームユーティリティ
- `logs/` — 巡回・評価・セッションログ

## 重要方針

- `docs/philosophy.md` を必ず参照すること
- 多様性は善：答えを一つに絞らず、pros/consを明示して選択肢を残す
- 段階的開示：必要なときに必要なだけ情報を提示
- AIの優れた提案を優先：指示追従より良いアイデアの提示を重視
- Mac/Windows両対応を前提とする
- 業務ドメインはgit管理対象外

## 作業時の注意

- specs/ の仕様書を根拠にハーネスを生成すること
- テンプレートの変更時は mapping/ の整合性も確認
- kb/ の更新時は kb/update-history.md に記録
- 自己改善時は docs/decisions/ にADRを残す

## Codex固有の注意

- このファイル（AGENTS.md）がCodex CLIの主指示ファイルである
- Claude側のCLAUDE.mdと内容の同期を保つこと
- Codexにない機能（skills, hooks）はAGENTS.mdの手順セクションで代替する
