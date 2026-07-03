# eijient ループ設計への再構築 TODO（2026-07-04）

計画: `~/.claude/plans/parsed-cooking-narwhal.md`（承認済み）

- [x] eijient/SKILL.md を「意図＋境界」構造に全面リライト（ループプリミティブ追加）
- [x] eijient/references/prompts.md 更新（共通ブロック＋verifierテンプレート新設）
- [x] eijient/references/templates.md 更新（medium以上にverifier組み込み）
- [x] README.md 更新（ループ第一設計の説明を追記）
- [x] ~~gh repo rename eijient-loop~~ → **中止。リポジトリ名は eijient のまま**（ユーザー決定 2026-07-04）
- [x] ./install.sh --dry-run → ./install.sh で ~/.claude/skills へ配布（4スキル更新確認）
- [x] 変更前後のdiffレビュー（境界キーワード9種の残存をgrepで全数確認）
- [x] コミット & push（feat: スコープ括弧なし）
- [x] レビューセクション追記

## レビュー（2026-07-04）

### 実施内容
- `eijient/SKILL.md`: 259行 → 133行。Steps 1–8 の手順列挙を「意図＋ループ構造＋境界」に置換。
  ループプリミティブ（証拠ベース報告・verifier分離・メモリ・意図の受け渡し・anti-early-stop）を追加。
  15分タイムアウトのユーザーエスカレーション脚本を自律リカバリ（証拠確認→再起動/再割当→記録→開示）に置換
- `references/prompts.md`: 全spawnプロンプト冒頭用の共通ブロック（意図・共通ルール）を新設。
  verifierテンプレート追加（reviewerとは別物・実行ベース検証・実装禁止）
- `references/templates.md`: medium以上の全構成にverifier組み込み。smallはチーム外の単発検証サブエージェントで代替
- `README.md`: ループ第一設計の説明を追記（リポジトリ名は eijient のまま維持）
- 「推論を出力に説明させる」系指示はgrepで全ファイル走査し不検出（対応不要と確認）
- `~/.claude/skills/` へ再インストール済み（diff -q でソースと一致確認）

### 残タスク
1. `@eijient --dry-run` での実挙動確認（スキル再読込のため次セッション）
