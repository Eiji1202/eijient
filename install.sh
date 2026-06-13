#!/usr/bin/env bash
#
# eijient skills インストーラ
#
# リポジトリ配下の各Skillフォルダ（SKILL.md を含むディレクトリ）を
# ~/.claude/skills/ の直下に一括コピーする。
# すでに存在する場合は上書き更新する。
#
# 使い方:
#   ./install.sh              # ~/.claude/skills/ にインストール
#   ./install.sh --dry-run    # 何がコピーされるか確認だけする
#   SKILLS_DIR=/path ./install.sh   # コピー先を変更する

set -euo pipefail

# このスクリプトが置かれているディレクトリ（= リポジトリルート）
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# コピー先（環境変数で上書き可能）
SKILLS_DIR="${SKILLS_DIR:-$HOME/.claude/skills}"

DRY_RUN=false
if [[ "${1:-}" == "--dry-run" || "${1:-}" == "-n" ]]; then
  DRY_RUN=true
fi

echo "📦 eijient skills インストーラ"
echo "   コピー元: $REPO_DIR"
echo "   コピー先: $SKILLS_DIR"
$DRY_RUN && echo "   モード: dry-run（コピーは行いません）"
echo ""

mkdir -p "$SKILLS_DIR"

installed=0
for skill_md in "$REPO_DIR"/*/SKILL.md; do
  # SKILL.md が1つも無い場合のグロブ展開対策
  [[ -e "$skill_md" ]] || continue

  skill_path="$(dirname "$skill_md")"
  skill_name="$(basename "$skill_path")"
  dest="$SKILLS_DIR/$skill_name"

  if [[ -d "$dest" ]]; then
    status="🔄 更新"
  else
    status="✨ 新規"
  fi

  if $DRY_RUN; then
    echo "$status  $skill_name"
  else
    # 既存を消してから丸ごとコピー（削除されたファイルも反映するため）
    rm -rf "$dest"
    cp -R "$skill_path" "$dest"
    echo "$status  $skill_name  →  $dest"
  fi
  installed=$((installed + 1))
done

echo ""
if [[ "$installed" -eq 0 ]]; then
  echo "⚠️  SKILL.md を含むフォルダが見つかりませんでした。"
  exit 1
fi

if $DRY_RUN; then
  echo "✅ $installed 件のSkillがインストール対象です（dry-run）。"
else
  echo "✅ $installed 件のSkillをインストールしました。"
  echo "   Claude Code を再起動すると反映されます。"
fi
