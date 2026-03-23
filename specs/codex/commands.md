# OpenAI Codex CLI コマンド仕様

最終更新: 2026-03-23（巡回更新）

---

## 1. Slash Commands 一覧

対話モード（TUI）内で `/` プレフィックスを付けて実行するコマンド群。

### 1.1 モデル・モード制御

| コマンド | 構文 | 説明 |
|----------|------|------|
| `/model` | `/model` | 使用モデルと推論レベルを選択・変更 |
| `/plan` | `/plan [prompt]` | プランモードに切り替え（任意でプロンプト送信） |
| `/fast` | `/fast [on\|off\|status]` | GPT-5.4 の Fast モードを切り替え |
| `/personality` | `/personality` | 応答スタイルを選択（friendly / pragmatic / none） |
| `/experimental` | `/experimental` | サブエージェント等の実験的機能を有効/無効化 |

### 1.2 コード・差分操作

| コマンド | 構文 | 説明 |
|----------|------|------|
| `/diff` | `/diff` | Git の変更差分を表示（未追跡ファイル含む） |
| `/review` | `/review` | ワーキングツリーの変更をレビュー分析（ベースブランチ差分、未コミット変更、特定コミット等のプリセット） |
| `/copy` | `/copy` | 最新の Codex 出力をクリップボードにコピー |
| `/mention` | `/mention <path>` | 特定のファイルやフォルダを会話に添付 |

### 1.3 権限・セキュリティ

| コマンド | 構文 | 説明 |
|----------|------|------|
| `/permissions` | `/permissions` | Codex が承認なしで実行可能な操作を設定 |
| `/sandbox-add-read-dir` | `/sandbox-add-read-dir <path>` | Windows サンドボックスに読み取りディレクトリを追加 |

### 1.4 セッション管理

| コマンド | 構文 | 説明 |
|----------|------|------|
| `/resume` | `/resume` | 保存済みセッション一覧から会話を再開 |
| `/fork` | `/fork` | 現在の会話を新しいスレッドに複製 |
| `/new` | `/new` | 同じ CLI セッション内で新しい会話を開始 |
| `/clear` | `/clear` | 表示をリセットし、同じセッション内でチャットを再開 |
| `/compact` | `/compact` | 会話履歴を圧縮してコンテキスト容量を節約 |

### 1.5 情報・デバッグ

| コマンド | 構文 | 説明 |
|----------|------|------|
| `/status` | `/status` | セッション設定とトークン使用量を表示 |
| `/debug-config` | `/debug-config` | 設定レイヤーと requirements 診断を出力 |
| `/ps` | `/ps` | 実験的バックグラウンドターミナルと出力を表示 |
| `/mcp` | `/mcp` | 設定済み MCP ツールの一覧を表示 |
| `/statusline` | `/statusline` | フッターのステータスライン項目を設定・並べ替え |

### 1.6 その他

| コマンド | 構文 | 説明 |
|----------|------|------|
| `/agent` | `/agent` | アクティブなエージェントスレッドを切り替え（サブエージェント検査） |
| `/apps` | `/apps` | アプリ（コネクタ）を閲覧しプロンプトに挿入 |
| `/init` | `/init` | カレントディレクトリに AGENTS.md の雛形を生成 |
| `/feedback` | `/feedback` | ログと診断情報をメンテナーに送信 |
| `/send-feedback` | `/send-feedback` | `/feedback` の別名 |
| `/logout` | `/logout` | 現在のセッションの認証情報をクリア |
| `/exit` / `/quit` | `/exit` | CLI セッションを終了 |

> 公式ドキュメント: [Slash Commands](https://developers.openai.com/codex/cli/slash-commands)

---

## 2. codex exec（非対話モード）

CI/CD パイプラインやスクリプトから Codex を呼び出すための非対話実行モード。

### 2.1 基本構文

```bash
codex exec "タスクの説明"
codex e "タスクの説明"          # エイリアス

# stdin からプロンプトを渡す
echo "テストを実行して" | codex exec -

# サイレント実行（CI 向け）
codex -q "タスクの説明"
```

### 2.2 主要オプション

| オプション | 説明 |
|-----------|------|
| `--color <always\|never\|auto>` | ANSI カラー出力の制御 |
| `--ephemeral` | セッションファイルを永続化せずに実行 |
| `--json` / `--experimental-json` | 改行区切り JSON イベントを出力 |
| `--output-last-message, -o <path>` | 最終アシスタントメッセージをファイルに書き出し |
| `--output-schema <path>` | ツール出力を検証する JSON Schema |
| `--skip-git-repo-check` | Git リポジトリ外での実行を許可 |

### 2.3 グローバルフラグ（全サブコマンド共通）

| フラグ | 説明 |
|--------|------|
| `--model, -m <model>` | 使用モデルを指定 |
| `--ask-for-approval, -a <policy>` | 承認ポリシー（`untrusted` / `on-request` / `never`） |
| `--sandbox, -s <mode>` | サンドボックスモード（`read-only` / `workspace-write` / `danger-full-access`） |
| `--profile, -p <name>` | 設定プロファイルを読み込み |
| `--config, -c <key=value>` | 設定値を上書き |
| `--cd, -C <path>` | 作業ディレクトリを設定 |
| `--add-dir <path>` | 追加の書き込み可能ディレクトリを付与 |
| `--image, -i <path>` | 画像ファイルを添付 |
| `--full-auto` | 低摩擦モード（on-request 承認） |
| `--yolo` | 承認・サンドボックスを完全バイパス（非推奨） |
| `--enable / --disable <feature>` | 機能フラグの有効化/無効化 |
| `--no-alt-screen` | TUI の代替画面モードを無効化 |
| `--oss` | ローカル OSS モデルプロバイダー（Ollama）を使用 |
| `--search` | ライブ Web 検索を有効化 |

### 2.4 CI/CD での推奨パターン

```bash
# JSON 出力 + 最終メッセージのファイル保存
codex exec --json --output-last-message result.md "ユニットテストを生成して"

# エフェメラル実行（セッション残さない）
codex exec --ephemeral -a never -s workspace-write "lint を修正して"
```

> 公式ドキュメント: [CLI Reference](https://developers.openai.com/codex/cli/reference)

---

## 3. セッション管理

Codex CLI はトランスクリプトをローカルに保存し、セッションの再開・分岐が可能。

### 3.1 resume（セッション再開）

中断したセッションのコンテキストを保持したまま再開する。

```bash
# 対話モードでセッション一覧から選択
codex resume

# 最後のセッションを即座に再開
codex resume --last

# 特定のセッション ID を指定して再開
codex resume <SESSION_ID>

# 全ディレクトリのセッションを表示（デフォルトは CWD スコープ）
codex resume --all
```

#### exec からの resume

```bash
# 非対話モードで前回のセッションを続行
codex exec resume --last "前回の続きで、エラーハンドリングも追加して"
codex exec resume <SESSION_ID> --image screenshot.png "この画面の問題を修正して"
```

### 3.2 fork（セッション分岐）

元のトランスクリプトを保持したまま、新しいスレッドに分岐する。

```bash
# 対話モードでセッション一覧から選択して分岐
codex fork

# 最後のセッションを分岐
codex fork --last

# 特定のセッション ID から分岐
codex fork <SESSION_ID>
```

TUI 内では `/fork` スラッシュコマンドで現在の会話からも分岐可能。

### 3.3 new（新規セッション）

```bash
# TUI 内で新しい会話を開始（セッションは維持）
/new
```

### 3.4 セッション保存の制御

```toml
# ~/.codex/config.toml
[history]
persistence = "none"       # セッション保存を無効化
max_bytes = 1048576        # 最大サイズ（超過時は自動コンパクション）
```

`--ephemeral` フラグを使うとセッションファイルを一切残さずに実行可能。

---

## 4. その他のサブコマンド

| コマンド | 説明 |
|----------|------|
| `codex login` | ブラウザ OAuth または API キーで認証（`--device-auth` でデバイスコードフロー、`--with-api-key` で stdin から読み込み） |
| `codex logout` | 認証情報をクリア |
| `codex login status` | 認証状態を確認（成功時 exit code 0） |
| `codex features list` | 機能フラグ一覧と状態を表示 |
| `codex features enable/disable <feature>` | 機能フラグの永続的な有効化/無効化 |
| `codex mcp list/add/get/remove` | MCP サーバー管理（詳細は [mcp.md](./mcp.md) 参照） |
| `codex sandbox -- <COMMAND>` | サンドボックス内でコマンドを実行 |
| `codex completion <shell>` | シェル補完スクリプトの生成（bash / zsh / fish / power-shell / elvish） |
| `codex app` | デスクトップアプリを起動（macOS のみ） |
| `codex mcp-server` | Codex 自体を MCP サーバーとして起動（他エージェントからの利用向け） |
| `codex cloud` | クラウドタスク管理（`--env`, `--attempts` オプション） |
| `codex apply <TASK_ID>` | Codex Cloud タスクの差分を適用 |
| `codex execpolicy check` | ポリシー評価（プレビュー機能） |

> 公式ドキュメント: [CLI Reference](https://developers.openai.com/codex/cli/reference) / [CLI Features](https://developers.openai.com/codex/cli/features)
