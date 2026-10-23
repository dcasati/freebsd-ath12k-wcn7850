# freebsd-ath12k-wcn7850

Qualcomm WCN7850 (ath12k) Wi-Fi bring-up on native FreeBSD 15.1 through LinuxKPI.

Status: station mode with WPA2-PSK works. Verified on hardware: unattended boot via rc.d, DHCP and ping on 5 GHz channel 44 and 2.4 GHz channel 1. The restructured series compiles to the same objects as the hardware-tested build, except that two log messages are demoted to debug output.

## Layout

| Path | Contents |
|------|----------|
| `patches/stable-15/0001-0007` | Upstream candidate series against freebsd-src `stable/15` at `169e254b` (hardware-validated base) |
| `patches/main/0001-0007` | The same series rebased onto freebsd-src `main` at `91bff7d7ed4` (no conflicts) |
| `patches/local/0008-0010` | Local only, not for upstream: ATH12KHOST/ATH12KLAB kernel configs, test harnesses, rc.d script. Apply on top of `stable-15` |
| `tools/ath12k_wlan.rc` | rc.d script that brings up `wlan0` at boot (also in `local/0010`) |

The upstream series is split for review: one ath12k Makefile fix, the net80211 hook, LinuxKPI primitives, LinuxKPI MHI/QMI, LinuxKPI 802.11, ath12k WCN7850 support, and the ath12k 4-way handshake fix.

- Changes to vendor code in `sys/contrib/dev/athk` are additive only: each one is wrapped in `#if defined(__FreeBSD__)` and keeps the original Linux code under `#else`.
- Native code follows style(9).
- On both bases, every commit builds GENERIC and the LinuxKPI/wlan/athk/iwlwifi/rtw/mt76 modules with no new warnings.
- `if_ath12k.ko` builds from 0006 on. The module is not in `sys/modules/Makefile`.
- `ath11k` fails to build at both bases, before any patch is applied.

## Apply and build

```sh
git clone https://github.com/freebsd/freebsd-src.git && cd freebsd-src
git checkout -b ath12k-wcn7850 169e254b8440c010139b1351f46b70bc7ad3d5cb
git am /path/to/freebsd-ath12k-wcn7850/patches/stable-15/*.patch
git am /path/to/freebsd-ath12k-wcn7850/patches/local/*.patch   # optional

make buildkernel KERNCONF=GENERIC
make installkernel KERNCONF=GENERIC KODIR=/boot/kernel.ath12k
```

For `main`, check out `91bff7d7ed461360bc992dcd411703db6cd6d2a1` and apply `patches/main/*.patch` instead.

Firmware: the driver reads the raw images from `/boot/firmware/ath12k/WCN7850/hw2.0/`. Do not also `kldload` the firmware kld (`ath12k_wcn7850_fw`). `devmatch` loads `if_ath12k` early in boot, so the kld then fails with `firmware_register: ... already registered` / `MOD_LOAD ... error 6`. The `kldload: ... Unsupported file layout` lines at attach are harmless: firmware(9) probes each raw image as a kld before falling back to reading the file.

Install `tools/ath12k_wlan.rc` as `/usr/local/etc/rc.d/ath12k_wlan` and set `ath12k_wlan_enable="YES"`. Keep backups out of `rc.d`: `rc` runs every file there except `*.bak`, `*.orig`, `*.OLD`, `*~` and `*,v`.

Tunables (`/boot/loader.conf`):

```
hw.ath12k.country="CA"   # ISO 3166 alpha-2 regulatory country
```

## License

BSD-2-Clause, see [LICENSE](LICENSE). Modified upstream files keep their original licenses: ath12k is BSD-3-Clause-Clear, LinuxKPI is BSD-2-Clause.
