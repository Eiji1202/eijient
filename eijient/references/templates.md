# チームテンプレート集

## small: バグ修正・単一機能

```
Planner (opus) + Worker 1名
```

| 役割 | モデル | 担当 |
|-----|------|-----|
| planner | opus | 設計・レビュー・統合 |
| fullstack-dev | sonnet | 実装全般 |

**適用例:**
- バグ修正
- 単一コンポーネントの追加
- 設定ファイルの変更
- README更新

---

## medium-frontend: フロントエンド中心の新機能

```
Planner (opus) + Worker 2名
```

| 役割 | モデル | 担当ファイル |
|-----|------|-----------|
| planner | opus | 設計・調整・統合 |
| frontend-dev | sonnet | `src/app/**`, `src/components/**` |
| tester | sonnet | `tests/**`, `__tests__/**` |

**適用例:**
- 新画面の追加
- UIコンポーネントの実装
- フォーム機能の追加

---

## medium-fullstack: フルスタック新機能

```
Planner (opus) + Worker 3名
```

| 役割 | モデル | 担当ファイル |
|-----|------|-----------|
| planner | opus | 設計・調整・統合 |
| frontend-dev | sonnet | `src/app/**`, `src/components/**` |
| backend-dev | sonnet | `src/api/**`, `src/lib/**`, `src/agents/**` |
| tester | sonnet | `tests/**`, `__tests__/**` |

**適用例:**
- 認証機能の実装
- CRUD機能の追加
- API連携機能

---

## large-feature: 大規模新機能・複数機能

```
Planner (opus) + Worker 4名
```

| 役割 | モデル | 担当ファイル |
|-----|------|-----------|
| planner | opus | 設計・調整・統合 |
| frontend-dev | sonnet | `src/app/**`, `src/components/**` |
| backend-dev | sonnet | `src/api/**`, `src/lib/**` |
| db-dev | sonnet | `src/db/**`, `migrations/**`, `schema/**` |
| tester | sonnet | `tests/**`, `__tests__/**`, `e2e/**` |

**適用例:**
- 決済システムの実装
- ユーザー管理システム
- 通知システム

---

## large-refactor: 大規模リファクタ

```
Planner (opus) + Worker 4〜5名
```

| 役割 | モデル | 担当ファイル |
|-----|------|-----------|
| planner | opus | 設計・調整・品質管理 |
| frontend-dev | sonnet | フロントエンド担当ファイル |
| backend-dev | sonnet | バックエンド担当ファイル |
| db-dev | sonnet | DB・マイグレーション担当 |
| reviewer | sonnet | コードレビュー・品質チェック |
| tester | sonnet | テスト全般（必要に応じて追加） |

**適用例:**
- アーキテクチャ変更
- 技術スタック移行
- 大規模リネーム・整理

---

## review: 並列コードレビュー

```
Team Lead + Reviewer 3名（spawnのみ・実装なし）
```

| 役割 | モデル | 観点 |
|-----|------|-----|
| security-reviewer | sonnet | セキュリティ・脆弱性 |
| performance-reviewer | sonnet | パフォーマンス・最適化 |
| quality-reviewer | sonnet | コード品質・テストカバレッジ |

**適用例:**
- PRレビュー
- セキュリティ監査
- パフォーマンス調査
