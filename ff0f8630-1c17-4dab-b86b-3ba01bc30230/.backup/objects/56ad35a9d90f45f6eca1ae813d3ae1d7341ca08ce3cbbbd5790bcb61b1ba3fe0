include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-network-scripts
PKG_VERSION:=3.0
PKG_RELEASE:=Pro

PKG_MAINTAINER:=Antigravity <antigravity@cyber.elf>
PKG_LICENSE:=MIT

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-network-scripts
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=Advanced Network Switching & Auth System (v3.0 Pro)
  PKGARCH:=all
  DEPENDS:=+curl +openssl-util +ip-full +jsonfilter
endef

define Package/luci-app-network-scripts/description
  Full-featured network switching and authentication system for Campus Network.
  Includes Quality Check, Dual-WAN Switch, DingTalk Notify and History Stats.
endef

define Build/Compile
endef

define Package/luci-app-network-scripts/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci
	$(CP) ./luasrc/* $(1)/usr/lib/lua/luci/
	
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./root/etc/config/network_scripts $(1)/etc/config/network_scripts
	
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./root/etc/init.d/network_scripts $(1)/etc/init.d/network_scripts
	
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./root/usr/bin/network_switch.sh $(1)/usr/bin/network_switch.sh
	
	$(INSTALL_DIR) $(1)/usr/lib/network_scripts
	$(INSTALL_BIN) ./root/usr/lib/network_scripts/*.sh $(1)/usr/lib/network_scripts/
endef

$(eval $(call BuildPackage,luci-app-network-scripts))