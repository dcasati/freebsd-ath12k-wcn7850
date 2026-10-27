# freebsd-ath12k-wcn7850

Patches that make the Qualcomm WCN7850 Wi-Fi card work in station mode
on FreeBSD, using the in-tree ath12k driver (`sys/contrib/dev/athk/ath12k`)
through LinuxKPI.

**Status:** WPA2-PSK station mode works on 2.4 GHz (20 MHz) and 5 GHz
(HT40/VHT80) on FreeBSD 15.1, with unattended bring-up at boot, DHCP
and ping. Test results are in
[results/2026-10-27](results/2026-10-27/README.md), including a boot
[dmesg](results/2026-10-27/dmesg.boot). The hardware runs used the
previous revision of the stable/15 series; the current one adds style,
module-dependency and debugfs build fixes and has been build-tested.

![Architecture overview](docs/figures/fig1-architecture.svg)

More diagrams are in [docs/figures](docs/figures/).

## How this was made, and what is asked

The author is a long-time FreeBSD user, not a kernel developer. Most of
the code was written with an AI coding assistant (GitHub Copilot) under
his direction; he ran all hardware tests. Treat this as a working proof
of concept and a reference, not as commit-ready code. Feedback, review
of the design questions in [DEVELOPER-NOTES.md](DEVELOPER-NOTES.md),
and testing on other hardware are welcome.

## What's here

| Path | Contents |
|------|----------|
| `patches/stable-15/` | 0001-0010 against `stable/15` at `169e254b` (tested on hardware) |
| `patches/main/` | The same 10 patches against `main` at `91bff7d7ed4` (build-tested only) |
| `patches/local/` | 0011-0014, not for upstream: kernel configs, test harnesses, Kyua hookup, rc.d script |
| `patches/linuxkpi-txq-leak/` | Independent LinuxKPI 802.11 fix: free per-TID txqs in `lkpi_lsta_free()` |
| `tools/` | `ath12k_wlan.rc` (rc.d script), `plot-results.pl` (CSV to SVG) |
| `results/` | Hardware test results, charts and raw data |
| `DEVELOPER-NOTES.md` | Test detail, patch split, design questions, known limitations |

Changes to vendor code under `sys/contrib/dev/athk` are wrapped in
`#if defined(__FreeBSD__)`, with the Linux code kept under `#else`.
QMI and the MHI host are implemented in LinuxKPI, so ath12k keeps its
stock `qmi_handle_init()` path. `if_ath12k.ko` is not yet hooked into
`sys/modules/Makefile`.

## Quick start (stable/15)

```sh
git clone https://github.com/freebsd/freebsd-src.git && cd freebsd-src
git checkout -b ath12k-wcn7850 169e254b8440c010139b1351f46b70bc7ad3d5cb
git am /path/to/freebsd-ath12k-wcn7850/patches/stable-15/*.patch
git am /path/to/freebsd-ath12k-wcn7850/patches/local/*.patch   # optional

make buildkernel KERNCONF=GENERIC
make installkernel KERNCONF=GENERIC KODIR=/boot/kernel.ath12k
```

For `main`, check out `91bff7d7ed461360bc992dcd411703db6cd6d2a1` and
apply `patches/main/*.patch` instead. The txq leak fix is recommended if
you unload and reload the driver; it applies on its own to either base:
`git am /path/to/freebsd-ath12k-wcn7850/patches/linuxkpi-txq-leak/*.patch`.

**Firmware.** The driver reads the raw images from
`/boot/firmware/ath12k/WCN7850/hw2.0/`. Do not also load the
`ath12k_wcn7850_fw` KLD: devmatch(8) loads `if_ath12k` early, and the
KLD then fails with `already registered` / `error 6`. The
`kldload: ... Unsupported file layout` lines at attach are harmless;
firmware(9) tries each image as a KLD before reading the raw file.

**Regulatory.** Set the country in loader.conf(5):

```
hw.ath12k.country="CA"   # ISO 3166 alpha-2
```

**Boot.** Install `tools/ath12k_wlan.rc` as
`/usr/local/etc/rc.d/ath12k_wlan` and set `ath12k_wlan_enable="YES"` in
rc.conf(5). With `ath12k_wlan_dhcp="YES"` (the default), dhclient(8) is
started by a `wpa_cli -a` action script on association, so late
associations still get a lease. Do not leave backup copies in `rc.d`;
rc(8) runs every file there except `*.bak`, `*.orig`, `*.OLD`, `*~` and
`*,v`.

## Known issues

- After each unload/reload, `idr`, `taskqueue` and `lkpikmalloc` still
  grow slightly. The source is not yet known.
- In one of four delayed-association tests, traffic did not resume after
  reconnect until the service was restarted. That run overlapped with
  `lkpi_regulatory_test` loads, which register a second LinuxKPI 802.11
  device. Run the Kyua kernel tests on a machine that is not using Wi-Fi.
- Not supported or not tested: 6 GHz, 160 MHz, 2.4 GHz 40 MHz,
  WPA3/SAE/PMF, suspend/resume. Tested with one host, one card and
  essentially one access point.

The full list is in [DEVELOPER-NOTES.md](DEVELOPER-NOTES.md).

## License

This repository is BSD-2-Clause ([LICENSE](LICENSE)). Files touched by
the patches keep their SPDX license:

| Area | License |
|---|---|
| `sys/contrib/dev/athk` (ath12k, plus small ath10k/ath11k changes; new `dp_cc.h`) | BSD-3-Clause-Clear |
| `sys/compat/linuxkpi` (new MHI/QMI code), `sys/net80211`, `ath12k.4`, `tests/`, `tools/` | BSD-2-Clause |
| `sys/tests/linuxkpi_wlan` (local only) | BSD-2-Clause, or BSD-3-Clause-Clear where ath12k tables are reused |

No GPL code was intentionally used. The Linux MHI and QMI code is
GPL-2.0, so the LinuxKPI versions were written against the Linux header
interfaces (`linux/mhi.h`, `linux/soc/qcom/qmi.h`), not ported. OpenBSD
qwz(4) was consulted for the WCN7850 MHI boot sequence, not copied. A
line comparison against those sources (2026-10-27) found no shared lines
beyond `#include` lines and Linux API calls; this rules out verbatim
copying, not paraphrase.

**AI assistance:** most of this code was written with an AI coding assistant (GitHub Copilot) under the author's direction, and is shared under the licenses above. The FreeBSD Project has not yet published a policy on AI-assisted contributions; this work will follow it once it exists.
