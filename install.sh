#!/usr/bin/env bash
# 把本仓库 skills/ 下的 acr-* 装到全局 ~/.claude/skills/
#
#   bash install.sh          安装/更新（仓库 → 全局）
#   bash install.sh --check  只比对，不写（发现漂移用）
#
# 仓库是唯一真相源：改 skill 改这里，然后跑一次安装。
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$REPO_DIR/skills"
DST="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"

[ -d "$SRC" ] || { echo "找不到源目录：$SRC" >&2; exit 1; }
[ -d "$DST" ] || { echo "找不到全局 skills 目录：$DST" >&2; exit 1; }

mapfile -t SKILLS < <(cd "$SRC" && ls -d acr-* 2>/dev/null || true)
[ ${#SKILLS[@]} -gt 0 ] || { echo "源目录里没有 acr-* 模块" >&2; exit 1; }

MODE="install"
[ "${1:-}" = "--check" ] && MODE="check"

drift=0
for s in "${SKILLS[@]}"; do
  if [ "$MODE" = "check" ]; then
    if diff -r "$SRC/$s" "$DST/$s" >/dev/null 2>&1; then
      echo "一致    $s"
    else
      echo "有差异  $s   ← 全局与仓库不一致"
      drift=1
    fi
  else
    rm -rf "$DST/$s"
    cp -r "$SRC/$s" "$DST/$s"
    echo "已安装  $s"
  fi
done

if [ "$MODE" = "check" ]; then
  [ $drift -eq 0 ] && echo "全部一致（全局 = 仓库）" || { echo "存在漂移：跑 bash install.sh 覆盖全局" >&2; exit 1; }
else
  echo "完成：${#SKILLS[@]} 个模块 → $DST"
fi
