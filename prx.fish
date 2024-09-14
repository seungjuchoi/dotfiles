function prx
    if test (count $argv) -eq 1
        set port $argv[1]
        set -gx http_proxy socks5h://127.0.0.1:$port
        set -gx https_proxy socks5h://127.0.0.1:$port
        set -gx no_proxy 127.0.0.1,localhost
        echo "Proxy set to 127.0.0.1:$port"
    else
        echo "Usage: prx <port>"
    end
end
