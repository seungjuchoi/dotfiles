#!/usr/bin/env bash
# tmuxcc 업데이트: origin(내 포크) pull + upstream(원저자) merge 후 재빌드·설치
set -uo pipefail

# popup/launchd 등 최소 환경에서도 cargo·git을 찾도록 PATH 보정
export PATH="$HOME/.cargo/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"

REPO="${TMUXCC_REPO:-$HOME/Documents/Code/tz/tmuxcc}"
UPSTREAM_BRANCH="upstream/master"
PAUSE=0
[ "${1:-}" = "--pause" ] && PAUSE=1   # tmux popup에서 결과를 읽을 수 있게 대기

pause_exit() {
  if [ "$PAUSE" = 1 ]; then
    printf '\n\033[2m아무 키나 누르면 닫힙니다\033[0m'
    read -n 1 -s -r
    echo
  fi
  exit "$1"
}

die() { printf '\n\033[31m✗ %s\033[0m\n' "$*" >&2; pause_exit 1; }
info() { printf '\033[36m› %s\033[0m\n' "$*"; }
ok() { printf '\033[32m✓ %s\033[0m\n' "$*"; }

[ -d "$REPO/.git" ] || die "저장소를 찾을 수 없음: $REPO"
cd "$REPO" || die "cd 실패: $REPO"

BRANCH=$(git rev-parse --abbrev-ref HEAD)
BEFORE=$(git rev-parse HEAD)

if [ -n "$(git status --porcelain)" ]; then
  git status --short
  die "커밋되지 않은 변경이 있어 중단. 정리 후 다시 실행하세요."
fi

info "fetch 중 (origin, upstream)"
git fetch --quiet origin || die "origin fetch 실패"
git remote get-url upstream >/dev/null 2>&1 && git fetch --quiet upstream

# 1) 내 포크의 최신 변경 반영 (fast-forward만)
if git rev-parse --quiet --verify "origin/$BRANCH" >/dev/null; then
  if ! git merge --ff-only "origin/$BRANCH" >/dev/null 2>&1; then
    AHEAD=$(git rev-list --count "origin/$BRANCH..HEAD")
    BEHIND=$(git rev-list --count "HEAD..origin/$BRANCH")
    [ "$BEHIND" -gt 0 ] && die "origin/$BRANCH 와 갈라짐 (앞선 커밋 $AHEAD, 뒤처진 커밋 $BEHIND). 수동으로 rebase 하세요."
  fi
  ok "origin/$BRANCH 동기화 완료"
fi

# 2) 원저자(upstream)의 개선 병합
if git rev-parse --quiet --verify "$UPSTREAM_BRANCH" >/dev/null; then
  NEW=$(git rev-list --count "HEAD..$UPSTREAM_BRANCH")
  if [ "$NEW" -gt 0 ]; then
    info "upstream 신규 커밋 ${NEW}개 병합 시도"
    git log --oneline "HEAD..$UPSTREAM_BRANCH" | sed 's/^/    /'
    if ! git merge --no-edit "$UPSTREAM_BRANCH"; then
      git merge --abort
      die "upstream 병합 충돌 → 롤백함. '$REPO'에서 직접 해결하세요: git merge $UPSTREAM_BRANCH"
    fi
    ok "upstream 병합 완료"
  else
    ok "upstream 신규 커밋 없음"
  fi
fi

AFTER=$(git rev-parse HEAD)
INSTALLED=$(command -v tmuxcc || true)

if [ "$BEFORE" = "$AFTER" ] && [ -n "$INSTALLED" ] && [ -z "${TMUXCC_FORCE:-}" ]; then
  ok "이미 최신 ($(git log -1 --format=%h\ %s))  — 재빌드 생략 (강제: TMUXCC_FORCE=1)"
  pause_exit 0
fi

info "빌드·설치 중 (cargo install --path .)"
cargo install --path . --quiet || die "빌드 실패"

ok "설치 완료: $(tmuxcc --version 2>/dev/null || echo tmuxcc) — $(git log -1 --format=%h\ %s)"
if [ -n "${TMUX:-}" ] && pgrep -qx tmuxcc; then
  printf '\033[33m! 실행 중인 tmuxcc는 재시작해야 새 버전이 적용됩니다.\033[0m\n'
fi
pause_exit 0
