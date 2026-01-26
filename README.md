# Easy MWAN3 Configurator (v2.1 Ultimate)

> **极简、强大、智能的 OpenWrt 多拨负载均衡配置工具**

![Build Status](https://img.shields.io/badge/build-passing-brightgreen)
![Version](https://img.shields.io/badge/version-2.1%20Ultimate-blue)
![License](https://img.shields.io/badge/license-MIT-orange)

## 💡 简介

**Easy MWAN3** 是为了解决 OpenWrt 原生 MWAN3 配置极其繁琐、劝退新手的痛点而诞生的。
它将原本需要手动配置接口、成员、策略、规则等几十个步骤的复杂流程，浓缩为**一键式**的智能化操作。

**v2.1 Ultimate 版本** 更是引入了“混合策略引擎”和“设备感知”技术，不仅能做简单的负载均衡，还能实现复杂的精细化流量控制。

---

## 🔥 核心特性 (v2.1 Ultimate)

### 1. 🚀 混合策略引擎 (Hybrid Strategy Engine)
告别单一的“均衡”或“主备”。现在，你可以同时拥有：
- **全局负载均衡**：所有流量默认在 WAN/WAN2 之间按权重（如 1:1 或 2:1）分配，带宽叠加，网速起飞。
- **特定设备强制走主线**：打游戏怕跳 ping？指定游戏 PC 强制走 WAN (主线)，绝不漂移。
- **智能故障切换**：任意线路掉线，流量毫秒级自动切换到存活线路，断网？不存在的。

### 2. 👁️ 设备感知与可视化 (Device Awareness)
- **不再查 MAC 地址**：自动读取 DHCP 租约，直接显示“张三的iPhone”、“客厅电视”等设备名称。
- **下拉选择**：配置策略时，直接从下拉菜单选择设备，像点菜一样简单。

### 3. 🛡️ 智能保活与断网自愈
- **全自动健康检查**：内置 Ping 检测，自动判断线路通断。
- **死锁解除机制**：(针对校园网等特殊环境) 当 WAN 口掉线且需要认证时，自动保留静态路由通道，确保能访问认证服务器，防止“断网-无法认证-彻底死锁”的循环。

---

## ⚠️ 重要提示

**本插件依赖 mwan3，而 mwan3 仅支持 iptables/fw3，不支持 nftables/fw4。**

如果你的 OpenWrt 使用 firewall4 (fw4)，此插件将无法正常工作。请使用以下替代方案：
- **策略路由**: 使用 `pbr` (Policy Based Routing)，支持 nftables
- **回退 fw3**: 安装 iptables 和 firewall3 替换 fw4

## 🛠️ 安装与使用

### 安装
下载 `.ipk` 文件后，上传至路由器安装：
```bash
opkg install luci-app-easy-mwan3_2.1-Ultimate_all.ipk
opkg install luci-i18n-easy-mwan3-zh-cn  # 中文翻译
```

### 快速上手
1. 进入 OpenWrt 后台 -> **网络** -> **Easy MWAN3**。
2. **基本设置**：勾选“启用”，选择你的 WAN 接口（支持多选）。
3. **策略模式**：
   - **均衡模式**：所有流量在选定接口间负载均衡。
   - **主备模式**：优先走主 WAN，挂了走备用。
4. **高级策略 (可选)**：
   - 在下方列表中，添加规则。
   - 选择设备（如“我的电脑”），选择策略（如“强制 WAN1”）。
   - 点击“保存并应用”。

---

## ❓ 常见问题 (FAQ)

**Q: 和原版 MWAN3 有什么区别？**
A: 原版是“手动挡”，功能多但难开；Easy MWAN3 是“自动挡 + 运动模式”，保留了核心性能，操作简化了 99%。

**Q: 校园网认证会冲突吗？**
A: v2.1 版本已优化。插件会接管路由表，但我们建议在插件设置中开启“保持默认路由”或手动指定认证服务器的静态路由，即可完美共存。

---

### 📝 更新日志

#### v2.1 Ultimate
- [新增] 混合策略支持：同时通过 IP 规则指定特定设备走特定线路。
- [新增] DHCP 设备名读取：配置界面直接显示主机名。
- [优化] 针对多拨环境的 metric 自动调整算法。

#### v1.0
- 初始版本，实现基本的“一键多拨均衡”。

---
*Created with ❤️ by PengCong226 & Antigravity AI*
