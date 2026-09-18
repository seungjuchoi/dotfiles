#!/bin/sh
# tmux.conf 의 prefix+f 바인딩에서 호출 — main 세션에 window 를 하나 만들고 그 창으로
# 이동한다. agent(cl/co 등)는 열린 창에서 직접 실행한다.
#
# tmux 서버가 실행 주체라 호출한 pane 은 건드리지 않는다. 이전의 ag 함수는 호출한
# pane 의 셸에서 돌면서 그 pane 을 kill 했기 때문에, 자기 자신을 SIGHUP 으로 끝내거나
# 세션 마지막 pane 일 때 세션까지 연쇄 소멸시키는 문제가 있었다.
#
# 작업 디렉터리: zoxide 의 tz(범용 작업 폴더)를 우선 사용한다 — 일반 질문·작업은
# 한 폴더에서 해야 Claude 프로젝트 메모리가 거기에 쌓인다. zoxide 가 없거나 tz 를
# 못 찾으면 기존처럼 인자(호출한 pane 의 경로)로 폴백한다. tmux 서버는 homebrew
# PATH 없이 뜰 수 있어 PATH 를 보강한다. (프로젝트 폴더에서 열고 싶으면 prefix+c.)
set -e
PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
dir=$(zoxide query tz 2>/dev/null) || dir=
[ -d "$dir" ] || dir=${1:-$HOME}
[ -d "$dir" ] || dir=$HOME

if tmux has-session -t '=main' 2>/dev/null; then
    tmux new-window -t '=main:' -c "$dir"
else
    tmux new-session -d -s main -c "$dir"
fi

# new-window 가 main 의 현재 창을 방금 만든 창으로 바꿔 두므로, 세션만 잡으면 된다.
# (이미 main 에 있었다면 new-window 가 알아서 이동시켜 이 줄은 no-op 이다.)
tmux switch-client -t '=main:'
