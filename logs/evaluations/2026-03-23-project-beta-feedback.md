# project-beta ハーネス新規作成フィードバック

日付: 2026-03-23
対象PR: <private-pr-url>

## project-alphaとの比較

| 観点 | project-alpha | project-beta |
|------|--------|----------------|
| プロジェクト種別 | コーディング（Java+Rust） | ナレッジ管理（Markdown vault） |
| ビルド | mvn, cargo | なし |
| テスト | JUnit, cargo test | なし |
| ハーネスの複雑さ | 高（9スキル、7ルール、4hooks） | 低（2スキル、1ルール） |
| 必要なスキル | 自律タスク、PDCA、PRレビュー | yaml管理、sync修復 |
| ドメイン知識 | 日本株市場仕様、COM、DDE | Obsidianプラグイン、vault管理 |

## 学んだこと

### 1. コーディングプロジェクトとナレッジ管理プロジェクトのハーネスは根本的に異なる
project-alphaのパターン（autonomous-task, pr-review-cycle等）はproject-betaには不要。
逆にyaml-frontmatterやgithub-force-syncはproject-alphaには不要。
→ **テンプレートは「minimal」を最小にして、目的別テンプレートで差分を提供すべき**

### 2. ゼロからのハーネス作成はスムーズだった
project-alphaの改善（既存ハーネスの診断→修正）より、ゼロからの方が速い。
既存のしがらみがないため、最新のベストプラクティスを直接適用できる。

### 3. CIワークフローがないプロジェクトではレビューサイクルがない
project-betaにはclaude-pr-reviewがないため、レビューなしでマージ。
→ **GitHub Actionsのclaude-pr-reviewワークフローのテンプレート化が急務**

### 4. obsidian-gitの自動コミットとハーネスのコミットが混在する
vault backupの自動コミットとharness改善のコミットが区別しにくい。
→ 特に対策不要（コミットメッセージで区別可能）

## プロジェクト間コピー候補

project-betaからは汎用パターンは少ない。ただし:
- yaml-frontmatterスキルの「ファイル一括処理」パターンは /batch 的で他でも使える
- github-force-syncスキルはgitを使う全プロジェクトで有用

## registry更新済み
