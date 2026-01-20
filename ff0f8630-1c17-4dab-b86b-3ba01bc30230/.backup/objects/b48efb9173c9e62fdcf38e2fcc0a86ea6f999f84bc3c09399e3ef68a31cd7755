# Easy MWAN3 Configurator (luci-app-easy-mwan3)

**Version:** v2.1 Ultimate  
**Author:** Antigravity  
**License:** MIT

## 简介 (Introduction)
这是一个为 OpenWrt MWAN3 (Multi-WAN) 设计的极简配置插件。它旨在解决 MWAN3 配置繁琐、逻辑复杂的问题，通过简单的 Web 界面一键生成企业级的负载均衡与故障转移策略。

## v2.1 Ultimate 新特性 (New Features)

### 1. 混合策略引擎 (Hybrid Policy Engine)
打破了全局模式的限制，现在你可以同时拥有“负载均衡”和“故障转移”：
*   **全局模式**：设定默认行为（如“负载均衡”）。
*   **个体覆盖**：指定特定设备强制使用相反的模式（如某台设备“强制故障转移”），或者独占特定接口。
*   **底层逻辑**：自动生成三套 Member 组（`_b` 均衡, `_f` 主备, `_s` 独占）以支持复杂的策略组合。

### 2. 可视化设备选择器 (Visual Device Selector)
*   **智能识别**：自动读取 `/tmp/dhcp.leases` 和 ARP 缓存。
*   **信息展示**：下拉框直接显示 `MAC 地址 - 主机名 (IP)`，无需手动查找 MAC。

### 3. 策略增强
*   新增 **Target Policy** 选项：
    *   `Default`: 跟随全局设置。
    *   `Force Balance`: ★ 强制参与负载均衡（无论全局如何）。
    *   `Force Failover`: ★ 强制使用主备切换（按优先级）。
    *   `Interface X`: 强制独占特定接口。

## 功能列表 (Features)
*   **一键生成**: 自动配置 Interface, Member, Policy, Rule。
*   **智能检测**: 自动设置连通性检测 IP (Ping)。
*   **HTTPS 粘滞**: 防止网银/游戏因 IP 变动而掉线。
*   **源地址粘滞**: 可选的激进模式，锁定设备出口 IP。
*   **目标分流**: 指定特定目的 IP 走特定接口。

## 安装 (Installation)
1.  下载 `luci-app-easy-mwan3-v2.1-Ultimate.zip`。
2.  解压并上传到路由器。
3.  安装依赖: `opkg install mwan3 luci-app-mwan3`。
4.  安装插件: 
    ```bash
    # 假设文件在 /tmp
    cp -r luasrc/* /usr/lib/lua/luci/
    cp root/etc/config/easy_mwan3 /etc/config/
    cp root/usr/bin/easy_mwan3_gen.sh /usr/bin/
    chmod +x /usr/bin/easy_mwan3_gen.sh
    ```
5.  刷新 LuCI 界面，在 "Services" -> "Easy MWAN3" 中配置。

## 使用警告 (Warning)
*   **覆盖风险**: 启用本插件将**覆盖**您现有的 `/etc/config/mwan3` 配置。请提前备份。
*   **冲突**: 请勿手动修改 MWAN3 的高级设置，否则可能被本插件生成的配置覆盖。
