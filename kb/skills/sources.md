---
title: スキルエコシステム参照先
last_checked: "2026-03-28"
---

# スキルエコシステム参照先

巡回対象の公式・コミュニティサイト。信頼度と役割を整理。

## Anthropic公式

| サイト | URL | 役割 | 巡回優先度 |
|--------|-----|------|----------|
| claude.com/plugins | https://claude.com/plugins | 公式プラグインディレクトリ。72+件、24カテゴリ | 高 |
| anthropics/skills (GitHub) | https://github.com/anthropics/skills | 公式スキル実装例。source-available | 高 |
| anthropics/claude-plugins-official (GitHub) | https://github.com/anthropics/claude-plugins-official | 高品質プラグインディレクトリ | 中 |
| Claude Code Skills Docs | https://code.claude.com/docs/en/skills | スキル仕様・ベストプラクティス | 高 |

## OpenAI公式

| サイト | URL | 役割 | 巡回優先度 |
|--------|-----|------|----------|
| Codex Skills Docs | https://developers.openai.com/codex/skills | Skills = authoring format の仕様 | 高 |
| Codex Plugins Docs | https://developers.openai.com/codex/plugins | Plugins = installable distribution unit | 高 |
| openai/skills (GitHub) | https://github.com/openai/skills | Codex Skills Catalog。.system/.curated/.experimental | 中 |

## オープン標準

| サイト | URL | 役割 | 巡回優先度 |
|--------|-----|------|----------|
| agentskills.io | https://agentskills.io/ | Agent Skills仕様。33+プラットフォーム採用。SKILL.mdフォーマット | 中 |

## コミュニティ

| サイト | URL | 役割 | 巡回優先度 |
|--------|-----|------|----------|
| skills.sh | https://skills.sh/ | コミュニティディレクトリ。90K+スキル登録。リーダーボード | 中 |
| awesome-claude-skills | https://github.com/travisvn/awesome-claude-skills | キュレーション済みリスト | 低 |

## 重要な区別

- **skills.shはAnthropicの公式サイトではない**。コミュニティ運営のディレクトリとして扱う
- **agentskills.ioはディレクトリではなく仕様サイト**。スキル一覧はここにはない
- **OpenAI側: Skills = authoring format、Plugins = distribution unit**。公開マーケットプレイスは準備中
- **Agent Skills標準（SKILL.md）は33+プラットフォームで共通**。Claude/Codex間でスキルファイル自体は変換不要
