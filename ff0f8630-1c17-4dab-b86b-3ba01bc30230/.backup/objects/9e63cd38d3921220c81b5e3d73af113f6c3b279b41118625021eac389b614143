include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-easy-mwan3
PKG_VERSION:=2.1
PKG_RELEASE:=Ultimate

PKG_MAINTAINER:=Antigravity <antigravity@cyber.elf>
PKG_LICENSE:=MIT

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-easy-mwan3
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=Easy Configuration for MWAN3 (v2.1 Ultimate)
  PKGARCH:=all
  DEPENDS:=+mwan3 +luci-app-mwan3
endef

define Package/luci-app-easy-mwan3/description
  The Ultimate MWAN3 configuration tool.
  Features: Hybrid Policy Engine, DHCP-aware Device Selector, Auto-Gen.
endef

define Build/Compile
endef

define Package/luci-app-easy-mwan3/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci
	$(CP) ./luasrc/* $(1)/usr/lib/lua/luci/
	
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./root/etc/config/easy_mwan3 $(1)/etc/config/easy_mwan3
	
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./root/usr/bin/easy_mwan3_gen.sh $(1)/usr/bin/easy_mwan3_gen.sh
endef

$(eval $(call BuildPackage,luci-app-easy-mwan3))
