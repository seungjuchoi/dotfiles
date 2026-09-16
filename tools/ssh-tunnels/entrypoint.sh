#!/bin/sh

MONITOR_PORT=20100

# SSH 키 디렉터리는 /ssh-src 에 read-only 로 마운트된다 (docker-compose.yml).
# 권한을 강제하려면 쓰기 가능한 복사본이 필요하므로 /root/.ssh 로 복사한다.
SSH_SRC=/ssh-src
if [ ! -d "$SSH_SRC" ]; then
  echo "SSH key directory not mounted at $SSH_SRC" >&2
  exit 1
fi
rm -rf /root/.ssh
mkdir -p /root/.ssh
cp -R "$SSH_SRC"/. /root/.ssh/
chmod 700 /root/.ssh
chmod 600 /root/.ssh/*
chmod 644 /root/.ssh/*.pub 2>/dev/null

# 컨테이너 내부의 0.0.0.0 바인딩은 docker 포트 매핑에 필요하다.
# 외부 노출 범위는 docker-compose.override.yml 의 ports 에서
# "127.0.0.1:PORT:PORT" 로 제한한다.

echo "$SSH_TUNNELS" | while IFS= read -r tunnel; do
  [[ -z "$tunnel" || "$tunnel" =~ ^[[:space:]]*# ]] && continue
  tunnel="${tunnel%%#*}"
  tunnel="$(echo "$tunnel" | xargs)"

  TYPE=$(echo "$tunnel" | cut -d':' -f1)
  LOCAL_PORT=$(echo "$tunnel" | cut -d':' -f2)

  case "$TYPE" in
    L|R)
      DESTINATION_HOST=$(echo "$tunnel" | cut -d':' -f3)
      DESTINATION_PORT=$(echo "$tunnel" | cut -d':' -f4)
      SSH_HOST=$(echo "$tunnel" | cut -d':' -f5)
      ;;
    D)
      DESTINATION_HOST=""
      DESTINATION_PORT=""
      SSH_HOST=$(echo "$tunnel" | cut -d':' -f3)
      ;;
    *)
      echo "Unsupported tunnel type: $TYPE"
      continue
      ;;
  esac

  echo "Configuring tunnel type: $TYPE, ports: $LOCAL_PORT -> $DESTINATION_HOST:$DESTINATION_PORT, via: $SSH_HOST"

  case "$TYPE" in
    L) # Local port forwarding
      autossh -M "$MONITOR_PORT" -N -L "0.0.0.0:${LOCAL_PORT}:${DESTINATION_HOST}:${DESTINATION_PORT}" "${SSH_HOST}" &
      echo ">> Local port forwarding Done"
      ;;
    R) # Remote port forwarding
      autossh -M "$MONITOR_PORT" -N -R "${LOCAL_PORT}:${DESTINATION_HOST}:${DESTINATION_PORT}" "${SSH_HOST}" &
      echo ">> Remote port forwarding Done"
      ;;
    D) # Dynamic port forwarding (SOCKS)
      autossh -M "$MONITOR_PORT" -N -D "0.0.0.0:${LOCAL_PORT}" "${SSH_HOST}" &
      echo ">> Dynamic port forwarding Done"
      ;;
  esac
  MONITOR_PORT=$((MONITOR_PORT + 2))
done

tail -f /dev/null
