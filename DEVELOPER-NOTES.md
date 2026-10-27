# Developer notes: WCN7850 (ath12k) on FreeBSD via LinuxKPI

Detail behind the freebsd-wireless RFC email. See the README for the
license and AI-assistance notes. The code was written by an AI coding
assistant (GitHub Copilot) under my direction; I am a FreeBSD user, not
a kernel developer. The questions below came out of that work; I offer
them to reviewers as open points, not as settled designs.

```
Hardware and setup
------------------

- Qualcomm WCN7850 hw2.0, firmware WLAN.HMT.1.1.c7-00108, on one amd64
  host running FreeBSD 15.1-STABLE.
- Access point: GL.iNet GL-MT3000 (MT7981, OpenWrt 21.02), WPA2-PSK
  CCMP. 5 GHz on channel 36 with VHT80 and 2 spatial streams; 2.4 GHz
  on channel 1 with HT20.
- The series (10 commits) is against main (91bff7d7ed4). An equivalent
  stable/15 series (169e254b) is the one that was tested on hardware.
  The main series was build-tested but not booted.

What works
----------

- Station mode with WPA2-PSK on 2.4 GHz (20 MHz) and 5 GHz (HT40 and
  VHT80), with unattended bring-up at boot, DHCP and ping.
- Firmware download over MHI, QMI over a minimal QRTR endpoint, and the
  stock ath12k qmi_handle_init() path.
- Strict self-managed regulatory with a hw.ath12k.country tunable.
  NO_IR and DFS channels are passive. 40/80 MHz is enabled on 5 GHz only
  inside allowed 80 MHz blocks.
- kldunload/kldload of if_ath12k, including while associated.

Test results (hardware: stable/15 kernel, earlier revision)
-----------------------------------------------------------

The hardware runs below used the previous revision of the stable/15
series. The current revision changes style, wraps the ath10k/ath11k
edits in __FreeBSD__, adds module dependencies and the debugfs build
fixes; it was build-tested, and the hardware runs have not been
repeated on it yet.


- Unload/reload: 20/20 unloads clean, no WMI timeouts. 19/20 came back
  unattended in 13-21 s. In one cycle my local rc script's dhclient
  gave up before a late 2.4 GHz association; that is not a driver
  issue, and the script has since been changed (not re-run yet).
  Hot unload while associated: 10/10.
- Reconnect (wpa_cli disconnect/reconnect): 20/20 on 5 GHz, mean
  3.65 s (19 x 3 s, 1 x 16 s); 20/20 on 2.4 GHz, all 3 s, with
  "scanvalid 10".
- Ping soak: 5 GHz 30 min 1800/1800 (avg 2.44 ms, max 14.8 ms); 5 GHz
  15 min 900/900 (avg 2.60 ms, max 11.2 ms); 2.4 GHz 15 min 900/900
  (avg 5.07 ms, max 57.4 ms).
- iperf3 against the AP, 5 GHz VHT80: TCP down 337 Mb/s (370 with 4
  streams), TCP up 338 Mb/s, UDP down 350 Mb/s at 0% loss. The AP's
  CPU was the limit, not the WLAN. 2.4 GHz HT20: 28-34 Mb/s each way.
- The in-kernel regulatory test and the regulatory model test pass.
- Build, on both bases, amd64: GENERIC plus the linuxkpi,
  linuxkpi_wlan, wlan, ath10k, iwlwifi, rtw88, rtw89, mt76 and ath12k
  modules with 0 errors and 0 warnings; ath12k with ATH12K_DEBUGFS=1
  and lindebugfs also 0/0. The ath11k module does not build at either
  base (4 pre-existing errors: of_reserved_mem.h missing, pointer types
  in wmi.c); its mac.c, which 05 changes, compiles cleanly. Other
  architectures and LINT have not been built yet.
- Kyua, tests/sys/compat/linuxkpi (a local test harness, not part of
  the series; 5 cases, one needs the hardware unattached): 3 passed,
  2 skipped, 0 failed on the host as root.
- checkstyle9: 0 errors, 0 warnings on native FreeBSD code. The
  remaining reports are in Linux-style code under sys/contrib.


Separate LinuxKPI fix
---------------------

While testing unload/reload I found that lkpi_lsta_free() never frees
the per-TID lkpi_txq allocations made in lkpi_lsta_alloc(). With
if_ath12k that leaked 64 allocations (16 KiB) of M_LKPI80211 per
cycle. With the fix, M_LKPI80211 is unchanged over 20 cycles. It is
independent of ath12k, should affect every LinuxKPI wireless driver,
and I will send it on its own first.

How the series is split
-----------------------

  Separate: LinuxKPI: 802.11: free per-TID txqs when freeing an lsta
     (patches/linuxkpi-txq-leak, +37/-1)

  01 ath12k: fix wifi7/hal.c path in module Makefile (+1/-1)
  02 net80211: add optional controlled-port authorize hook (+12/-1)
  03 LinuxKPI: add primitives needed by ath12k (+431/-131)
  04 LinuxKPI: implement MHI host and QMI interfaces (+3436/-56)
  05 LinuxKPI: 802.11 station controlled port and strict regulatory
     (+1693/-145)
  06 ath12k: add WCN7850 support on FreeBSD (+3686, all vendor
     changes under #if defined(__FreeBSD__); includes the
     MODULE_VERSION/MODULE_DEPEND declarations)
  07 ath12k: keep 4-way peers unauthorized on rate-update peer_assoc
     (+21)
  08 ath12k.4: add manual page (+171)
  09 LinuxKPI: add helpers needed by ath12k debugfs (+67/-3)
  10 ath12k: fix ATH12K_DEBUGFS build on FreeBSD (+5)
  later, optional: tests/sys/compat/linuxkpi Kyua tests.

Design questions
----------------

Q1. QMI placement. linux/soc/qcom/qmi.h in the tree is stubs with an
    "XXX-TODO need implementation somewhere" note. I implemented the
    QMI handle API and a minimal QRTR endpoint per MHI controller in
    LinuxKPI (linux_qmi.c, linux_qmi_codec.c, linux_mhi.c), so ath12k
    keeps its stock QMI code. Is LinuxKPI the right home, or would you
    rather keep this in the driver?

Q2. dp.c DMA ownership ("quarantine"). To make teardown after a failed
    or partial start safe, 0006 adds about 620 lines to dp.c (plus
    dp.h and dp_cc.h) to track which DMA memory the device may still
    write, and to never free it early. It is all under __FreeBSD__, but
    it is the largest part of the vendor diff. Should this logic move
    into LinuxKPI or a non-contrib helper, with only hook calls left in
    dp.c?

Q3. rc_update before sta add. lkpi_lsta_alloc() ->
    lkpi_sta_sync_from_ni() triggers a rate-control update before the
    driver has added the station. ath12k logs "mac sta rc update failed
    to fetch link sta" (seen 3 times in 20 unload cycles, and on
    reconnects). Right after association, the SUPP_RATES update also
    made ath12k re-send peer_assoc with WMI_PEER_AUTH set, and the
    firmware then dropped EAPOL M4. Patch 07 works around that in the
    driver. Should LinuxKPI instead defer rc_update until the station
    is added and authorized?

Q4. %pM. LinuxKPI's printk does not support %pM, so these messages
    print a pointer followed by "M". Would you take %pM (and similar)
    support in LinuxKPI, or prefer the drivers to be adjusted?

Q5. Controlled-port hook in net80211. 02 adds an optional
    iv_port_authorize vap method. ieee80211_node_authorize() asks the
    driver first. With WPA2, the link-state UP notification is delayed
    until the node is authorized, so dhclient does not start before
    the port opens. LinuxKPI uses it to gate the port on a TX-acked
    EAPOL M4, installed keys and firmware peer authorization. Is a new
    vap method acceptable, or is there a better existing place? The
    struct change also affects an MFC to stable/15.

Q6. Strict regulatory in LinuxKPI. 05 adds opt-in handling of
    self-managed regulatory domains. Drivers that do not opt in keep
    their current behaviour. Is LinuxKPI the right layer?

Q7. 05 changes cfg80211_find_vendor_ie() to return a const pointer, as
    in Linux, and adapts ath10k and ath11k mac.c under
    #if defined(__FreeBSD__), keeping the upstream code in #else. Is
    that acceptable, or would you rather keep the old prototype?

Known limitations
-----------------

- Not supported or not tested: 6 GHz, 160 MHz, 2.4 GHz 40 MHz,
  WPA3/SAE/PMF (net80211 and wpa_supplicant driver_bsd),
  suspend/resume (my host has no S3).
- Tested with one host, one card and essentially one access point.
- After each unload/reload, idr (768 B), taskqueue (304 B) and
  lkpikmalloc (80 B) still grow. The source is not yet attributed.
- In about 30% of wpa_cli disconnects, the AP logs no DIS-ASSOC. It did
  not reproduce with LinuxKPI TX tracing on; reconnects are unaffected.
- With the default "scanvalid 60", reconnects to this AP could stall
  for about 65 s. The cause is in net80211: it answers
  wpa_supplicant's SCAN_CHECK from its cache. "scanvalid 10" bounds it.
- ath12k logs "Received with invalid mcs in VHT mode 10/11" for the
  MT7981's non-standard VHT MCS 10/11. The message is rate-limited, as
  in Linux.
- ATH12K_DEBUGFS builds (09, 10) but has not been runtime-tested.
- if_ath12k is not connected to sys/modules/Makefile, and ath12k.4 is
  not in man4/Makefile (same as ath10k.4).

```
