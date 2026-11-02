#!/usr/bin/env bash
# Show Kiro CLI session titles as Herdr pane titles.
#
# Kiro CLI (v3 TUI) only writes "kiro: <cwd>" to the terminal title, but it
# stores the generated session title on disk:
#   ~/.kiro/sessions/<hash>/sess_<uuid>/.lock         {"pid": <tui pid>, ...}
#   ~/.kiro/sessions/<hash>/sess_<uuid>/session.json  {"title": "...", ...}
# The .lock pid is a process inside the pane, which ties a session to a pane.
#
# The title is published three ways:
#   --title          pane/agent views (prefix+g)
#   --token title=   the sidebar ($title in ui.sidebar.agents.rows_by_agent.kiro)
#   pane label       clients that only read labels/terminal titles (Collie)
# The label is only set when it is empty or was set by this plugin, and is
# cleared again once Kiro leaves the pane.
#
# Usage: kiro-title.sh event   (plugin event hook; reads HERDR_PLUGIN_EVENT_JSON)
#        kiro-title.sh all     (sync every Kiro pane, clear stale labels)
set -uo pipefail

HERDR="${HERDR_BIN_PATH:-herdr}"
SESSIONS_DIR="${KIRO_SESSIONS_DIR:-$HOME/.kiro/sessions}"
SOURCE="plugin:${HERDR_PLUGIN_ID:-timer.kiro-title}"
STATE_DIR="${HERDR_PLUGIN_STATE_DIR:-${TMPDIR:-/tmp}/herdr-kiro-title}"
UNTITLED="New Session"

mkdir -p "$STATE_DIR"

state_file() { echo "$STATE_DIR/$(tr ':' '_' <<<"$1").$2"; }

# All pids running in a pane: foreground processes plus descendants of the shell.
pane_pids() {
  local info shell_pid
  info=$("$HERDR" pane process-info --pane "$1" 2>/dev/null) || return 1
  jq -r '.result.process_info.foreground_processes[]?.pid' <<<"$info"
  shell_pid=$(jq -r '.result.process_info.shell_pid // empty' <<<"$info")
  [[ -n "$shell_pid" ]] && descendants "$shell_pid"
}

descendants() {
  local child
  for child in $(pgrep -P "$1" 2>/dev/null); do
    echo "$child"
    descendants "$child"
  done
}

# Title of the Kiro session whose .lock pid runs in the pane.
session_title() {
  local pids lock pid title
  pids=" $(pane_pids "$1" | tr '\n' ' ') "
  for lock in "$SESSIONS_DIR"/*/sess_*/.lock; do
    [[ -f "$lock" ]] || continue
    pid=$(jq -r '.pid // empty' "$lock" 2>/dev/null)
    [[ -n "$pid" && "$pids" == *" $pid "* ]] || continue
    title=$(jq -r '.title // empty' "$(dirname "$lock")/session.json" 2>/dev/null)
    [[ -n "$title" && "$title" != "$UNTITLED" ]] && { echo "$title"; return 0; }
  done
  return 1
}

pane_field() {
  "$HERDR" pane get "$1" 2>/dev/null | jq -r ".result.pane.$2 // empty"
}

sync_label() {
  local pane="$1" title="$2" owned label
  owned=$(state_file "$pane" label)
  label=$(pane_field "$pane" label)
  [[ "$label" == "$title" ]] && return 0
  # Never overwrite a label the user set by hand.
  if [[ -n "$label" && ! ( -f "$owned" && "$(cat "$owned")" == "$label" ) ]]; then
    return 0
  fi
  "$HERDR" pane rename "$pane" "$title" >/dev/null && echo "$title" >"$owned"
}

# Remove the label this plugin set, if the user has not changed it since.
clear_label() {
  local pane="$1" owned
  owned=$(state_file "$pane" label)
  [[ -f "$owned" ]] || return 0
  [[ "$(pane_field "$pane" label)" == "$(cat "$owned")" ]] &&
    "$HERDR" pane rename "$pane" --clear >/dev/null 2>&1
  rm -f "$owned" "$(state_file "$pane" title)"
}

sync_pane() {
  local pane="$1" title cache
  cache=$(state_file "$pane" title)
  title=$(session_title "$pane") || return 1
  if [[ ! -f "$cache" || "$(cat "$cache")" != "$title" ]]; then
    "$HERDR" pane report-metadata "$pane" --source "$SOURCE" --agent kiro \
      --title "$title" --token title="$title" >/dev/null && echo "$title" >"$cache"
  fi
  sync_label "$pane" "$title"
}

case "${1:-all}" in
  event)
    event="${HERDR_PLUGIN_EVENT_JSON:-}"
    printf '%s\n' "$event" >"$STATE_DIR/last-event.json"
    pane=$(jq -r '[.. | objects | .pane_id? // empty][0] // empty' <<<"$event" 2>/dev/null)
    [[ -n "$pane" ]] || pane="${HERDR_PANE_ID:-}"
    [[ -n "$pane" ]] || exit 0
    if [[ "$(pane_field "$pane" agent)" != kiro ]]; then
      clear_label "$pane"
      exit 0
    fi
    # Kiro writes the title shortly after the first turn; retry briefly.
    for _ in 1 2 3 4 5; do
      sync_pane "$pane" && exit 0
      sleep 2
    done
    ;;
  all)
    kiro_panes=" $("$HERDR" agent list 2>/dev/null |
      jq -r '.result.agents[] | select(.agent == "kiro") | .pane_id' | tr '\n' ' ') "
    for pane in $kiro_panes; do sync_pane "$pane"; done
    # Labels left behind by Kiro panes that are gone or now run something else.
    for owned in "$STATE_DIR"/*.label; do
      [[ -f "$owned" ]] || continue
      pane=$(basename "$owned" .label | tr '_' ':')
      [[ "$kiro_panes" == *" $pane "* ]] || clear_label "$pane"
    done
    ;;
  *)
    echo "usage: $0 event|all" >&2
    exit 2
    ;;
esac
exit 0
