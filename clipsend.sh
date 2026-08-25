#!/usr/bin/env bash
# clipsend — 로컬 클립보드(이미지 → 파일 → 텍스트 순)를 ssh 원격 호스트의 클립보드로 보낸다.
#
#   clipsend HOST            HOST(ssh config 이름)로 전송하고 HOST를 기억
#   clipsend                 마지막으로 보낸 HOST로 전송 (기록 없으면 오류)
#   clipsend --hosts         ~/.ssh/config 의 Host 목록 (셸 자동완성용)
#   clipsend --last          마지막 HOST 출력
#   clipsend --install-shim HOST   헤드리스 Linux 원격에 xclip 셰임만 설치
#
# 지원 조합 (로컬 → 원격): macOS/Linux → macOS/Linux
#   이미지  : macOS pngpaste/osascript, Linux xclip/wl-paste 로 추출 → 원격 클립보드에 PNG 주입
#   파일    : Finder/파일관리자에서 복사한 파일·폴더를 원격 ~/.clipsend/files/ 로 복사하고
#             원격 클립보드에 그 경로를 넣는다 (macOS: 파일 참조라 Finder ⌘V 가능, Linux: 경로 텍스트)
#   텍스트  : 위 둘이 없을 때
#   헤드리스 Linux(DISPLAY 없음): ~/.clipsend/ 에 저장하고 ~/.local/bin/xclip 셰임을 두어
#             Claude Code 의 Ctrl+V(xclip -selection clipboard -t image/png -o) 가 그대로 동작
set -euo pipefail

STATE_DIR="$HOME/.clipsend"
LAST_FILE="$STATE_DIR/last_host"

die() { echo "clipsend: $*" >&2; exit 1; }
b64enc() { base64 | tr -d '\n'; }

list_hosts() {
  local files=("$HOME/.ssh/config")
  [ -d "$HOME/.ssh/config.d" ] && files+=("$HOME/.ssh/config.d"/*)
  cat "${files[@]}" 2>/dev/null \
    | awk 'tolower($1)=="host"{for(i=2;i<=NF;i++) if($i !~ /[*?!]/) print $i}' \
    | sort -u
}

# file:///a/b%20c → /a/b c  (file:// 접두사가 없으면 그대로 경로로 취급)
uri_to_path() {
  local line
  while IFS= read -r line; do
    line="${line%$'\r'}"; [ -z "$line" ] && continue; [ "${line#\#}" != "$line" ] && continue
    line="${line#file://localhost}"; line="${line#file://}"
    printf '%b\n' "${line//%/\\x}"
  done
}

# ---------- 로컬 클립보드 읽기 ----------
# 성공 시 $PAYLOAD(파일), $KIND(png|text|file|tar), $META(base64: 파일 이름 목록) 를 채운다.
PAYLOAD=""; KIND=""; META=""
clip_paths() {  # 클립보드의 파일 경로 목록(줄 단위) — 없으면 실패
  case "$(uname -s)" in
    Darwin)
      osascript -l JavaScript -e 'ObjC.import("AppKit"); const items=$.NSPasteboard.generalPasteboard.pasteboardItems; let o=[]; for(let i=0;i<items.count;i++){const s=items.objectAtIndex(i).stringForType("public.file-url"); if(!s.isNil()) o.push(ObjC.unwrap($.NSURL.URLWithString(s).path));} o.join("\n")' 2>/dev/null ;;
    Linux)
      { xclip -selection clipboard -t text/uri-list -o 2>/dev/null \
        || { command -v wl-paste >/dev/null 2>&1 && wl-paste -t text/uri-list 2>/dev/null; }; } | uri_to_path ;;
  esac
}

pack_files() {  # $1.. = 경로들 → PAYLOAD/KIND/META
  local p names=() dirs=()
  for p in "$@"; do [ -e "$p" ] || die "not found: $p"; names+=("$(basename "$p")"); dirs+=("$(dirname "$p")"); done
  if [ $# -eq 1 ] && [ -f "$1" ]; then
    KIND=file; cp "$1" "$PAYLOAD"
  else
    KIND=tar; local args=() i
    for i in "${!names[@]}"; do args+=(-C "${dirs[$i]}" "${names[$i]}"); done
    # macOS xattr/리소스포크를 빼서 GNU tar 쪽 경고를 막는다
    COPYFILE_DISABLE=1 tar --no-xattrs -czf "$PAYLOAD" "${args[@]}"
  fi
  META="$(printf '%s\n' "${names[@]}" | b64enc)"
}

capture_local() {
  PAYLOAD="$(mktemp -t clipsend.XXXXXX)"
  local paths
  case "$(uname -s)" in
    Darwin)
      if command -v pngpaste >/dev/null 2>&1; then
        pngpaste "$PAYLOAD" 2>/dev/null && KIND=png
      else
        osascript -e 'set png_data to (the clipboard as «class PNGf»)' \
                  -e "set fp to open for access POSIX file \"$PAYLOAD\" with write permission" \
                  -e 'write png_data to fp' -e 'close access fp' >/dev/null 2>&1 && KIND=png
      fi
      if [ -z "$KIND" ] && paths="$(clip_paths)" && [ -n "$paths" ]; then
        local arr=(); while IFS= read -r p; do arr+=("$p"); done <<< "$paths"; pack_files "${arr[@]}"
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
      elif paths="$(clip_paths)" && [ -n "$paths" ] && [ -e "$(printf '%s\n' "$paths" | head -1)" ]; then
        local arr=(); while IFS= read -r p; do arr+=("$p"); done <<< "$paths"; pack_files "${arr[@]}"
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
  [ -n "$KIND" ] || die "local clipboard is empty (no image, no file, no text)"
}

# ---------- 원격에서 실행될 스크립트 ----------
# $1 = png|text|file|tar, $2 = base64(파일 이름 목록), stdin = payload.  macOS/Linux 모두 처리.
read -r -d '' REMOTE_SCRIPT <<'REMOTE_EOF' || true
set -eu
kind="$1"; meta="${2:-}"
dir="$HOME/.clipsend"; mkdir -p "$dir"
os="$(uname -s)"
paths=()
case "$kind" in
  png)  f="$dir/clip.png"; cat > "$f"; printf png > "$dir/type" ;;
  text) f="$dir/clip.txt"; cat > "$f"; printf text > "$dir/type" ;;
  file|tar)
    files="$dir/files"; mkdir -p "$files"
    while IFS= read -r n; do [ -n "$n" ] && paths+=("$files/$n"); done < <(printf '%s' "$meta" | base64 -d)
    if [ "$kind" = file ]; then cat > "${paths[0]}"; else tar -xzf - -C "$files"; fi
    f="$dir/clip.txt"; printf '%s\n' "${paths[@]}" > "$f"; printf text > "$dir/type"
    printf 'path:%s\n' "${paths[@]}" ;;
esac

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
    [ "$kind" = text ] && { printf 'TARGETS\nUTF8_STRING\ntext/plain\ntext/uri-list\n'; exit 0; }
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
    case "$kind" in
      png)  osascript -e "set the clipboard to (read (POSIX file \"$f\") as «class PNGf»)" ;;
      text) pbcopy < "$f" ;;
      # 여러 파일 참조(furl)를 넣는다. 프로세스 종료 전에 각 항목의 types 를 읽어야 지연 기록이 플러시되어 전부 남는다.
      *)    osascript -l JavaScript -e 'ObjC.import("AppKit"); function run(argv){const pb=$.NSPasteboard.generalPasteboard; pb.clearContents; const urls=argv.map(p=>$.NSURL.fileURLWithPath($(p))); const ok=pb.writeObjects($(urls)); const it=pb.pasteboardItems; for(let i=0;i<it.count;i++) it.objectAtIndex(i).types; return ok;}' "${paths[@]}" >/dev/null ;;
    esac
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
remote_cmd() {  # $1 = kind, $2 = meta(base64)
  local b64; b64="$(printf '%s\n' "$REMOTE_SCRIPT" | b64enc)"
  printf 'mkdir -p ~/.clipsend; echo %s | base64 -d > ~/.clipsend/run.sh; bash ~/.clipsend/run.sh %s %s' "$b64" "$1" "${2:-}"
}

send() {  # $1 = host
  local host="$1" out via
  capture_local
  trap 'rm -f "${PAYLOAD:-}"' EXIT
  # 원격 셸 설정이 stdout 에 찍는 잡음(경고·ANSI)은 버리고 via:/path: 줄만 취한다
  out="$(ssh "$host" "$(remote_cmd "$KIND" "$META")" < "$PAYLOAD" | sed -n -e 's/.*\(via:[^[:cntrl:]]*\).*/\1/p' -e 's/.*\(path:[^[:cntrl:]]*\).*/\1/p')"
  via="$(printf '%s\n' "$out" | sed -n 's/^via://p' | tail -1)"
  [ -n "$via" ] || die "failed to send to $host"
  mkdir -p "$STATE_DIR"; printf '%s' "$host" > "$LAST_FILE"
  echo "✅ $KIND → $host clipboard ($(wc -c < "$PAYLOAD" | tr -d ' ') bytes, $via)"
  printf '%s\n' "$out" | sed -n 's/^path:/   📄 /p'
}

case "${1:-}" in
  -h|--help) sed -n '2,18p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
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
