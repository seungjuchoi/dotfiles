#!/usr/bin/env bash
# tmux-assistant-resurrect 의 post-restore 훅 래퍼 — 중복 실행 방지.
#
# 배경: tmux 서버 시작 레이스 등으로 continuum 의 자동 restore 가 두 번 뜨면
# restore-assistant-sessions.sh 두 인스턴스가 "같은 초에" 병렬로 돈다. 그러면
# "이 pane 에 이미 assistant 가 떠 있나" 가드를 둘 다 통과해버려서, 뒤늦은 쪽이
# 이미 기동한 claude/codex TUI 입력창에 resume 명령을 그대로 타이핑한다.
# (증상: 복구는 정상인데 프롬프트에 `cd ...; command claude --resume ...` 가 남음)
#
# mkdir 은 원자적이라 별도 flock 없이 상호배제가 된다. macOS 에는 util-linux 의
# flock 이 없으므로 이 방식을 쓴다.
set -u

PLUGIN_SCRIPT="$HOME/.tmux/plugins/tmux-assistant-resurrect/scripts/restore-assistant-sessions.sh"
LOCK_DIR="${TMPDIR:-/tmp}/tmux-assistant-restore.lock"
# 락 유지 시간. 첫 인스턴스가 끝난 직후에 두 번째가 떠도 TUI 가 아직 기동 중이면
# 가드를 빠져나가므로, 복원 완료 후에도 이만큼 더 잠가둔다.
LOCK_HOLD=60
# 이전 실행이 비정상 종료해 남은 락으로 판단하는 기준.
STALE_AFTER=300

[ -f "$PLUGIN_SCRIPT" ] || exit 0

resurrect_dir="$(tmux show-option -gqv @resurrect-dir 2>/dev/null || true)"
[ -n "$resurrect_dir" ] || resurrect_dir="$HOME/.tmux/resurrect"
LOG_FILE="${resurrect_dir/#\~/$HOME}/assistant-restore.log"

log() {
	[ -d "$(dirname "$LOG_FILE")" ] || return 0
	echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] once-wrapper: $* (pid $$)" >>"$LOG_FILE"
}

mtime_of() {
	# BSD(macOS) 와 GNU(coreutils) 양쪽 지원
	stat -f %m "$1" 2>/dev/null || stat -c %Y "$1" 2>/dev/null || echo 0
}

# 죽은 인스턴스가 남긴 오래된 락 정리
if [ -d "$LOCK_DIR" ]; then
	lock_age=$(($(date +%s) - $(mtime_of "$LOCK_DIR")))
	if [ "$lock_age" -ge "$STALE_AFTER" ]; then
		log "stale lock (${lock_age}s) 제거"
		rmdir "$LOCK_DIR" 2>/dev/null || true
	fi
fi

if ! mkdir "$LOCK_DIR" 2>/dev/null; then
	log "중복 복원 건너뜀 — 다른 인스턴스가 이미 복원했다"
	exit 0
fi

log "복원 시작"
bash "$PLUGIN_SCRIPT"
status=$?
log "복원 종료 (exit $status)"

# 락은 바로 풀지 않고 LOCK_HOLD 초 뒤에 해제한다.
nohup bash -c "sleep $LOCK_HOLD; rmdir '$LOCK_DIR' 2>/dev/null" >/dev/null 2>&1 &

exit $status
