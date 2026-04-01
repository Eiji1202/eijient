# eijient

Claude Code用のオリジナルSkill集。

## Skills

### @eijient

機能実装・バグ修正・リファクタなど、開発タスクをAgent Teamで自動実行するSkill。

- Plannerは常に1体（opus）
- Worker数はタスク規模に応じて自動判定（1〜5体）
- GitHub Issue作成・ブランチ作成・PR作成まで自動
- Workerが無応答の場合はタイムアウト検知してユーザーに報告
- PRマージはユーザーが行う

### @eijient-e2e

Playwright MCPを使ってブラウザを直接操作し、E2Eテストを実行するSkill。

- テストコード不要でブラウザを操作して動作確認
- `--save` オプションで操作内容をPlaywrightテストコード（.spec.ts）として保存
- コンソールエラー・ネットワークリクエストも同時に検証
- 要Playwright MCP（`claude mcp add playwright npx @playwright/mcp@latest`）

### @eijient-setup

新しいプロジェクトや新しいマシンの初期セットアップSkill。

- `~/.claude/settings.json` の設定を自動追加
- 対話形式でプロジェクトの `CLAUDE.md` を生成
- `@eijient` を使うかどうかを選択でき、使う場合のみ関連ルールをCLAUDE.mdに追記

## インストール

```bash
git clone https://github.com/Eiji1202/eijient.git ~/.claude/skills/
```

これだけで `@eijient` と `@eijient-setup` が使えるようになります。

## 使い方

### E2Eテスト実行

```bash
# ブラウザで動作確認
@eijient-e2e ログイン画面を確認して

# テストコードも保存
@eijient-e2e --url http://localhost:3000/login --save ログインフローをテストして
```

### 新しいマシンのセットアップ

```bash
cd ~/your-project
claude
# Claude Code内で
@eijient-setup
```

### 機能実装

```bash
@eijient ログイン機能を実装してください
```

### @eijient オプション

```bash
# スケール指定
@eijient --scale large 決済システムを実装してください

# 構成確認のみ
@eijient --dry-run 認証機能を実装してください

# 設計承認あり
@eijient --plan-approval 大規模リファクタをお願いします

# コスト重視
@eijient --model budget READMEを更新してください
```

### @eijient-setup オプション

```bash
# CLAUDE.mdのみ再生成したい場合（新プロジェクト時など）
@eijient-setup --claude-md-only

# settings.jsonのみ設定したい場合（新マシン時など）
@eijient-setup --settings-only
```

## 前提条件

- Claude Code v2.1.32以上
- `gh` CLI インストール・認証済み
- `~/.claude/settings.json` に `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS: "1"` が設定済み
  （`@eijient-setup` が自動で追加します）
