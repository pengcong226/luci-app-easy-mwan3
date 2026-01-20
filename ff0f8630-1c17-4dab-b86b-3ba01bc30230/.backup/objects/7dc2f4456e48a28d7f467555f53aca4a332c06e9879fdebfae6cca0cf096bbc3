#!/bin/sh
# Easy MWAN3 Config Generator v2.1 Ultimate
# Powered by Antigravity

. /lib/functions.sh

CONFIG="easy_mwan3"
MWAN_CFG="/etc/config/mwan3"
BACKUP_CFG="/etc/config/mwan3.bak"

log() {
    logger -t "easy_mwan3" "$1"
    echo "$1"
}

generate_config() {
    local enabled=$(uci -q get ${CONFIG}.global.enabled)
    local mode=$(uci -q get ${CONFIG}.global.mode)
    local check_ip=$(uci -q get ${CONFIG}.global.check_ip)
    local sticky_https=$(uci -q get ${CONFIG}.global.sticky_https)
    local sticky_source=$(uci -q get ${CONFIG}.global.sticky_source)
    local sticky_timeout=$(uci -q get ${CONFIG}.global.sticky_timeout)
    
    [ "$enabled" != "1" ] && log "Plugin disabled." && return 0
    
    log "Generating v2.1 Ultimate config..."
    cp "$MWAN_CFG" "$BACKUP_CFG"
    
    # === 1. 初始化 ===
    echo "config globals 'globals'" > "$MWAN_CFG"
    echo "	option mmx_mask '0x3F00'" >> "$MWAN_CFG"
    echo "	option local_source 'lan'" >> "$MWAN_CFG"
    
    # === 2. 接口与 Member (三套车模式) ===
    # members_b: 强制均衡组
    # members_f: 强制主备组
    local members_b=""
    local members_f=""
    
    config_load "${CONFIG}"
    
    handle_interface() {
        local section="$1"
        local iface=$(config_get "$section" "interface")
        local weight=$(config_get "$section" "weight" "1")
        local metric=$(config_get "$section" "metric" "10")
        [ -z "$iface" ] && return
        
        # Interface 定义
        echo "" >> "$MWAN_CFG"
        echo "config interface '$iface'" >> "$MWAN_CFG"
        echo "	option enabled '1'" >> "$MWAN_CFG"
        echo "	list track_ip '$check_ip'" >> "$MWAN_CFG"
        echo "	option reliability '1'" >> "$MWAN_CFG"
        echo "	option count '1'" >> "$MWAN_CFG"
        echo "	option timeout '2'" >> "$MWAN_CFG"
        echo "	option interval '5'" >> "$MWAN_CFG"
        echo "	option down '3'" >> "$MWAN_CFG"
        echo "	option up '3'" >> "$MWAN_CFG"
        
        # 2.1 Member_B: Balance (Metric=1)
        echo "" >> "$MWAN_CFG"
        echo "config member '${iface}_b'" >> "$MWAN_CFG"
        echo "	option interface '$iface'" >> "$MWAN_CFG"
        echo "	option metric '1'" >> "$MWAN_CFG"
        echo "	option weight '$weight'" >> "$MWAN_CFG"
        members_b="$members_b ${iface}_b"
        
        # 2.2 Member_F: Failover (Metric=User Config)
        echo "config member '${iface}_f'" >> "$MWAN_CFG"
        echo "	option interface '$iface'" >> "$MWAN_CFG"
        echo "	option metric '$metric'" >> "$MWAN_CFG"
        echo "	option weight '1'" >> "$MWAN_CFG"
        members_f="$members_f ${iface}_f"
        
        # 2.3 Member_S: Solo (Metric=1, Weight=1, 独占)
        echo "config member '${iface}_s'" >> "$MWAN_CFG"
        echo "	option interface '$iface'" >> "$MWAN_CFG"
        echo "	option metric '1'" >> "$MWAN_CFG"
        echo "	option weight '1'" >> "$MWAN_CFG"
        
        # 2.4 Policy: Solo
        echo "config policy 'policy_${iface}'" >> "$MWAN_CFG"
        echo "	list use_member '${iface}_s'" >> "$MWAN_CFG"
        echo "	option last_resort 'unreachable'" >> "$MWAN_CFG"
    }
    config_foreach handle_interface "interface"
    
    # === 3. 策略生成 ===
    
    # 3.1 强制均衡策略 (All Balance)
    echo "" >> "$MWAN_CFG"
    echo "config policy 'policy_balanced_force'" >> "$MWAN_CFG"
    for m in $members_b; do
        echo "	list use_member '$m'" >> "$MWAN_CFG"
    done
    echo "	option last_resort 'unreachable'" >> "$MWAN_CFG"
    
    # 3.2 强制主备策略 (All Failover)
    echo "" >> "$MWAN_CFG"
    echo "config policy 'policy_failover_force'" >> "$MWAN_CFG"
    for m in $members_f; do
        echo "	list use_member '$m'" >> "$MWAN_CFG"
    done
    echo "	option last_resort 'unreachable'" >> "$MWAN_CFG"
    
    # 3.3 默认策略 (根据全局设置指向上述两者之一)
    echo "" >> "$MWAN_CFG"
    echo "config policy 'easy_default'" >> "$MWAN_CFG"
    if [ "$mode" = "balance" ]; then
        for m in $members_b; do echo "	list use_member '$m'" >> "$MWAN_CFG"; done
    else
        for m in $members_f; do echo "	list use_member '$m'" >> "$MWAN_CFG"; done
    fi
    echo "	option last_resort 'unreachable'" >> "$MWAN_CFG"
    
    # === 4. 规则生成 ===
    add_rule() {
        local name="$1"
        local src="$2"
        local dest="$3"
        local proto="$4"
        local port="$5"
        local sticky="$6"
        local policy="$7"
        
        echo "" >> "$MWAN_CFG"
        echo "config rule '$name'" >> "$MWAN_CFG"
        [ -n "$src" ] && echo "	option src_ip '$src'" >> "$MWAN_CFG"
        [ -n "$dest" ] && echo "	option dest_ip '$dest'" >> "$MWAN_CFG"
        [ -n "$proto" ] && echo "	option proto '$proto'" >> "$MWAN_CFG"
        [ -n "$port" ] && echo "	option dest_port '$port'" >> "$MWAN_CFG"
        [ -n "$sticky" ] && echo "	option sticky '$sticky'" >> "$MWAN_CFG"
        [ "$sticky" = "1" ] && echo "	option timeout '$sticky_timeout'" >> "$MWAN_CFG"
        echo "	option use_policy '$policy'" >> "$MWAN_CFG"
    }

    # 4.1 目标分流
    handle_dest_rule() {
        local section="$1"
        local dest_ip=$(config_get "$section" "dest_ip")
        local policy_tag=$(config_get "$section" "target_policy")
        local name=$(config_get "$section" "name" "dst")
        
        local target="easy_default"
        if [ "$policy_tag" = "force_balance" ]; then target="policy_balanced_force"
        elif [ "$policy_tag" = "force_failover" ]; then target="policy_failover_force"
        elif [ "$policy_tag" != "default" ]; then target="policy_${policy_tag}"; fi
        
        if [ -n "$dest_ip" ]; then
            add_rule "dst_${name}_${section}" "" "$dest_ip" "all" "" "0" "$target"
        fi
    }
    config_foreach handle_dest_rule "dest_rule"
    
    # 4.2 设备分流
    handle_device_rule() {
        local section="$1"
        local mac=$(config_get "$section" "mac")
        local src_ip=$(config_get "$section" "src_ip")
        local policy_tag=$(config_get "$section" "target_policy")
        local name=$(config_get "$section" "name" "dev")
        
        local target="easy_default"
        if [ "$policy_tag" = "force_balance" ]; then target="policy_balanced_force"
        elif [ "$policy_tag" = "force_failover" ]; then target="policy_failover_force"
        elif [ "$policy_tag" != "default" ]; then target="policy_${policy_tag}"; fi
        
        if [ -n "$mac" ] || [ -n "$src_ip" ]; then
            echo "" >> "$MWAN_CFG"
            echo "config rule 'dev_${name}_${section}'" >> "$MWAN_CFG"
            [ -n "$mac" ] && echo "	option src_mac '$mac'" >> "$MWAN_CFG"
            [ -n "$src_ip" ] && echo "	option src_ip '$src_ip'" >> "$MWAN_CFG"
            echo "	option proto 'all'" >> "$MWAN_CFG"
            echo "	option sticky '0'" >> "$MWAN_CFG"
            echo "	option use_policy '$target'" >> "$MWAN_CFG"
        fi
    }
    config_foreach handle_device_rule "device_rule"
    
    # 4.3 粘滞与默认
    [ "$sticky_https" = "1" ] && add_rule "https_sticky" "" "" "tcp" "443" "1" "easy_default"
    [ "$sticky_source" = "1" ] && add_rule "source_sticky" "" "" "all" "" "1" "easy_default"
    add_rule "default_rule" "0.0.0.0/0" "0.0.0.0/0" "all" "" "0" "easy_default"
    
    log "Config generation complete."
}

restart_mwan3() {
    log "Restarting MWAN3..."
    /etc/init.d/mwan3 restart
}

case "$1" in
    generate) generate_config ;;
    restart) generate_config; restart_mwan3 ;;
    *) echo "Usage: $0 {generate|restart}"; exit 1 ;;
esac
