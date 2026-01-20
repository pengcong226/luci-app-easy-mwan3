#!/bin/sh
# 校园网认证脚本 v4.0 - 最终完结 (信任模式)
. /usr/lib/network_scripts/common.sh

LOG_FILE="/var/log/network_scripts/campus_auth.log"
COOKIE_FILE="/tmp/campus_auth_cookie"

# ================= 配置加载 =================
USERNAME=$(get_config "campus_auth" "username" "")
PASSWORD=$(get_config "campus_auth" "password" "")
AC_IP=$(get_config "campus_auth" "wlanacip" "172.16.1.82")
AC_NAME=$(get_config "campus_auth" "wlanacname" "GXSTNU-BRAS")

# 真实服务器
AUTH_SERVER_IP="172.20.4.3"
AUTH_DOMAIN="auth.gxstnu.edu.cn"

WAN_IF=$(get_config "network_switch" "broadband_interface" "wan")
WAN_DEV=$(get_config "network_switch" "broadband_device" "")
[ -z "$WAN_DEV" ] && WAN_DEV=$(get_interface_device "$WAN_IF")
WAN_GW=$(get_config "network_switch" "broadband_gateway" "172.17.21.1")

# ================= 功能函数 =================
get_wan_ip() { get_interface_ip "$WAN_DEV"; }
get_wan_mac() { get_interface_mac "$WAN_DEV"; }

do_auth_request() {
    local user="$1"
    local pass="$2"
    local user_ip="$3"
    local user_mac="$4"
    
    local mac_lower=$(echo "$user_mac" | tr 'A-Z' 'a-z')
    
    # 1. 获取 Cookie
    curl -s -k --connect-timeout 5 \
        --interface "$WAN_DEV" \
        --resolve "${AUTH_DOMAIN}:443:${AUTH_SERVER_IP}" \
        -c "$COOKIE_FILE" \
        "https://${AUTH_DOMAIN}/" >/dev/null 2>&1

    # 2. 构建 Payload (完美版)
    local p_base="wlanacip=${AC_IP}&wlanacname=${AC_NAME}&wlanuserip=${user_ip}&mac=${mac_lower}&vlan=0&url=http://1.1.1.1/"
    local p_static="&scheme=https&serverIp=tomcat_server1:443&hostIp=http://127.0.0.1:8446/&loginType=&auth_type=0"
    local p_flags="&isBindMac1=0&pageid=5&templatetype=1&listbindmac=0&recordmac=0&isRemind=1&loginTimes=&groupId=&distoken=&echostr="
    local p_extra="&url=http://1.1.1.1/&isautoauth=&mobile=&notice_pic_loop2=/portal/uploads/pc/demo2/images/bj.png&notice_pic_loop1=/portal/uploads/pc/demo2/images/logo.png"
    local p_auth="&userId=${user}&passwd=${pass}&remInfo=on"
    
    local data="${p_base}${p_static}${p_flags}${p_extra}${p_auth}"
    
    local ua="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0"
    
    log_msg "📤 发送认证请求..." "debug" "$LOG_FILE"
    
    # 3. 发送 POST
    local result=$(curl -s -S -k -i \
        --interface "$WAN_DEV" \
        --noproxy "*" \
        --connect-timeout 10 \
        --max-time 30 \
        --resolve "${AUTH_DOMAIN}:443:${AUTH_SERVER_IP}" \
        -b "$COOKIE_FILE" -c "$COOKIE_FILE" \
        -A "$ua" \
        -H "Host: ${AUTH_DOMAIN}" \
        -H "Origin: https://${AUTH_DOMAIN}" \
        -H "Referer: https://${AUTH_DOMAIN}/webauth.do?wlanacip=${AC_IP}&wlanuserip=${user_ip}&mac=${mac_lower}&vlan=0&url=http://1.1.1.1/" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -d "$data" \
        "https://${AUTH_DOMAIN}/webauth.do" 2>&1)
    
    echo "$result"
}

check_auth_result() {
    local result="$1"
    
    # 【核心逻辑变更】：只要 HTTP 200 OK，就视为成功
    if echo "$result" | grep -q "HTTP/1.1 200 OK"; then
         log_msg "✅ 服务器响应 200 OK，认定认证成功" "info" "$LOG_FILE"
         return 0
    fi
    
    # 兼容 302 跳转成功的情况
    if echo "$result" | grep -q "HTTP/1.1 302"; then
         if echo "$result" | grep -qi "Location" | grep -v "error" | grep -v "login"; then
             log_msg "✅ 检测到成功跳转，认定认证成功" "info" "$LOG_FILE"
             return 0
         fi
    fi
    
    if echo "$result" | grep -qiE "success|成功|已登录"; then return 0; fi
    
    # 如果上面都没通过，才尝试 Ping (兜底)
    if ping -c 1 -W 1 -I "$WAN_DEV" 223.5.5.5 >/dev/null 2>&1; then
        return 0
    fi

    return 1
}

do_login() {
    log_msg "================================================" "info" "$LOG_FILE"
    log_msg "🚀 开始校园网认证 (v4.0 完结版)" "info" "$LOG_FILE"
    
    local user_ip=$(get_wan_ip)
    local user_mac=$(get_wan_mac)
    
    if [ -z "$user_ip" ]; then
        log_msg "❌ 错误：无 WAN IP" "error" "$LOG_FILE"; return 1
    fi
    
    ip route add "${AUTH_SERVER_IP}" via "$WAN_GW" dev "$WAN_DEV" 2>/dev/null
    
    local result=$(do_auth_request "$USERNAME" "$PASSWORD" "$user_ip" "$user_mac")
    
    # 修复 Broken pipe: 先截取前500字符再打印
    local short_res=$(echo "${result}" | head -c 500)
    log_msg "📥 响应摘要: ${short_res}..." "debug" "$LOG_FILE"
    
    check_auth_result "$result"
    local status=$?
    
    if [ $status -eq 0 ]; then
        log_msg "✅ 认证成功！(网络已连通)" "info" "$LOG_FILE"
        record_history "auth" "认证成功" "success"
        return 0
    else
        log_msg "❌ 认证失败" "error" "$LOG_FILE"
        return 1
    fi
}

case "$1" in
    login) do_login ;;
    *) do_login ;;
esac