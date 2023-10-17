set fish_greeting ""
set -gx MANPAGER "less -I"
if command -qs nvim
    alias vi nvim
    alias vim nvim
    set -gx EDITOR nvim
end
if command -qs ipython
    alias ipy ipython
end
if command -qs yazi
    alias ya yazi
end
if command -qs eza
    alias ll "eza -l --hyperlink --sort modified --icons --git"
    alias lla "eza -l -a --hyperlink --sort modified --icons --git"
else if command -qs lsd
    alias ll "lsd --group-directories-first -l --hyperlink auto -g"
    alias lla "lsd --group-directories-first -l --hyperlink auto -g -a"
else if command -qs exa
        alias ll "exa --group-directories-first -l --icons $argv"
        alias lla "exa --group-directories-first -l --icons -a $argv"
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
set -gx ICLOUD_PATH /Users/(whoami)/Library/Mobile\ Documents/com~apple~CloudDocs
set -gx OBSIDIAN_PATH /Users/(whoami)/Library/Mobile\ Documents/iCloud~md~obsidian/Documents
if test -d /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib
    set -gx LIBRARY_PATH "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib"
end
set LOCAL_FISH_CONF (dirname (status --current-filename))/config_local.fish
if test -f $LOCAL_FISH_CONF
    source $LOCAL_FISH_CONF
end
if test -d /opt/homebrew/opt/llvm
    set -gx LDFLAGS "-L/opt/homebrew/opt/llvm/lib"
    set -gx CPPFLAGS "-I/opt/homebrew/opt/llvm/include"
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

function _vf_install_essentials --on-event virtualenv_did_create
    echo Install Essential Packages..
    pip install -U pip
    pip install pynvim ipython matplotlib
end
