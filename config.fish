if status is-interactive
    # Commands to run in interactive sessions can go here
    set fish_greeting ""
    if command -qs nvim
        alias vi nvim
        alias vim nvim
        set -gx EDITOR nvim
    end

    if command -qs exa
        alias ll "exa --group-directories-first -l --icons $argv"
        alias lla "exa --group-directories-first -l --icons -a $argv"
    end
    if command -qs lazygit
        alias lg lazygit $argv
    end
    set -gx ICLOUD_PATH /Users/(whoami)/Library/Mobile\ Documents/com~apple~CloudDocs
    if test -d /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib
        set -gx LIBRARY_PATH "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib"
    end
    set LOCAL_CONFIG (dirname (status --current-filename))/config_local.fish
    if test -f $LOCAL_CONFIG
      source $LOCAL_CONFIG
    end
end
if test -d /opt/homebrew/opt/llvm
    set -gx LDFLAGS "-L/opt/homebrew/opt/llvm/lib"
    set -gx CPPFLAGS "-I/opt/homebrew/opt/llvm/include"
end
if test -d /opt/homebrew/opt/libpq
   set -gx LDFLAGS $LDFLAGS "-L/opt/homebrew/opt/libpq/lib"
   set -gx CPPFLAGS $CPPFLAGS "-I/opt/homebrew/opt/libpq/include"
end
