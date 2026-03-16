function prxh
    if test (count $argv) -eq 1
        if test $argv[1] = "off"
            set -e http_proxy
            set -e https_proxy
            set -e no_proxy
            echo "Proxy settings have been removed."
        else
            set port $argv[1]
            set -gx http_proxy http://127.0.0.1:$port
            set -gx https_proxy http://127.0.0.1:$port
            set -gx no_proxy 127.0.0.1,localhost
            echo "Proxy set to 127.0.0.1:$port"
        end
    else
        echo "Usage: prxh <port> or prxh off"
    end
end
