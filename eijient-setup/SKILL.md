---
name: eijient-setup
description: >
  新しいプロジェクトや新しいマシンで eijient を使うための環境セットアップを行うSkill。
  ~/.claude/settings.json の設定と、プロジェクトの CLAUDE.md を対話的に生成する。
---

# eijient-setup Skill

## 概要

このSkillは以下を自動で行います：

1. `~/.claude/settings.json` に必要な設定を追加
2. プロジェクト情報をヒアリングして `CLAUDE.md` を生成

---

## ワークフロー

### Step 1: settings.json のセットアップ

`~/.claude/settings.json` を確認し、以下の設定が存在しない場合は追加・マージする。

```json
{
  "defaultMode": "auto",
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  },
  "permissions": {
    "allow": [
      "ToolSearch",
      "Agent",
      "Bash(npm run:*)",
      "Bash(git add:*)",
      "Bash(git commit:*)",
      "Bash(git push:*)",
      "Bash(gh issue create:*)",
      "Bash(gh pr create:*)",
      "Read",
      "Write",
      "Edit"
    ]
  }
}
```

**注意：** 既存の設定がある場合は上書きせず、不足しているキーだけをマージする。

### Step 2: 依存ツールの確認

以下のツールがインストール・設定済みか確認する：

```bash
# gh CLI の確認
gh --version
gh auth status

# tmux の確認（任意・split-pane表示に必要）
which tmux
```

不足している場合はインストール方法をユーザーに案内する（自動インストールはしない）。

### Step 3: CLAUDE.md のヒアリング

カレントディレクトリに `CLAUDE.md` が存在するか確認する。

**存在する場合：** 「CLAUDE.md はすでに存在します。上書きしますか？」と確認してから進む。

**存在しない場合：** 以下の順番でユーザーに質問する：

```
1. プロジェクト名は何ですか？
2. このプロジェクトは何を作るものですか？（1〜2行で）
3. ターゲットユーザーは誰ですか？
4. フロントエンドの技術スタックを教えてください
   （例: Next.js 15 / TypeScript / Tailwind CSS）
5. バックエンドの技術スタックを教えてください
   （例: Hono / Cloudflare Workers）
   ※ない場合は「なし」と答えてください
6. DBは何を使いますか？
   （例: Supabase (PostgreSQL)）
   ※ない場合は「なし」と答えてください
7. 認証は何を使いますか？
   （例: Supabase Auth）
   ※ない場合は「なし」と答えてください
8. ディレクトリ構成を教えてください
   （例: src/app, src/components, src/api, src/lib）
   ※わからない場合は「スキップ」と答えてください
```

### Step 4: CLAUDE.md の生成

ヒアリング内容をもとに以下のテンプレートに埋め込んでCLAUDE.mdを生成する。

```markdown
# {プロジェクト名}

## プロジェクト概要
- {何を作るか}
- ターゲット: {ターゲットユーザー}

## 技術スタック
{フロントエンドがある場合}
- Frontend: {フロントエンドスタック}
{バックエンドがある場合}
- Backend: {バックエンドスタック}
{DBがある場合}
- DB: {DBスタック}
{認証がある場合}
- 認証: {認証スタック}

## ディレクトリ構成
{ディレクトリ構成をツリー形式で記載}
{スキップした場合はこのセクションを省略}

## 開発ルール
- コードのコメントは日本語
- ターミナルのログ出力は日本語
- 変数名・関数名は英語
- コミットメッセージは英語（例: feat: add login feature）

## 開発フロー
- 実装前にGitHub Issueを作成する
- ブランチ名: feature/issue-{番号}-{説明}
- 実装完了後にPRを作成してユーザーに報告・停止
- マージはユーザーが行う（自分でマージしない）

## @eijient 利用ルール
- 機能実装は @eijient を使う
- Agent Team利用時はTeam LeadのみGitHub操作を行う
- WorkerはコードとテストのみでGitHub操作はしない
- PRを作成したら必ず停止してユーザーに報告する

## やってはいけないこと
- git push --force
- mainへの直接push
- PRのマージ
- .envファイルのコミット
```

### Step 5: 完了報告

セットアップが完了したら以下を報告して停止する：

```
✅ eijient-setup 完了

【settings.json】
- defaultMode: auto ✓
- CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS: 1 ✓
- permissions: 設定済み ✓

【依存ツール】
- gh CLI: {確認結果}
- tmux: {確認結果}

【CLAUDE.md】
- {生成済み or スキップ} ✓

@eijient を使って開発を始められます！
```

---

## 使用例

```bash
# 新しいマシンのセットアップ
@eijient-setup

# CLAUDE.mdのみ再生成したい場合
@eijient-setup --claude-md-only

# settings.jsonのみ設定したい場合
@eijient-setup --settings-only
```

---

## 引数

| 引数 | 説明 |
|-----|-----|
| `--claude-md-only` | CLAUDE.mdの生成のみ行う（settings.jsonはスキップ） |
| `--settings-only` | settings.jsonの設定のみ行う（CLAUDE.mdはスキップ） |

---

## 注意事項

- settings.json の既存設定は上書きしない（マージのみ）
- CLAUDE.md の生成前に必ず上書き確認を行う
- gh CLI の認証・tmux のインストールは手動で行うよう案内する（自動インストールはしない）
