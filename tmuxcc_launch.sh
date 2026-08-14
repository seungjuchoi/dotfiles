#!/usr/bin/env bash
# tmuxcc 실행 런처 (tmux: prefix + g / prefix + C-g)
# 설치돼 있으면 바로 띄우고, 없으면 팝업이 조용히 닫히는 대신 상황을 알리고
# 그 자리에서 설치(prefix + G와 같은 tmuxcc-update)까지 진행한다.
set -uo pipefail

# popup/launchd 등 최소 환경에서도 cargo·git을 찾도록 PATH 보정
export PATH="$HOME/.cargo/bin:$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"

BIN="${TMUXCC_BIN:-tmuxcc}"                              # 테스트용으로 덮어쓸 수 있음
UPDATE="${TMUXCC_UPDATE:-$HOME/.local/bin/tmuxcc-update}"

# -E 팝업은 명령이 끝나면 닫히므로, 읽을 게 있으면 붙잡아 둔다
hold() {
  printf '\n\033[2m아무 키나 누르면 닫힙니다\033[0m'
  read -n 1 -s -r
  echo
}

if command -v "$BIN" >/dev/null 2>&1; then
  exec "$BIN"
fi

printf '\033[33m! tmuxcc가 설치돼 있지 않습니다.\033[0m\n'
printf '  Rust로 빌드해 설치합니다 (prefix + G 와 같은 동작, 첫 설치는 몇 분 걸립니다).\n\n'
printf '지금 설치할까요? [Y/n] '
read -n 1 -r answer
echo
case "$answer" in
    "" | y | Y) ;;
    *)
        printf '\033[2m설치를 건너뜁니다. 나중에 prefix + G 로도 설치할 수 있습니다.\033[0m\n'
        hold
        exit 0
        ;;
esac

if [ ! -x "$UPDATE" ]; then
    printf '\n\033[31m✗ 설치 스크립트가 없습니다: %s\033[0m\n' "$UPDATE"
    printf '  dotfiles 디렉터리에서 ./3_set_config.fish 를 실행해 링크를 만들어 주세요.\n'
    hold
    exit 1
fi

echo
"$UPDATE"
status=$?

if [ "$status" -ne 0 ] || ! command -v "$BIN" >/dev/null 2>&1; then
    printf '\n\033[31m✗ 설치에 실패했습니다. 위 로그를 확인하세요.\033[0m\n'
    hold
    exit 1
fi

printf '\n\033[32m✓ 설치 완료 — tmuxcc 를 시작합니다\033[0m\n'
sleep 1
exec "$BIN"
