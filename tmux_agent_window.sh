#!/bin/sh
# tmux.conf 의 prefix+f 바인딩에서 호출 — main 세션에 window 를 하나 만들고 그 창으로
# 이동한다. agent(cl/co 등)는 열린 창에서 직접 실행한다.
#
# tmux 서버가 실행 주체라 호출한 pane 은 건드리지 않는다. 이전의 ag 함수는 호출한
# pane 의 셸에서 돌면서 그 pane 을 kill 했기 때문에, 자기 자신을 SIGHUP 으로 끝내거나
# 세션 마지막 pane 일 때 세션까지 연쇄 소멸시키는 문제가 있었다.
#
# 인자: 새 창의 작업 디렉터리 (보통 호출한 pane 의 경로).
set -e
dir=${1:-$HOME}
[ -d "$dir" ] || dir=$HOME

if tmux has-session -t '=main' 2>/dev/null; then
    tmux new-window -t '=main:' -c "$dir"
else
    tmux new-session -d -s main -c "$dir"
fi

# new-window 가 main 의 현재 창을 방금 만든 창으로 바꿔 두므로, 세션만 잡으면 된다.
# (이미 main 에 있었다면 new-window 가 알아서 이동시켜 이 줄은 no-op 이다.)
tmux switch-client -t '=main:'
