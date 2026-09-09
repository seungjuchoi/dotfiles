#!/usr/bin/env bash
# tmux-file-picker(raine) 래퍼 — prefix+e 팝업에서 호출한다.
#
# tmux-file-picker 본체는 이 저장소에 없다. 최초 1회만 설치:
#   curl -fsSLo ~/.local/bin/tmux-file-picker \
#     https://raw.githubusercontent.com/raine/tmux-file-picker/main/tmux-file-picker
#   chmod +x ~/.local/bin/tmux-file-picker
# 의존성: fzf, fd (선택: bat, zoxide, tree, coreutils(grealpath))
#
# -g 는 git 루트 기준 상대경로를 주지만 저장소 밖에서는 에러로 즉시 종료해
# 팝업이 열리자마자 닫힌 것처럼 보인다. 그래서 여기서 분기한다.
set -euo pipefail

PICKER="$HOME/.local/bin/tmux-file-picker"
if [[ ! -x $PICKER ]]; then
	echo "tmux-file-picker 가 없습니다: $PICKER" >&2
	echo "설치: 이 스크립트 상단 주석 참고" >&2
	read -rsn1 -p "아무 키나 누르면 닫힙니다..."
	exit 1
fi

if git rev-parse --show-toplevel >/dev/null 2>&1; then
	exec "$PICKER" -g "$@"
else
	exec "$PICKER" "$@"
fi
