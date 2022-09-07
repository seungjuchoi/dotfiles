if status is-interactive
    # Commands to run in interactive sessions can go here
    set fish_greeting ""
    alias vi nvim
    function ll
        command exa --group-directories-first -l --icons
    end
    function lla
        command exa --group-directories-first -l --icons -a
    end
    function lg
        command lazygit
    end

    set -gx ICLOUD_PATH /Users/(whoami)/Library/Mobile\ Documents/com~apple~CloudDocs
end

