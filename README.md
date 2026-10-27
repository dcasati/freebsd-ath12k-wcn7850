# freebsd-ath12k-wcn7850

Qualcomm WCN7850 (ath12k) Wi-Fi bring-up on native FreeBSD 15.1 through LinuxKPI.

Status: station mode with WPA2-PSK works on 2.4 GHz (20 MHz) and 5 GHz (HT40/VHT80). Verified on hardware: unattended boot via rc.d, DHCP and ping on 5 GHz and 2.4 GHz. Full results with charts and raw data: [results/2026-10-27](results/2026-10-27/README.md).

- Soaks: 30 min on 5 GHz with 1800/1800 pings, and 15 min each on 5 GHz and 2.4 GHz with 900/900 pings. 0% loss in every run.
- Disconnect/reconnect: 20/20 cycles passed on 5 GHz (mean 3.65 s) and 20/20 on 2.4 GHz (3 s).
- Driver unload/reload: 20/20 unloads clean, plus 10/10 hot unloads while associated. No WMI timeouts in either.
- Kernel memory: with the separate LinuxKPI txq fix, `lkpi80211` no longer grows across unload/reload (it grew 16 KiB per cycle before).
- iperf3 on 5 GHz VHT80: TCP 337 Mb/s down (370 Mb/s with 4 streams) and 338 Mb/s up; UDP 350 Mb/s down at 0% loss. These numbers are limited by the access point's CPU.
- The in-kernel regulatory test and the regulatory model test pass.
- Kyua: `tests/sys/compat/linuxkpi` (local patch 0013) runs the LinuxKPI test modules: 3 passed and 2 skipped (one needs a WCN7850 with no driver attached, one was not run on this host), 0 failed.

Open issues: idr/taskqueue/lkpikmalloc still grow slightly on each unload/reload; in one of four delayed-association tests traffic did not resume after reconnect (TX/RX errors, no DHCP lease) until the service was restarted. That run overlapped with `lkpi_regulatory_test` loads on the live kernel, which register a second LinuxKPI 802.11 device, so run the Kyua kernel tests on a machine that is not using Wi-Fi until this is understood.

QMI is implemented in LinuxKPI (`linux_qmi*.c`), and ath12k uses the stock `qmi_handle_init` path. Strict regulatory enables 40/80 MHz on 5 GHz only within allowed 80 MHz blocks. NO_IR and DFS channels are passive. 160 MHz and 6 GHz are not enabled.

## Layout

| Path | Contents |
|------|----------|
| `patches/stable-15/0001-0010` | Upstream candidate series against freebsd-src `stable/15` at `169e254b` (hardware-validated base) |
| `patches/main/0001-0010` | The same series rebased onto freebsd-src `main` at `91bff7d7ed4` (no conflicts) |
| `patches/local/0011-0014` | Local only, not for upstream: ATH12KHOST/ATH12KLAB kernel configs, test harnesses, Kyua hookup for the test modules (`tests/sys/compat/linuxkpi`), rc.d script. Apply on top of `stable-15` |
| `patches/linuxkpi-txq-leak/0001` | Separate LinuxKPI 802.11 fix, independent of ath12k: free the per-TID txqs in `lkpi_lsta_free()`. Applies unchanged to `stable/15`, `main`, or on top of either series |
| `tools/ath12k_wlan.rc` | rc.d script that brings up `wlan0` at boot (also in `local/0014`) |
| `tools/plot-results.pl` | Renders the CSV data under `results/` as SVG charts |
| `DEVELOPER-NOTES.md` | Detail for reviewers: hardware test results, patch split, design questions, known limitations |
| `results/` | Hardware test results: numbers, charts, raw data |

The upstream series is split for review: one ath12k Makefile fix, the net80211 hook, LinuxKPI primitives, LinuxKPI MHI/QMI, LinuxKPI 802.11, ath12k WCN7850 support, the ath12k 4-way handshake fix, the ath12k(4) manual page, the LinuxKPI helpers for ath12k debugfs, and the ath12k debugfs build fix.

- Changes to vendor code in `sys/contrib/dev/athk` are additive only: each one is wrapped in `#if defined(__FreeBSD__)` and keeps the original Linux code under `#else`.
- Native code follows style(9): `tools/build/checkstyle9.pl` reports 0 errors and 0 warnings outside `sys/contrib`. `mandoc -Tlint` is clean on both manual pages.
- On both bases, every commit builds GENERIC and the LinuxKPI/wlan/athk/iwlwifi/rtw/mt76 modules with no new warnings. This was checked per commit after the latest fold.
- `if_ath12k.ko` builds from 0006 on, and with `ATH12K_DEBUGFS=1` from 0010 on. It declares `MODULE_VERSION` and depends on `linuxkpi`, `linuxkpi_wlan` (and `lindebugfs` with debugfs), so `kldload` pulls them in on kernels without them compiled in. The module is not in `sys/modules/Makefile`.
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

The LinuxKPI txq leak fix is separate and recommended, especially if you unload and reload the driver: `git am /path/to/freebsd-ath12k-wcn7850/patches/linuxkpi-txq-leak/*.patch`. It does not depend on the ath12k series.

Firmware: the driver reads the raw images from `/boot/firmware/ath12k/WCN7850/hw2.0/`. Do not also `kldload` the firmware kld (`ath12k_wcn7850_fw`). `devmatch` loads `if_ath12k` early in boot, so the kld then fails with `firmware_register: ... already registered` / `MOD_LOAD ... error 6`. The `kldload: ... Unsupported file layout` lines at attach are harmless: firmware(9) probes each raw image as a kld before falling back to reading the file.

Install `tools/ath12k_wlan.rc` as `/usr/local/etc/rc.d/ath12k_wlan` and set `ath12k_wlan_enable="YES"`. Keep backups out of `rc.d`: `rc` runs every file there except `*.bak`, `*.orig`, `*.OLD`, `*~` and `*,v`.

With `ath12k_wlan_dhcp="YES"` (default) the script does not start `dhclient` right away: a `wpa_cli -a` action daemon starts it on association, so DHCP also works when association happens late.

Tunables (`/boot/loader.conf`):

```
hw.ath12k.country="CA"   # ISO 3166 alpha-2 regulatory country
```

## License

The contents of this repository (patches, tools, results) are offered under BSD-2-Clause, see [LICENSE](LICENSE). Every file touched by the patches keeps the license in its SPDX header:

| Area | License | Notes |
|---|---|---|
| `sys/contrib/dev/athk/ath12k` (and the small ath10k/ath11k adaptations) | BSD-3-Clause-Clear | Qualcomm/Linux Foundation vendor driver; changes are under `#if defined(__FreeBSD__)`. New file `dp_cc.h` uses the same license. |
| `sys/compat/linuxkpi` (incl. new `linux_mhi.c` code, `linux_qmi*.c/h`, `linux_80211_sta.h`) | BSD-2-Clause | New files carry `Copyright (c) 2026 Diego Casati`. |
| `sys/net80211` | BSD-2-Clause | +12/-1. |
| `share/man/man4/ath12k.4`, `tests/`, `tools/` | BSD-2-Clause | |
| `sys/tests/linuxkpi_wlan` (local only) | BSD-2-Clause, or BSD-3-Clause-Clear where a test reuses ath12k tables | |

No GPL code was intentionally used. The Linux MHI host and QMI code (`drivers/bus/mhi`, `drivers/soc/qcom/qmi_*.c`) is GPL-2.0, so the LinuxKPI MHI/QMI implementations here were written against the Linux *header* interfaces (`linux/mhi.h`, `linux/soc/qcom/qmi.h`) rather than ported. OpenBSD qwz(4) (ISC) was consulted as a behavioural reference for the WCN7850 MHI boot sequence, not copied.

A whitespace-normalised line comparison (2026-10-27) of the new MHI/QMI code (~1300 non-trivial lines) against Linux master `drivers/bus/mhi/host/{boot,init,main,pm}.c`, `internal.h`, `drivers/bus/mhi/common.h`, `drivers/soc/qcom/qmi_{encdec,interface}.c` and OpenBSD `sys/dev/pci/if_qwz_pci.c` found no shared lines other than `#include` lines and Linux API calls (for example `release_firmware(firmware);`). That check rules out verbatim copying, not paraphrase.

**AI assistance:** most of this code was written with an AI coding assistant (GitHub Copilot) under the author's direction, and is shared under the licenses above. The FreeBSD Project has not yet published a policy on AI-assisted contributions; this work will follow it once it exists.
