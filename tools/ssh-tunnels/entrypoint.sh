#!/bin/sh

MONITOR_PORT=20100

chmod 700 /root/.ssh
chmod 600 /root/.ssh/*
chmod 644 /root/.ssh/*.pub

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
