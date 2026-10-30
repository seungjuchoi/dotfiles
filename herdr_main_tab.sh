#!/bin/sh
# prefix+f / prefix+o 에서 호출 — tz 워크스페이스에 tz 폴더로 탭을 하나 만들고 그 탭으로 이동한다.
# tmux_agent_window.sh(main 세션에 window)를 herdr 로 옮긴 것.
#
# --ai 를 주면(prefix+o) 탭을 연 뒤 MAIN_AI_CMD(기본 cl)를 입력해 바로 agent 로 들어간다.
# MAIN_AI_CMD 는 config_local.fish 에서 바꾼다. herdr 서버 환경엔 없을 수 있어 fish 에 물어본다.
#
# 작업 디렉터리: zoxide 의 tz 를 우선 — 일반 질문·작업은 한 폴더에서 해야 Claude 프로젝트
# 메모리가 거기에 쌓인다. 못 찾으면 호출한 pane 의 경로로 폴백. (프로젝트 폴더에서 열려면 prefix+c.)
set -e
PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
H="${HERDR_BIN_PATH:-herdr}"
ai=
if [ "$1" = --ai ]; then
    ai=${MAIN_AI_CMD:-$(fish -c 'echo $MAIN_AI_CMD' 2>/dev/null || true)}
    ai=${ai:-cl}
fi
dir=$(zoxide query tz 2>/dev/null) || dir=
[ -d "$dir" ] || dir=${HERDR_ACTIVE_PANE_CWD:-$HOME}
[ -d "$dir" ] || dir=$HOME

# 라벨이 tz 인 워크스페이스를 메인으로 쓴다. 없으면 만든다.
ws=$("$H" workspace list | jq -r '[.result.workspaces[] | select(.label == "tz")][0].workspace_id // empty')
if [ -n "$ws" ]; then
    pane=$("$H" tab create --workspace "$ws" --cwd "$dir" --focus | jq -r '.result.root_pane.pane_id')
    "$H" workspace focus "$ws" >/dev/null
else
    pane=$("$H" workspace create --cwd "$dir" --label tz --focus | jq -r '.result.root_pane.pane_id // .result.pane.pane_id')
fi

# 셸 프롬프트가 뜨기 전에 보내도 tty 입력 버퍼에 쌓였다가 그대로 실행된다.
[ -n "$ai" ] && "$H" pane run "$pane" "$ai" >/dev/null
exit 0
