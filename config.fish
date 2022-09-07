if status is-interactive
    # Commands to run in interactive sessions can go here
    set fish_greeting ""
    command -qs nvim && alias vi nvim
    if command -qs exa
        alias ll "exa --group-directories-first -l --icons"
        alias lla "exa --group-directories-first -l --icons -a"
    end
    if command -qs lazygit
        alias lg lazygit
    end
    alias min "open -a min"
    set -gx ICLOUD_PATH /Users/(whoami)/Library/Mobile\ Documents/com~apple~CloudDocs
end
