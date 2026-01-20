#!/bin/sh
. /usr/lib/network_scripts/common.sh

check_network_quality() {
    local iface="$1"
    local target="${2:-223.5.5.5}"
    local count="${3:-5}"
    
    local result=$(ping -c $count -W 2 -I "$iface" "$target" 2>/dev/null)
    if [ $? -ne 0 ]; then
        echo "fail"
        return 1
    fi
    
    local latency=$(echo "$result" | grep -oE 'avg.*=.*[0-9.]+' | grep -oE '[0-9.]+' | head -1)
    [ -z "$latency" ] && latency=$(echo "$result" | grep -oE 'time=[0-9.]+' | tail -1 | grep -oE '[0-9.]+')
    
    local packet_loss=$(echo "$result" | grep -oE '[0-9]+%' | head -1 | tr -d '%')
    
    latency=${latency:-999}
    packet_loss=${packet_loss:-100}
    
    echo "${latency}:${packet_loss}"
    return 0
}

evaluate_quality() {
    local iface="$1"
    local quality=$(check_network_quality "$iface")
    
    if [ "$quality" = "fail" ]; then echo "0"; return 1; fi
    
    local latency=$(echo "$quality" | cut -d: -f1)
    local packet_loss=$(echo "$quality" | cut -d: -f2)
    local latency_score=50
    local latency_int=${latency%.*}
    
    if [ "$latency_int" -gt 300 ]; then latency_score=0
    elif [ "$latency_int" -gt 200 ]; then latency_score=10
    elif [ "$latency_int" -gt 100 ]; then latency_score=30
    elif [ "$latency_int" -gt 50 ]; then latency_score=40
    fi
    
    local loss_score=50
    if [ "$packet_loss" -gt 50 ]; then loss_score=0
    elif [ "$packet_loss" -gt 20 ]; then loss_score=20
    elif [ "$packet_loss" -gt 10 ]; then loss_score=35
    elif [ "$packet_loss" -gt 5 ]; then loss_score=45
    fi
    
    echo "$((latency_score + loss_score))"
    return 0
}

check_quality_threshold() {
    local iface="$1"
    local quality_check=$(get_config "network_switch" "quality_check" "1")
    [ "$quality_check" != "1" ] && return 0
    
    local max_latency=$(get_config "network_switch" "max_latency" "200")
    local max_loss=$(get_config "network_switch" "max_packet_loss" "20")
    local quality=$(check_network_quality "$iface")
    
    if [ "$quality" = "fail" ]; then return 1; fi
    
    local latency=$(echo "$quality" | cut -d: -f1)
    local packet_loss=$(echo "$quality" | cut -d: -f2)
    local latency_int=${latency%.*}
    
    [ "$latency_int" -gt "$max_latency" ] && return 1
    [ "$packet_loss" -gt "$max_loss" ] && return 1
    return 0
}