# OpenAI Codex CLI ベストプラクティス

最終更新: 2026-03-23

---

## 1. AGENTS.md 作成のベストプラクティス

### 1.1 階層設計の原則

```
~/.codex/AGENTS.md                    # グローバル: 全プロジェクト共通の指示
<repo-root>/AGENTS.md                 # プロジェクト: リポジトリ全体の規約
<repo-root>/src/AGENTS.md             # ディレクトリ: 特定モジュールの指示
<repo-root>/services/payments/AGENTS.override.md  # override: 特殊な上書き
```

- **グローバル**（`~/.codex/AGENTS.md`）: 全プロジェクトで共通の個人設定を配置（コーディングスタイルの好み、言語設定等）
- **プロジェクトルート**: リポジトリ全体のコーディング規約、使用技術スタック、テスト方針を記述
- **サブディレクトリ**: 専門領域のみに限定した指示を記述（例: `services/payments/` にはセキュリティ要件を追記）
- **override**: 本当に必要な場合のみ使用。親の指示を完全に置換するため、慎重に

### 1.2 記述のガイドライン

- 簡潔かつ具体的に記述する（32 KiB のサイズ制限あり）
- 肯定的な指示を優先する（「～しないでください」より「～してください」）
- 実行可能な指示を書く（抽象的な理念より具体的なルール）
- 検証可能な記述にする

```markdown
# プロジェクト規約

## コーディングスタイル
- TypeScript を使用し、`any` 型の使用を避ける
- 関数には JSDoc コメントを付与する
- エラーハンドリングには Result 型パターンを使用する

## テスト方針
- 新規関数には必ずユニットテストを作成する
- テストフレームワークは Vitest を使用する
- テストファイルは `__tests__/` ディレクトリに配置する

## Git 規約
- コミットメッセージは Conventional Commits 形式で記述する
- 明示的に指示されない限り、`git push` を実行しない
```

### 1.3 `/init` による雛形生成

```bash
# カレントディレクトリに AGENTS.md の雛形を生成
/init
```

### 1.4 確認とデバッグ

```bash
# 現在有効な指示を確認
codex --ask-for-approval never "現在読み込まれている指示ファイルをすべて列挙してください"

# ログで読み込まれたファイルを監査
# ~/.codex/log/codex-tui.log を確認
```

> 公式ドキュメント: [AGENTS.md Guide](https://developers.openai.com/codex/guides/agents-md)

---

## 2. 承認ポリシー設計

### 2.1 用途別の推奨設定

| ユースケース | `approval_policy` | `sandbox_mode` | 備考 |
|-------------|-------------------|----------------|------|
| 初回導入・評価段階 | `on-request` | `read-only` | 全操作を確認して挙動を把握 |
| 日常的な開発作業 | `on-request` | `workspace-write` | ファイル編集・コマンドの承認を都度判断 |
| 信頼済みタスクの自動化 | `untrusted` | `workspace-write` | 安全な操作は自動実行、状態変更のみ承認 |
| CI/CD パイプライン | `never` | `workspace-write` | 非対話環境向け。サンドボックスで安全性を担保 |
| 完全自律実行 | `never` | `danger-full-access` | 隔離された VM/コンテナ内でのみ使用 |

### 2.2 段階的な緩和アプローチ

1. `on-request` + `read-only` から開始
2. Codex の挙動に慣れたら `workspace-write` に緩和
3. 信頼できるタスクパターンが確立されたら `untrusted` を検討
4. `never` は CI/CD またはサンドボックス環境でのみ使用

### 2.3 プロファイルによる使い分け

```toml
# ~/.codex/config.toml

[profiles.safe]
approval_policy = "on-request"
sandbox_mode = "read-only"

[profiles.dev]
approval_policy = "on-request"
sandbox_mode = "workspace-write"

[profiles.ci]
approval_policy = "never"
sandbox_mode = "workspace-write"
```

```bash
codex -p safe "このコードベースを分析して"
codex -p dev "リファクタリングして"
codex -p ci "テストを実行して修正して"
```

### 2.4 避けるべきパターン

- `--yolo`（`--dangerously-bypass-approvals-and-sandbox`）の日常的な使用
- `--full-auto` + `danger-full-access` のサンドボックス外での使用
- `approval_policy = "never"` をサンドボックスなしで使用

---

## 3. セキュリティ設定

### 3.1 サンドボックスの活用

#### macOS（Seatbelt）

macOS 12+ では自動的に Apple Seatbelt を使用。`workspace-write` モードの保護対象:

- `.git` ディレクトリ: 読み取り専用（直接の Git 操作を防止）
- `.agents/` ディレクトリ: 読み取り専用
- `.codex/` ディレクトリ: 読み取り専用
- ネットワーク: デフォルト無効

#### Linux（bubblewrap + seccomp）

```bash
# Docker コンテナ内での推奨実行
# iptables/ipset ファイアウォールで OpenAI API 以外の通信を遮断
./run_in_container.sh
```

#### サンドボックス内でのコマンド実行

```bash
# 任意のコマンドをサンドボックス内で実行
codex sandbox -- npm test
codex sandbox --full-auto -- make build
```

### 3.2 ネットワークアクセスの制御

```toml
# デフォルトではネットワーク無効
# 必要な場合のみ選択的に有効化
[sandbox_workspace_write]
network_access = true
```

Web 検索はデフォルトで `cached` モード（インジェクションリスク低減）。

### 3.3 シェル環境の保護

```toml
[shell_environment_policy]
inherit = "core"                    # 最小限の環境変数のみ継承
exclude = ["*_SECRET", "*_TOKEN"]   # 秘匿情報を除外（glob 対応）
set = { NODE_ENV = "development" }  # 固定値を設定
```

### 3.4 履歴データの保護

```toml
[history]
persistence = "none"    # 機密プロジェクトではセッション保存を無効化

# または秘匿パターンを設定
sensitive_patterns = ["password", "secret", "token", "api_key"]
```

### 3.5 認証情報の管理

```bash
# キーリングを使用（推奨）
# config.toml で設定
# credential_storage = "keyring"

# ログイン状態の確認
codex login status

# API キーでのログイン（stdin から読み込み）
echo $OPENAI_API_KEY | codex login --with-api-key
```

### 3.6 監視（OpenTelemetry）

```toml
[otel]
environment = "production"
exporter = "otlp-http"
log_user_prompt = false    # プロンプト内容はログに含めない
```

追跡可能なイベント:
- API リクエスト / レスポンス
- ツールの呼び出しと承認
- ユーザープロンプト（リダクト済み）
- セッションのライフサイクル

### 3.7 分析データの無効化

```toml
[analytics]
enabled = false

[feedback]
enabled = false
```

---

## 4. チーム運用

### 4.1 プロジェクト設定の共有

チームで統一した Codex 体験を提供するため、以下をリポジトリにコミットする:

```
.codex/
  config.toml       # プロジェクト共通設定
AGENTS.md            # プロジェクト規約
```

```toml
# .codex/config.toml（プロジェクトレベル）
model = "gpt-5.4"
approval_policy = "on-request"
sandbox_mode = "workspace-write"

[features]
multi_agent = true
web_search = false          # 社内プロジェクトでは無効化
```

### 4.2 AGENTS.md のチーム規約

```markdown
# プロジェクト規約（AGENTS.md）

## 技術スタック
- 言語: TypeScript 5.x
- フレームワーク: Next.js 15
- テスト: Vitest + Playwright
- パッケージマネージャー: pnpm

## コーディング規約
- ESLint / Prettier の設定に従う
- 新規ファイルは既存のディレクトリ構造に合わせて配置する
- データベースのマイグレーションは手動で承認してから実行する

## 禁止事項
- 本番環境への直接デプロイ操作
- .env ファイルや認証情報の変更
- package.json の依存関係の大幅な変更（事前確認が必要）
```

### 4.3 CI/CD 統合

```yaml
# GitHub Actions の例
- name: Codex による自動修正
  run: |
    codex exec --ephemeral \
      --ask-for-approval never \
      --sandbox workspace-write \
      --json \
      --output-last-message result.md \
      "lint エラーを修正して"
```

ポイント:
- `--ephemeral` でセッションファイルを残さない
- `--json` でマシンリーダブルな出力
- `--output-last-message` で結果をファイルに保存
- サンドボックスを必ず設定

### 4.4 Git ワークフローとの統合

- Codex 実行前に **git status をクリーンに保つ**（パッチの分離が容易）
- `/diff` や `/review` を活用して変更内容を確認してからコミット
- AGENTS.md に Git の規約（ブランチ戦略、コミットメッセージ形式）を明記

### 4.5 コスト管理

- `service_tier = "flex"` で低コスト実行
- `model_reasoning_effort` を用途に応じて調整（軽微なタスクには `"low"`）
- `/compact` で会話を圧縮しトークン消費を抑制
- サブエージェント（`multi_agent`）はトークン消費が増えるため、必要に応じて無効化

### 4.6 トラブルシューティング

| 問題 | 対処法 |
|------|--------|
| AGENTS.md が読み込まれない | `/debug-config` で設定レイヤーを確認。`~/.codex/log/codex-tui.log` を監査 |
| MCP サーバーが起動しない | `codex mcp list` で状態確認。`startup_timeout_sec` を増加 |
| サンドボックスでコマンドが失敗 | `--add-dir` で追加ディレクトリを付与、または `/sandbox-add-read-dir` を使用 |
| トークン上限に達する | `/compact` で履歴圧縮。`model_reasoning_effort` を下げる |
| 設定が反映されない | `--config` フラグで直接上書きし動作確認。優先順位を確認 |

> 公式ドキュメント: [Codex CLI](https://developers.openai.com/codex/cli) / [Agent Approvals & Security](https://developers.openai.com/codex/agent-approvals-security) / [AGENTS.md Guide](https://developers.openai.com/codex/guides/agents-md)
