# eijient

Claude Code用のオリジナルSkill集。
エージェントを長時間無人で回す「ループ設計」（計画→実行→検証→記録→次の周回）を軸に、
夜の間にエージェントを走らせて朝に成果をレビューする運用を目指す。

## Skills

### @eijient

機能実装・バグ修正・リファクタなど、開発タスクをAgent Teamの自律ループで完遂するSkill。

- ループ構造: 計画 → 実装 → 検証 → 記録。検証済みの成果だけをPRにする
- Plannerは常に1体（opus）、Worker数はタスク規模に応じて自動判定（1〜5体）
- 実装Workerとは別の**verifier**（まっさらなコンテキスト）が動作を検証してからPR作成
- 進捗・完了の報告は証拠ベース（ツール結果を指せる作業だけを報告、未検証は明示）
- Workerの停止・暴走は自律リカバリ（再起動・再割当）し、最終報告で開示
- 得られた教訓は対象プロジェクトの `tasks/lessons/` に記録して次の周回へ引き継ぐ
- GitHub Issue作成・ブランチ作成・PR作成まで自動。PRマージはユーザーが行う

### @eijient-e2e

Playwright MCPを使ってブラウザを直接操作し、E2Eテストを実行するSkill。

- テストコード不要でブラウザを操作して動作確認
- `--save` オプションで操作内容をPlaywrightテストコード（.spec.ts）として保存
- コンソールエラー・ネットワークリクエストも同時に検証
- 要Playwright MCP（`claude mcp add playwright npx @playwright/mcp@latest`）

### @eijient-refacta

コードベースを分析してリファクタリング指示書（`refactor-instructions.md`）を作るSkill。

- Phase 1（分析）では**実装せず**、ルートに `refactor-instructions.md` を出力して停止
- 技術的負債を「根拠・影響・リスク・改善案・検証方法・実装可否」付きで整理
- ユーザーが承認してから Phase 2（実行）に進む
- 大きな設計変更は勝手に実装せず「提案のみ」に分類

### @eijient-setup

新しいプロジェクトや新しいマシンの初期セットアップSkill。

- `~/.claude/settings.json` の設定を自動追加
- 対話形式でプロジェクトの `CLAUDE.md` を生成
- `@eijient` を使うかどうかを選択でき、使う場合のみ関連ルールをCLAUDE.mdに追記

## インストール

Skillは `~/.claude/skills/` の **直下に各Skillフォルダがある** 必要があります
（`~/.claude/skills/eijient/SKILL.md` のような階層）。
リポジトリをそのまま clone すると階層が1つ深くなり認識されないため、付属の `install.sh` でコピーします。

```bash
# 任意の場所にリポジトリを取得
git clone https://github.com/Eiji1202/eijient.git
cd eijient

# 4つのSkillを ~/.claude/skills/ 直下にインストール（既存は上書き更新）
./install.sh
```

これで `@eijient` / `@eijient-e2e` / `@eijient-refacta` / `@eijient-setup` が使えるようになります。
Claude Code を再起動すると反映されます。

### 更新・確認

```bash
# リポジトリを更新してから再インストール（上書き）
git pull && ./install.sh

# 何がコピーされるか確認だけする
./install.sh --dry-run

# コピー先を変えたい場合
SKILLS_DIR=/path/to/skills ./install.sh
```

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

### リファクタリング（分析 → 承認 → 実行）

```bash
# 分析して指示書を作成（実装はせず承認待ち）
@eijient-refacta このプロジェクトのリファクタ計画を立てて

# 分析だけして終わる
@eijient-refacta --analyze-only リファクタ指示書だけ作って

# 承認後、既存の指示書から実行
@eijient-refacta --execute
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
