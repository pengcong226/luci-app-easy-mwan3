#!/bin/sh
. /usr/lib/network_scripts/common.sh

check_auth_status() {
    local iface="${1:-wan}"
    if ! ping -c 1 -W 2 -I "$iface" 223.5.5.5 >/dev/null 2>&1; then
        local gw=$(ip route | grep "$iface" | grep default | awk '{print $3}' | head -1)
        if [ -n "$gw" ] && ping -c 1 -W 2 "$gw" >/dev/null 2>&1; then
            echo "need_auth"
            return 1
        else
            echo "offline"
            return 2
        fi
    fi
    
    check_captive_portal "$iface"
    local portal_status=$?
    case $portal_status in
        0) echo "authenticated"; return 0 ;;
        1) echo "need_auth"; return 1 ;;
        *) echo "unknown"; return 3 ;;
    esac
}

get_last_auth_time() {
    local history_file="$LOG_DIR/history.log"
    [ ! -f "$history_file" ] && echo "未知" && return
    local last_auth=$(grep "|auth|success|" "$history_file" 2>/dev/null | tail -1 | cut -d'|' -f1)
    [ -n "$last_auth" ] && echo "$last_auth" || echo "未知"
}