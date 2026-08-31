#!/bin/bash
# 归档 tasks/ 下过期的月目录到 archive/YYYY/MM/
# 保留当月和上月，更早的整月搬走。幂等，随时可跑。

set -euo pipefail

# Windows 上归档交给 archive.ps1（settings.json / hooks.json 里的 powershell 分支）。
# Git Bash / MSYS 下本脚本能跑，但会和 ps1 同时搬同一批目录，所以直接退。
case "$(uname -s)" in
    MINGW*|MSYS*|CYGWIN*) exit 0 ;;
esac

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TASKS="$ROOT/tasks"
ARCHIVE="$ROOT/archive"
LOG="$ROOT/.agents/archive.log"

# 每次运行都留痕，用来确认 hook 真的被触发了
log() { printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" >>"$LOG"; }

[ -d "$TASKS" ] || { log "跳过：tasks/ 不存在"; exit 0; }

# 保留下界：上月的 YYYYMM。小于它的月目录搬走。
KEEP_FROM="$(date -v-1m +%Y%m 2>/dev/null || date -d '1 month ago' +%Y%m)"

moved=0
for dir in "$TASKS"/*/; do
    [ -d "$dir" ] || continue
    name="$(basename "$dir")"

    # 只认 YYYY-MM，其他目录不碰
    [[ "$name" =~ ^([0-9]{4})-([0-9]{2})$ ]] || continue
    year="${BASH_REMATCH[1]}"
    month="${BASH_REMATCH[2]}"

    [ "$year$month" -lt "$KEEP_FROM" ] || continue

    # 空目录直接删，不值得归档
    if [ -z "$(ls -A "$dir")" ]; then
        rmdir "$dir"
        continue
    fi

    target="$ARCHIVE/$year/$month"
    if [ -e "$target" ]; then
        log "冲突：archive/${year}/${month} 已存在，跳过 ${name}（需手动处理）"
        echo "archive.sh: $target 已存在，跳过 ${name}（需手动处理）" >&2
        continue
    fi

    mkdir -p "$(dirname "$target")"
    mv "$dir" "$target"
    log "归档：${name} -> archive/${year}/${month}"
    echo "archive.sh: ${name} -> archive/${year}/${month}"
    moved=$((moved + 1))
done

[ "$moved" -eq 0 ] && log "运行：无过期月目录（保留下界 ${KEEP_FROM}）"

exit 0
