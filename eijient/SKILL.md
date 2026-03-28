---
name: eijient
description: >
  プロジェクトの規模を自動判定し、最適なAgent Teamを編成して開発を進めるSkill。
  Plannerは常に1体配置し、プロジェクト規模に応じてWorkerの数を動的に決定する。
  GitHub IssueとPRの作成も自動で行う。
---

# Agent Team Builder Skill

## 概要

このSkillは以下を自動で行います：

1. プロジェクト規模を判定してチーム構成を決定
2. GitHub Issueを作成
3. 最適なAgent Teamをspawn
4. 実装完了後にPRを作成してユーザーに報告・停止

---

## ワークフロー

### Step 1: プロジェクト規模の判定

ユーザーのリクエストを分析し、以下の基準でスケールを判定する：

| スケール | 判定基準 | Planner | Workers |
|--------|--------|---------|---------|
| **small** | 単一機能・単一ファイル変更・バグ修正 | 1 (opus) | 1 (sonnet) |
| **medium** | 複数ファイル・複数レイヤー・新機能実装 | 1 (opus) | 2〜3 (sonnet) |
| **large** | 複数機能・フルスタック・大規模リファクタ | 1 (opus) | 3〜5 (sonnet) |

判定に迷う場合は **medium** をデフォルトとする。

### Step 2: チーム構成の決定

規模に応じてWorkerの専門領域を分割する。
参考: `references/templates.md`

各Workerには以下を必ず定義する：
- 役割名（例: `frontend-dev`, `backend-dev`, `tester`）
- 担当ファイル所有権（例: `src/app/**`）
- 使用モデル（原則 sonnet）

### Step 3: GitHub Issue作成

```bash
gh issue create \
  --title "feat: {機能名}" \
  --body "## 概要
{リクエスト内容}

## チーム構成
- Planner (opus): 設計・ディレクション
{各Workerの役割と担当範囲}

## 完了条件
{実装内容から導いたAcceptance Criteria}"
```

Issue番号を取得してブランチ名に使用する。

### Step 4: ブランチ作成

```bash
git checkout -b feature/issue-{番号}-{短い説明}
```

### Step 5: Agent Teamのspawn

以下のプロンプト形式でAgent Teamを起動する：

```
チームを使って以下を実装してください。

## タスク
{ユーザーのリクエスト}

## チーム構成
- planner (opus): 設計・タスク分解・統合担当。実装前に設計を立て全Workerに共有する
{各Workerの定義（参考: references/prompts.md）}

## ルール
- plannerが設計を完了してから各Workerは実装を開始すること
- 各Workerは自分の担当ファイル以外は触らないこと
- Worker間で必要な情報はメッセージで直接やりとりすること
- 完了したら必ずTeam Leadに報告すること
- GitHub操作（Issue/PR）はTeam Leadのみが行う

## ファイル所有権
{各Workerの担当ファイルパス}
```

Spawn Promptのテンプレートは `references/prompts.md` を参照。

### Step 6: 実装完了後のPR作成

全Workerの完了報告を受けたら：

```bash
git add .
git commit -m "feat: #{Issue番号} {機能名}"
git push origin feature/issue-{番号}-{短い説明}

gh pr create \
  --title "feat: #{Issue番号} {機能名}" \
  --body "## 概要
{実装内容の説明}

## 変更内容
{変更ファイルのサマリー}

## チーム
{参加したエージェントと担当範囲}

Closes #{Issue番号}"
```

### Step 7: ユーザーへの報告・停止

PR作成後、必ずユーザーに以下を報告して停止する：

```
✅ 実装完了・PR作成しました

- Issue: #{番号} {タイトル}
- PR: #{番号} {タイトル}
- ブランチ: feature/issue-{番号}-{説明}
- 参加エージェント: {チーム構成}

PRをご確認の上、マージをお願いします。
```

**マージは絶対に行わない。**

---

## 引数

| 引数 | 短縮 | デフォルト | 説明 |
|-----|-----|---------|-----|
| `--scale` | `-s` | auto | チームスケール: small / medium / large / auto |
| `--model` | `-m` | adaptive | モデル戦略: deep / adaptive / fast / budget |
| `--plan-approval` | `-p` | false | Workerの実装前にPlannerの設計承認を要求 |
| `--dry-run` | `-d` | false | チーム構成の確認のみ（spawnしない） |
| `--no-issue` | | false | GitHub Issue作成をスキップ |

### モデル戦略

| 戦略 | Planner | Worker | 用途 |
|-----|---------|--------|-----|
| `deep` | opus | opus | 最高品質が必要な複雑タスク |
| `adaptive` | opus | sonnet | 品質とコストのバランス（推奨） |
| `fast` | sonnet | sonnet | 速度重視・明確なタスク |
| `budget` | sonnet | haiku | シンプルなタスク・コスト重視 |

---

## 使用例

```
# 基本的な使い方（スケール自動判定）
@eijient ログイン機能を実装してください

# スケール指定
@eijient --scale large 認証システム全体をリファクタリングしてください

# 設計承認あり・dry-run確認
@eijient --plan-approval --dry-run Stripe決済を実装してください

# コスト重視
@eijient --model budget READMEを更新してください
```

---

## ベストプラクティス（必ず守ること）

以下は公式ドキュメントと実践から得られた知見。適用漏れを防ぐためにワークフローに組み込んでいる。

### チームサイズの設計

- **3〜5体がベスト。** それ以上はコスト増に見合わない
- Worker 1人あたり **最大5〜6タスク**。それ以上はタスクを細分化する
- 「多ければいいわけではない」。3体の集中したWorkerが5体の散漫なWorkerより優れる

### タスク設計

- **小さすぎ**: 調整コストが利益を超える（単純な1行修正をチームでやらない）
- **大きすぎ**: Worker が長時間チェックなしで動き続けてミスが蓄積する
- **ちょうどいい**: 関数・コンポーネント・テストファイルなど明確な成果物を持つ単位

### ファイル競合の防止

- 2体のWorkerが同じファイルを編集すると**無言で上書きされる**（Gitコンフリクトにならない）
- templates.mdのファイル所有権設計を必ず守る
- 共有型定義など複数Workerが参照するファイルは **Plannerが先に作成**してからWorkerに渡す

### Plannerの役割を守る

- Plannerは **設計・調整・統合のみ**。実装コードを書かない
- Plannerが実装を始めたらユーザーに「Plannerが実装を始めています。待つよう指示してください」と報告する

### Workerの完了を待つ

- Team Leadは全Workerの完了報告を確認してから次のStepに進む
- Workerを待たずに自分で実装を始めてしまう場合は明示的に制止する

### 監視とリダイレクト

- うまくいっていないアプローチを取るWorkerには早めにフィードバックを送る
- チームを長時間放置すると無駄な作業が蓄積するリスクが上がる

---

## 注意事項

- Agent Teamsは実験的機能。`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` が必要
- Workerが同じファイルを編集しないようファイル所有権を必ず設定する
- 1 Workerあたり最大5〜6タスクを上限とする
- トークンコストはWorker数 × セッション分かかる
- `gh` CLIがインストール・認証済みであること

---

## 参考

- `references/templates.md` - チームテンプレート集
- `references/prompts.md` - Spawn Promptテンプレート
