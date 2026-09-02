set fish_greeting ""
set -gx COLORTERM truecolor
set -gx LANG en_US.UTF-8
set -gx LC_CTYPE en_US.UTF-8
set -gx LC_ALL en_US.UTF-8
set -gx MANPAGER "less -I"
set LOCAL_FISH_CONF (dirname (status --current-filename))/config_local.fish # place first cuz linuxbrew
if test -f $LOCAL_FISH_CONF
    source $LOCAL_FISH_CONF
end
if command -qs nvim
    alias vi nvim
    alias vim nvim
    set -gx EDITOR nvim
end
if command -qs ipython
    alias ipy ipython
end
if command -qs eza
    alias ll "eza -l --hyperlink --sort modified --icons --git"
    alias lla "eza -l -a --hyperlink --sort modified --icons --git"
end

if command -qs yazi
    alias yz "yazi"
end
if command -qs lazygit
    alias lg lazygit $argv
end
if command -qs lazydocker
    alias lk lazydocker $argv
end
if command -qs convmv
    alias convmv "convmv -r -f utf8 -t utf8 --notest --nfc $argv"
end
if command -qs starship
    starship init fish | source
end
if command -qs zoxide
    zoxide init fish | source
end
if command -qs thefuck
    thefuck --alias | source
end
if command -qs claude
    # Enterprise (company) accounts disallow bypassPermissions; skip the flag there.
    function _claude_perm_flags
        if jq -e '.oauthAccount.organizationType == "claude_enterprise"' ~/.claude.json >/dev/null 2>&1
            return
        end
        echo --dangerously-skip-permissions
    end
    if test -n "$_CL_PROXY_PORT"
        function cl
            if test "$PWD" = "$HOME"; and type -q z
                z tz
            end
            prxh $_CL_PROXY_PORT
            claude (_claude_perm_flags) $argv
            prxh off
        end
        function clp
            prxh $_CL_PROXY_PORT
            claude (_claude_perm_flags) -p $argv
            prxh off
        end
    else
        function cl
            if test "$PWD" = "$HOME"; and type -q z
                z tz
            end
            claude (_claude_perm_flags) $argv
        end
        function clp
            claude (_claude_perm_flags) -p $argv
        end
    end

    function _ck_gateway_health
        set -l body (curl -sf --max-time 0.3 http://127.0.0.1:$argv[1]/health 2>/dev/null)
        or return 1
        string match -qr '"status"\s*:\s*"healthy"' -- $body
    end

    function _ck_port_busy
        lsof -nP -iTCP:$argv[1] -sTCP:LISTEN >/dev/null 2>&1
    end

    # Proxy the gateway should use for upstream Kiro/SSO calls.
    # "direct" = no proxy. Kept as an explicit token so it can be persisted
    # and compared against an already-running gateway.
    function _ck_proxy_state
        if test -n "$_CL_PROXY_PORT"
            echo http://127.0.0.1:$_CL_PROXY_PORT
        else
            echo direct
        end
    end

    # Fingerprint of the gateway's Python sources (newest mtime).
    # Python loads modules at start, so patching files on disk — which
    # kiro-gateway-update does on every run — has no effect on a process
    # that is already running. Recording this at start lets us notice a
    # gateway that is serving stale code and restart it.
    function _ck_code_stamp
        set -l dir $HOME/.local/share/kiro-gateway
        find $dir -name '*.py' -not -path '*/.venv/*' -exec stat -f '%m' {} + 2>/dev/null |
            sort -n | tail -1
    end

    function _ck_gateway_pid
        set -l main $HOME/.local/share/kiro-gateway/main.py
        for pid in (lsof -nP -iTCP:$argv[1] -sTCP:LISTEN -t 2>/dev/null)
            if string match -q "*$main*" -- (ps -o command= -p $pid 2>/dev/null)
                echo $pid
            end
        end
    end

    function _ck_stop_gateway
        set -l pids (_ck_gateway_pid $argv[1])
        test (count $pids) -gt 0; or return 0
        kill $pids 2>/dev/null
        for i in (seq 1 20)
            if not _ck_gateway_health $argv[1]
                return 0
            end
            sleep 0.25
        end
        _ck_gateway_health $argv[1]; and return 1
        return 0
    end

    function _ck_pick_port
        set -l dir $HOME/.local/share/kiro-gateway
        set -l preferred 8000
        if test -n "$CK_PORT"
            set preferred $CK_PORT
        else if test -f $dir/port
            set preferred (string trim < $dir/port)
        end

        if string match -qr '^[0-9]+$' -- $preferred
            if _ck_gateway_health $preferred
                echo $preferred
                return 0
            end
        else
            set preferred 8000
        end

        for p in (seq 8000 8019)
            if _ck_gateway_health $p
                echo $p
                return 0
            end
        end

        if not _ck_port_busy $preferred
            echo $preferred
            return 0
        end

        for p in (seq 8000 8019)
            if not _ck_port_busy $p
                echo $p
                return 0
            end
        end

        echo "no free port in 8000-8019 (set CK_PORT to override)" >&2
        return 1
    end

    function _ck_ensure_gateway
        set -l dir $HOME/.local/share/kiro-gateway
        set -l want (_ck_proxy_state)
        set -l stamp (_ck_code_stamp)
        set -l port (_ck_pick_port)
        or return $status

        if _ck_gateway_health $port
            set -l have
            if test -f $dir/proxy
                set have (string trim < $dir/proxy)
            end
            set -l have_stamp
            if test -f $dir/code
                set have_stamp (string trim < $dir/code)
            end

            set -l why
            if test "$have" != "$want"
                set why "proxy mismatch (running: '$have', want: '$want')"
            else if test -n "$stamp" -a "$have_stamp" != "$stamp"
                # Missing $dir/code means it predates this check, so treat it
                # as stale too — that gateway may well be serving old code.
                set why "code changed since it started"
            end

            if test -z "$why"
                echo $port >$dir/port
                echo $port
                return 0
            end
            echo "kiro-gateway $why; restarting..." >&2
            if not _ck_stop_gateway $port
                echo "could not stop kiro-gateway on :$port; kill it manually" >&2
                return 1
            end
        end

        if not test -x $dir/.venv/bin/python
            echo "kiro-gateway missing; installing..." >&2
            set -l installer
            if type -q kiro-gateway-update
                set installer kiro-gateway-update
            else
                set -l df (dirname (realpath (status filename)))
                if test -f $df/kiro_gateway_update.fish
                    set installer fish $df/kiro_gateway_update.fish
                end
            end
            if test -z "$installer"
                echo "kiro-gateway-update not found; run kiro_gateway_update.fish from dotfiles" >&2
                return 1
            end
            $installer
            or return $status
            if not test -x $dir/.venv/bin/python
                echo "kiro-gateway install finished but $dir/.venv/bin/python is missing" >&2
                return 1
            end
            # The installer rewrites sources and re-applies local.patch, so the
            # stamp taken above is already out of date.
            set stamp (_ck_code_stamp)
        end

        set -l log $dir/gateway.log
        set -l db "$HOME/Library/Application Support/kiro-cli/data.sqlite3"
        set -l env_args
        set -a env_args PROXY_API_KEY=kiro-local-proxy-key
        set -a env_args SERVER_HOST=127.0.0.1
        set -a env_args SERVER_PORT=$port
        # The gateway defaults these to relative paths, so they land in whatever
        # directory `ck` was invoked from. Pin them next to the gateway itself.
        set -a env_args "ACCOUNTS_CONFIG_FILE=$dir/credentials.json"
        set -a env_args "ACCOUNTS_STATE_FILE=$dir/state.json"
        if test -f $db
            set -a env_args "KIRO_CLI_DB_FILE=$db"
        else if test -f $HOME/.aws/sso/cache/kiro-auth-token.json
            set -a env_args "KIRO_CREDS_FILE=$HOME/.aws/sso/cache/kiro-auth-token.json"
        end
        if test "$want" = direct
            # Explicit empty value overrides a stale VPN_PROXY_URL in $dir/.env
            set -a env_args "VPN_PROXY_URL="
        else
            set -a env_args "VPN_PROXY_URL=$want"
        end
        echo "Starting kiro-gateway on :$port..." >&2
        pushd $dir
        env $env_args $dir/.venv/bin/python $dir/main.py --host 127.0.0.1 --port $port >$log 2>&1 &
        disown
        popd
        for i in (seq 1 40)
            if _ck_gateway_health $port
                echo $port >$dir/port
                echo $want >$dir/proxy
                echo $stamp >$dir/code
                echo $port
                return 0
            end
            sleep 0.25
        end
        echo "kiro-gateway failed to start on :$port; see $log" >&2
        return 1
    end

    function _ck_run_claude
        set -l port (_ck_ensure_gateway)
        or return $status
        set -lx ANTHROPIC_BASE_URL http://127.0.0.1:$port
        set -lx ANTHROPIC_API_KEY kiro-local-proxy-key
        set -lx ANTHROPIC_AUTH_TOKEN kiro-local-proxy-key
        set -lx ANTHROPIC_MODEL claude-opus-5
        set -lx ANTHROPIC_DEFAULT_SONNET_MODEL claude-sonnet-5
        set -lx ANTHROPIC_DEFAULT_OPUS_MODEL claude-opus-5
        set -lx ANTHROPIC_DEFAULT_HAIKU_MODEL claude-haiku-4.5
        set -lx CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY 1
        if test -n "$_CL_PROXY_PORT"
            prxh $_CL_PROXY_PORT
            claude --dangerously-skip-permissions $argv
            prxh off
        else
            claude --dangerously-skip-permissions $argv
        end
    end

    function ck
        if test "$PWD" = "$HOME"; and type -q z
            z tz
        end
        _ck_run_claude $argv
    end

    function ckp
        _ck_run_claude -p $argv
    end
end
if command -qs gemini
    alias ge "gemini -y"
    alias gep "gemini"
end
if command -qs crush
    alias cr "crush -y"
    alias crp "crush run"
end
if command -qs kiro-cli
    # TUI 는 --trust-all-tools 를 직접 소비한다. --no-interactive 는 ACP 로
    # 플래그를 넘기는데, ACP v3 는 --trust-all-tools 를 거절한다.
    alias kr "kiro-cli chat --trust-all-tools --v3"
    alias krp "kiro-cli chat --trust-all-tools --no-interactive"
end
if command -qs opencode
    alias op "opencode"
    alias opp "opencode run"
end
if command -qs codex
    if test -n "$_CL_PROXY_PORT"
        function co
            prxh $_CL_PROXY_PORT
            codex --dangerously-bypass-approvals-and-sandbox $argv
            prxh off
        end
        function cop
            prxh $_CL_PROXY_PORT
            codex exec --dangerously-bypass-approvals-and-sandbox $argv
            prxh off
        end
    else
        alias co "codex --dangerously-bypass-approvals-and-sandbox"
        alias cop "codex exec --dangerously-bypass-approvals-and-sandbox"
    end
end
if command -qs pi
    if test -n "$_CL_PROXY_PORT"
        function pi
            prxh $_CL_PROXY_PORT
            command pi $argv
            prxh off
        end
        function pix
            prxh $_CL_PROXY_PORT
            command pi -p $argv
            prxh off
        end
    else
        alias pix "pi -p"
    end
end
if command -qs openclaw
    alias oc "openclaw tui"
end

if test (uname) = "Darwin"
    set -gx ICLOUD_PATH /Users/(whoami)/Library/Mobile\ Documents/com~apple~CloudDocs
    set -gx OBSIDIAN_PATH /Users/(whoami)/Library/Mobile\ Documents/iCloud~md~obsidian/Documents
end
if test -d /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib
    set -gx LIBRARY_PATH "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib"
end
if test -d /opt/homebrew/opt/llvm
    set -gx LDFLAGS $LDFLAGS "-L/opt/homebrew/opt/llvm/lib"
    set -gx LDFLAGS $LDFLAGS "-L/opt/homebrew/opt/llvm/lib/c++ -Wl,-rpath,/opt/homebrew/opt/llvm/lib/c++"
    set -gx CPPFLAGS $CPPFLAGS "-I/opt/homebrew/opt/llvm/include"
end
if test -d /opt/homebrew/opt/libpq
   set -gx LDFLAGS $LDFLAGS "-L/opt/homebrew/opt/libpq/lib"
   set -gx CPPFLAGS $CPPFLAGS "-I/opt/homebrew/opt/libpq/include"
end
if test -d /opt/homebrew/opt/opencv@3
   set -gx LDFLAGS $LDFLAGS "-L/opt/homebrew/opt/opencv@3/lib"
   set -gx CPPFLAGS $CPPFLAGS "-I/opt/homebrew/opt/opencv@3/include"
   set -gx PKG_CONFIG_PATH "/opt/homebrew/opt/opencv@3/lib/pkgconfig" $PKG_CONFIG_PATH
end
if test -d /opt/homebrew/opt/curl
   set -gx LDFLAGS $LDFLAGS "-L/opt/homebrew/opt/curl/lib"
   set -gx CPPFLAGS $CPPFLAGS "-I/opt/homebrew/opt/curl/include"
   set -gx PKG_CONFIG_PATH "/opt/homebrew/opt/curl/lib/pkgconfig" $PKG_CONFIG_PATH
end

if type -q brew
    eval "$(brew shellenv)"
end
fish_add_path ~/.cargo/bin
fish_add_path ~/.local/bin

set -g fzf_fd_opts --exclude "Library/Mobile Documents"
fzf_configure_bindings --variables=\e\cv

# python
set -gx PYTHONBREAKPOINT "ipdb.set_trace"

if test -z "$VIRTUAL_ENV"; and begin; type -q python || type -q ipython || type -q ipython3; end
    set_color yellow
    echo "⚠️  Warning: Global Python executables detected outside of virtual environment"
    set_color normal
end


function you_down -d "Download videos using yt-dlp"
    function on_sigint --on-signal SIGINT
        echo "다운로드 중단..."
        # 현재 실행 중인 모든 배경 작업을 종료
        for job in (jobs -p)
            kill $job
        end
        exit 1
    end
    if not type -q yt-dlp
        echo "yt-dlp가 설치되어 있지 않습니다. 설치 후 다시 시도해주세요."
        return 1
    end

    function print_usage
        echo "Usage:"
        echo "  download_ytdlp [URL or FILE]"
        echo "  URL: 다운로드할 YouTube URL"
        echo "  FILE: URL 목록이 담긴 파일 경로"
    end

    if test (count $argv) -eq 0
        print_usage
        return 1
    end

    if string match -qr 'https?://.*' $argv[1]
        yt-dlp --write-thumbnail --embed-thumbnail -o '%(title)s.%(ext)s' -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/mp4' $argv[1]
        for file in (find . -name "*.webp")
            rm $file
        end
    else if test -f $argv[1]
        set urls (cat $argv[1])
        for url in $urls
            yt-dlp --write-thumbnail --embed-thumbnail -o '%(title)s.%(ext)s' -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/mp4' $url &
        end
        wait
        for file in (find . -name "*.webp")
            rm $file
        end
    else
        echo "Invalid argument: $argv[1]"
        print_usage
        return 1
    end
end

function _vf_install_essentials --on-event virtualenv_did_create
    echo Install Essential Packages..
    pip install -U pip
    pip install pynvim ipython matplotlib
end

function ggifer --description 'Convert MP4 to high-quality GIF with customizable fps and scale'
    # Default values
    set -l fps 24
    set -l scale 1080

    # Parse arguments
    set -l options 'f/fps=' 's/scale='
    argparse $options -- $argv

    # Override defaults if options are provided
    if set -q _flag_fps
        set fps $_flag_fps
    end

    if set -q _flag_scale
        set scale $_flag_scale
    end

    # Check if input file is provided
    if test (count $argv) -lt 1
        echo "Usage: ggifer [options] input.mp4 [output.gif]"
        echo "       ggifer [options] input1.mp4 input2.mp4 ..."
        echo "Options:"
        echo "  -f/--fps=NUMBER    Set frames per second (default: 24)"
        echo "  -s/--scale=NUMBER  Set width in pixels (default: 720)"
        return 1
    end

    # Two args with a .gif second arg = explicit output name; otherwise every arg is an input
    if test (count $argv) -eq 2; and string match -qr '\.gif$' $argv[2]
        set -l input $argv[1]
        set -l output $argv[2]
        echo "Converting $input to $output with fps=$fps and scale=$scale..."
        ffmpeg -i $input -vf "fps=$fps,scale=$scale:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" $output
        return $status
    end

    set -l failed 0
    for input in $argv
        set -l output (string replace -r '\.[^.]+$' '.gif' $input)
        echo "Converting $input to $output with fps=$fps and scale=$scale..."
        ffmpeg -i $input -vf "fps=$fps,scale=$scale:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" $output
        or set failed (math $failed + 1)
    end

    if test $failed -gt 0
        echo "$failed file(s) failed to convert"
        return 1
    end
end

function ta
  if test -n "$TMUX"
    echo "Already inside a tmux session"
    return 1
  end
  # 붙을 세션이 있으면 그대로 붙는다 (가장 최근 세션).
  tmux attach
  and return

  # 여기 도달 = 서버가 없거나 붙을 세션이 없음.
  # 예전에는 `tmux new-session $argv` 였는데 -s 가 없어서 익명 세션(0,1,2…)이
  # 생겼다. 서버가 죽으면 붙어있던 클라이언트들의 attach 가 "server exited
  # unexpectedly" 로 동시에 실패하면서 전부 이 경로를 타고, 이름 없는 세션이
  # 우수수 생겨 원래 세션 이름·경로가 통째로 사라진다 (2026-08-15 사고).
  # -A: 그 레이스에서 다른 클라이언트가 main 을 이미 만들었으면 새로 만드는 대신
  #     붙는다. 없으면 "duplicate session: main" 으로 실패해 빈손이 된다.
  if test (count $argv) -gt 0
    tmux new-session $argv
  else
    tmux new-session -A -s main
  end
end

# ta + prefix+f + cl: main 세션에 현재 디렉터리로 새 창을 만들고 거기서 cl 을 띄운 뒤 붙는다.
# 인자는 cl 로 그대로 넘어간다 (taa -c → cl -c).
# send-keys 는 tmux 가 pty 에 버퍼링해 두므로 셸이 뜨기 전에 보내도 셸이 읽는다.
function taa
  if test -n "$TMUX"
    echo "Already inside a tmux session"
    return 1
  end
  set -l win
  if tmux has-session -t '=main' 2>/dev/null
    set win (tmux new-window -P -F '#{window_id}' -t '=main:' -c $PWD)
  else
    set win (tmux new-session -d -P -F '#{window_id}' -s main -c $PWD)
  end
  or return
  tmux send-keys -t $win (string join -- ' ' cl (string escape -- $argv)) Enter
  tmux attach -t '=main'
end

alias tx 'tmux detach'
alias av 'aven tui'

if test "$TERM_PROGRAM" = "kiro"; and command -q kiro
    . (kiro --locate-shell-integration-path fish)
end


# >>> grok installer >>>
fish_add_path $HOME/.grok/bin
# <<< grok installer <<<

if command -qs grok
    alias gk "grok --always-approve"
    alias gkp "grok --always-approve -p"
end
