---
name: patrol-docs
description: |
  Claude Code・Codex CLIの公式ドキュメントとスキルエコシステムを巡回し、specs/・kb/を最新化するスキル。
  変更があればcommit→push→PR作成（→自動マージ）まで実行。
  スキルエコシステム（公式スキル、推薦スキル、トレンド）も巡回対象。
  「巡回して」「公式ドキュメント巡回」「patrol」「specs更新して」で起動。
  定期実行はlaunchd-scheduleスキルと組み合わせて実現。
---

# patrol-docs スキル

Claude Code・Codex CLIの公式ドキュメントとスキルエコシステムを巡回し、harness-harnessのspecs/・kb/を最新化する。

## 引数

- `--auto-merge` (デフォルト: true): PRを自動マージする。`false`指定でPR作成のみ
- `--skip-cache`: キャッシュを無視して全URL巡回

## 処理フロー

### Phase 1: 変更検出

キャッシュ（`.patrol-cache/url-metadata.json`、gitignored）を活用し、変更があったURLのみを特定する。

1. **巡回起点の取得**: 以下からURLを柔軟に収集
   - Claude Code: `https://code.claude.com/docs/llms.txt` からドキュメント一覧を取得
   - Codex: `https://developers.openai.com/codex/changelog` を起点に関連ページを辿る
   - 前回のキャッシュに記録されたURLも対象

2. **キャッシュとの比較**: 各URLのページ内容を取得し、前回キャッシュのMD5ハッシュと比較
   - 変更なし → スキップ
   - 変更あり or 新規 → Phase 2の対象に追加

3. **キャッシュ更新**: 今回のハッシュを `.patrol-cache/url-metadata.json` に保存

キャッシュファイル:
```
.patrol-cache/
├── url-metadata.json   ← URL, content_hash, checked_at
└── pages/              ← ページ本体キャッシュ（オプション）
```

### Phase 2: 仕様書更新

変更が検出されたURLの内容を読み取り、対応するspecs/ファイルと比較して更新判断する。

**AIエージェントとして柔軟に判断する。スクリプト的な固定処理ではない。**

判断基準:
- 新機能の追加 → specs/の該当セクションに追記
- 既存機能の変更 → specs/の該当部分を修正
- 非推奨化 → specs/に「非推奨」を明記
- マイナーバグ修正のみ → specs/更新不要

更新対象の対応関係（目安。公式サイトリニューアルで変わる場合はエージェントが柔軟に追随）:

| 公式ドキュメント | specs/ファイル |
|----------------|--------------|
| Claude Code settings | specs/claude/configuration.md |
| Claude Code skills | specs/claude/skills-and-commands.md |
| Claude Code hooks | specs/claude/hooks.md |
| Claude Code MCP | specs/claude/mcp.md |
| Claude Code agent-teams | specs/claude/agent-teams.md |
| Claude Code best-practices | specs/claude/best-practices.md |
| Claude Code changelog | specs/claude/changelog.md |
| Codex config | specs/codex/configuration.md |
| Codex commands | specs/codex/commands.md |
| Codex changelog | specs/codex/changelog.md |

### Phase 3: 変更一覧（changelog）更新

各プラットフォームのバージョン変更履歴を更新する。

- `specs/claude/changelog.md` — Claude Codeのバージョン別変更一覧
- `specs/codex/changelog.md` — Codex CLIのバージョン別変更一覧

変更一覧の方針:
- 新機能・重要な変更・非推奨化を記載
- マイナーなバグ修正は省略
- 各バージョンの日付を記載
- 分かりやすい日本語で簡潔に

changelog元データの取得先（公式サイトリニューアルで変わっても追随）:
- Claude Code: `https://code.claude.com/docs/en/changelog` または GitHub CHANGELOG.md
- Codex: `https://developers.openai.com/codex/changelog`

### Phase 3.5: スキルエコシステム巡回

kb/skills/ のスキルエコシステム情報を巡回・更新する。

**スキップ判定**: `kb/skills/_index.md` の `last_patrol` が7日以内ならPhase 3.5全体をスキップする。

**巡回対象**:

| サイト | URL | 確認内容 |
|--------|-----|---------|
| anthropics/skills | https://github.com/anthropics/skills | 新スキル追加、Stars変動 |
| openai/skills | https://github.com/openai/skills | 新スキル追加、カテゴリ変更 |
| claude.com/plugins | https://claude.com/plugins | 新プラグイン、カテゴリ変更 |
| Codex Skills Docs | https://developers.openai.com/codex/skills | 仕様変更 |
| skills.sh | https://skills.sh/ | トレンドスキル上位10件 |
| agentskills.io | https://agentskills.io/ | 仕様バージョン変更 |

**更新判断**:
- 新しい有力スキルが登場 → `kb/skills/recommended.md` に追加検討（昇格ルーブリックで評価）
- 既存推薦スキルが非推奨・放棄 → Tier降格 or 削除
- Agent Skills仕様変更 → `kb/skills/sources.md` 更新
- トレンドの変化 → `kb/skills/_index.md` の最終巡回日更新

**段階的開示**: 全スキル一覧は不要。推薦に値するものだけ `recommended.md` に記録。詳細は必要時に公式サイトにWebFetchでアクセス。

**分野バランス**: `recommended.md` の分野カバレッジテーブルを確認し、特定分野に偏りすぎないよう注意する。カバーされていない分野で有力スキルがあれば優先的に検討。

### Phase 4: kb/update-history.md記録

巡回結果をkb/update-history.mdに記録:
- 日付
- 巡回で検出した変更の概要
- 更新したファイル一覧

### Phase 5: PR作成

specs/やkb/に変更がある場合のみ実行。変更なしなら何もしない。

1. featureブランチ作成: `patrol/docs-YYYYMMDD`
2. 変更をcommit
3. push
4. PR作成
5. `--auto-merge=true`（デフォルト）なら自動マージ

## 注意事項

- 公式サイトのURL構造が変わっても、llms.txtやchangelogページを起点に柔軟に追随する
- スクリプトによる固定処理ではなく、AIエージェントとして内容を理解して判断する
- キャッシュ（`.patrol-cache/`）はgitignored。ローカルのみ
- mapping/に影響がある変更（新機能のClaude/Codex互換性等）はmapping/も更新する
- プライベートプロジェクト名を公開情報に混入させない
