include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-easy-mwan3
PKG_VERSION:=2.1
PKG_RELEASE:=Ultimate

PKG_MAINTAINER:=PengCong226
PKG_LICENSE:=MIT

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-easy-mwan3
	SECTION:=luci
	CATEGORY:=LuCI
	SUBMENU:=3. Applications
	TITLE:=Easy MWAN3 Configurator (Ultimate Edition)
	DEPENDS:=+luci-base +mwan3 +ip-full +ipset
	PKGARCH:=all
endef

define Package/luci-app-easy-mwan3/description
	Easy MWAN3 Configurator is a user-friendly LuCI interface for configuring MWAN3 load balancing.
	v2.1 Ultimate Edition with Hybrid Strategy Engine.
endef

define Build/Compile
endef

define Package/luci-app-easy-mwan3/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./luasrc/controller/easy_mwan3.lua $(1)/usr/lib/lua/luci/controller/easy_mwan3.lua
	
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi
	$(INSTALL_DATA) ./luasrc/model/cbi/easy_mwan3.lua $(1)/usr/lib/lua/luci/model/cbi/easy_mwan3.lua
	
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/easy_mwan3
	$(INSTALL_DATA) ./luasrc/view/easy_mwan3/status.htm $(1)/usr/lib/lua/luci/view/easy_mwan3/status.htm
	
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./root/etc/uci-defaults/99_easy_mwan3 $(1)/etc/uci-defaults/99_easy_mwan3
endef

$(eval $(call BuildPackage,luci-app-easy-mwan3))
