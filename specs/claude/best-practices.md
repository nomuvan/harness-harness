# Claude Code ベストプラクティス

最終更新: 2026-03-23

公式ドキュメント: https://code.claude.com/docs/en/best-practices

---

## 1. CLAUDE.md 作成のベストプラクティス

### 1.1 `/init` で始める

```bash
claude
> /init
```

コードベースを分析し、ビルドシステム・テストフレームワーク・コードパターンを検出して CLAUDE.md の雛形を生成する。既存 CLAUDE.md がある場合は改善提案を行う。

`CLAUDE_CODE_NEW_INIT=true` で対話式フロー（CLAUDE.md + Skills + Hooks のセットアップ）を有効化。

### 1.2 含めるべきもの・除外すべきもの

| 含めるべき | 除外すべき |
|:--|:--|
| Claude が推測できない Bash コマンド | コードを読めば分かること |
| デフォルトと異なるコードスタイル規則 | Claude が既知の標準的な言語慣例 |
| テスト指示と推奨テストランナー | 詳細な API ドキュメント（リンクで代替） |
| リポジトリ慣例（ブランチ命名、PR規約） | 頻繁に変更される情報 |
| プロジェクト固有のアーキテクチャ決定 | 長い説明やチュートリアル |
| 開発環境の癖（必要な環境変数） | ファイルごとのコードベース説明 |
| 一般的な落とし穴や非自明な動作 | 「クリーンなコードを書く」等の自明な実践 |

### 1.3 サイズとフォーマット

- **200行以下**を目標（1ファイルあたり）
- Markdown の見出しと箇条書きで構造化
- 検証可能な具体的指示を書く
  - 良い例: 「2スペースインデント」「`npm test` をコミット前に実行」
  - 悪い例: 「コードを適切にフォーマット」「変更をテスト」
- 矛盾する指示がないか定期的に見直す

### 1.4 強調と遵守率

重要な指示には「IMPORTANT」「YOU MUST」等の強調を追加することで遵守率が向上する。

### 1.5 配置戦略

| 用途 | 配置場所 |
|:--|:--|
| 全セッション共通の個人設定 | `~/.claude/CLAUDE.md` |
| チーム共有のプロジェクト規約 | `./CLAUDE.md`（git にコミット） |
| モノレポのサブプロジェクト | `root/CLAUDE.md` + `root/foo/CLAUDE.md`（自動マージ） |
| 特定ファイルタイプ向け指示 | `.claude/rules/` にパススコープルール |
| 個人的なプロジェクトオーバーライド | `@~/.claude/my-project-instructions.md` でインポート |

### 1.6 CLAUDE.md をコードとして扱う

- git にコミットしてチームで共同改善
- 問題発生時にレビュー・剪定する
- Claude の行動変化を観察して効果を検証
- 時間とともに価値が蓄積される

### 1.7 肥大化の対処

CLAUDE.md が長すぎると指示が無視される。対策:
- `@path/to/import` でファイル分割
- `.claude/rules/` でトピック別ファイルに分離
- `paths` フロントマターでパススコープルールを活用
- タスク固有の指示は Skills に移動（オンデマンド読み込み）

---

## 2. コンテキスト管理

**Claude のコンテキストウィンドウは最重要リソース。** パフォーマンスはコンテキストの充填に伴い劣化する。

### 2.1 基本原則

- **`/clear` を頻繁に使用**: 無関係なタスク間でコンテキストをリセット
- **`/compact` の活用**: カスタム指示付きでコンパクション可能（例: `/compact API変更に集中`）
- **`/btw` でサイドクエスチョン**: コンテキストに残らない一時的な質問
- **`/context` でコンテキスト使用量を可視化**: 最適化提案も表示

### 2.2 サブエージェントによるコンテキスト保全

調査タスクはサブエージェントに委譲して、メインコンテキストの消費を防ぐ:

```
サブエージェントを使って認証システムのトークンリフレッシュの仕組みと
既存の OAuth ユーティリティを調査してください。
```

### 2.3 コンパクション戦略

- 自動コンパクションはコンテキスト限界に近づくと発動
- `/compact Focus on the API changes` のようにフォーカス指示が可能
- `Esc + Esc` または `/rewind` で部分的な要約（選択メッセージ以降を要約）
- CLAUDE.md に「コンパクション時に変更ファイル一覧とテストコマンドを保持」等の指示を記載可能

### 2.4 アンチパターン: キッチンシンクセッション

1つのタスクから無関係な質問に移り、また元に戻る。コンテキストが不要情報で汚染される。

**対策**: `/clear` でタスク間をリセット。

### 2.5 アンチパターン: 繰り返し修正

2回以上修正しても改善しない場合、コンテキストが失敗アプローチで汚染されている。

**対策**: `/clear` してより良い初期プロンプトを書き直す。

---

## 3. Skills 設計

### 3.1 リファレンスコンテンツ vs タスクコンテンツ

- **リファレンス**: コーディング規約・パターン・ドメイン知識。インラインで実行
- **タスク**: デプロイ・コミット等のステップバイステップ指示。`disable-model-invocation: true` 推奨

### 3.2 設計ガイドライン

- `SKILL.md` は500行以下。詳細は別ファイルに分離
- `description` は Claude が自動適用を判断できる具体的なキーワードを含める
- 副作用のあるワークフロー（deploy, commit）は `disable-model-invocation: true`
- バックグラウンド知識は `user-invocable: false`
- `context: fork` で隔離が必要なタスクをサブエージェントで実行

### 3.3 動的コンテキスト注入の活用

`` !`command` `` で実行時にデータを注入:

```yaml
---
name: pr-summary
context: fork
agent: Explore
allowed-tools: Bash(gh *)
---

## PRコンテキスト
- PR diff: !`gh pr diff`
- コメント: !`gh pr view --comments`
```

### 3.4 スキルのコンテキストバジェット

スキル説明はコンテキストウィンドウの2%（フォールバック: 16,000文字）まで読み込まれる。多数のスキルがある場合は `/context` で除外警告を確認。`SLASH_COMMAND_TOOL_CHAR_BUDGET` 環境変数で上限変更可能。

---

## 4. Hooks 活用

### 4.1 Hooks が適する場面

- **例外なく毎回実行すべきアクション**: ファイル編集後のリント、コミット前のテスト
- **セキュリティポリシーの強制**: 破壊的コマンドのブロック、機密ファイルへの書き込み防止
- **環境のセットアップ**: セッション開始時の環境変数設定

### 4.2 Claude に Hooks を書かせる

```
ファイル編集ごとに eslint を実行するフックを書いて
```

```
migrations フォルダへの書き込みをブロックするフックを書いて
```

### 4.3 主要パターン

#### ファイル編集後の自動フォーマット

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Edit|Write",
      "hooks": [{ "type": "command", "command": "npx prettier --write" }]
    }]
  }
}
```

#### 破壊的コマンドのブロック

```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Bash",
      "hooks": [{ "type": "command", "command": ".claude/hooks/block-destructive.sh" }]
    }]
  }
}
```

#### セッション開始時のコンテキスト注入

```json
{
  "hooks": {
    "SessionStart": [{
      "hooks": [{ "type": "command", "command": ".claude/hooks/session-context.sh" }]
    }]
  }
}
```

### 4.4 `/hooks` で確認

設定済みフックの読み取り専用ブラウザ。イベント・matcher・ハンドラ設定・ソース元を表示。

---

## 5. 効果的なプロンプティング

### 5.1 検証手段を提供する

Claude に自己検証の手段を与えることが最大のレバレッジ:

- テストケースを明示: 「`user@example.com` は true、`invalid` は false」
- テスト実行を指示: 「実装後にテストを実行して失敗を修正」
- スクリーンショット比較: 「このデザインを実装してスクリーンショットで比較」

### 5.2 探索 → 計画 → 実装

1. **探索**: プランモードでコードベースを読む
2. **計画**: 実装計画を作成させる（`Ctrl+G` でエディタで編集可能）
3. **実装**: ノーマルモードで実装
4. **コミット**: コミット・PR作成

小さな修正（タイポ、ログ追加、リネーム）は計画をスキップして直接実行。

### 5.3 具体的なコンテキストを提供

- ファイルを `@` で参照
- 画像をペースト/ドラッグ&ドロップ
- URL を提供
- `cat error.log | claude` でデータをパイプ
- 既存パターンを指し示す: 「HotDogWidget.php をパターンとして参照」

### 5.4 Claude にインタビューさせる

```
[簡潔な説明]を作りたい。AskUserQuestion ツールを使って詳しくインタビューして。
技術実装、UI/UX、エッジケース、懸念点、トレードオフについて聞いて。
全てカバーしたら SPEC.md に完全な仕様を書いて。
```

仕様完成後、新しいセッションで実装を開始（クリーンなコンテキスト）。

---

## 6. 組織・チーム向け運用

### 6.1 Managed CLAUDE.md

組織全体の指示を IT/DevOps が配布:

- macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md`
- Linux/WSL: `/etc/claude-code/CLAUDE.md`
- Windows: `C:\Program Files\ClaudeCode\CLAUDE.md`

MDM / Group Policy / Ansible 等で配布。除外不可。

### 6.2 Managed Settings vs Managed CLAUDE.md

| 用途 | 設定場所 |
|:--|:--|
| ツール・コマンド・ファイルパスのブロック | Managed settings: `permissions.deny` |
| サンドボックス隔離の強制 | Managed settings: `sandbox.enabled` |
| 環境変数・APIプロバイダ | Managed settings: `env` |
| 認証方式・組織ロック | Managed settings: `forceLoginMethod`, `forceLoginOrgUUID` |
| コードスタイル・品質ガイドライン | Managed CLAUDE.md |
| データハンドリング・コンプライアンス | Managed CLAUDE.md |
| Claude の行動指示 | Managed CLAUDE.md |

### 6.3 プロジェクト標準化

- `.claude/settings.json` をバージョン管理にコミット
- `.claude/skills/` をチームで共有
- `.claude/agents/` をプロジェクト固有のサブエージェントとして共有
- `.mcp.json` でプロジェクト共通の MCP サーバーを定義

### 6.4 権限管理

- **権限許可リスト**: 安全と分かっているツールを許可（`npm run lint`, `git commit`）
- **サンドボックス**: OS レベルの隔離で安全な自由実行を実現
- **`--dangerously-skip-permissions`**: インターネットアクセスのないサンドボックス内でのみ使用

### 6.5 並列作業によるスケーリング

- **デスクトップアプリ**: 複数ローカルセッションの視覚的管理
- **Web**: Anthropic クラウドインフラで隔離VM実行
- **エージェントチーム**: 共有タスク・メッセージング・チームリードによる自動調整
- **Writer/Reviewer パターン**: 1つのセッションで実装、別のセッションでレビュー

### 6.6 ファンアウトパターン

大規模マイグレーションや分析を並列化:

```bash
for file in $(cat files.txt); do
  claude -p "Migrate $file from React to Vue. Return OK or FAIL." \
    --allowedTools "Edit,Bash(git commit *)"
done
```

### 6.7 非対話モード

CI/CD パイプラインやスクリプトでの使用:

```bash
# 単発クエリ
claude -p "このプロジェクトが何をするか説明して"

# 構造化出力
claude -p "全APIエンドポイントを一覧" --output-format json

# ストリーミング
claude -p "このログファイルを分析" --output-format stream-json
```

---

## 7. よくある失敗パターンと対策

| パターン | 問題 | 対策 |
|:--|:--|:--|
| キッチンシンクセッション | 無関係なタスクの混在 | `/clear` でタスク間をリセット |
| 繰り返し修正 | 失敗アプローチでコンテキスト汚染 | 2回失敗後、`/clear` して改善プロンプト |
| 肥大化 CLAUDE.md | 重要な指示がノイズに埋もれる | 剪定。正しく動作する指示は削除またはフックに変換 |
| 信頼→検証ギャップ | エッジケース未対応の実装 | テスト・スクリプト・スクリーンショットで検証 |
| 無限探索 | スコープなしの調査でコンテキスト消費 | 調査を狭くスコープ、またはサブエージェント使用 |

---

## 参考リンク

- ベストプラクティス: https://code.claude.com/docs/en/best-practices
- 共通ワークフロー: https://code.claude.com/docs/en/common-workflows
- メモリ: https://code.claude.com/docs/en/memory
- Skills: https://code.claude.com/docs/en/skills
- Hooks ガイド: https://code.claude.com/docs/en/hooks-guide
- 権限: https://code.claude.com/docs/en/permissions
- サンドボックス: https://code.claude.com/docs/en/sandboxing
- コスト管理: https://code.claude.com/docs/en/costs
