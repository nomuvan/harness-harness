# ClaudeによるCodex計画レビュー

レビュー対象: `docs/codex-plan.md`（plan/codex-initialブランチ）
レビュアー: Claude Opus 4.6
日付: 2026-03-23

## 総評

Codexの計画は**質が高い**。特に「Claudeの劣化コピーにしない」という姿勢が一貫しており、Codex固有の強みを的確に活かしている。Claudeの計画が「仕様整備→テンプレート」というトップダウンだったのに対し、Codexは「ネイティブ運用を先に作る→共通化は後」というボトムアップで、この補完関係が有益。

## 強み（採用すべき提案）

### 1. mappingの4分類（★最重要）
> 「shared」「claude-native」「codex-native」「wrapper-required」の4分類

現在のmapping/は1:1変換表だが、実際には「無理に変換すべきでないもの」が多い。この4分類は本質的で、mapping/の次版に即採用すべき。

### 2. プロファイルによる自律レベルの実装
> safe / author / verify / ci

philosophy.mdの自律レベルが抽象概念のままだったのを、Codexのプロファイル機能で具体的な設定に落とし込んでいる。Claude側でもsettings.jsonの複数バリエーション（安全/通常/自律）として同等の仕組みを作るべき。

### 3. 「翻訳より先にネイティブ」の原則

各プラットフォームで「その環境にとって自然な形」を先に作り、共通化は後からやる。これはClaude計画の「仕様→マッピング→テンプレート」より健全なアプローチ。

### 4. codex execベースの非対話自動化レーン

Claude側にはこの発想が薄かった。`codex exec --json --output-schema` の活用は、CI/CD統合やバッチ処理で明確な優位性がある。

### 5. Hooks不在をラッパースクリプトで埋める設計

無い機能を嘆くのではなく、既存手段（scripts/）で実用的に補う。render-harness.py、validate-harness.pyの提案は具体的で実装可能。

## 懸念・改善提案

### 1. Pythonスクリプト群は時期尚早

5つのPythonスクリプト（render, validate, codex-exec, preflight, postflight）を初期に作るのは、まさに「過剰構造化リスク」に該当する。まず1プロジェクトでハーネスを手動生成し、痛みがわかってから自動化すべき。

**提案:** Phase 1ではスクリプトなしでテンプレートを手動適用。痛みが明確になったPhase 2でスクリプト化。

### 2. shared/ ディレクトリの追加は要検討

templates/shared/ の提案はテンプレート設計として合理的だが、現時点で「共通化すべきもの」が見えていない。実際に2-3プロジェクトでClaude/Codex両方のハーネスを作ってみて、本当に共通化すべき部分が判明してからでよい。

### 3. JSON Schemaによる検証は後回し可

`--output-schema` は強力だが、初期構築でスキーマ定義まで着手すると作業量が膨らむ。まずは手動確認→後でスキーマ化の順が妥当。

### 4. codex mcp-server はPoC優先

> Claude から Codex を呼ぶブリッジ候補にする

これは非常に面白い提案。ただし今回 `codex exec` で十分にCodex呼び出しが機能したので、mcp-serverの必要性はPoCで評価してからにすべき。

## Claude計画の自己反省（Codex計画を受けて）

- Claude計画はspecs/やmapping/に時間をかけすぎた。Codexの「ネイティブ運用を先に」が正しい
- Skills/Hooksを中心に据えたアーキテクチャ図は、確かにClaude語彙に引っ張られている
- 非対話・CI/CDの視点が弱かった。これはCodexの明確な補完ポイント

## 最終計画への反映推奨

| 項目 | 推奨 | 優先度 |
|------|------|--------|
| mappingの4分類 | 即採用 | 高 |
| プロファイル設計 | 即採用（Codex）、Claude側も同等設計 | 高 |
| ネイティブ先行原則 | 即採用 | 高 |
| codex exec自動化 | Phase 2で | 中 |
| Pythonスクリプト群 | 痛みが判明してから | 低 |
| shared/ テンプレート | 実績ができてから | 低 |
| JSON Schema | 後回し | 低 |
| codex mcp-server | PoC | 低 |
