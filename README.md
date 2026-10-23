# freebsd-ath12k-wcn7850

Qualcomm WCN7850 (ath12k) Wi-Fi bring-up on native FreeBSD 15.1 through LinuxKPI.

Status: station mode with WPA2-PSK works. Verified: unattended boot via rc.d, DHCP, and ping on 5 GHz channel 44.

## Layout

| Path | Contents |
|------|----------|
| `patches/0001-0008` | Patch series against freebsd-src `main` at `169e254b` (hardware-validated) |
| `patches/pending/0009` | Removal of the M4/controlled-port experiment code. Unit-tested, **not yet validated on hardware** |
| `tools/ath12k_wlan.rc` | rc.d script that brings up `wlan0` at boot (also included in patch 0006) |

## Apply and build

```sh
git clone https://github.com/freebsd/freebsd-src.git && cd freebsd-src
git checkout -b ath12k-wcn7850 169e254b8440c010139b1351f46b70bc7ad3d5cb
git am /path/to/freebsd-ath12k-wcn7850/patches/*.patch
# optional, untested on hardware:
# git am /path/to/freebsd-ath12k-wcn7850/patches/pending/*.patch

make buildkernel KERNCONF=GENERIC
make installkernel KERNCONF=GENERIC KODIR=/boot/kernel.ath12k
```

Firmware: install the WCN7850 firmware package (`wifi-firmware-ath12k-kmod-wcn7850_hw20`) and load it before `if_ath12k`.

Tunables (`/boot/loader.conf`):

```
hw.ath12k.country="CA"   # ISO 3166 alpha-2 regulatory country
```

## License

BSD-2-Clause, see [LICENSE](LICENSE). Modified upstream files keep their original licenses: ath12k is BSD-3-Clause-Clear, LinuxKPI is BSD-2-Clause.
