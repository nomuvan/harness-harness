# Codex視点 初期構築計画

Codex CLI を Claude の単純な変換先ではなく第一級ターゲットとして扱うための初期構築計画。

## 前提

- 本計画は、現時点で存在する `docs/`, `specs/`, `mapping/`, `kb/` をレビューした上で作成する
- 明示的な「Claude計画書」は未作成のため、`docs/architecture.md` と各仕様書から Claude 側の暗黙の計画を読み解いて評価する
- 基本思想は `docs/philosophy.md` を継承する
- Mac/Windows 両対応、symlink 非依存、業務ドメイン非同梱を前提にする

## Claude 側成果物のレビュー

### 良い点

- `specs/claude/`, `specs/codex/` が先に整理されており、機能差分の議論を仕様ベースで進められる
- `mapping/` がすでに存在し、Claude ⇔ Codex の往復変換を前提にした設計思想がある
- `docs/philosophy.md` に「段階的開示」「透過性」「自律改善」「多様性は善」が定義されており、ハーネス生成方針の土台として十分強い
- `docs/architecture.md` と `docs/conventions.md` に worktree 活用、Markdown 中心、ファイルシステム中心の方針があり、Codex にも適合する
- `kb/external/` の調査結果があり、OpenClaw / gstack / superpowers の知見を再利用できる

### Codex 視点での改善提案

| 観点 | 現状の評価 | Codex 視点の改善 |
|------|------------|------------------|
| アーキテクチャ | `skills/ & commands/` レイヤーが中央にあり、Claude の機能語彙に引っ張られている | ランタイム層を `claude-runtime` / `codex-runtime` に分離し、Codex は `AGENTS.md` + `.codex/config.toml` + `codex exec` を中核に置く |
| mapping | 1:1 変換表は強いが、何を「変換しないか」の指針が弱い | 「shared」「claude-native」「codex-native」「wrapper-required」の4分類を追加し、無理な互換化を避ける |
| templates | スケルトンのみで、実行可能成果物が未着手 | Codex 向けに `AGENTS.md`、`.codex/config.toml`、`codex exec` ラッパーを最優先で具体化する |
| scripts | Hooks 代替や自動化の設計が未実装 | `codex exec` を中心に、preflight/postflight/validate をラップするスクリプト層を設ける |
| 運用設計 | 承認ポリシー、サンドボックス、プロファイルの運用モデルが未定義 | `safe` / `author` / `verify` / `ci` のプロファイル設計を初期段階から入れる |
| CI/非対話 | Claude 側の対話・Hooks・Skills 寄りの発想が強い | Codex は `codex exec --json --output-last-message --output-schema --ephemeral` を前提にした自動化レーンを持つ |
| マルチエージェント | Claude の強みに比べて Codex は実験的機能 | `multi_agent` は初期構築の前提にしない。使えても補助機能扱いに留める |

## Codex で取るべき独自アプローチ

### 1. 「翻訳」より「ネイティブ運用」を先に作る

- Codex には Claude の Skills / Hooks / カスタムサブエージェントと同等の正式機能がない
- したがって、Claude 機能の欠落を AGENTS の文章で補うだけでは弱い
- Codex 側では以下を第一級成果物として扱う
  - `AGENTS.md`
  - `.codex/config.toml`
  - `codex exec` を包む実行ラッパー
  - 機械検証用の JSON Schema と検証スクリプト

### 2. プロファイルを「自律レベルの実装」に使う

- `docs/philosophy.md` の自律レベルを、Codex では抽象概念で終わらせず設定に落とす
- 初期の推奨プロファイルは以下

| プロファイル | 目的 | 主要設定 |
|--------------|------|----------|
| `safe` | 初回読解・監査 | `approval_policy = "on-request"`, `sandbox_mode = "read-only"` |
| `author` | 通常編集 | `approval_policy = "on-request"`, `sandbox_mode = "workspace-write"` |
| `verify` | 検証・軽自動化 | `approval_policy = "untrusted"`, `sandbox_mode = "workspace-write"` |
| `ci` | 非対話実行 | `approval_policy = "never"`, `sandbox_mode = "workspace-write"`, `--ephemeral` 前提 |

- `danger-full-access` と `--yolo` は初期構築では不採用とする

### 3. Hooks 不在はラッパースクリプトで埋める

- Codex には Claude の Hooks がないため、ライフサイクル制御は `scripts/` 側に持つ
- 初期構築で用意するべき責務
  - preflight: 仕様書・テンプレート・registry の整合確認
  - invoke: `codex exec` の統一実行
  - postflight: 出力保存、ログ整形、要約抽出
  - validate: 生成されたハーネスの構造チェック
- これにより「助言的な AGENTS」と「決定論的な自動処理」を分離できる

### 4. Codex を人間向け対話と機械向け自動化の両方で使う

- 対話モードでは `/plan`, `/review`, `/debug-config`, `/status`, `/diff` を重視する
- 非対話モードでは `codex exec` を標準 API と見なす
- 特に以下のオプションは Codex 独自価値として積極利用する
  - `--json`
  - `--output-last-message`
  - `--output-schema`
  - `--ephemeral`
  - `resume`
  - `fork`

## テンプレート設計方針

### AGENTS.md 設計

- ルート `AGENTS.md` は不変の規約だけを書く
- 可変情報、長い手順、環境依存情報は直接書かない
- Codex は `@import` を持たないため、共有断片を手書きで複製しない
- 共有ソースはテンプレート断片として保持し、最終 `AGENTS.md` は生成物として組み立てる
- `AGENTS.override.md` は通常テンプレートには含めない
- 1 ディレクトリ 1 ファイルという制約を前提に、必要な場合はサブディレクトリに `AGENTS.md` を置いて差分だけを持たせる
- 32 KiB 制限を超えないよう、生成前にサイズ検査を必須にする

### 初期テンプレートで持つべき AGENTS セクション

- プロジェクト概要
- 必須参照ドキュメント
- 編集原則
- テスト・検証原則
- 破壊的操作の禁止
- `codex exec` を使う自動化手順
- ディレクトリ別の注意点

### `.codex/config.toml` 設計

- プロジェクト共通設定は `.codex/config.toml` に集約する
- 初期値の方針
  - `model = "gpt-5.4"`
  - `approval_policy = "on-request"`
  - `sandbox_mode = "workspace-write"`
  - `personality = "pragmatic"`
  - `web_search = "disabled"` または `cached` を用途別に分ける
- `profiles.*` で前述の運用モードを定義する
- `shell_environment_policy` を設定し、秘匿環境変数の漏洩を防ぐ
- `history.persistence` は対話と CI で使い分ける
- `features.multi_agent` は明示的に opt-in にし、初期ハーネスの必須要件にしない

### 望ましいテンプレート配置

```text
templates/
  shared/
    agents-src/
    docs-src/
  codex/
    base/
      AGENTS.md.tmpl
      .codex/
        config.toml.tmpl
    profiles/
      safe.toml
      author.toml
      verify.toml
      ci.toml
    commands/
      codex-exec-task.md.tmpl
```

- `shared/` は抽象ルールの単一ソース
- `codex/` は Codex ネイティブ成果物
- Claude 向けと無理に同一ファイルへ押し込まず、共有元だけを共通化する

### scripts/ の初期構築方針

- クロスプラットフォーム性を優先し、スクリプト本体は Python 標準ライブラリ中心で設計する
- 必要なら `.sh` / `.ps1` は薄いラッパーだけにする
- 初期に用意すべきもの

| スクリプト | 役割 |
|-----------|------|
| `scripts/render-harness.py` | テンプレート断片から `AGENTS.md` / `.codex/config.toml` を生成 |
| `scripts/validate-harness.py` | 必須セクション、サイズ、パス、frontmatter 相当ルールを検証 |
| `scripts/codex-exec.py` | `codex exec` を標準フラグ込みで呼び出す |
| `scripts/preflight.py` | 仕様書、registry、テンプレート選択の整合確認 |
| `scripts/postflight.py` | `logs/` への記録、出力整形、評価メタデータ保存 |

- これにより Codex 側の「Hooks 不在」を実装面で補完する

## Codex 固有機能の活用計画

| 機能 | 初期構築での使い方 |
|------|-------------------|
| プロファイル | 自律レベル・用途別の運用モードとして定義 |
| 承認ポリシー | 監査、編集、検証、CI を安全に切り替える |
| サンドボックス | `read-only` / `workspace-write` を標準化し、`danger-full-access` を避ける |
| `codex exec` | 生成、診断、再構築、レビューの標準実行経路にする |
| `--output-schema` | テンプレート生成結果や診断結果の機械検証に使う |
| `--ephemeral` | CI と評価ジョブの履歴汚染を防ぐ |
| `codex sandbox --` | ハーネス検証コマンドの安全実行に使う |
| MCP の `enabled_tools` / `disabled_tools` | プロジェクト別の道具立てを制御する |
| `codex mcp-server` | Claude から Codex を呼ぶブリッジ候補にする |
| `/review` | 生成ハーネスや差分の定常 QA レーンにする |

## Claude 側にない Codex 独自価値

- `codex exec` により、会話を介さない再現可能な運用経路を作りやすい
- `profiles` により、同じハーネスでも安全度と自律度を切り替えられる
- `--output-schema` により、LLM 出力を機械的に受け取る設計がしやすい
- `--ephemeral` により、検証ジョブを履歴非永続で回せる
- `.codex/config.toml` によるプロジェクト単位の設定共有が強い
- `shell_environment_policy` により、環境変数の継承を制御しやすい
- `codex mcp-server` により、Codex 自体を他エージェントから利用可能な部品にできる

## Claude との協業ポイント

### Claude が先行しやすい領域

- Hooks を使った決定論的ガードレール
- Skills によるオンデマンド知識注入
- サブエージェントを使った探索・計画・分業
- ユーザーへのインタビューや要件抽出

### Codex が補完しやすい領域

- `codex exec` による CI / バッチ / 再現実行
- `.codex/config.toml` とプロファイル設計
- `AGENTS.md` 階層と override 戦略
- JSON / schema ベースの機械可読な出力
- MCP サーバーとしての橋渡し

### 具体的な協業パターン

1. Claude がワークフロー案を作り、Codex がそれを `AGENTS.md` / `.codex/config.toml` / wrapper script に落とし込む
2. Claude が生成したテンプレートを Codex が `/review` と `codex exec` で検証する
3. Codex を `mcp-server` として公開し、Claude からセカンドオピニオンや Codex 専用処理を呼ぶ
4. 両者の差分は `mapping/` に還元し、共有概念とネイティブ概念を切り分ける

## フェーズ別の初期構築計画

### Phase 0: 方針固定

- `docs/codex-plan.md` を基準計画として確定
- Codex を第一級ターゲットとする ADR を作成
- `mapping/` に shared / native / wrapper-required の分類方針を追加

### Phase 1: Codex ネイティブ最小ハーネス

- `templates/codex/base/AGENTS.md.tmpl` を作成
- `templates/codex/base/.codex/config.toml.tmpl` を作成
- `safe` / `author` / `verify` / `ci` プロファイルを実装
- 本リポジトリ自身に dogfood 適用できる状態まで持っていく

### Phase 2: 自動化レーン構築

- `scripts/render-harness.py` と `scripts/validate-harness.py` を実装
- `scripts/codex-exec.py` で非対話実行を標準化
- `logs/` に実行メタデータを残す構造を決める
- L1 の静的検証を整備する

### Phase 3: 相互補完レイヤー

- Claude ⇔ Codex 間の変換ルールを再整理する
- Hooks / Skills の Claude 固有資産に対する Codex 側代替を明文化する
- `codex mcp-server` 利用の可否を PoC で確認する
- クロスモデルレビューをワークフロー化する

### Phase 4: 評価と自己改善

- L2 として LLM-as-Judge を使ったハーネス評価を追加する
- `docs/decisions/` に改善判断を継続的に記録する
- registry ベースでプロジェクトごとの成熟度を追跡する

## 初期構築でやらないこと

- `multi_agent` 実験機能への依存
- `danger-full-access` 前提の運用
- `--yolo` を使う通常フロー
- symlink ベース配布
- Claude の Skills / Hooks を Codex に無理に擬似再現すること

## 最初の実装順

1. Codex ネイティブなテンプレート断片と `.codex/config.toml` 雛形を作る
2. `AGENTS.md` を生成するレンダラとサイズ検証を作る
3. `codex exec` ラッパーとログ保存を作る
4. `mapping/` を「変換表」から「共有概念 + ネイティブ実装方針」に進化させる
5. harness-harness 自身で dogfooding して改善点を ADR として残す

## 成功条件

- Codex 用ハーネスが Claude の劣化コピーではなく、単体で運用価値を持つ
- `AGENTS.md` と `.codex/config.toml` がテンプレートから再生成可能である
- `codex exec` ベースの非対話運用が成立する
- 承認ポリシーとサンドボックスの運用がテンプレートに埋め込まれている
- Claude との協業点と非互換点が `mapping/` に明示されている
