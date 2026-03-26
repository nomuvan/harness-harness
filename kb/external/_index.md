# 外部プロジェクト調査レジストリ

harness-harnessの設計に影響を与えうる外部プロジェクトの調査一覧。

## 調査対象プロジェクト

| 名前 | URL | 概要 | 最終確認日 | ステータス |
|------|-----|------|-----------|-----------|
| OpenClaw | https://github.com/openclaw/openclaw | ローカルファーストの自律AIエージェント。20+チャネル統合、53+バンドルスキル、ClawHubレジストリ（13,700+スキル）。Peter Steinberger作。GitHub 180,000+スター | 2026-03-23 | active |
| gstack | https://github.com/garrytan/gstack | Garry Tan（YC CEO）のClaude Codeワークフロー。ロールベースの仮想開発チーム、28スキル、構造化スプリントプロセス。MIT License | 2026-03-23 | active |
| superpowers | https://github.com/obra/superpowers | Jesse Vincent作のマルチプラットフォームスキルフレームワーク。Claude Code / Codex / Cursor / OpenCode対応。SKILL.mdフロントマター標準。GitHub 107,000+スター | 2026-03-23 | active |
| autoresearch | https://github.com/karpathy/autoresearch | Andrej Karpathy作。AIエージェントによる自律的LLM訓練実験ループ。program.mdで研究方針を定義し、train.pyをエージェントが改善し続ける。「Karpathy Loop」パターンはML以外にも汎用適用可能。GitHub 56,900+スター | 2026-03-26 | active |
| DeerFlow 2.0 | https://github.com/bytedance/deer-flow | ByteDance製マルチエージェントSuperAgentハーネス。Harness/App分離、Progressive Skill Loading、Markdownスキル、永続メモリ（信頼度スコア付き）。MIT License。GitHub 47,900+スター | 2026-03-26 | active |

## 調査方針

- 「多様性は善」の原則に従い、一つのプロジェクトを正解とせず、各プロジェクトのアプローチのpros/consを明示する
- 各プロジェクトの `analysis.md` で深掘り、`takeaways.md` で harness-harness への適用判断を記録
- 定期的に再調査し、最終確認日を更新すること

## ディレクトリ構成

```
kb/external/
  _index.md          # 本ファイル（レジストリ）
  openclaw/
    analysis.md      # 深掘り分析
    takeaways.md     # 採用/不採用判断
  gstack/
    analysis.md
    takeaways.md
  superpowers/
    analysis.md
    takeaways.md
  autoresearch/
    analysis.md
```
