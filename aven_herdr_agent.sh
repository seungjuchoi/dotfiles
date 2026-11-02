#!/usr/bin/env bash
# aven TUI 커스텀 명령 (z / ㅋ). 선택한 task로 herdr agent 탭을 연다.
# herdr prefix+o(main-tab.sh --ai)처럼 tz 워크스페이스에 tz 폴더로 새 탭을 만들고
# MAIN_AI_CMD(기본 kr)를 띄운 뒤, task 제목·설명을 프롬프트에 써 둔다. Enter는 치지 않는다.
# 마지막에 빈 줄을 하나 두고 그 아래에 커서가 오게 해서 이어서 적을 수 있게 한다.
set -euo pipefail
PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

if [ "${HERDR_ENV:-}" != 1 ]; then
    echo "herdr 안에서 연 aven에서만 동작합니다" >&2
    exit 1
fi
H="${HERDR_BIN_PATH:-herdr}"

input=$(mktemp)
trap 'rm -f "$input"' EXIT
cat > "$input"

ref=$(jq -r '.selection.primary.ref // empty' "$input")
[ -n "$ref" ] || { echo "선택한 task가 없습니다" >&2; exit 1; }

# 제목·설명에서 제어 문자를 지운다. CR은 Enter로 처리돼 프롬프트가 제출될 수 있다.
clean() { tr '\t' ' ' | tr -d '\000-\011\013-\037\177'; }
title=$(jq -r '.selection.primary.task.title // ""' "$input" | clean)
desc=$(jq -r '.selection.primary.task.description // ""' "$input" | clean)

text="[$ref] $title"
[ -n "$desc" ] && text+=$'\n\n'"$desc"
text+=$'\n\n'

ai=${MAIN_AI_CMD:-$(fish -c 'echo $MAIN_AI_CMD' 2>/dev/null || true)}
ai=${ai:-kr}
dir=$(zoxide query tz 2>/dev/null) || dir=
[ -d "$dir" ] || dir=${HERDR_ACTIVE_PANE_CWD:-$HOME}
[ -d "$dir" ] || dir=$HOME

# main-tab.sh와 같은 규칙: 라벨이 tz인 워크스페이스에 탭을 만들고, 없으면 워크스페이스를 만든다.
ws=$("$H" workspace list | jq -r '[.result.workspaces[] | select(.label == "tz")][0].workspace_id // empty')
if [ -n "$ws" ]; then
    pane=$("$H" tab create --workspace "$ws" --cwd "$dir" --focus | jq -r '.result.root_pane.pane_id')
    "$H" workspace focus "$ws" >/dev/null
else
    pane=$("$H" workspace create --cwd "$dir" --label tz --focus | jq -r '.result.root_pane.pane_id // .result.pane.pane_id')
fi
"$H" pane run "$pane" "$ai" >/dev/null

# agent가 감지되고 입력을 받을 수 있을 때까지 기다린다 (최대 45초).
ready=
for _ in $(seq 90); do
    state=$("$H" agent get "$pane" 2>/dev/null | jq -r '.result.agent.agent_status // empty') || state=
    case "$state" in idle|done) ready=1; break ;; esac
    sleep 0.5
done
[ -n "$ready" ] || { echo "agent가 45초 안에 준비되지 않았습니다 ($pane)" >&2; exit 1; }
sleep 0.5

"$H" pane send-text "$pane" "$text" >/dev/null
"$H" agent focus "$pane" >/dev/null 2>&1 || true
