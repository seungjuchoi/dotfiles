#!/usr/bin/env bash
# clipsend — 로컬 클립보드(이미지 우선, 없으면 텍스트)를 ssh 원격 호스트의 클립보드로 보낸다.
#
#   clipsend HOST            HOST(ssh config 이름)로 전송하고 HOST를 기억
#   clipsend                 마지막으로 보낸 HOST로 전송 (기록 없으면 오류)
#   clipsend --hosts         ~/.ssh/config 의 Host 목록 (셸 자동완성용)
#   clipsend --last          마지막 HOST 출력
#   clipsend --install-shim HOST   헤드리스 Linux 원격에 xclip 셰임만 설치
#
# 지원 조합 (로컬 → 원격): macOS/Linux → macOS/Linux
#   macOS   : pngpaste(있으면) 또는 osascript 로 PNG 추출 / osascript 로 주입
#   Linux   : wl-paste·xclip 으로 추출 / wl-copy·xclip 으로 주입
#   헤드리스 Linux(DISPLAY 없음): ~/.clipsend/ 에 저장하고 ~/.local/bin/xclip 셰임을 두어
#             Claude Code 의 Ctrl+V(xclip -selection clipboard -t image/png -o) 가 그대로 동작
set -euo pipefail

STATE_DIR="$HOME/.clipsend"
LAST_FILE="$STATE_DIR/last_host"

die() { echo "clipsend: $*" >&2; exit 1; }

list_hosts() {
  local files=("$HOME/.ssh/config")
  [ -d "$HOME/.ssh/config.d" ] && files+=("$HOME/.ssh/config.d"/*)
  cat "${files[@]}" 2>/dev/null \
    | awk 'tolower($1)=="host"{for(i=2;i<=NF;i++) if($i !~ /[*?!]/) print $i}' \
    | sort -u
}

# ---------- 로컬 클립보드 읽기 ----------
# 성공 시 파일 경로를 $PAYLOAD, 종류(png|text)를 $KIND 에 넣는다.
capture_local() {
  PAYLOAD="$(mktemp -t clipsend.XXXXXX)"
  KIND=""
  case "$(uname -s)" in
    Darwin)
      if command -v pngpaste >/dev/null 2>&1; then
        pngpaste "$PAYLOAD" 2>/dev/null && KIND=png
      else
        osascript -e 'set png_data to (the clipboard as «class PNGf»)' \
                  -e "set fp to open for access POSIX file \"$PAYLOAD\" with write permission" \
                  -e 'write png_data to fp' -e 'close access fp' >/dev/null 2>&1 && KIND=png
      fi
      if [ -z "$KIND" ]; then
        pbpaste > "$PAYLOAD" 2>/dev/null && [ -s "$PAYLOAD" ] && KIND=text
      fi
      ;;
    Linux)
      # Claude Code 와 같은 순서: xclip → wl-paste (xclip 셰임이 있으면 그것도 통한다)
      if xclip -selection clipboard -t TARGETS -o 2>/dev/null | grep -q '^image/png' \
         && xclip -selection clipboard -t image/png -o > "$PAYLOAD" 2>/dev/null && [ -s "$PAYLOAD" ]; then
        KIND=png
      elif command -v wl-paste >/dev/null 2>&1 && wl-paste -l 2>/dev/null | grep -q '^image/png' \
         && wl-paste --type image/png > "$PAYLOAD" 2>/dev/null && [ -s "$PAYLOAD" ]; then
        KIND=png
      elif xclip -selection clipboard -t text/plain -o > "$PAYLOAD" 2>/dev/null && [ -s "$PAYLOAD" ]; then
        KIND=text
      elif command -v wl-paste >/dev/null 2>&1 && wl-paste --no-newline > "$PAYLOAD" 2>/dev/null && [ -s "$PAYLOAD" ]; then
        KIND=text
      elif command -v xsel >/dev/null 2>&1 && xsel --clipboard --output > "$PAYLOAD" 2>/dev/null && [ -s "$PAYLOAD" ]; then
        KIND=text
      fi
      ;;
    *) die "unsupported local OS: $(uname -s)" ;;
  esac
  [ -n "$KIND" ] || die "local clipboard is empty (no image, no text)"
}

# ---------- 원격에서 실행될 스크립트 ----------
# $1 = png|text, stdin = payload.  macOS/Linux 모두 처리.
read -r -d '' REMOTE_SCRIPT <<'REMOTE_EOF' || true
set -eu
kind="$1"
dir="$HOME/.clipsend"; mkdir -p "$dir"
os="$(uname -s)"
if [ "$kind" = png ]; then f="$dir/clip.png"; else f="$dir/clip.txt"; fi
cat > "$f"
printf '%s' "$kind" > "$dir/type"

install_shim() {
  mkdir -p "$HOME/.local/bin"
  cat > "$HOME/.local/bin/xclip" <<'SHIM_EOF'
#!/usr/bin/env bash
# xclip 셰임 (clipsend 가 설치) — 헤드리스 Linux 에서 ~/.clipsend/ 를 클립보드처럼 제공한다.
# DISPLAY 가 있고 진짜 xclip 이 있으면 그쪽으로 넘긴다.
if [ -n "${DISPLAY:-}" ]; then
  self="$(readlink -f "$0" 2>/dev/null || echo "$0")"
  while IFS= read -r cand; do
    [ "$(readlink -f "$cand" 2>/dev/null)" = "$self" ] && continue
    exec "$cand" "$@"
  done < <(type -aP xclip 2>/dev/null)
fi
dir="$HOME/.clipsend"
target=""; mode=out; infile=""
while [ $# -gt 0 ]; do
  case "$1" in
    -t|-target) target="$2"; shift 2 ;;
    -o|-out) mode=out; shift ;;
    -i|-in) mode=in; shift; [ $# -gt 0 ] && [ "${1#-}" = "$1" ] && { infile="$1"; shift; } ;;
    -selection|-sel|-d|-display|-l|-loops) shift 2 ;;
    -*) shift ;;
    *) infile="$1"; shift ;;
  esac
done
kind="$(cat "$dir/type" 2>/dev/null || true)"
if [ "$mode" = in ]; then
  mkdir -p "$dir"
  case "$target" in
    image/png) k=png; f="$dir/clip.png" ;;
    *)         k=text; f="$dir/clip.txt" ;;
  esac
  if [ -n "$infile" ]; then cat "$infile" > "$f"; else cat > "$f"; fi
  printf '%s' "$k" > "$dir/type"; exit 0
fi
case "$target" in
  TARGETS)
    [ "$kind" = png ] && { printf 'TARGETS\nimage/png\n'; exit 0; }
    [ "$kind" = text ] && { printf 'TARGETS\nUTF8_STRING\ntext/plain\n'; exit 0; }
    exit 1 ;;
  image/png) [ "$kind" = png ] && exec cat "$dir/clip.png"; exit 1 ;;
  image/*)   exit 1 ;;
  *)         [ "$kind" = text ] && exec cat "$dir/clip.txt"; exit 1 ;;
esac
SHIM_EOF
  chmod +x "$HOME/.local/bin/xclip"
}

case "$os" in
  Darwin)
    if [ "$kind" = png ]; then
      osascript -e "set the clipboard to (read (POSIX file \"$f\") as «class PNGf»)"
    else
      pbcopy < "$f"
    fi
    echo "via:osascript"
    ;;
  Linux)
    if [ -n "${WAYLAND_DISPLAY:-}" ] && command -v wl-copy >/dev/null 2>&1; then
      if [ "$kind" = png ]; then wl-copy -t image/png < "$f"; else wl-copy < "$f"; fi
      echo "via:wl-copy"
    elif [ -n "${DISPLAY:-}" ] && real="$(type -aP xclip 2>/dev/null | grep -v "$HOME/.local/bin/xclip" | head -1)" && [ -n "$real" ]; then
      if [ "$kind" = png ]; then "$real" -selection clipboard -t image/png -i "$f"; else "$real" -selection clipboard -i "$f"; fi
      echo "via:xclip"
    else
      installed=""
      [ -x "$HOME/.local/bin/xclip" ] && grep -q 'clipsend' "$HOME/.local/bin/xclip" || { install_shim; installed=" (shim installed → ~/.local/bin/xclip)"; }
      case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) installed="$installed [WARN: ~/.local/bin not in PATH]" ;; esac
      echo "via:shim$installed"
    fi
    ;;
  *) echo "unsupported remote OS: $os" >&2; exit 1 ;;
esac
REMOTE_EOF

# 원격 로그인 셸(fish/zsh/bash)에 무관하게 동작하도록 스크립트를 base64 로 실어 보낸다.
remote_cmd() {  # $1 = kind
  local b64
  b64="$(printf '%s\n' "$REMOTE_SCRIPT" | base64 | tr -d '\n')"
  printf 'mkdir -p ~/.clipsend; echo %s | base64 -d > ~/.clipsend/run.sh; bash ~/.clipsend/run.sh %s' "$b64" "$1"
}

send() {  # $1 = host
  local host="$1" via
  capture_local
  trap 'rm -f "${PAYLOAD:-}"' EXIT
  # 원격 셸 설정이 stdout 에 찍는 잡음(경고·ANSI)은 버리고 via: 토큰만 취한다
  via="$(ssh "$host" "$(remote_cmd "$KIND")" < "$PAYLOAD" | sed -n 's/.*\(via:[^[:cntrl:]]*\).*/\1/p' | tail -1)"
  [ -n "$via" ] || die "failed to send to $host"
  mkdir -p "$STATE_DIR"; printf '%s' "$host" > "$LAST_FILE"
  echo "✅ $KIND → $host clipboard ($(wc -c < "$PAYLOAD" | tr -d ' ') bytes, $via)"
}

case "${1:-}" in
  -h|--help) sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
  --hosts)   list_hosts; exit 0 ;;
  --last)    cat "$LAST_FILE" 2>/dev/null || die "no last host"; echo; exit 0 ;;
  --install-shim)
    [ -n "${2:-}" ] || die "usage: clipsend --install-shim HOST"
    printf '' | ssh "$2" "$(remote_cmd text)" >/dev/null && echo "✅ shim checked/installed on $2"; exit 0 ;;
  -*) die "unknown option: $1" ;;
  "")
    host="$(cat "$LAST_FILE" 2>/dev/null || true)"
    [ -n "$host" ] || die "no host given and no previous host. usage: clipsend HOST   (see: clipsend --hosts)"
    send "$host" ;;
  *) send "$1" ;;
esac
