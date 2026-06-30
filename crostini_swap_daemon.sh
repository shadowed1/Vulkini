#!/bin/bash

# crostini_swap_daemon
# for crosvm
# by shadowed1

RED=$'\033[31m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
BLUE=$'\033[34m'
MAGENTA=$'\033[35m'
CYAN=$'\033[36m'
BOLD=$'\033[1m'
RESET=$'\033[0m'
SWAPFILE="/swapfile"
SERVICE_NAME="crostini-swap-daemon"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
INSTALL_PATH="/bin/crostini_swap_daemon"
SAFETY_MARGIN_MB=1024

detect_ram_mb() {
    awk '/MemTotal/ {printf "%d", $2/1024}' /proc/meminfo
}

current_swap_mb() {
    if [ -f "$SWAPFILE" ]; then
        local bytes
        bytes=$(stat -c %s "$SWAPFILE" 2>/dev/null || echo 0)
        echo $(( bytes / 1048576 ))
    else
        echo 0
    fi
}

clean_size() {
    awk -v m="$1" 'BEGIN {
        g = m / 1024
        if (g == int(g)) printf "%dG", g
        else printf "%.1fG", g
    }'
}

mb_from_arg() {
    local val="$1"
    if [[ "$val" =~ ^([0-9]+(\.[0-9]+)?)([GgMm]?)$ ]]; then
        local num="${BASH_REMATCH[1]}"
        local unit="${BASH_REMATCH[3],,}"
        if [ "$unit" = "m" ]; then
            awk -v n="$num" 'BEGIN{printf "%d", n}'
        else
            awk -v n="$num" 'BEGIN{printf "%d", n*1024}'
        fi
    fi
}

avail_mb() {
    df --output=avail -B1M "$(dirname "$SWAPFILE")" 2>/dev/null | tail -n1 | tr -d ' '
}

apply_swap() {
    local size_mb="$1"
    if ! [[ "$size_mb" =~ ^[0-9]+$ ]] || [ "$size_mb" -le 0 ]; then
        echo "${RED}${BOLD}[crostini_swap_daemon] ERROR:${RESET} invalid swap size '${size_mb}'"
        exit 1
    fi

    # drop the old swapfile first so its space counts as free
    sudo /usr/sbin/swapoff "$SWAPFILE" 2>/dev/null
    sudo rm -f "$SWAPFILE" 2>/dev/null

    local free_mb cap_mb
    free_mb=$(avail_mb)

    if [[ "$free_mb" =~ ^[0-9]+$ ]]; then
        cap_mb=$(( free_mb - SAFETY_MARGIN_MB ))

        if [ "$cap_mb" -le 0 ]; then
            echo "${RED}${BOLD}[crostini_swap_daemon] ERROR:${RESET} only $(clean_size "$free_mb") free, not enough to safely create swap"
            exit 1
        fi

        if [ "$size_mb" -gt "$cap_mb" ]; then
            echo "${YELLOW}[crostini_swap_daemon] requested $(clean_size "$size_mb") exceeds free space, limiting to ${BOLD}$(clean_size "$cap_mb")${RESET}${YELLOW} - Free up additional space! ${RESET}"
            size_mb="$cap_mb"
        fi
    else
        echo "${YELLOW}[crostini_swap_daemon] WARNING:${RESET} could not determine free space, skipping size check"
    fi

    echo "${CYAN}[crostini_swap_daemon] target swap size: ${BOLD}$(clean_size "$size_mb")${RESET}"

    sudo touch "$SWAPFILE"
    sudo chattr +C "$SWAPFILE" 2>/dev/null

    if ! sudo fallocate -l "${size_mb}M" "$SWAPFILE"; then
        echo "${RED}${BOLD}[crostini_swap_daemon] ERROR:${RESET} fallocate failed, aborting"
        sudo rm -f "$SWAPFILE"
        exit 1
    fi

    sudo chmod 600 "$SWAPFILE"

    if ! sudo mkswap "$SWAPFILE" > /dev/null; then
        echo "${RED}${BOLD}[crostini_swap_daemon] ERROR:${RESET} mkswap failed, aborting"
        sudo rm -f "$SWAPFILE"
        exit 1
    fi

    if ! sudo /usr/sbin/swapon "$SWAPFILE"; then
        echo "${RED}${BOLD}[crostini_swap_daemon] ERROR:${RESET} swapon failed, aborting"
        sudo rm -f "$SWAPFILE"
        exit 1
    fi

    local active
    active=$(swapon --show=NAME,SIZE --noheadings "$SWAPFILE" 2>/dev/null)
    echo "${GREEN}[crostini_swap_daemon] swap active:${BOLD} ${active:-$SWAPFILE}"
    echo
}

cmd_default() {
    local ram_mb swap_mb
    ram_mb=$(detect_ram_mb)
    swap_mb=$(( ram_mb * 2 ))
    echo
    echo "${BLUE}[crostini_swap_daemon] detected RAM: ${BOLD}$(clean_size "$ram_mb")${RESET}"
    apply_swap "$swap_mb"
}

cmd_set() {
    local requested_mb
    requested_mb=$(mb_from_arg "$1")
    if [ -z "$requested_mb" ]; then
        echo "${RED}${BOLD}[crostini_swap_daemon] ERROR:${RESET} invalid size '$1' (use e.g. 8, 8G, 6.5G, 13312M)"
        exit 1
    fi
    apply_swap "$requested_mb"
}

cmd_status() {
    echo "${CYAN}[crostini_swap_daemon] current swapfile size: ${BOLD}$(clean_size "$(current_swap_mb)")${RESET}"
    swapon --show 2>/dev/null
}

cmd_startup() {
    printf "${CYAN}${BOLD}Enable swap daemon to boot with Crostini? [Y/n]: ${RESET}"
    read -r answer
    case "${answer,,}" in
        ""|y|yes) _startup_enable ;;
        n|no)     _startup_disable ;;
        *) echo "${RED}No changes made.${RESET}"; exit 1 ;;
    esac
}

_startup_enable() {
    if [ "$0" != "$INSTALL_PATH" ] && [ ! -f "$INSTALL_PATH" ]; then
        echo "${YELLOW}[crostini_swap_daemon] installing self to ${INSTALL_PATH}...${RESET}"
        sudo cp "$0" "$INSTALL_PATH"
        sudo chmod +x "$INSTALL_PATH"
    fi
    echo "${CYAN}Installing systemd service...${RESET}"
    sudo tee "$SERVICE_FILE" > /dev/null << SERVICE_EOF
[Unit]
Description=Crostini Swap Daemon
After=local-fs.target systemd-tmpfiles-setup.service
[Service]
Type=oneshot
ExecStart=${INSTALL_PATH}
RemainAfterExit=yes
[Install]
WantedBy=multi-user.target
SERVICE_EOF
    sudo systemctl daemon-reload
    sudo systemctl enable "$SERVICE_NAME"
    sudo systemctl start $SERVICE_NAME 2>/dev/null
    echo "${GREEN}${BOLD}Startup enabled.${RESET}"
    echo
}

_startup_disable() {
    sudo systemctl stop "$SERVICE_NAME" 2>/dev/null || true
    sudo systemctl disable "$SERVICE_NAME" 2>/dev/null || true
    sudo rm -f "$SERVICE_FILE"
    sudo systemctl daemon-reload 2>/dev/null || true
    echo "${YELLOW}Startup disabled.${RESET}"
    echo
}

case "${1:-}" in
    startup) cmd_startup ;;
    status)  cmd_status ;;
    "")      cmd_default ;;
    *)       cmd_set "$1" ;;
esac
