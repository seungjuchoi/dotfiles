set fish_greeting ""
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
    alias ya "WEZTERM_EXECUTABLE=1 yazi"
end
if command -qs lazygit
    alias lg lazygit $argv
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
if command -qs atuin
    atuin init fish | source
end

set -gx ICLOUD_PATH /Users/(whoami)/Library/Mobile\ Documents/com~apple~CloudDocs
set -gx OBSIDIAN_PATH /Users/(whoami)/Library/Mobile\ Documents/iCloud~md~obsidian/Documents
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
end

# python
set -gx PYTHONBREAKPOINT "ipdb.set_trace"

function pipi
    if test (count $argv) -eq 0
        echo "Error: No package provided. Please provide at least one package to install."
        return 1
    end
    for pkg in $argv
        set pkg_name (string split "=" $pkg)[1]
        set pkg_version (string split "=" $pkg)[2]
        if test -n "$VIRTUAL_ENV"
            if not test -e requirements.txt
                touch requirements.txt
            end
            if not grep -iq $pkg_name requirements.txt
                echo "Installing and adding $pkg to requirements.txt"
                pip install $pkg_name
                and pip freeze | grep -i $pkg_name >> requirements.txt
            else
                set installed_version (pip freeze | grep -i $pkg_name | string split "=")[2]
                if test "$installed_version" != "$pkg_version"
                    echo "Updating $pkg in requirements.txt"
                    pip install $pkg_name
                    and sed -i "/$pkg_name/d" requirements.txt
                    and pip freeze | grep -i $pkg_name >> requirements.txt
                else
                    echo "Package $pkg is already in requirements.txt with the same version"
                end
            end
        else
            echo "Not in a virtual environment. Installing $pkg without updating requirements.txt"
            pip install $pkg
        end
    end
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

if status is-login; and not set -q TMUX; and type -q tmux
    tmux attach || tmux new-session
end

