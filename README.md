# eijient

Claude Code用のオリジナルSkill集。

## Skills

### @eijient

プロジェクトの規模を自動判定し、最適なAgent Teamを編成して開発を進めるSkill。

- Plannerは常に1体（opus）
- Worker数はタスク規模に応じて自動判定（1〜5体）
- GitHub Issue作成・ブランチ作成・PR作成まで自動
- PRマージはユーザーが行う

### @eijient-setup

新しいプロジェクトや新しいマシンの初期セットアップSkill。

- `~/.claude/settings.json` の設定を自動追加
- 対話形式でプロジェクトの `CLAUDE.md` を生成

## インストール

```bash
git clone https://github.com/Eiji1202/eijient.git ~/.claude/skills/
```

これだけで `@eijient` と `@eijient-setup` が使えるようになります。

## 使い方

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
