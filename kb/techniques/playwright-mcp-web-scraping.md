---
title: Playwright MCPによるJSレンダリングページ取得
tags: [playwright, mcp, web-scraping, chatgpt, x-twitter, spa]
last_checked: "2026-03-29"
summary: "WebFetchで取得できないSPA/JSレンダリングページをPlaywright MCPのbrowser_evaluate経由で取得する手法"
---

# Playwright MCPによるJSレンダリングページ取得

## 問題

WebFetchツールは静的HTMLのみ取得する。以下のようなJavaScriptで動的レンダリングされるページは内容を取得できない:
- ChatGPT共有リンク（`chatgpt.com/share/...`）
- X(Twitter)投稿（`x.com/.../status/...`）
- その他SPA（Single Page Application）

## 解決策

Playwright MCPサーバーをインストールし、ヘッドレスブラウザで実際にJSを実行してからDOM内容を取得する。

### セットアップ

```bash
claude mcp add playwright -- npx @anthropic-ai/mcp-playwright
```

### 使い方

```
# 1. ページにナビゲート
mcp__playwright__browser_navigate(url: "https://chatgpt.com/share/...")

# 2. ページ内容をJS経由で取得（3000文字ずつ分割）
mcp__playwright__browser_evaluate(function: "() => document.body.innerText.substring(0, 3000)")
mcp__playwright__browser_evaluate(function: "() => document.body.innerText.substring(3000, 6000)")
# ... 全文取得まで繰り返し

# 3. 全文の長さを先に確認すると効率的
mcp__playwright__browser_evaluate(function: "() => document.body.innerText.length")
```

### 実証済みサイト

| サイト | URL形式 | WebFetch | Playwright MCP |
|--------|---------|----------|---------------|
| ChatGPT共有リンク | `chatgpt.com/share/...` | NG（ログインページに飛ぶ） | OK |
| X(Twitter)投稿 | `x.com/.../status/...` | NG（402エラー） | 未検証（要確認） |

### 注意事項

- `browser_evaluate`の戻り値には文字数制限がある。3000文字程度ずつ分割取得が安全
- ページによってはJSレンダリング完了まで待機が必要（`browser_wait_for`を使う）
- 認証が必要なページ（非公開）は取得できない
- レート制限に注意。連続アクセスは間隔を空ける

### harness-harnessでの活用場面

- **init-project**: ユーザーが参照URLとしてChatGPT共有リンクやX投稿を指定した場合
- **research-kb**: 調査対象のWebページがSPAの場合
- **patrol-docs**: 公式ドキュメントがSPAで提供されている場合
