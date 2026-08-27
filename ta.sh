#!/bin/sh
# fish 밖(bash/zsh 등)에서 ta 를 치면 fish 로 들어가서 fish 의 ta 함수를 실행한다.
# fish 안에서는 ta 함수가 PATH 명령보다 우선이므로 이 스크립트는 호출되지 않는다.
cmd=ta
for a in "$@"; do
    # fish 의 작은따옴표 안에서는 \ 와 ' 두 글자만 이스케이프하면 된다.
    esc=$(printf '%s' "$a" | sed -e 's/\\/\\\\/g' -e "s/'/\\\\'/g")
    cmd="$cmd '$esc'"
done
exec fish -C "$cmd"
