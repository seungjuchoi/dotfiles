function prx
    if test (count $argv) -eq 1
        if test $argv[1] = "off"
            set -e http_proxy
            set -e https_proxy
            set -e no_proxy
            echo "Proxy settings have been removed."
        else
            set port $argv[1]
            set -gx http_proxy socks5h://127.0.0.1:$port
            set -gx https_proxy socks5h://127.0.0.1:$port
            set -gx no_proxy 127.0.0.1,localhost
            echo "Proxy set to 127.0.0.1:$port"
        end
    else
        echo "Usage: prx <port> or prx off"
    end
end
