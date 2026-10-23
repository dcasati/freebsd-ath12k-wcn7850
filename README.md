# freebsd-ath12k-wcn7850

Qualcomm WCN7850 (ath12k) Wi-Fi bring-up on native FreeBSD 15.1 through LinuxKPI.

Status: station mode with WPA2-PSK works. Verified: unattended boot via rc.d, DHCP, and ping on 5 GHz channel 44.

## Layout

| Path | Contents |
|------|----------|
| `patches/0001-0008` | Patch series against freebsd-src `main` at `169e254b` (hardware-validated) |
| `tools/ath12k_wlan.rc` | rc.d script that brings up `wlan0` at boot (also included in patch 0006) |

## Apply and build

```sh
git clone https://github.com/freebsd/freebsd-src.git && cd freebsd-src
git checkout -b ath12k-wcn7850 169e254b8440c010139b1351f46b70bc7ad3d5cb
git am /path/to/freebsd-ath12k-wcn7850/patches/*.patch

make buildkernel KERNCONF=GENERIC
make installkernel KERNCONF=GENERIC KODIR=/boot/kernel.ath12k
```

Firmware: the driver reads the raw images from `/boot/firmware/ath12k/WCN7850/hw2.0/`. Do not also `kldload` the firmware kld (`ath12k_wcn7850_fw`). `devmatch` loads `if_ath12k` early in boot, so the kld then fails with `firmware_register: ... already registered` / `MOD_LOAD ... error 6`. The `kldload: ... Unsupported file layout` lines at attach are harmless: firmware(9) probes each raw image as a kld before falling back to reading the file.

Install `tools/ath12k_wlan.rc` as `/usr/local/etc/rc.d/ath12k_wlan` and set `ath12k_wlan_enable="YES"`. Keep backups out of `rc.d`: `rc` runs every file there except `*.bak`, `*.orig`, `*.OLD`, `*~` and `*,v`.

Tunables (`/boot/loader.conf`):

```
hw.ath12k.country="CA"   # ISO 3166 alpha-2 regulatory country
```

## License

BSD-2-Clause, see [LICENSE](LICENSE). Modified upstream files keep their original licenses: ath12k is BSD-3-Clause-Clear, LinuxKPI is BSD-2-Clause.
