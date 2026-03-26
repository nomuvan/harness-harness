# DeerFlow 2.0 からの知見と採用判断

調査日: 2026-03-26
対象: https://github.com/bytedance/deer-flow

## 方針

DeerFlowは「直接組み込む対象」ではなく「再利用可能ハーネスの設計例」として参照する。harness-harnessのcore（spec/template/file-first）は維持しつつ、設計パターンを借りる。

## 採用判断

| パターン/機能 | 判定 | 理由 | 適用方法 |
|-------------|------|------|---------|
| Harness/App分離 | 最優先採用 | harness-harnessの「ドメイン非依存構造とドメイン固有の分離」と完全合致。境界テストでCI強制 | architecture.mdの設計原則として明文化。テンプレートは「Harness kernel」として独立性を維持 |
| Progressive Skill Loading | 強く採用 | 段階的開示の具体実装。必要時だけスキルをコンテキスト注入 | CLAUDE.mdの肥大化防止策として適用。skills/public + skills/custom の二層構造を参考に |
| skills/public + skills/custom分離 | 採用 | テンプレートデフォルトとプロジェクト固有の明確な分離 | templates/ = public相当、対象プロジェクト固有 = custom相当 |
| Lead/SubAgentパターン | 部分採用 | 思想は良いがLangGraph前提実装は重い。Claude Agent Teams/Codex multi_agentで代替可能 | マルチエージェント設計のテンプレートパターンとしてkb/に記録 |
| ミドルウェアパイプライン | 参考 | 12段は過剰だが、関心の分離パターンとして参考に | Hooks設計のガイドラインに反映（SessionStart, PreToolUse等を段階的に導入） |
| メモリの信頼度スコア | 条件付き採用 | 事実に信頼度+タイムスタンプは有用。ただしJSON-onlyは不採用、Markdown-first | kb/の知見管理に応用。鮮度と信頼性の構造的管理 |
| 境界テスト(test_harness_boundary.py) | 採用 | アーキテクチャ境界をCIで自動検証 | テンプレートがドメイン固有情報を含んでいないかの自動チェック |
| LangChain/LangGraph依存 | 不採用 | harness-harnessは特定フレームワークに依存すべきでない | パターンのみ抽出 |
| Server-first構成 | 不採用 | harness-harnessはファイルベースのテンプレート管理 | file-firstを維持 |
| BytePlus商業化パターン | 不採用 | 純粋OSSを維持 | — |

## harness-harnessへの組み込み指針

### 既存ハーネスへの適用

1. **Harness/App分離を明文化**: ハーネス（CLAUDE.md, settings.json, skills, rules）はドメイン非依存のコアとして独立させ、対象プロジェクトのアプリケーションコードに依存しない設計を徹底
2. **Progressive Skill Loading**: create-harnessで生成するスキルに `paths` フィールドを積極活用。必要な領域でのみスキルをコンテキストに注入
3. **skills/public + custom**: cross-project-copyスキルでの「汎用パターン（★★★★★）」= public、「ドメイン固有（★★☆☆☆以下）」= custom という対応関係を明確化

### 新規ハーネスへの適用

1. **テンプレート設計原則**: 「テンプレートはHarness kernelであり、App layerから独立している」を原則に追加
2. **段階的スキル導入**: create-harnessのPhase 2で「最小限のスキルから始め、必要に応じて追加」を明示
3. **メモリ設計**: auto-memoryの知見をMarkdown-firstで管理するガイドラインを追加

### 組み込むべきでないもの

- DeerFlowそのものへの依存（コードベースの取り込み）
- LangGraph/LangChainの導入
- Server-first / Docker-first の構成（harness-harnessはファイルベース）
- 12段ミドルウェアのような過剰な複雑性（対象プロジェクト規模に合わせた簡素化が必要）
- multi-agentを先に目的化すること（policy abstractionだけ先に置く）

## Claude/Codexクロスレビュー結果

### Claude評価の強み
- 網羅的なアーキテクチャ分析（三層構造、12段ミドルウェアの全列挙）
- 類似ツールとの詳細比較（GPT Researcher, autoresearchとの対照表）
- コミュニティ反応（X/Twitter、Hacker News）の収集

### Codex評価の強み
- harness-harnessの既存アセット（philosophy.md, architecture.md）との照合が具体的
- 「中庸案」の提案が実践的（パターンを借りつつcore維持）
- 「bridge skill / adapter command」の概念提案が独創的
- 「multi-agentは実装ではなくpolicy abstraction」という切り分けが鋭い

### 統合判断
- Codexの「Harness/App分離を最優先」「runtime-managed skills」の評価をClaude側の知見で裏付け
- Claude側の「Progressive Skill Loading」の具体例をCodex側の「nested SKILL.md discovery」と統合
- メモリはClaude側「信頼度スコア付き」+Codex側「Markdown-first」の折衷案を採用
