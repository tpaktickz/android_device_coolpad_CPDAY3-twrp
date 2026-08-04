#
# Copyright (C) 2024 The Android Open Source Project
# Copyright (C) 2024 SebaUbuntu's TWRP device tree generator
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/aosp_base.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/gsi_keys.mk)

# Inherit some common Twrp stuff.
$(call inherit-product, vendor/twrp/config/common.mk)

# Inherit from CPDAY3 device
$(call inherit-product, device/coolpad/CPDAY3/device.mk)

PRODUCT_DEVICE := CPDAY3
PRODUCT_NAME := twrp_CPDAY3
PRODUCT_BRAND := coolpad
PRODUCT_MODEL := CPDAY3
PRODUCT_MANUFACTURER := coolpad
BUILD_FINGERPRINT := coolpad/CPDAY3/L71E:11/RP1A.200720.011/1752729022:eng/release-keys