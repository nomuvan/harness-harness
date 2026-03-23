# harness-harness

ハーネスを作り、育て、壊して作り直すハーネス。

## 概要

AI実行基盤（Claude Code CLI, Codex CLI）のハーネスを管理する母艦プロジェクト。

### 提供機能

- 新規プロジェクトへのハーネス作成（Claude / Codex）
- Claude⇔Codexハーネスの相互変換・同期
- 目的別マルチハーネス管理（フロント、バックエンド、テスト等）
- ハーネスの診断・改善提案
- 陳腐化したハーネスの破壊＆再構築
- 公式ドキュメント・外部プロジェクトの継続巡回
- 自己評価・自律改善サイクル

### 対象AI実行基盤

- Claude Code CLI（.claude）
- Codex CLI（.codex）
- 将来: ローカルLLM等の追加可能性あり

## セットアップ

```bash
# Claude Code
claude

# Codex CLI
codex
```

## ディレクトリ構成

```
docs/       思想・方針、アーキテクチャ、規約
specs/      Claude Code, Codex CLIの仕様書
kb/         外部プロジェクト調査、戦術的知見
templates/  ハーネステンプレート
mapping/    Claude⇔Codex変換ルール
registry/   管理対象プロジェクト一覧（テンプレート）
scripts/    ユーティリティスクリプト
private/    git submodule（プロジェクト固有データ）
```

## ReadOnlyモード

push権限やprivate submoduleへのアクセスがなくてもReadOnlyで利用可能。AIがspecs/, kb/, mapping/, templates/ を参照して対象プロジェクトのハーネスを自動生成できる。harness-harness自体への書き込み（ログ記録等）のみ制限される。MITライセンスなので自由にforkして独自に育ててOK。詳細は [docs/readonly-mode.md](docs/readonly-mode.md) 参照。
