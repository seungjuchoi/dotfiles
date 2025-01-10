#!/bin/sh

MONITOR_PORT=20000

echo "$SSH_TUNNELS" | while IFS= read -r tunnel; do
  [[ -z "$tunnel" || "$tunnel" =~ ^[[:space:]]*# ]] && continue
  tunnel="${tunnel%%#*}"
  tunnel="$(echo "$tunnel" | xargs)"

  TYPE=$(echo "$tunnel" | cut -d':' -f1)
  LOCAL_PORT=$(echo "$tunnel" | cut -d':' -f2)
  DESTINATION_HOST=$(echo "$tunnel" | cut -d':' -f3)
  DESTINATION_PORT=$(echo "$tunnel" | cut -d':' -f4)
  SSH_HOST=$(echo "$tunnel" | cut -d':' -f5)

  echo "Configuring tunnel type: $TYPE, ports: $LOCAL_PORT -> $DESTINATION_HOST:$DESTINATION_PORT, via: $SSH_HOST"

  case "$TYPE" in
    L) # Local port forwarding
      autossh -M "$MONITOR_PORT" -N -L "${LOCAL_PORT}:${DESTINATION_HOST}:${DESTINATION_PORT}" "${SSH_HOST}" &
      ;;
    R) # Remote port forwarding
      autossh -M "$MONITOR_PORT" -N -R "${LOCAL_PORT}:${DESTINATION_HOST}:${DESTINATION_PORT}" "${SSH_HOST}" &
      ;;
    D) # Dynamic port forwarding (SOCKS)
      autossh -M "$MONITOR_PORT" -N -D "${LOCAL_PORT}" "${SSH_HOST}" &
      ;;
    *)
      echo "Unsupported tunnel type: $TYPE"
      ;;
  esac
  MONITOR_PORT=$((MONITOR_PORT + 2))
done

tail -f /dev/null
