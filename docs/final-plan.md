# 最終計画

Claude-Codexクロスレビューを経て決定した、harness-harness初期構築の最終計画。

## 決定プロセス

1. Claudeが計画策定 → `plan/claude-initial` ブランチ
2. Codexが計画策定 → `plan/codex-initial` ブランチ（`docs/codex-plan.md`）
3. ClaudeがCodexの計画をレビュー → `docs/review-codex-by-claude.md`
4. CodexがClaudeの計画をレビュー → `docs/review-claude-by-codex.md`
5. Claudeが最終計画を決定 → 本ドキュメント

## 双方の一致点（最終計画の土台）

- 過剰構造化リスクは中〜高。メタ構造が実働物より先に増えている
- 実践先行すべき。dogfoodingが最優先
- ただし理論・仕様調査も重要。ユーザーが知らなかった機能を発見し改善に繋げることがharness-harnessの核心的価値。理論で発見→実践で検証のサイクル
- 各プラットフォームはネイティブ運用を先に確立すべき
- 無理な互換化を避ける。変換できないものは変換しない

## 採用する方針

### Codex計画から採用

| 項目 | 理由 |
|------|------|
| mappingの4分類（shared/claude-native/codex-native/wrapper-required） | 「何を変換しないか」の判断基準になる |
| プロファイル設計（safe/author/verify/ci） | 自律レベルを抽象概念から設定に落とし込む |
| 「翻訳より先にネイティブ」の原則 | 過剰構造化を防ぐ |
| codex execベースの非対話自動化レーン | Claude側にない明確な補完価値 |

### Claude計画から維持

| 項目 | 理由 |
|------|------|
| specs/による仕様書整備 | 仕様ベースで差分議論できる基盤として有効 |
| kb/external/の調査蓄積 | 外部知見の蓄積は継続的に価値がある |
| 自律改善サイクルの設計 | 長期的な成長に必要 |
| worktreeによる並列作業 | 実際に有効だった |

### 後回しにするもの

| 項目 | 条件 |
|------|------|
| Pythonスクリプト群（render, validate, preflight, postflight） | 2-3プロジェクトで痛みが判明してから |
| templates/shared/ | 共通化すべき部分が実践で見えてから |
| JSON Schema検証 | 手動確認で限界を感じてから |
| codex mcp-server | PoCで有効性を確認してから |

## 次のアクション（優先順）

### 即座に実行

1. レビュー結果と最終計画をmainにマージ
2. mapping/を4分類に再編

### 短期（次の1-2セッション）

3. harness-harness自身でdogfooding
   - Claude: CLAUDE.md + .claude/ が実際のセッションで正しく動作するか確認
   - Codex: AGENTS.md + .codex/config.toml が実際のセッションで正しく動作するか確認
4. 既存の実プロジェクト1つにハーネスを生成してみる
5. 痛みと発見をADRとして記録

### 中期（3-5セッション）

6. dogfoodingの結果からテンプレート初版を作成
7. 必要と判明したスクリプトのみ実装
8. Codexプロファイル（safe/author/ci）のテンプレート化

## 成功条件

- Claude用ハーネスがClaudeセッションで正しくロードされ、意図通りに動作する
- Codex用ハーネスがCodexセッションで単独運用でき、Claudeの劣化コピーではない
- 実プロジェクト1つ以上でハーネスが生成・運用できている
- 増えたドキュメント量より、減った手作業量の方が大きい
