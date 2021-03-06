# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lora_gateway
PKG_VERSION:=1.2.6
PKG_RELEASE:=3

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk

define Package/lora-gateway/Default
  TITLE:=Semtech lora-gateway package
  URL:=http://www.semtech.com/wireless-rf/lora.html
endef

define Package/lora-gateway
$(call Package/lora-gateway/Default)
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libuci +libftdi +libsqlite3
endef

define Package/lora-gateway/description
  lora-gateway is a library to build a gateway based on 
  a Semtech LoRa multi-channel RF receiver (a.k.a. concentrator).
endef

TARGET_CFLAGS += $(FPIC) -O2 -Wall -Wextra -std=c99 -DBIGENDIAN -Iinc -I. -lm

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/?* $(PKG_BUILD_DIR)/
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/lora-gateway
	$(CP) $(PKG_BUILD_DIR)/libloragw/inc/* $(1)/usr/include/lora-gateway
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/libloragw/libloragw.a $(1)/usr/lib/
endef

define Package/lora-gateway/install
	$(INSTALL_DIR) $(1)/usr/lora
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/libloragw/test* $(1)/usr/lora
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/util_spectral_scan/util_spectral_scan $(1)/usr/lora
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/util_spi_stress/util_spi_stress $(1)/usr/lora
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/util_lbt_test/util_lbt_test $(1)/usr/lora
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/util_tx_continuous/util_tx_continuous $(1)/usr/lora
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/reset_lgw.sh $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lora_pkt_fwd/single_tx $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lora_pkt_fwd/lora_pkt_fwd $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/util_tx_test/util_tx_test $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/util_test_hal/util_test_hal $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/util_pkt_logger/util_pkt_logger $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc/lora
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/lora_pkt_fwd/*conf.json $(1)/etc/lora
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/lora_pkt_fwd/devskey $(1)/etc/lora
	$(INSTALL_DIR) $(1)/etc/lora/cfg-301
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/lora_pkt_fwd/cfg-301/*.json* $(1)/etc/lora/cfg-301
	$(INSTALL_DIR) $(1)/etc/lora/cfg-308
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/lora_pkt_fwd/cfg-308/*.json* $(1)/etc/lora/cfg-308
	$(INSTALL_DIR) $(1)/etc/lora/customized_scripts
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lora_pkt_fwd/customized_scripts/* $(1)/etc/lora/customized_scripts
	$(INSTALL_DIR) $(1)/etc/lora/decoder
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lora_pkt_fwd/decoder/* $(1)/etc/lora/decoder
endef

$(eval $(call BuildPackage,lora-gateway))
