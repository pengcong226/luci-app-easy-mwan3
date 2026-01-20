#!/bin/sh
. /usr/lib/network_scripts/common.sh
. /usr/lib/network_scripts/quality.sh
. /usr/lib/network_scripts/auth_status.sh

LOG_FILE="$LOG_DIR/network_switch.log"

load_config() {
    BROADBAND_INTERFACE=$(get_config "network_switch" "broadband_interface" "wan")
    BROADBAND_DEVICE=$(get_config "network_switch" "broadband_device" "")
    [ -z "$BROADBAND_DEVICE" ] && BROADBAND_DEVICE=$(get_interface_device "$BROADBAND_INTERFACE")
    
    CPE_INTERFACE=$(get_config "network_switch" "cpe_interface" "lan1")
    CPE_DEVICE=$(get_config "network_switch" "cpe_device" "")
    [ -z "$CPE_DEVICE" ] && CPE_DEVICE=$(get_interface_device "$CPE_INTERFACE")
    
    BROADBAND_GATEWAY=$(get_config "network_switch" "broadband_gateway" "")
    CPE_GATEWAY=$(get_config "network_switch" "cpe_gateway" "192.168.8.1")
    
    BROADBAND_START=$(get_config "network_switch" "broadband_start" "6")
    BROADBAND_END=$(get_config "network_switch" "broadband_end" "24")
    
    LOCK_MODE=$(get_config "network_switch" "lock_mode" "off")
    LOCK_UNTIL=$(get_config "network_switch" "lock_until" "0")
    QUALITY_CHECK=$(get_config "network_switch" "quality_check" "1")
    
    CHECK_INTERVAL=$(get_config "network_switch" "check_interval" "10")
}

check_lock_mode() {
    [ "$LOCK_MODE" = "off" ] && return 1
    local now=$(date +%s)
    if [ "$LOCK_UNTIL" != "0" ] && [ "$now" -ge "$LOCK_UNTIL" ]; then
        log_msg "锁定已过期，自动解锁" "info" "$LOG_FILE"
        set_config "network_switch" "lock_mode" "off"
        set_config "network_switch" "lock_until" "0"
        LOCK_MODE="off"
        return 1
    fi
    return 0
}

get_scheduled_line() {
    local hour=$(date +%H | sed 's/^0//')
    local schedules=$(uci show network_scripts 2>/dev/null | grep "=schedule" | cut -d. -f2 | cut -d= -f1)
    
    for sched in $schedules; do
        local enabled=$(uci -q get network_scripts.${sched}.enabled 2>/dev/null)
        [ "$enabled" != "1" ] && continue
        local start=$(uci -q get network_scripts.${sched}.start 2>/dev/null | sed 's/^0//')
        local end=$(uci -q get network_scripts.${sched}.end 2>/dev/null | sed 's/^0//')
        local use=$(uci -q get network_scripts.${sched}.use 2>/dev/null)
        
        [ -z "$start" ] || [ -z "$end" ] || [ -z "$use" ] && continue
        
        if [ "$start" -gt "$end" ]; then
            if [ "$hour" -ge "$start" ] || [ "$hour" -lt "$end" ]; then echo "$use"; return 0; fi
        else
            if [ "$hour" -ge "$start" ] && [ "$hour" -lt "$end" ]; then echo "$use"; return 0; fi
        fi
    done
    
    if [ "$hour" -ge "$BROADBAND_START" ] && [ "$hour" -lt "$BROADBAND_END" ]; then
        echo "broadband"
    else
        echo "cpe"
    fi
}

get_current_gateway() { ip route show default 2>/dev/null | head -1 | awk '{print $3}'; }
get_current_device() { ip route show default 2>/dev/null | head -1 | awk '{print $5}'; }

check_interface_available() {
    local iface="$1"; local dev="$2"
    if ! ping -c 1 -W 2 -I "$dev" 223.5.5.5 >/dev/null 2>&1; then return 1; fi
    if [ "$QUALITY_CHECK" = "1" ]; then
        if ! check_quality_threshold "$dev"; then return 1; fi
    fi
    return 0
}

do_switch() {
    local target_gw="$1"; local target_dev="$2"; local target_name="$3"
    local current_gw=$(get_current_gateway)
    [ "$current_gw" = "$target_gw" ] && return 0

    log_msg "🔄 路由切换: 目标 -> $target_name" "info" "$LOG_FILE"
    local retry=0
    while ip route del default 2>/dev/null; do
        retry=$((retry + 1)); [ $retry -gt 10 ] && break
    done
    
    if ip route add default via "$target_gw" dev "$target_dev" metric 100 2>/dev/null; then
        log_msg "✅ 切换成功！当前流量走: $target_name" "info" "$LOG_FILE"
        record_history "switch" "切换到 $target_name" "success"
        local notify_switch=$(get_config "notification" "notify_switch" "0")
        [ "$notify_switch" = "1" ] && send_dingtalk "🔄 网络切换" "已切换到 **${target_name}**\n\n网关: ${target_gw}"
        return 0
    else
        log_msg "❌ 路由设置失败" "error" "$LOG_FILE"
        record_history "switch" "切换到 $target_name 失败" "fail"
        return 1
    fi
}

silent_fix_broadband() {
    log_msg "🛠️ [后台维护] 正在尝试静默修复宽带..." "info" "$LOG_FILE"
    local auth_status=$(check_auth_status "$BROADBAND_DEVICE")
    
    if [ "$auth_status" = "need_auth" ] || [ "$auth_status" = "offline" ]; then
        log_msg "执行认证..." "info" "$LOG_FILE"
        if [ -x "/usr/lib/network_scripts/campus_auth.sh" ]; then
            /usr/lib/network_scripts/campus_auth.sh login >> "$LOG_FILE" 2>&1
            sleep 3
            if check_interface_available "$BROADBAND_INTERFACE" "$BROADBAND_DEVICE"; then
                log_msg "🎉 宽带恢复！" "info" "$LOG_FILE"
                return 0
            fi
        fi
    fi
    
    ifdown "$BROADBAND_INTERFACE" 2>/dev/null; sleep 2; ifup "$BROADBAND_INTERFACE" 2>/dev/null
    sleep 15
    if [ -x "/usr/lib/network_scripts/campus_auth.sh" ]; then
        /usr/lib/network_scripts/campus_auth.sh login >> "$LOG_FILE" 2>&1
        sleep 3
        if check_interface_available "$BROADBAND_INTERFACE" "$BROADBAND_DEVICE"; then
            log_msg "🎉 接口重启后恢复！" "info" "$LOG_FILE"
            return 0
        fi
    fi
    
    local notify_offline=$(get_config "notification" "notify_offline" "1")
    [ "$notify_offline" = "1" ] && send_dingtalk "⚠️ 宽带离线" "宽带修复失败，已切换到 CPE"
    
    local retry=0
    while ip route del default 2>/dev/null; do
        retry=$((retry + 1)); [ $retry -gt 10 ] && break
    done
    ip route add default via "$CPE_GATEWAY" dev "$CPE_DEVICE" metric 100 2>/dev/null
    return 1
}

get_quality_json() {
    local dev="$1"
    local r=$(check_network_quality "$dev")
    if [ "$r" = "fail" ]; then
        echo '{"status":"offline"}'
    else
        local lat=$(echo "$r" | cut -d: -f1)
        local loss=$(echo "$r" | cut -d: -f2)
        local score=$(evaluate_quality "$dev")
        echo "{\"latency\":$lat,\"loss\":$loss,\"score\":$score,\"status\":\"online\"}"
    fi
}

run_check_loop() {
    log_msg "🚀 网络智能切换守护进程启动 (v3.0 Pro)" "info" "$LOG_FILE"
    
    while true; do
        load_config
        
        # 1. 宽带网关探测
        if [ -z "$BROADBAND_GATEWAY" ]; then
            BROADBAND_GATEWAY=$(ip route 2>/dev/null | grep "$BROADBAND_DEVICE" | grep -v default | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -1)
            [ -z "$BROADBAND_GATEWAY" ] && BROADBAND_GATEWAY=$(ip route show default 2>/dev/null | grep "$BROADBAND_DEVICE" | awk '{print $3}')
        fi
        
        # 2. 执行切换逻辑
        local current_mode="unknown"
        if check_lock_mode; then
            if [ "$LOCK_MODE" = "broadband" ]; then
                ! check_interface_available "$BROADBAND_INTERFACE" "$BROADBAND_DEVICE" && silent_fix_broadband
                do_switch "$BROADBAND_GATEWAY" "$BROADBAND_DEVICE" "宽带(锁定)"
                current_mode="locked_broadband"
            elif [ "$LOCK_MODE" = "cpe" ]; then
                do_switch "$CPE_GATEWAY" "$CPE_DEVICE" "CPE(锁定)"
                current_mode="locked_cpe"
            fi
        else
            local target_line=$(get_scheduled_line)
            local current_dev=$(get_current_device)
            
            if [ "$target_line" = "broadband" ]; then
                if [ "$current_dev" = "$BROADBAND_DEVICE" ]; then
                    if ! check_interface_available "$BROADBAND_INTERFACE" "$BROADBAND_DEVICE"; then
                        log_msg "⚠️ 宽带异常，切换到 CPE..." "warn" "$LOG_FILE"
                        do_switch "$CPE_GATEWAY" "$CPE_DEVICE" "CPE"
                        current_mode="cpe (failover)"
                    else
                        current_mode="broadband"
                    fi
                else
                    if check_interface_available "$BROADBAND_INTERFACE" "$BROADBAND_DEVICE"; then
                        log_msg "⚡ 宽带可用，切回宽带..." "info" "$LOG_FILE"
                        do_switch "$BROADBAND_GATEWAY" "$BROADBAND_DEVICE" "宽带"
                        current_mode="broadband"
                    else
                        silent_fix_broadband && do_switch "$BROADBAND_GATEWAY" "$BROADBAND_DEVICE" "宽带"
                        [ $? -eq 0 ] && current_mode="broadband" || current_mode="cpe"
                    fi
                fi
            else
                [ -n "$CPE_GATEWAY" ] && do_switch "$CPE_GATEWAY" "$CPE_DEVICE" "CPE"
                current_mode="cpe (scheduled)"
            fi
        fi
        
        # 3. 搜集状态并写入内存文件
        local cur_gw=$(get_current_gateway)
        local cur_dev=$(get_current_device)
        local is_online="offline"
        ping -c 1 -W 2 223.5.5.5 >/dev/null 2>&1 && is_online="online"
        
        local auth_st="unknown"
        if [ "$cur_dev" = "$BROADBAND_DEVICE" ]; then
            auth_st=$(check_auth_status "$BROADBAND_DEVICE")
        fi
        
        local q_bb=$(get_quality_json "$BROADBAND_DEVICE")
        local q_cpe=$(get_quality_json "$CPE_DEVICE")
        
        update_state_json "$cur_gw" "$cur_dev" "$is_online" "$LOCK_MODE" "$auth_st" "$current_mode" "$q_bb" "$q_cpe"
        
        sleep "$CHECK_INTERVAL"
    done
}

case "$1" in
    monitor)
        run_check_loop
        ;;
    status)
        load_config
        echo "当前网关: $(get_current_gateway)"; echo "策略线路: $(get_scheduled_line)"
        echo "锁定模式: $LOCK_MODE"
        ;;
    lock)
        load_config; mode="${2:-broadband}"; duration="${3:-0}"
        if [ "$mode" = "off" ]; then
            set_config "network_switch" "lock_mode" "off"
            set_config "network_switch" "lock_until" "0"
            echo "✅ 已解除锁定"
        else
            set_config "network_switch" "lock_mode" "$mode"
            if [ "$duration" != "0" ]; then
                until_ts=$(($(date +%s) + duration * 3600))
                set_config "network_switch" "lock_until" "$until_ts"
                echo "✅ 已锁定到 $mode ($duration 小时)"
            else
                set_config "network_switch" "lock_until" "0"
                echo "✅ 已锁定到 $mode (永久)"
            fi
        fi
        ;;
    history)
        get_statistics "${2:-today}"
        ;;
    test)
        load_config
        echo "=== 宽带测试 ==="; check_network_quality "$BROADBAND_DEVICE" "223.5.5.5" 10
        echo "=== CPE测试 ==="; check_network_quality "$CPE_DEVICE" "223.5.5.5" 10
        ;;
    *)
        echo "用法: $0 [monitor|status|lock|history|test]"
        ;;
esac