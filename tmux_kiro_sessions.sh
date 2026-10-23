#!/usr/bin/env bash
# Kiro CLI 세션 저장/복원 — tmux-resurrect 훅용 (tmux-assistant-resurrect 는 Kiro 미지원).
#
#   save     resurrect post-save 훅에서 호출. pane 별 Kiro 세션 ID 를 kiro-sessions.json 에 기록.
#   restore  post-restore 훅(assistant-restore-once.sh)에서 호출. 기록된 pane 에
#            `kiro-cli chat ... --resume-id <id>` 를 타이핑해 대화를 다시 연다.
#
# pane ↔ 세션 매핑: Kiro(v3)는 열린 세션 폴더 ~/.kiro/sessions/<해시>/sess_<uuid>/.lock 에
# TUI 프로세스 pid 를 적어 둔다. 그 pid 의 조상 중 pane_pid 가 있으면 그 pane 의 세션이다.
# 세션을 닫으면 .lock 은 지워지므로, 열려 있는 세션만 저장된다.
#
# macOS 기본 /bin/bash(3.2)에서도 돌도록 연관 배열 없이 awk 로 프로세스 트리를 푼다.
set -u

KIRO_SESSIONS_DIR="${KIRO_SESSIONS_DIR:-$HOME/.kiro/sessions}"

resurrect_dir="$(tmux show-option -gqv @resurrect-dir 2>/dev/null || true)"
[ -n "$resurrect_dir" ] || resurrect_dir="$HOME/.tmux/resurrect"
resurrect_dir="${resurrect_dir/#\~/$HOME}"
STATE_FILE="${KIRO_STATE_FILE:-$resurrect_dir/kiro-sessions.json}"
LOG_FILE="$resurrect_dir/kiro-sessions.log"

log() {
	[ -d "$resurrect_dir" ] || return 0
	echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] kiro-$MODE: $*" >>"$LOG_FILE"
}

# POSIX 작은따옴표 인용 — bash/zsh/fish 모두에서 안전.
posix_quote() {
	printf "'%s'" "$(printf '%s' "$1" | sed "s/'/'\\\\''/g")"
}

# "pid<TAB>session_id<TAB>session_dir" — 열린(.lock 있는) 세션 목록.
list_locks() {
	local lock dir pid
	for lock in "$KIRO_SESSIONS_DIR"/*/sess_*/.lock; do
		[ -f "$lock" ] || continue
		pid=$(jq -r '.pid // empty' "$lock" 2>/dev/null) || continue
		[ -n "$pid" ] || continue
		dir=$(dirname "$lock")
		printf '%s\t%s\t%s\n' "$pid" "$(basename "$dir")" "$dir"
	done
}

# kiro-cli 명령줄에서 재개용 인자만 남긴다.
# 실행 파일·`chat`·세션 선택 플래그(--resume*, 목록 등)·위치 인자(프롬프트)는 버린다.
# 위치 인자를 버리는 이유: `kiro-cli chat "<프롬프트>"` 로 띄운 세션을 복원할 때
# 옛 프롬프트가 재개된 대화에 다시 제출되면 안 된다.
resume_args() {
	local skip_next=0 keep_next=0 tok out=""
	set -f
	# shellcheck disable=SC2086
	set -- $1
	set +f
	shift # 실행 파일
	[ "${1:-}" = "chat" ] && shift
	for tok in "$@"; do
		if [ $skip_next = 1 ]; then skip_next=0; continue; fi
		if [ $keep_next = 1 ]; then keep_next=0; out="$out $(posix_quote "$tok")"; continue; fi
		case "$tok" in
		--resume-id | --delete-session | -d | --session-source | --repo | --format | -f | --output-format)
			skip_next=1 ;;
		-r | --resume | --resume-id=* | --resume-picker | --sessions | --no-interactive | \
			-l | --list-sessions | --all-cwds | --list-models | --cloud | --repo=* | -h | --help)
			;;
		--agent | --model | --effort | --trust-tools | -w | --wrap | --agent-engine | --mode)
			keep_next=1; out="$out $tok" ;;
		-*)
			out="$out $(posix_quote "$tok")" ;;
		*)
			;; # 위치 인자(프롬프트) 버림
		esac
	done
	printf '%s' "${out# }"
}

do_save() {
	local panes locks tsv
	panes=$(tmux list-panes -a -F '#{session_name}:#{window_index}.#{pane_index}	#{pane_pid}	#{pane_current_path}' 2>/dev/null) || exit 0
	locks=$(list_locks)

	if [ -z "$locks" ]; then
		tsv=""
	else
		# 입력 3종을 한 awk 에서 처리: ps 트리, 락, pane.
		# 출력: pane<TAB>session_id<TAB>session_dir<TAB>pane_path<TAB>kiro 최상위 명령줄
		tsv=$(awk -F'\t' '
			FNR == 1 { file++ }
			file == 1 {
				line = $0; sub(/^ +/, "", line)
				pid = line; sub(/ .*/, "", pid)
				rest = line; sub(/^[0-9]+ +/, "", rest)
				ppid = rest; sub(/ .*/, "", ppid)
				cmd = rest; sub(/^[0-9]+ +/, "", cmd)
				parent[pid] = ppid; command[pid] = cmd
				next
			}
			file == 2 { lock_sid[$1] = $2; lock_dir[$1] = $3; next }
			file == 3 { pane_of[$2] = $1; path_of[$2] = $3; next }
			function is_kiro(c,   exe) {
				exe = c; sub(/ .*/, "", exe); sub(/.*\//, "", exe)
				return exe == "kiro-cli" || exe == "kiro"
			}
			END {
				for (lp in lock_sid) {
					top = ""; p = lp; depth = 0
					while (p != "" && p != "0" && p != "1" && depth < 20) {
						if (is_kiro(command[p])) top = command[p]
						if (p in pane_of) {
							printf "%s\t%s\t%s\t%s\t%s\n", pane_of[p], lock_sid[lp], lock_dir[lp], path_of[p], top
							break
						}
						p = parent[p]; depth++
					}
				}
			}
		' <(ps -A -o pid=,ppid=,command=) <(printf '%s\n' "$locks") <(printf '%s\n' "$panes"))
	fi

	local tmp pane sid dir path top cwd args count=0
	tmp=$(mktemp)
	while IFS=$'\t' read -r pane sid dir path top; do
		[ -n "$pane" ] || continue
		cwd=$(jq -r '.workspacePaths[0] // empty' "$dir/session.json" 2>/dev/null)
		[ -n "$cwd" ] || cwd="$path"
		[ -n "$top" ] || top="kiro-cli chat"
		args=$(resume_args "$top")
		jq -nc --arg pane "$pane" --arg sid "$sid" --arg cwd "$cwd" --arg args "$args" \
			'{pane: $pane, session_id: $sid, cwd: $cwd, cli_args: $args}' >>"$tmp"
		count=$((count + 1))
	done <<<"$tsv"

	jq -s '{saved_at: (now | todate), sessions: .}' "$tmp" >"$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
	rm -f "$tmp"
	log "saved $count session(s)"
}

# 세션이 이미 살아 있는 kiro 프로세스에 열려 있나 (다른 pane 에서 이미 재개됐거나 수동으로 연 경우).
session_is_open() {
	local lock="$1/.lock" pid cmd
	[ -f "$lock" ] || return 1
	pid=$(jq -r '.pid // empty' "$lock" 2>/dev/null)
	[ -n "$pid" ] || return 1
	cmd=$(ps -o command= -p "$pid" 2>/dev/null) || return 1
	# 재부팅 뒤 남은 낡은 락의 pid 가 우연히 다른 프로세스에 재사용됐을 수 있다.
	case "$cmd" in *kiro-cli* | *tui.js*) return 0 ;; esac
	return 1
}

# pane 의 프로세스 트리 아래에 kiro-cli 가 이미 떠 있나 (중복 복원 방지).
# 실행 파일 이름으로만 본다 — 셸 통합 표식 `fish (kiro-cli-term)` 은 Kiro 가 아니다.
pane_runs_kiro() {
	local pane_pid
	pane_pid=$(tmux display-message -t "$1" -p '#{pane_pid}' 2>/dev/null) || return 1
	ps -A -o pid=,ppid=,command= | awk -v root="$pane_pid" '
		{
			pid = $1; ppid = $2
			exe = $3; sub(/.*\//, "", exe)
			parent[pid] = ppid
			if (exe == "kiro-cli" || exe == "kiro-cli-chat" || exe == "kiro") kiro[pid] = 1
		}
		END {
			for (k in kiro) {
				p = k; depth = 0
				while (p != "" && p != "0" && depth < 20) {
					if (p == root) exit 0
					p = parent[p]; depth++
				}
			}
			exit 1
		}'
}

do_restore() {
	[ -f "$STATE_FILE" ] || { log "no state file"; exit 0; }
	local count
	count=$(jq '.sessions | length' "$STATE_FILE" 2>/dev/null || echo 0)
	if [ "$count" -eq 0 ]; then
		log "no kiro sessions to restore"
		exit 0
	fi
	log "restoring $count kiro session(s)..."

	local restored=0 entry pane sid cwd args tmux_session dir pane_cmd client_wait cmd
	while IFS= read -r entry; do
		pane=$(jq -r '.pane' <<<"$entry")
		sid=$(jq -r '.session_id' <<<"$entry")
		cwd=$(jq -r '.cwd // empty' <<<"$entry")
		args=$(jq -r '.cli_args // empty' <<<"$entry")

		case "$sid" in sess_*) ;; *) log "bad session id '$sid' for $pane, skipping"; continue ;; esac
		dir=$(ls -d "$KIRO_SESSIONS_DIR"/*/"$sid" 2>/dev/null | head -1)
		if [ -z "$dir" ]; then
			log "session $sid not found on disk (deleted?), skipping $pane"
			continue
		fi
		if session_is_open "$dir"; then
			log "session $sid already open, skipping $pane"
			continue
		fi

		tmux_session="${pane%%:*}"
		if ! tmux list-panes -t "$pane" >/dev/null 2>&1; then
			log "pane $pane does not exist, skipping"
			continue
		fi

		# TUI 기동 시 터미널 질의(OSC 11 등)가 클라이언트 없이 버려지지 않게 잠깐 기다린다.
		client_wait=0
		while [ "$(tmux list-clients -t "$tmux_session" 2>/dev/null | wc -l)" -eq 0 ] && [ $client_wait -lt 50 ]; do
			sleep 0.1
			client_wait=$((client_wait + 1))
		done

		# 셸이 아닌 게 떠 있으면 거기에 타이핑하면 안 된다.
		pane_cmd=$(tmux display-message -t "$pane" -p '#{pane_current_command}' 2>/dev/null || true)
		pane_cmd="${pane_cmd#-}"
		case "$pane_cmd" in
		bash | zsh | fish | sh | dash | ksh | tcsh | csh | nu) ;;
		*)
			log "pane $pane is running '$pane_cmd' (not a shell), skipping"
			continue
			;;
		esac
		if pane_runs_kiro "$pane"; then
			log "pane $pane already runs kiro-cli, skipping"
			continue
		fi

		cmd="command kiro-cli chat${args:+ $args} --resume-id $(posix_quote "$sid")"
		if [ -n "$cwd" ]; then
			cmd="cd $(posix_quote "$cwd") 2>/dev/null; $cmd"
		fi
		log "restoring $sid in $pane: $cmd"

		# resurrect 가 되살린 옛 화면 내용을 지우고 띄운다.
		tmux send-keys -t "$pane" "clear" Enter
		tmux clear-history -t "$pane"
		sleep 0.3
		tmux send-keys -t "$pane" "$cmd" Enter
		restored=$((restored + 1))
		sleep 1
	done < <(jq -c '.sessions[]' "$STATE_FILE")

	log "restored $restored of $count kiro session(s)"
}

MODE="${1:-}"
case "$MODE" in
save) do_save ;;
restore) do_restore ;;
*)
	echo "usage: $0 save|restore" >&2
	exit 2
	;;
esac
