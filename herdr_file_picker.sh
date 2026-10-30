#!/usr/bin/env bash
# prefix+e 팝업에서 호출 — fzf 로 파일을 골라 경로를 아래 pane 커서에 붙여넣는다.
# tmux 의 tmux-file-picker(raine)는 tmux 전용이라 herdr 용으로 핵심만 옮겼다.
# Tab 다중선택. git 저장소 안이면 루트 기준 상대경로, 아니면 현재 폴더 기준.
# 아래 pane 이 agent 면 @경로, 셸이면 셸 이스케이프한 경로를 넣는다.
set -euo pipefail
PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
H="${HERDR_BIN_PATH:-herdr}"
pane=${HERDR_ACTIVE_PANE_ID:?}
cd "${HERDR_ACTIVE_PANE_CWD:-$PWD}"
base=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$base"

selected=$(fd --type f --hidden --exclude .git | fzf -m --reverse \
    --preview 'bat --color=always --style=numbers --line-range=:200 {}') || exit 0
[ -n "$selected" ] || exit 0

agent=$("$H" pane get "$pane" | jq -r '.result.pane.agent // empty')
out=
while IFS= read -r f; do
    if [ -n "$agent" ]; then out+="@$f "; else printf -v q '%q' "$f"; out+="$q "; fi
done <<< "$selected"
"$H" pane send-text "$pane" "$out" >/dev/null
