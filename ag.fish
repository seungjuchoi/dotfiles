function ag --description "add-agent: tmux main 세션에 window를 추가해 agent를 실행하고 그 창으로 이동"
    argparse -s h/help d/dir= s/session= n/no-switch k/keep -- $argv
    or return 1

    set -l default_agent cl
    set -q ag_default_agent; and set default_agent $ag_default_agent

    set -l session main
    set -q ag_session; and set session $ag_session
    set -q _flag_session; and set session $_flag_session

    if set -q _flag_help
        echo "사용법: ag [옵션] [agent] [프롬프트...]"
        echo ""
        echo "  tmux '$session' 세션(없으면 생성)에 새 window를 만들어 agent를 띄우고"
        echo "  그 창으로 focus를 옮긴다. tmux 밖에서 실행하면 세션에 attach 한다."
        echo "  tmux 안에서 실행했다면 ag 를 입력한 pane 은 focus 이동 후 정리한다."
        echo ""
        echo "옵션:"
        echo "  -d, --dir DIR     작업 디렉터리 지정 (기본: 현재 폴더, \$HOME이면 z tz)"
        echo "  -s, --session S   대상 tmux 세션 (기본: main)"
        echo "  -n, --no-switch   window만 만들고 이동하지 않음 (호출 pane 유지)"
        echo "  -k, --keep        호출 pane 을 지우지 않음"
        echo "  -h, --help        도움말"
        echo ""
        echo "예시:"
        echo "  ag                       # $default_agent 실행"
        echo "  ag cl 오늘 날씨 어때?    # cl \"오늘 날씨 어때?\""
        echo "  ag co 이 버그 고쳐줘     # codex 로"
        echo "  ag 이거 리뷰해줘         # agent 생략 → $default_agent"
        echo "  ag cl -c 이어서 얘기해   # 앞쪽 -flag 는 agent 에 그대로 전달"
        echo ""
        echo "설정 변수: ag_default_agent, ag_session, ag_agents(추가 agent 목록)"
        return 0
    end

    if not type -q tmux
        echo "ag: tmux 가 필요합니다." >&2
        return 1
    end

    # ── agent / 프롬프트 분리 ────────────────────────────────────────────
    set -l agents cl clp co cop ge gep cr crp kr krp op opp pi pix gk gkp oc \
        claude codex gemini crush opencode grok kiro-cli openclaw
    set -q ag_agents; and set -a agents $ag_agents

    set -l agent $default_agent
    set -l prompt_words
    if test (count $argv) -gt 0
        if contains -- $argv[1] $agents
            set agent $argv[1]
            set prompt_words $argv[2..]
        else
            set prompt_words $argv
        end
    end

    # ── 작업 디렉터리 결정 ──────────────────────────────────────────────
    set -l dir
    if set -q _flag_dir
        set dir $_flag_dir
    else if test "$PWD" = "$HOME"; and type -q zoxide
        set dir (zoxide query tz 2>/dev/null)
    end
    test -z "$dir"; and set dir $PWD
    if not test -d "$dir"
        echo "ag: 디렉터리가 없습니다: $dir" >&2
        return 1
    end
    set dir (path resolve $dir)

    # ── 실행 명령 조립 ──────────────────────────────────────────────────
    # 앞쪽의 -flag 들은 agent 옵션으로 그대로 넘기고, 나머지 단어는 하나의
    # 프롬프트 인자로 묶는다. (예: ag cl -c 이어서 얘기해 → cl -c "이어서 얘기해")
    set -l agent_flags
    while test (count $prompt_words) -gt 0; and string match -qr '^-' -- $prompt_words[1]
        set -a agent_flags (string escape -- $prompt_words[1])
        set prompt_words $prompt_words[2..]
    end

    # 새 window 에서 실행할 fish 명령 만들기.
    # fish -i -C: config.fish 를 읽은 뒤(=cl/co 같은 함수가 정의된 상태) 명령을 실행하고,
    # agent 가 종료돼도 window 는 프롬프트가 남은 채 살아있다.
    set -l inner (string join " " -- $agent $agent_flags)
    if test (count $prompt_words) -gt 0
        set inner "$inner "(string escape -- (string join " " -- $prompt_words))
    end
    set -l shcmd "fish -i -C '"(string replace -a "'" "'\\''" -- $inner)"'"

    # ── 세션 확보 + window 생성 ─────────────────────────────────────────
    # window 이름은 지정하지 않는다 → tmux 의 automatic-rename
    # (automatic-rename-format "#{b:pane_current_path}") 이 살아있어서
    # 창 안에서 디렉터리를 옮기면 이름도 따라간다.
    set -l target
    if tmux has-session -t "=$session" 2>/dev/null
        set target (tmux new-window -d -P -F '#{window_id}' -t "=$session:" -c $dir $shcmd)
        or return 1
    else
        tmux new-session -d -s $session -c $dir $shcmd
        or return 1
        set target (tmux display-message -p -t "=$session:" '#{window_id}')
    end

    # ── focus 이동 ──────────────────────────────────────────────────────
    if set -q _flag_no_switch
        echo "ag: $session 세션에 window 생성 → $agent @ $dir ($target)"
        return 0
    end

    if set -q TMUX
        # 붙어있는 client 가 없는(detached) 세션에서 호출된 경우 대비
        tmux switch-client -t $target 2>/dev/null
        or tmux select-window -t $target

        # ag 를 입력한 pane 은 더 쓸 일이 없으므로 정리한다.
        # kill-pane 이 이 함수를 실행 중인 fish 를 SIGHUP 으로 끝내므로
        # 반드시 focus 이동 뒤 마지막 줄이어야 한다.
        # tmux 밖(=터미널 최상위 셸)에서는 절대 하지 않는다.
        if not set -q _flag_keep
            tmux kill-pane -t $TMUX_PANE
        end
    else
        tmux select-window -t $target
        tmux attach-session -t "=$session"
    end
end
