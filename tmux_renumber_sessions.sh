#!/bin/sh
# 세션마다 1-based 순번을 @pos 세션 옵션에 기록한다.
# 순서는 세션 ID(생성) 순 — 상태바 #{S:} 루프 및 choose-tree -O index 와 일치.
i=1
tmux list-sessions -F '#{session_id}' | tr -d '$' | sort -n | while IFS= read -r sid; do
    tmux set-option -t "\$$sid" @pos "$i"
    i=$((i + 1))
done
