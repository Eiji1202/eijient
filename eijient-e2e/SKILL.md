---
name: eijient-e2e
description: >
  Playwright MCPを使ってブラウザを直接操作し、E2Eテストを実行するSkill。
  「E2Eテストして」「動作確認して」「ブラウザで確認して」「テストを実行して」のように
  動作検証・テスト実行を依頼されたときに使う。テストコード不要でその場でブラウザを操作し、
  必要なら操作内容をPlaywrightテストコード（.spec.ts）として保存することもできる。
---

# eijient-e2e Skill

## 概要

Playwright MCPを使い、Claudeが直接ブラウザを操作してE2Eテストを実行する。
テストコードなしで動作確認ができ、`--save` オプションで操作内容を `.spec.ts` として保存できる。

---

## 前提条件

Playwright MCPがClaude Codeに追加されていること。未追加の場合はまず以下を実行するよう案内する：

```bash
claude mcp add playwright npx @playwright/mcp@latest
```

追加後、Claude Codeを再起動して `@eijient-e2e` を再度呼び出す。

---

## ワークフロー

### Step 1: テスト対象・シナリオの確認

ユーザーのリクエストを分析し、不明な場合は以下を確認する：

```
1. テスト対象のURLは何ですか？
   （例: http://localhost:3000）
2. 確認したい操作・画面はどれですか？
   （例: ログイン → ダッシュボード表示）
3. テストコードとして保存しますか？（yes / no）
```

`--url`・`--scenario`・`--save` が引数で指定されている場合はヒアリングをスキップする。

### Step 2: 開発サーバーの確認

ローカルURLの場合、サーバーが起動しているか確認する：

```bash
# package.jsonのdevスクリプトを確認
cat package.json | grep -A5 '"scripts"'
```

サーバーが起動していない場合はユーザーに起動を依頼して待機する。
（Skillが自動でサーバーを起動するとプロセス管理が複雑になるため、起動はユーザーに委ねる）

### Step 3: Playwright MCPでブラウザ操作・テスト実行

Playwright MCPの以下のツールを使ってテストシナリオを実行する：

#### 基本操作ツール

| ツール                    | 用途                                         |
| ------------------------- | -------------------------------------------- |
| `browser_navigate`        | URLに移動                                    |
| `browser_snapshot`        | 現在のページ構造を取得（操作前後に必ず実行） |
| `browser_click`           | 要素をクリック                               |
| `browser_fill_form`       | フォームに入力                               |
| `browser_type`            | テキストを入力                               |
| `browser_wait_for`        | テキスト表示・非表示を待機                   |
| `browser_take_screenshot` | スクリーンショット（記録用）                 |

#### 検証ツール

| ツール                           | 用途                                 |
| -------------------------------- | ------------------------------------ |
| `browser_verify_text_visible`    | テキストが画面に表示されているか確認 |
| `browser_verify_element_visible` | 要素が表示されているか確認           |
| `browser_verify_value`           | 要素の値を確認                       |
| `browser_console_messages`       | コンソールエラーを確認               |
| `browser_network_requests`       | APIリクエストを確認                  |

#### 操作の原則

- 各操作の前後で `browser_snapshot` を実行してページ状態を把握する
- 期待する状態が現れるまで `browser_wait_for` で待機する
- エラー・異常なコンソール出力は `browser_console_messages` で確認する
- `--save` が指定された場合は各操作のセレクタ・アクションを記録しておく

### Step 4: 検証・結果報告

テストシナリオの実行後、以下の形式でユーザーに報告する：

```
## E2Eテスト結果

**対象URL:** {URL}
**シナリオ:** {シナリオ名}

### ✅ 成功した操作
- {操作1}: {確認内容}
- {操作2}: {確認内容}

### ❌ 失敗した操作（あれば）
- {操作}: {エラー内容}
  → 原因: {推定される原因}
  → 対応: {修正提案}

### ⚠️ 気になった点（あれば）
- {コンソールエラーや想定外の挙動}

**総合判定:** ✅ PASS / ❌ FAIL
```

### Step 5: テストコードの保存（--save 指定時のみ）

`--save` が指定された場合、Step 3の操作をPlaywrightテストコードとして生成・保存する。

保存先はプロジェクトの既存テストディレクトリに合わせる：

```bash
# テストディレクトリを確認
ls -d tests/ e2e/ __tests__/ playwright/ 2>/dev/null | head -1
```

生成するテストコードのテンプレート：

```typescript
import { test, expect } from "@playwright/test";

test("{シナリオ名}", async ({ page }) => {
  // Step 1: {操作の説明}
  await page.goto("{URL}");

  // Step 2: {操作の説明}
  await page.getByRole("{role}", { name: "{name}" }).click();

  // Step 3: {検証の説明}
  await expect(page.getByText("{期待するテキスト}")).toBeVisible();
});
```

保存後、以下を案内する：

```
📄 テストコードを保存しました: {ファイルパス}

実行するには:
npx playwright test {ファイルパス}

# UIモードで確認:
npx playwright test {ファイルパス} --ui

※ playwright.config.ts がない場合は初期化が必要です:
npx playwright install
```

---

## 引数

| 引数           | 短縮 | デフォルト | 説明                                                 |
| -------------- | ---- | ---------- | ---------------------------------------------------- |
| `--url`        | `-u` | ヒアリング | テスト対象のURL                                      |
| `--scenario`   | `-s` | ヒアリング | テストシナリオの説明                                 |
| `--save`       |      | false      | 操作をPlaywrightテストコード（.spec.ts）として保存   |
| `--screenshot` |      | false      | 各ステップのスクリーンショットを保存                 |
| `--headed`     |      | false      | ブラウザをheadedモードで起動（デフォルトはheadless） |

---

## 使用例

```bash
# 基本的な動作確認
@eijient-e2e ログイン画面を確認して

# URL指定
@eijient-e2e --url http://localhost:3000 ログインからダッシュボードまで確認して

# テストコードも保存
@eijient-e2e --url http://localhost:3000/login --save ログインフローをテストして

# スクリーンショット付きで確認
@eijient-e2e --screenshot 商品一覧から購入完了までのフローを確認して
```

---

## ベストプラクティス

### 操作の粒度

- 1回の `@eijient-e2e` で確認するシナリオは **1フロー** に絞る
- 「ログイン → 商品追加 → 購入 → 確認メール」のような複数フローは分けて実行する

### セレクタの優先順位（テストコード保存時）

Playwright公式の推奨順に従う：

1. `getByRole` （最優先・アクセシビリティに基づく）
2. `getByLabel` （フォーム要素）
3. `getByText` （テキストが一意な場合）
4. `getByTestId` （`data-testid` 属性）
5. CSS/XPath は最終手段

### エラー時の対応

- ネットワークエラー → `browser_network_requests` でAPIレスポンスを確認
- 要素が見つからない → `browser_snapshot` でDOM構造を確認してからセレクタを修正
- タイムアウト → `browser_wait_for` の待機条件を見直す

---

## 注意事項

- Playwright MCPが未設定の場合は `claude mcp add playwright npx @playwright/mcp@latest` を案内して停止する
- 本番環境URLへのテストは破壊的操作（フォーム送信・削除等）が発生しうるため、実行前に確認する
- テストコードを保存する場合、`playwright.config.ts` の有無を確認し、なければ初期化を案内する
- ログイン等の認証が必要な場合は、認証情報をユーザーに入力してもらってから操作を続ける（Skillが認証情報を保持しない）

---

## 参考

- [Playwright MCP GitHub](https://github.com/microsoft/playwright-mcp)
- [Playwright テストドキュメント](https://playwright.dev/docs/writing-tests)
