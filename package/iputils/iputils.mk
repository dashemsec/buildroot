################################################################################
#
# iputils
#
################################################################################

# The original upstream was forked to the github repository in 2014 to
# pull fixes from other distribution and centralize the changes after
# the upstream seemed to have gone dormant.  The fork contains the
# latest changes including musl support, removing a libsysfs dependency
# and IPv6 updates.
# http://www.spinics.net/lists/netdev/msg279881.html

IPUTILS_VERSION = s20190515
IPUTILS_SITE = $(call github,iputils,iputils,$(IPUTILS_VERSION))
IPUTILS_LICENSE = GPL-2.0+, BSD-3-Clause
IPUTILS_LICENSE_FILES = LICENSE Documentation/LICENSE.BSD3 Documentation/LICENSE.GPL2
IPUTILS_DEPENDENCIES = $(TARGET_NLS_DEPENDENCIES)

ifeq ($(BR2_PACKAGE_LIBCAP),y)
IPUTILS_CONF_OPTS += -DUSE_CAP=true
IPUTILS_DEPENDENCIES += libcap
else
IPUTILS_CONF_OPTS += -DUSE_CAP=false
endif

ifeq ($(BR2_PACKAGE_LIBIDN2),y)
IPUTILS_CONF_OPTS += -DUSE_IDN=true
IPUTILS_DEPENDENCIES += libidn2
else
IPUTILS_CONF_OPTS += -DUSE_IDN=false
endif

ifeq ($(BR2_PACKAGE_NETTLE),y)
IPUTILS_CONF_OPTS += -DUSE_CRYPTO=nettle
IPUTILS_DEPENDENCIES += nettle
else ifeq ($(BR2_PACKAGE_LIBGCRYPT),y)
IPUTILS_CONF_OPTS += -DUSE_CRYPTO=gcrypt
IPUTILS_DEPENDENCIES += libgcrypt
else ifeq ($(BR2_PACKAGE_OPENSSL),y)
IPUTILS_CONF_OPTS += -DUSE_CRYPTO=openssl
IPUTILS_DEPENDENCIES += openssl
else ifeq ($(BR2_PACKAGE_LINUX_HEADERS),y)
IPUTILS_CONF_OPTS += -DUSE_CRYPTO=kernel
IPUTILS_DEPENDENCIES += linux-headers
else
IPUTILS_CONF_OPTS += -DUSE_CRYPTO=none
# BUILD_NINFOD=true and USE_CRYPTO=none cannot be combined
IPUTILS_CONF_OPTS += -DBUILD_NINFOD=false
endif

# XSL Stylesheets for DocBook 5 not packaged for buildroot
IPUTILS_CONF_OPTS += -DBUILD_MANS=false -DBUILD_HTML_MANS=false

# move iputils binaries to the same location as where Busybox installs
# the corresponding applets, so that we have a single version of the
# tools (from iputils)
define IPUTILS_MOVE_BINARIES
	mv $(TARGET_DIR)/usr/bin/arping $(TARGET_DIR)/usr/sbin/arping
	$(if $(BR2_ROOTFS_MERGED_USR),,\
		mv $(TARGET_DIR)/usr/bin/ping $(TARGET_DIR)/bin/ping)
	mv $(TARGET_DIR)/usr/bin/tftpd $(TARGET_DIR)/usr/sbin/tftpd
endef
IPUTILS_POST_INSTALL_TARGET_HOOKS += IPUTILS_MOVE_BINARIES

# handle permissions ourselves
IPUTILS_CONF_OPTS += -DNO_SETCAP_OR_SUID=true
define IPUTILS_PERMISSIONS
	/usr/sbin/arping      f 4755 0 0 - - - - -
	/usr/bin/clockdiff    f 4755 0 0 - - - - -
	/bin/ping             f 4755 0 0 - - - - -
endef

$(eval $(meson-package))
