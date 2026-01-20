#!/bin/sh
# 通用函数库 v3.0 Pro

LOG_DIR="/var/log/network_scripts"
STATE_FILE="/tmp/network_scripts_state.json"
LOG_MAX_LINES=500

get_log_level_num() {
    case "$1" in
        debug) echo 0 ;;
        info)  echo 1 ;;
        warn)  echo 2 ;;
        error) echo 3 ;;
        *)     echo 1 ;;
    esac
}

log_msg() {
    local msg="$1"
    local level="${2:-info}"
    local log_file="${3:-$LOG_DIR/network_switch.log}"
    
    [ -d "$LOG_DIR" ] || mkdir -p "$LOG_DIR"
    
    # 使用 logger 写入系统日志
    logger -t "network_scripts" -p user.$level "$msg"
    
    local configured_level=$(uci -q get network_scripts.network_switch.log_level 2>/dev/null)
    configured_level=${configured_level:-info}
    
    local msg_level_num=$(get_log_level_num "$level")
    local cfg_level_num=$(get_log_level_num "$configured_level")
    
    [ "$msg_level_num" -lt "$cfg_level_num" ] && return 0
    
    if [ -f "$log_file" ]; then
        local lines=$(wc -l < "$log_file" 2>/dev/null || echo 0)
        if [ "$lines" -gt "$LOG_MAX_LINES" ]; then
            mv "$log_file" "${log_file}.old"
        fi
    fi
    
    local level_tag=$(echo "$level" | tr 'a-z' 'A-Z')
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$level_tag] $msg" >> "$log_file"
}

update_state_json() {
    local tmp_file="${STATE_FILE}.tmp"
    # 使用 cat 写入，避免特殊字符问题
    cat > "$tmp_file" <<EOF
{
  "gateway": "${1:-}",
  "device": "${2:-}",
  "internet": "${3:-offline}",
  "lock_mode": "${4:-off}",
  "auth_status": "${5:-unknown}",
  "mode": "${6:-unknown}",
  "updated_at": $(date +%s),
  "quality": {
    "broadband": ${7:-{}},
    "cpe": ${8:-{}}
  }
}
EOF
    mv "$tmp_file" "$STATE_FILE"
}

get_config() {
    local section="$1"
    local key="$2"
    local default="$3"
    local val=$(uci -q get network_scripts.${section}.${key} 2>/dev/null)
    [ -z "$val" ] && echo "$default" || echo "$val"
}

set_config() {
    uci -q set network_scripts.$1.$2="$3"
    uci commit network_scripts
}

get_interface_device() {
    local iface="$1"
    local dev=$(uci -q get network.${iface}.device 2>/dev/null)
    [ -z "$dev" ] && dev=$(ifstatus "$iface" 2>/dev/null | jsonfilter -e '@["l3_device"]' 2>/dev/null)
    [ -z "$dev" ] && dev="$iface"
    echo "$dev"
}

get_interface_ip() {
    ip -4 addr show "$1" 2>/dev/null | grep inet | awk '{print $2}' | cut -d/ -f1 | head -n 1
}

get_interface_mac() {
    cat /sys/class/net/$1/address 2>/dev/null | tr 'a-f' 'A-F'
}

check_captive_portal() {
    local iface="$1"
    local test_url="http://connect.rom.miui.com/generate_204"
    local result=$(curl -s -o /dev/null -w "%{http_code}" --interface "$iface" --connect-timeout 5 --max-time 10 "$test_url" 2>/dev/null)
    
    if [ "$result" = "204" ]; then
        return 0
    elif [ "$result" = "302" ] || [ "$result" = "301" ] || [ "$result" = "200" ]; then
        return 1
    else
        return 2
    fi
}

send_dingtalk() {
    local title="$1"
    local content="$2"
    
    local enabled=$(get_config "notification" "enabled" "0")
    [ "$enabled" != "1" ] && return 0
    
    local webhook=$(get_config "notification" "dingtalk_webhook" "")
    local secret=$(get_config "notification" "dingtalk_secret" "")
    [ -z "$webhook" ] && return 1
    
    local timestamp=$(date +%s%3N)
    local sign=""
    
    if [ -n "$secret" ]; then
        local string_to_sign="${timestamp}\n${secret}"
        sign=$(echo -ne "$string_to_sign" | openssl dgst -sha256 -hmac "$secret" -binary | base64 | sed 's/+/%2B/g; s/\//%2F/g; s/=/%3D/g')
        webhook="${webhook}&timestamp=${timestamp}&sign=${sign}"
    fi
    
    local hostname=$(uci -q get system.@system[0].hostname 2>/dev/null || echo "OpenWrt")
    local full_content="**设备**: ${hostname}\n**时间**: $(date '+%Y-%m-%d %H:%M:%S')\n\n${content}"
    local json_data="{\"msgtype\":\"markdown\",\"markdown\":{\"title\":\"${title}\",\"text\":\"## ${title}\n\n${full_content}\"}}"
    
    curl -s -X POST "$webhook" -H "Content-Type: application/json" -d "$json_data" >/dev/null 2>&1 &
}

record_history() {
    local event_type="$1"
    local detail="$2"
    local status="${3:-success}"
    local history_file="$LOG_DIR/history.log"
    
    [ -d "$LOG_DIR" ] || mkdir -p "$LOG_DIR"
    
    if [ -f "$history_file" ]; then
        local lines=$(wc -l < "$history_file" 2>/dev/null || echo 0)
        if [ "$lines" -gt 500 ]; then
            tail -n 300 "$history_file" > "${history_file}.tmp" && mv "${history_file}.tmp" "$history_file"
        fi
    fi
    echo "$(date '+%Y-%m-%d %H:%M:%S')|${event_type}|${status}|${detail}" >> "$history_file"
}

get_statistics() {
    local history_file="$LOG_DIR/history.log"
    local period="${1:-today}"
    [ ! -f "$history_file" ] && echo "{}" && return
    
    local date_filter=""
    case "$period" in
        today) date_filter=$(date '+%Y-%m-%d') ;;
        week)  date_filter=$(date -d '7 days ago' '+%Y-%m-%d' 2>/dev/null || date '+%Y-%m-%d') ;;
        month) date_filter=$(date '+%Y-%m') ;;
        all)   date_filter="" ;;
    esac
    
    local total=0 success=0 fail=0 auth_count=0 switch_count=0
    
    while IFS='|' read -r timestamp event status detail; do
        [ -n "$date_filter" ] && ! echo "$timestamp" | grep -q "$date_filter" && continue
        total=$((total + 1))
        [ "$status" = "success" ] && success=$((success + 1))
        [ "$status" = "fail" ] && fail=$((fail + 1))
        [ "$event" = "auth" ] && auth_count=$((auth_count + 1))
        [ "$event" = "switch" ] && switch_count=$((switch_count + 1))
    done < "$history_file"
    
    local success_rate=0
    [ $total -gt 0 ] && success_rate=$((success * 100 / total))
    echo "{\"total\":$total,\"success\":$success,\"fail\":$fail,\"auth\":$auth_count,\"switch\":$switch_count,\"success_rate\":$success_rate}"
}