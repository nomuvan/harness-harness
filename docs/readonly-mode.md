# ReadOnlyモード

harness-harnessはpush権限がなくてもReadOnlyで利用可能。

## 利用方法

```bash
git clone https://github.com/nomuvan/harness-harness.git
```

以下を参照してハーネスを手動作成:
- `specs/` — Claude Code, Codex CLIの仕様書
- `kb/` — 外部プロジェクト調査、戦術的知見
- `mapping/` — Claude⇔Codex変換ルール
- `templates/` — ハーネステンプレート（準備中）
- `docs/philosophy.md` — 設計思想・方針

## 制限事項

- `logs/evaluations/` への学びの記録ができない → 自律学習・改善が制限される
- `registry/` でのプロジェクト管理ができない
- `private/` submoduleにアクセスできない（privateリポジトリ）

## Fork推奨

- MITライセンスなので自由にforkして独自に育ててOK
- 本家の更新をupstreamから取り込むことも可能
- 本家への貢献（PR）も歓迎
- forkした場合、自分のprivate submoduleを接続して完全なharness-harnessとして運用可能
