#!/bin/bash
# croswire.sh
# PulseAudio output normalizatiom
# Designed for ChromeOS Crostini
# by shadowed1
TARGET_VOLUME="100%"
CHECK_INTERVAL=5
LAST_SINK=""
apply_volume() {
    if ! pactl info >/dev/null 2>&1; then
        return
    fi
    SINK=$(pactl get-default-sink 2>/dev/null)
    if [[ -z "$SINK" ]]; then
        SINK=$(pactl list short sinks 2>/dev/null | awk 'NR==1 {print $1}')
    fi
    [[ -z "$SINK" ]] && return
    pactl set-sink-volume "$SINK" "$TARGET_VOLUME" >/dev/null 2>&1
    if [[ "$SINK" != "$LAST_SINK" ]]; then
        LAST_SINK="$SINK"
        echo "Using sink: $SINK"
    fi
}
sleep 2
apply_volume
pactl subscribe 2>/dev/null | while read -r line; do
    case "$line" in
        *"on sink"*|*"on server"*)
            sleep 0.25
            apply_volume
            ;;
    esac
done &
while true; do
    apply_volume
    sleep "$CHECK_INTERVAL"
done
