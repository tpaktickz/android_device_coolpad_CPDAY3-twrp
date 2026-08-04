```markdown
# TWRP Device Tree for Coolpad CPDAY3 (Fengshang 50 Lite MTK Edition)

The TWRP (Team Win Recovery Project) device tree repository for the **Coolpad CPDAY3 (codename: CPDAY3)** – also known as Fengshang 50 Lite MTK Edition.  
This device uses **recovery-as-boot** – it has no separate recovery partition. TWRP is built as a `boot.img` and booted via the normal boot partition.

## Device Specifications

| Feature | Details |
| ---- | ---- |
| Codename | CPDAY3 |
| Model | Coolpad Fengshang 50 Lite (MTK Version) |
| Chipset | MediaTek MT6769V/CB (Helio G85) |
| CPU Architecture | ARM64‑v8A (Octa‑core) |
| Kernel Version | Linux 4.14 / 5.4 (stock) |
| RAM | 4GB / 6GB |
| Storage | 64GB / 128GB |
| Battery | 4500mAh Li‑Po (typical) |
| Display | 6.52 inches, IPS LCD, 720×1600 pixels |
| Rear Camera | 13MP + 2MP (or similar) |
| Front Camera | 5MP |
| Platform | MediaTek MT6769 |
| Android Version | 11 (stock firmware) |


## Compatibility
- This device tree is built for **TWRP 11** (Android 11.0 base)
- Compatible with Coolpad CPDAY3 (Fengshang 50 Lite) MTK variants
- Supports stock firmware based on Android 12/13 with MTK‑specific kernel

## Important Notes about Recovery‑as‑Boot
The device **does not** have a `/recovery` partition. Instead, the same boot partition is used for both normal boot and recovery:

- Normal boot: kernel command line contains `androidboot.force_normal_boot=1`
- Recovery boot: kernel command line **does not** contain that flag, and the bootloader launches recovery mode

Thus:
- `BOARD_USES_RECOVERY_AS_BOOT := true` must be set.
- We build `boot.img`, **not** `recovery.img`.
- Flashing commands use `fastboot flash boot boot.img`.

## Features
### Working
- ✅ ADB access
- ✅ No need to decryption
- ✅ Touchscreen
- ✅ Internal storage / SD card mount
- ✅ Backup & Restore
- ✅ Flashing ZIP/IMG files
- ✅ Reboot to system/recovery/bootloader
- ✅ Vibration
- ✅ USB-OTG

### Not Working
- ✅ None (Full functional TWRP)

---

## Build Instructions

### 1. Initialize TWRP Source (branch twrp-11)
```bash
repo init --depth=1 -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git -b twrp-11
```

### 2. Sync Source
```bash
repo sync -j$(nproc --all) --force-sync
```

### 3. Clone Device Tree
```bash
git clone https://github.com/rtyutechstudio/android_device_coolpad_CPDAY3-twrp device/coolpad/CPDAY3
```

### 4. Apply the Necessary TWRP Source Change (One‑time)
TWRP 11 unconditionally appends `twrpfastboot=1` to the kernel command line when `BOARD_USES_RECOVERY_AS_BOOT` is set, which breaks normal boot on this device.  
We will **edit the TWRP core config** to make this optional, using the flag `TW_NO_FASTBOOT_BOOT`.

Edit file:  
`vendor/twrp/config/BoardConfigTWRP.mk`

Locate the block that adds `twrpfastboot=1` and wrap it with the `TW_NO_FASTBOOT_BOOT` check. The final code should look like:

```makefile
ifeq ($(BOARD_USES_RECOVERY_AS_BOOT),true)
    ifneq ($(TW_NO_FASTBOOT_BOOT),true)
        ifeq ($(BOARD_BOOT_HEADER_VERSION),3)
            GENERIC_KERNEL_CMDLINE += twrpfastboot=1
        else
            INTERNAL_KERNEL_CMDLINE += twrpfastboot=1
        endif
    endif
endif
```

*(If the existing code uses a different variable name, adjust accordingly – the key is to conditionally add `twrpfastboot=1` only when `TW_NO_FASTBOOT_BOOT` is **not** set.)*

### 5. Device Tree Configuration (already set)
In your device tree, ensure the following flags are present:

```makefile
BOARD_USES_RECOVERY_AS_BOOT := true
TARGET_NO_RECOVERY := true
TW_NO_FASTBOOT_BOOT := true
```

These tell TWRP to:
- Treat boot as recovery
- Not build a separate recovery image
- Skip adding `twrpfastboot=1` (thanks to the source change above)

### 6. Set Up Build Environment
```bash
source build/envsetup.sh
lunch twrp_CPDAY3-eng
```

### 7. Build Boot Image (not recovery!)
```bash
mka bootimage
```

The output image will be located at:
```
out/target/product/CPDAY3/boot.img
```

> **Warning:** Do **not** run `mka recoveryimage` – it is not used and will not produce a flashable image for this device.

---

## Kernel, SELinux and Decryption Notes

This device does not require decryption of the data partition.

### ⚠️ SELinux Note (Critical)

During early development I discovered that the stock kernel **has been stripped of the ability to disable SELinux**.  
If you attempt to set `androidboot.selinux=permissive` in the kernel command line (either in BoardConfig.mk or via any other means), the device will **fail to boot** and instead drop into bootloader mode with the following fatal errors in the log:

```
20917736 .(6)[1:init]selinux:
20917775 B.(6)[1:init]init: security_setenforce(false) failed: Invalid argument
20917863 b.(6)[1:init]init: InitFatalReboot: signal 6
20917924 .(6)[1:init][PWM] disp_pwm_set_backlight_cmdq: (id = 0x1, level_1024 = 0), old = -1
```

The root cause is that the kernel's SELinux hooks are partially or completely removed, so the `security_setenforce(false)` call always returns `-EINVAL`, causing `init` to trigger a fatal reboot and force the bootloader to take over.

**Therefore, do NOT add `androidboot.selinux=permissive` to `BOARD_KERNEL_CMDLINE` or any other command‑line variable in your BoardConfig.**  
If you have already added it, remove it immediately. The device must remain enforcing – this is a kernel limitation, not a TWRP issue.

---

## Installation Instructions

### Prerequisites
- Unlocked bootloader
- Fastboot installed on PC
- USB debugging & OEM unlocking enabled

### Flash via Fastboot (replace boot partition)
```bash
fastboot flash boot boot.img
fastboot reboot
```

To enter recovery after flashing, press the **Volume Up + Power** (or the key combination specific to your device) during boot, or use:
```bash
adb reboot recovery
```

---

## Notes
- This device tree is **only for CPDAY3** (Coolpad Fengshang 50 Lite MTK Edition not for sprd Edition)
- Do **not** flash on any other Coolpad/MediaTek devices
- Backup all data before flashing custom recovery
- Because this replaces the **boot** partition, ensure your stock boot image is backed up in case you need to revert
- **Never** add `androidboot.selinux=permissive` – see SELinux Note above

## Credits
- TWRP Team for recovery source
- github@rtyutechstudio (coolapk@cuoxianxu)
- Contributors to MediaTek device development
- Special thanks to the community for clarifying the recovery‑as‑boot and `twrpfastboot=1` handling

---

**Use this software at your own risk. The authors are not responsible for bricked devices or data loss.**
```