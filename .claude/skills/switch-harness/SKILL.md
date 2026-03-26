---
name: switch-harness
description: |
  1つのプロジェクトで目的別ハーネスを作成・一覧・切り替えるスキル。
  .claude-dev, .claude-refactor 等の目的別ディレクトリにハーネスを格納し、
  symlinkで .claude/ と CLAUDE.md を切り替える。worktreeやcloneとの併用も想定。
  「ハーネス切り替えて」「ハーネス一覧」「リファクタ用ハーネス作って」で起動。
---

# switch-harness スキル

1つのプロジェクトで目的別に複数のハーネスを管理し、symlinkで切り替える。

## コンセプト

```
project/
├── .claude-dev/           # 機能開発用ハーネス
│   ├── CLAUDE.md
│   ├── settings.json
│   ├── skills/
│   └── rules/
├── .claude-refactor/      # リファクタ用ハーネス
│   ├── CLAUDE.md
│   └── settings.json
├── .claude-analysis/      # 分析用ハーネス
│   ├── CLAUDE.md
│   └── settings.json
├── .claude → .claude-dev          (symlink)
├── CLAUDE.md → .claude-dev/CLAUDE.md  (symlink)
└── src/
```

切り替えはsymlink張り替えるだけ。別worktreeや別cloneに別ハーネスを配置する運用とも相性がよい。

## 操作

### create — 新しい目的別ハーネスを作成

```
リファクタ用ハーネスを作って
```

```
.claude-analysis を作って（分析用）
```

1. 目的名を決定（dev, refactor, test, analysis, marketing 等。自由に命名可）
2. `.claude-{purpose}/` ディレクトリを作成
3. ハーネスファイルを生成:
   - `CLAUDE.md` — 目的に最適化された指示。specs/を参照して生成
   - `settings.json` — 目的に合った権限・安全度レベル
   - 必要に応じて `skills/`, `rules/`, `agents/` も配置
4. 既存の `.claude-{purpose}/` がベースとして指定されていればコピーして調整
5. ユーザーと内容を確認

**ユーザー対話**: 目的の概要、安全度レベル、既存ハーネスからのコピー有無を確認。

### list — 目的別ハーネスの一覧

```
ハーネス一覧
```

```
=== ハーネス一覧 ===
  * .claude-dev/        (active)  — 機能開発用
    .claude-refactor/             — リファクタ用
    .claude-analysis/             — 分析用

現在: .claude → .claude-dev
```

プロジェクト直下の `.claude-*` ディレクトリを列挙し、現在のsymlinkの指す先を表示。

### switch — 別のハーネスに切り替え

```
リファクタ用に切り替えて
```

```
.claude-analysis に切り替えて
```

1. 指定された `.claude-{purpose}/` の存在を確認
2. 既存のsymlinkを削除
3. 新しいsymlinkを作成:
   - `.claude → .claude-{purpose}`
   - `CLAUDE.md → .claude-{purpose}/CLAUDE.md`
4. Codex対応がある場合: `AGENTS.md`, `.codex/` も同様に切替
5. 切替結果を表示

```
=== 切り替え完了 ===
.claude → .claude-refactor
CLAUDE.md → .claude-refactor/CLAUDE.md

セッションを再起動してください（/clear または新しいセッション）。
```

### remove — 目的別ハーネスを削除

```
.claude-analysis を削除して
```

1. 現在activeなハーネスは削除できない（先にswitchが必要）
2. `.claude-{purpose}/` ディレクトリを削除

## Codex対応

Codex CLIにも対応する場合、同じパターンで:

```
project/
├── .claude-dev/
├── .codex-dev/
├── AGENTS-dev.md
├── .claude → .claude-dev
├── .codex → .codex-dev
├── CLAUDE.md → .claude-dev/CLAUDE.md
└── AGENTS.md → AGENTS-dev.md
```

またはCodexプロファイル（`config.toml [profiles.*]`）で代替可能。プロファイルはsymlink不要でネイティブに切替できるため、Codex側はプロファイルを推奨。

## 既存スキルとの連携

- **create-harness**: 初回ハーネス生成後、目的別に分離したい場合にこのスキルを案内
- **diagnose-harness**: 各目的別ハーネスを個別に診断可能
- **sync-harness**: Claude側ハーネス切替時にCodex側も同期する場合に連携

## 注意事項

- symlinkはMac/Linux前提。Windowsではジャンクション or コピーで代替
- `.claude-*/` はgit管理対象にするかはユーザー判断（.gitignoreに入れるかどうか）
- settings.local.json はsymlink対象外（個人設定はハーネス切替に影響させない）
- 切替後はClaude Codeのセッション再起動が必要（/clear または新セッション）
- worktree/clone運用の場合、各コピーのトップに直接ハーネスを置く方が単純。symlinkは同一ディレクトリ内での切替用
