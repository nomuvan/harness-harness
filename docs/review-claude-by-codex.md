# Claude計画レビュー（Codex視点）

指定ドキュメント群を根拠に、Claude中心で組まれた暗黙計画を Codex CLI の実運用観点から評価したレビュー。

## レビュー前提

- 明示的な「Claude計画書」は見当たらないため、`docs/architecture.md`、`docs/philosophy.md`、`docs/conventions.md`、`specs/claude/`、`mapping/` から暗黙の計画を読み解いて評価した
- 評価軸は `docs/philosophy.md` の「段階的開示」「透過性」「多様性は善」「過度なエンジニアリング回避」を優先した
- Codex 側の事実確認はローカル環境の `codex-cli 0.116.0` に対する `codex --help`、`codex exec --help`、`codex mcp add --help`、`codex review --help`、`codex features list` を参照した

## 総評

Claude 計画の強みは、仕様書先行で整理し、Claude と Codex の差異を早い段階から明文化している点にある。`docs/philosophy.md` の設計思想も強く、Markdown 中心、ファイルシステム中心、worktree 活用という基盤も妥当である。

一方で、現状は「Claude の豊富な機能をどう Codex に翻訳するか」に重心が寄りすぎており、Codex ネイティブな最小運用系を先に成立させる設計にはまだなっていない。Codex 視点では、変換表の完成度よりも、`AGENTS.md`、`.codex/config.toml`、`codex exec` ラッパー、検証スクリプトの4点を先に実働させるべきである。

## 1. Claude計画の強み・弱み

### 強み

- 仕様書駆動である。`specs/claude/` と `mapping/` が先にあるため、感覚ではなく仕様差分で議論できる
- `docs/philosophy.md` が明快である。特に「段階的開示」「多様性は善」「過度なエンジニアリング回避」はハーネス設計のガードレールとして強い
- `docs/architecture.md` の Markdown 中心、ファイルシステム中心、symlink 非依存、worktree 活用は Codex にも相性がよい
- Claude 固有機能をそのまま普遍化せず、「非対称機能はドキュメントで代替」と認識している点は健全である
- `mapping/` を往復で持っているため、片方向変換ではなく、両者を第一級ターゲットにしようという意志は見える

### 弱み

- 明示的な Claude 計画書がない。結果として、アーキテクチャ、仕様、変換表から計画意図を推測する必要があり、優先順位が読みにくい
- アーキテクチャ図の中央に `skills/ & commands/` が置かれており、概念レイヤが Claude の語彙に引っ張られている
- `mapping/` が広く丁寧な反面、「何を変換しないか」「どこから先はネイティブ実装に切り替えるか」の境界が弱い
- Hooks、Skills、サブエージェント、メモリのような Claude の強い機能を、Codex で文章や代替策に落としているが、実行可能成果物まで降りていない
- `docs/philosophy.md` はシンプル志向なのに、現状の構成は抽象化レイヤが先に増えやすく、思想と実装順序に少しズレがある

## 2. Codex視点での具体的な改善提案

### 2.1 変換中心ではなくネイティブ最小構成を先に固定する

- 最初の必須成果物を `AGENTS.md`、`.codex/config.toml`、`codex exec` ラッパー、`validate` スクリプトに限定する
- `mapping/` はその後に「なぜそう生成したか」を説明する層へ下げる
- Claude の機能差分を埋める前に、Codex 単体で1プロジェクトを回せることを成功条件に置く

### 2.2 mapping を4分類に再編する

- `shared`: 両者でそのまま共有できる概念
- `claude-native`: Claude 専用として残す概念
- `codex-native`: Codex 専用として活かす概念
- `wrapper-required`: 変換ではなくスクリプトや運用で埋める概念

これにより、「全部を対応表に載せる」姿勢から、「どこで抽象化を打ち切るか」を判断できるようになる。

### 2.3 Codex の運用単位を profiles と exec に寄せる

- Codex では Hooks や Skills の不足を文章で補うより、プロファイルと非対話実行の設計を強くする方が実用的である
- まずは `safe`、`author`、`ci` の3プロファイルで十分で、`verify` などは dogfood 後に足せばよい
- 自律レベルは思想として書くだけでなく、`approval_policy` と `sandbox_mode` の組で運用に落とすべきである

### 2.4 Hooks 代替は「指示」ではなく「決定論的ラッパー」に寄せる

- `PostToolUse` 相当を AGENTS の文言で再現しようとすると、実行漏れが起きる
- Codex では `preflight`、`invoke`、`postflight`、`validate` のラッパー責務を `scripts/` に切り出す方が強い
- つまり、Claude では Hooks、Codex では wrapper scripts を第一級として設計すべきで、両者を無理に同じ概念にしない方がよい

### 2.5 Codex 固有価値を変換表の脚注ではなく主役にする

- `codex exec --json`
- `codex exec --output-last-message`
- `codex exec --output-schema`
- `codex exec --ephemeral`
- `codex review`
- `codex mcp-server`

このあたりは Claude の代用品ではなく、Codex 側の実行基盤として設計に前面登場させるべきである。

### 2.6 Codex 関連の事実更新を入れる

ローカルの `codex-cli 0.116.0` で確認した範囲では、Codex 側の記述に更新余地がある。

- `codex review` は独立したトップレベルサブコマンドとして存在する
- `codex features list` が存在し、feature 状態を直接確認できる
- `multi_agent` は feature 一覧上では `stable true` で、少なくとも「実験的」と固定表現するのは古くなりやすい

ここで重要なのは「今すぐ multi-agent 前提にすること」ではなく、成熟度の記述を固定テキスト化しすぎないことだ。変化の速い CLI 仕様は、仕様書に静的に書き切るより、確認手順を併記した方が保守しやすい。

## 3. 過剰構造化のリスクへの評価

### 評価

過剰構造化のリスクは中〜高である。

### 理由

- `docs/`、`specs/`、`mapping/`、`templates/`、`scripts/`、`registry/`、`logs/`、`ADR` が揃っており、器は強いが、最小実働物より先にメタ構造が増えやすい
- `mapping/` の往復表が丁寧すぎるため、機能差分を全部吸収したくなる圧力が生まれる
- Claude 固有機能の不足を Codex 側で逐一「擬似再現」しようとすると、運用は複雑になり、`docs/philosophy.md` の「成熟したアーキテクチャ上のシンプルさに回帰する」と逆行する
- パススコープルール、Hooks、Skills、メモリをすべて抽象化対象にすると、ユーザー価値より翻訳メンテナンスが主仕事になりやすい

### リスクを抑える判断基準

- 1回も dogfood していない機能には新しい抽象層を作らない
- 変換不能な機能は無理に表で埋めず、`native` か `wrapper-required` に落とす
- 新しいドキュメントを増やす前に、既存テンプレートかスクリプトに反映できるかを確認する
- 成果物は「説明文書」ではなく「再生成できるハーネス」を優先する

## 4. 実践先行アプローチへの提案

### 最初にやるべきこと

1. このリポジトリ自身を対象に、Codex ネイティブな最小ハーネスを作る
2. 生成対象を `AGENTS.md` と `.codex/config.toml` に絞る
3. `codex exec` を呼ぶ薄いラッパーを1本作る
4. サイズ検査、必須セクション検査、最小動作検証だけを実装する
5. 実運用で痛みが出た箇所だけを `mapping/` と `templates/` に還元する

### 最小 dogfood シナリオ

- シナリオ1: 読み取り専用でリポジトリレビューできるか
- シナリオ2: ワークスペース書き込みでドキュメント更新できるか
- シナリオ3: `codex exec` 非対話モードで再現実行できるか
- シナリオ4: MCP を1つ追加して、設定テンプレートが壊れないか

### 成果の判定基準

- Codex 用ハーネスが Claude の劣化コピーではなく、単独で説明可能である
- 生成結果が手作業ではなくテンプレートから再生成できる
- 1つ以上の実務タスクを `codex exec` ベースで安定再現できる
- 増えた文書量より、減った手作業量の方が明確に大きい

## 結論

Claude 計画は、仕様整理と抽象化の出発点としてはかなり強い。ただし Codex 視点では、現段階の最優先課題は「翻訳の完成度」ではなく「Codex ネイティブ最小運用系の成立」である。

したがって、次の一手は `mapping/` の拡張ではなく、`AGENTS.md`、`.codex/config.toml`、`codex exec` ラッパー、検証スクリプトを使った dogfooding を先に回すことを推奨する。その実測結果を受けて初めて、どの抽象化が必要で、どの抽象化が過剰かを正しく判定できる。
