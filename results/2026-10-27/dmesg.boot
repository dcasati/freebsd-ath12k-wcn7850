---<<BOOT>>---
Copyright (c) 1992-2025 The FreeBSD Project.
Copyright (c) 1979, 1980, 1983, 1986, 1988, 1989, 1991, 1992, 1993, 1994
	The Regents of the University of California. All rights reserved.
FreeBSD is a registered trademark of The FreeBSD Foundation.
FreeBSD 15.1-STABLE #0 f23c4ecc6197-dirty: Tue Oct 27 09:44:20 MDT 2026
    user@host:/usr/obj/usr/src/amd64.amd64/sys/ATH12KHOST amd64
FreeBSD clang version 21.1.8 (https://github.com/llvm/llvm-project.git llvmorg-21.1.8-0-g2078da43e25a)
WARNING: WITNESS option enabled, expect reduced performance.
VT(efifb): resolution 1920x1200
CPU: AMD Ryzen AI 7 PRO 360 w/ Radeon 880M           (1996.37-MHz K8-class CPU)
  Origin="AuthenticAMD"  Id=0xb20f40  Family=0x1a  Model=0x24  Stepping=0
  Features=0x178bfbff<FPU,VME,DE,PSE,TSC,MSR,PAE,MCE,CX8,APIC,SEP,MTRR,PGE,MCA,CMOV,PAT,PSE36,CLFLUSH,MMX,FXSR,SSE,SSE2,HTT>
  Features2=0x7ed8320b<SSE3,PCLMULQDQ,MON,SSSE3,FMA,CX16,SSE4.1,SSE4.2,MOVBE,POPCNT,AESNI,XSAVE,OSXSAVE,AVX,F16C,RDRAND>
  AMD Features=0x2e500800<SYSCALL,NX,MMX+,FFXSR,Page1GB,RDTSCP,LM>
  AMD Features2=0x75c237ff<LAHF,CMP,SVM,ExtAPIC,CR8,ABM,SSE4A,MAS,Prefetch,OSVW,IBS,SKINIT,WDT,TCE,Topology,PCXC,PNXC,DBE,PL2I,MWAITX,ADMSKX>
  Structured Extended Features=0xf1bf97ab<FSGSBASE,TSCADJ,BMI1,AVX2,SMEP,BMI2,ERMS,INVPCID,PQM,PQE,AVX512F,AVX512DQ,RDSEED,ADX,SMAP,AVX512IFMA,CLFLUSHOPT,CLWB,AVX512CD,SHA,AVX512BW,AVX512VL>
  Structured Extended Features2=0x19405fde<AVX512VBMI,UMIP,PKU,OSPKE,AVX512VBMI2,GFNI,VAES,VPCLMULQDQ,AVX512VNNI,AVX512BITALG,AVX512VPOPCNTDQ,RDPID,MOVDIRI,MOVDIR64B>
  Structured Extended Features3=0x10000110<FSRM,AVX512VP2INTERSECT,L1DFL>
  Structured Extended Features4=0x30
  XSAVE Features=0xf<XSAVEOPT,XSAVEC,XINUSE,XSAVES>
  AMD Extended Feature Extensions ID EBX=0x791ef257<CLZERO,IRPerf,XSaveErPtr,RDPRU,BE,WBNOINVD,IBPB,INT_WBINVD,IBRS,STIBP,STIBP_ALWAYSON,PREFER_IBRS,SAMEMODE_IBRS,NOLMSLE,SSBD,CPPC,PSFD,BTC_NO,IBPB_RET>
  SVM: NP,NRIP,VClean,AFlush,DAssist,NAsids=32768
  TSC: P-state invariant, performance statistics
real memory  = 34359738368 (32768 MB)
avail memory = 32549982208 (31042 MB)
Event timer "LAPIC" quality 600
ACPI APIC Table: <LENOVO TP-R2N  >
FreeBSD/SMP: Multiprocessor System Detected: 16 CPUs
FreeBSD/SMP: Non-uniform topology
random: registering fast source Intel Secure Key Seed
random: fast provider: "Intel Secure Key Seed"
random: unblocking device.
ioapic0 <Version 2.1> irqs 0-23
ioapic1 <Version 2.1> irqs 24-55
Launching APs: 1 15 6 3 10 14 7 4 2 12 5 11 8 13 9
random: entropy device external interface
kbd1 at kbdmux0
efirtc0: <EFI Realtime Clock>
efirtc0: registered as a time-of-day clock, resolution 1.000000s
smbios0: <System Management BIOS> at iomem 0x3e06d000-0x3e06d017
smbios0: Entry point: v3 (64-bit), Version: 3.4
aesni0: <AES-CBC,AES-CCM,AES-GCM,AES-ICM,AES-XTS,SHA1,SHA256>
acpi0: <LENOVO TP-R2N>
acpi_ec0: <Embedded Controller: GPE 0x7, ECDT> port 0x62,0x66 on acpi0
AMD-Vi: IVRS Info VAsize = 64 PAsize = 48 GVAsize = 2 flags:0
hpet0: <High Precision Event Timer> iomem 0xfed00000-0xfed003ff irq 0,8 on acpi0
Timecounter "HPET" frequency 14318180 Hz quality 950
Event timer "HPET" frequency 14318180 Hz quality 350
Event timer "HPET1" frequency 14318180 Hz quality 350
Event timer "HPET2" frequency 14318180 Hz quality 350
atrtc0: <AT realtime clock> port 0x70-0x71,0x72-0x73 on acpi0
atrtc0: registered as a time-of-day clock, resolution 1.000000s
Event timer "RTC" frequency 32768 Hz quality 0
attimer0: <AT timer> port 0x40-0x43 on acpi0
Timecounter "i8254" frequency 1193182 Hz quality 0
Event timer "i8254" frequency 1193182 Hz quality 100
acpi_timer0: <32-bit timer at 3.579545MHz> port 0x408-0x40b on acpi0
Timecounter "ACPI" frequency 3579545 Hz quality 900
isab0: <ACPI Generic ISA bridge> on acpi0
isa0: <ISA bus> on isab0
acpi_button0: <Power Button> on acpi0
pcib0: <ACPI Host-PCI bridge> on acpi0
pci0: <ACPI PCI bus> on pcib0
amdviiommu0 at device 0.2 on pci0
pcib1: <ACPI PCI-PCI bridge> at device 1.1 on pci0
pcib2: <ACPI PCI-PCI bridge> at device 1.2 on pci0
pcib3: <ACPI PCI-PCI bridge> at device 2.1 on pci0
pci1: <ACPI PCI bus> on pcib3
nvme0: <Generic NVMe Device> mem 0xb0e00000-0xb0e03fff at device 0.0 on pci1
pcib4: <ACPI PCI-PCI bridge> at device 2.3 on pci0
pci2: <ACPI PCI bus> on pcib4
pci2: <network> at device 0.0 (no driver attached)
pcib5: <ACPI PCI-PCI bridge> at device 8.1 on pci0
pci3: <ACPI PCI bus> on pcib5
vgapci0: <VGA-compatible display> port 0x1000-0x10ff mem 0x5000000000-0x500fffffff,0xb0000000-0xb01fffff,0xb0400000-0xb047ffff at device 0.0 on pci3
hdac0: <ATI (0x1640) HDA Controller> mem 0xb04c8000-0xb04cbfff at device 0.1 on pci3
pci3: <encrypt/decrypt> at device 0.2 (no driver attached)
xhci0: <XHCI (generic) USB 3.0 controller> mem 0xb0200000-0xb02fffff at device 0.4 on pci3
xhci0: 64 bytes context size, 64-bit DMA
xhci0: xECP capabilities <LEGACY,PROTO,PROTO,DEBUG>
usbus0 on xhci0
usbus0: 5.0Gbps Super Speed USB v3.0
pci3: <multimedia> at device 0.5 (no driver attached)
hdac1: <AMD Raven HDA Controller> mem 0xb04c0000-0xb04c7fff at device 0.6 on pci3
pcib6: <ACPI PCI-PCI bridge> at device 8.2 on pci0
pci4: <ACPI PCI bus> on pcib6
pcib7: <ACPI PCI-PCI bridge> at device 8.3 on pci0
pci5: <ACPI PCI bus> on pcib7
xhci1: <XHCI (generic) USB 3.0 controller> mem 0xb0800000-0xb08fffff at device 0.0 on pci5
xhci1: 64 bytes context size, 64-bit DMA
xhci1: xECP capabilities <LEGACY,PROTO,PROTO,PROTO,DEBUG>
usbus1 on xhci1
usbus1: 5.0Gbps Super Speed USB v3.0
xhci2: <XHCI (generic) USB 3.0 controller> mem 0xb0900000-0xb09fffff at device 0.3 on pci5
xhci2: 64 bytes context size, 64-bit DMA
xhci2: xECP capabilities <LEGACY,PROTO,PROTO,DEBUG>
usbus2 on xhci2
usbus2: 5.0Gbps Super Speed USB v3.0
xhci3: <XHCI (generic) USB 3.0 controller> mem 0xb0a00000-0xb0afffff at device 0.4 on pci5
xhci3: 64 bytes context size, 64-bit DMA
xhci3: xECP capabilities <LEGACY,PROTO,PROTO,DEBUG>
usbus3 on xhci3
usbus3: 5.0Gbps Super Speed USB v3.0
pci5: <serial bus, USB> at device 0.5 (no driver attached)
pci5: <serial bus, USB> at device 0.6 (no driver attached)
isab1: <PCI-ISA bridge> at device 20.3 on pci0
isa1: <ISA bus> on isab1
acpi_lid0: <Control Method Lid Switch> on acpi0
acpi_button1: <Sleep Button> on acpi0
acpi_tz0: <Thermal Zone> on acpi0
cpu0: <ACPI CPU> on acpi0
atkbdc0: <Keyboard controller (i8042)> port 0x60,0x64 irq 1 on acpi0
atkbd0: <AT Keyboard> irq 1 on atkbdc0
kbd0 at atkbd0
atkbd0: [GIANT-LOCKED]
psm0: <PS/2 Mouse> irq 12 on atkbdc0
psm0: [GIANT-LOCKED]
WARNING: Device "psm" is Giant locked and may be deleted before FreeBSD 16.0.
psm0: model Generic PS/2 mouse, device ID 0
acpi_acad0: <AC Adapter> on acpi0
battery0: <ACPI Control Method Battery> on acpi0
ivhd0: <AMD-Vi/IOMMU ivhd in mixed format> on acpi0
ivhd0: Unknown dev entry:0xf0
Variable size IVHD type 0xf0 not supported
ivhd0: Flag:30<IotlbSup,Coherent>
ivhd0: Features(type:0x40) MsiNumPPR = 0 PNBanks= 2 PNCounters= 4
ivhd0: Extended features[31:0]:a2254afa<PPRSup,NXSup,GTSup,<b5>,IASup,GASup,PCSup> HATS = 0x2 GATS = 0x0 GLXSup = 0x1 SmiFSup = 0x1 SmiFRC = 0x1 GAMSup = 0x1 DualPortLogSup = 0x2 DualEventLogSup = 0x2
ivhd0: Extended features[62:32]:246577ef<USSup,PprOvrflwEarlySup,PPRAutoRspSup,BlKStopMrkSup,PerfOptSup,MsiCapMmioSup,GIOSup,EPHSup,InvIotlbSup> Max PASID: 0x2f DevTblSegSup = 0x3 MarcSup = 0x1
ivhd0: supported paging level:7, will use only: 4
ivhd0: device [0x3 - 0xfffe] config:0
ivhd0: device [0xff00 - 0xffff] config:0
ivhd0: PCI cap 0x190b640f@0x40 feature:19<IOTLB,EFR,CapExt>
hwpstate0: <Cool`n'Quiet 2.0> on cpu0
cpufreq0: <CPU frequency control> on cpu0
Timecounter "TSC" frequency 1996244547 Hz quality 1000
Timecounters tick every 1.000 msec
ugen1.1: <AMD XHCI root HUB> at usbus1
ugen2.1: <AMD XHCI root HUB> at usbus2
ugen0.1: <AMD XHCI root HUB> at usbus0
ugen3.1: <AMD XHCI root HUB> at usbus3
uhub0 on usbus1
uhub0: <AMD XHCI root HUB, class 9/0, rev 3.00/1.00, addr 1> on usbus1
uhub1 on usbus2
uhub1: <AMD XHCI root HUB, class 9/0, rev 3.00/1.00, addr 1> on usbus2
uhub2 on usbus3
uhub2: <AMD XHCI root HUB, class 9/0, rev 3.00/1.00, addr 1> on usbus3
ZFS filesystem version: 5
ZFS storage pool version: features support (5000)
uhub3 on usbus0
uhub3: <AMD XHCI root HUB, class 9/0, rev 3.00/1.00, addr 1> on usbus0
hdacc0: <ATI R6xx HDA CODEC> at cad 0 on hdac0
hdaa0: <ATI R6xx Audio Function Group> at nid 1 on hdacc0
pcm0: <ATI R6xx (HDMI)> at nid 3 on hdaa0
pcm1: <ATI R6xx (HDMI)> at nid 5 on hdaa0
pcm2: <ATI R6xx (HDMI)> at nid 7 on hdaa0
pcm3: <ATI R6xx (HDMI)> at nid 9 on hdaa0
hdacc1: <Realtek ALC257 HDA CODEC> at cad 0 on hdac1
hdaa1: <Realtek ALC257 Audio Function Group> at nid 1 on hdacc1
pcm4: <Realtek ALC257 (Analog 2.0+HP/2.0)> at nid 20,33 and 25 on hdaa1
nda0 at nvme0 bus 0 scbus0 target 0 lun 1
nda0: <Micron MTFDKBA1T0TGD-2BK15ABLT 7007P8LN XXXXXXXXXXXX>
nda0: Serial Number XXXXXXXXXXXX
nda0: nvme version 2.0
nda0: 976762MB (2000409264 512 byte sectors)
Trying to mount root from zfs:zroot/ROOT/default []...
WARNING: WITNESS option enabled, expect reduced performance.
uhub2: 2 ports with 2 removable, self powered
uhub1: 2 ports with 2 removable, self powered
uhub3: 2 ports with 2 removable, self powered
uhub0: 7 ports with 7 removable, self powered
ugen3.2: <Belkin Belkin USB-C LAN> at usbus3
ugen0.2: <Chicony Electronics Co.,Ltd. Integrated Camera> at usbus0
ugen1.2: <Goodix Technology Co., Ltd. Goodix USB2.0 MISC> at usbus1
ugen1.3: <vendor 0x05e3 USB2.0 Hub> at usbus1
uhub4 on uhub0
uhub4: <vendor 0x05e3 USB2.0 Hub, class 9/0, rev 2.00/60.60, addr 2> on usbus1
uhub4: MTT enabled
Root mount waiting for: usbus1
uhub4: 2 ports with 2 removable, self powered
ugen1.4: <vendor 0x0489 product 0xe0fc> at usbus1
ugen1.5: <Generic EMV Smartcard Reader> at usbus1
intsmb0: <AMD FCH SMBus Controller> at device 20.0 on pci0
smbus0: <System Management Bus> on intsmb0
ath12k_wifi70: <ath12k_wifi7> mem 0xb0600000-0xb07fffff at device 0.0 on pci2
ath12k_wifi70: Wi-Fi 7 Hardware name: wcn7850 hw2.0
ath12k_wifi70: MSI vectors: 16
kldload: /boot/firmware/ath12k/WCN7850/hw2.0/amss.bin: Unsupported file layout
kldload: /boot/firmware/ath12k/WCN7850/hw2.0/amss.bin: Unsupported file layout
ath12k_wifi70: successfully loaded firmware image 'ath12k/WCN7850/hw2.0/amss.bin'
ath12k_wifi70: chip_id 0x2 chip_family 0x4 board_id 0xff soc_id 0x40170200
ath12k_wifi70: fw_version 0x1103006c fw_build_timestamp 2026-03-06 09:10 fw_build_id QC_IMAGE_VERSION_STRING=WLAN.HMT.1.1.c7-00108-QCAHMTSWPL_V1.0_V2.0_SILICONZ_UPSTREAM-3ath12k_wifi70: successfully loaded firmware image 'ath12k/WCN7850/hw2.0/board-2.bin'
ath12k_wifi70: successfully loaded firmware image 'ath12k/WCN7850/hw2.0/board-2.bin'
ath12k_wifi70: successfully loaded firmware image 'ath12k/WCN7850/hw2.0/board-2.bin'
kldload: /boot/firmware/ath12k/WCN7850/hw2.0/m3.bin: Unsupported file layout
kldload: /boot/firmware/ath12k/WCN7850/hw2.0/m3.bin: Unsupported file layout
ath12k_wifi70: successfully loaded firmware image 'ath12k/WCN7850/hw2.0/m3.bin'
acpi_wmi0: <ACPI-WMI mapping> on acpi0
acpi_wmi0: Embedded MOF found
ig4iic0: <Designware I2C Controller> iomem 0xfedc2000-0xfedc2fff irq 3 on acpi0
iicbus0: <Philips I2C bus (ACPI-hinted)> on ig4iic0
ath12k_wifi70: lkpi_ic_getradiocaps: Skipping disabled chan [12/2467/0x1e1]
ath12k_wifi70: lkpi_ic_getradiocaps: Skipping disabled chan [13/2472/0x1e1]
ath12k_wifi70: lkpi_ic_getradiocaps: Skipping disabled chan [14/2484/0x1e1]
ath12k_wifi70: lkpi_ic_getradiocaps: Skipping disabled chan [120/5600/0x1e1]
ath12k_wifi70: lkpi_ic_getradiocaps: Skipping disabled chan [124/5620/0x1e1]
ath12k_wifi70: lkpi_ic_getradiocaps: Skipping disabled chan [128/5640/0x1e1]
ath12k_wifi70: lkpi_ic_getradiocaps: Skipping disabled chan [169/5845/0x1e1]
iicbus0: <unknown card> at addr 0x10
ig4iic1: <Designware I2C Controller> iomem 0xfedc3000-0xfedc3fff irq 4 on acpi0
iicbus1: <Philips I2C bus (ACPI-hinted)> on ig4iic1
iicbus1: <unknown card> at addr 0x15
ig4iic2: <Designware I2C Controller> iomem 0xfedc4000-0xfedc4fff irq 6 on acpi0
iicbus2: <Philips I2C bus (ACPI-hinted)> on ig4iic2
ig4iic3: <Designware I2C Controller> iomem 0xfedc5000-0xfedc5fff irq 10 on acpi0
iicbus3: <Philips I2C bus (ACPI-hinted)> on ig4iic3
acpi_wmi1: <ACPI-WMI mapping> on acpi0
acpi_wmi1: Embedded MOF found
acpi_wmi2: <ACPI-WMI mapping> on acpi0
acpi_wmi2: Embedded MOF found
acpi_wmi3: <ACPI-WMI mapping> on acpi0
acpi_wmi3: Embedded MOF found
acpi_wmi4: <ACPI-WMI mapping> on acpi0
acpi_wmi4: Embedded MOF found
acpi_wmi5: <ACPI-WMI mapping> on acpi0
acpi_wmi5: Embedded MOF found
acpi_wmi6: <ACPI-WMI mapping> on acpi0
acpi_wmi6: Embedded MOF found
acpi_wmi7: <ACPI-WMI mapping> on acpi0
acpi_wmi7: Embedded MOF found
acpi_wmi8: <ACPI-WMI mapping> on acpi0
acpi_wmi8: Embedded MOF found
lo0: link state changed to UP
ure0 on uhub2
ure0: <Belkin Belkin USB-C LAN, class 0/0, rev 3.00/30.00, addr 1> on usbus3
miibus0: <MII bus> on ure0
rgephy0: <RTL8251/8153 1000BASE-T media interface> PHY 0 on miibus0
rgephy0:  none, 10baseT, 10baseT-FDX, 100baseTX, 100baseTX-FDX, 1000baseT-FDX, 1000baseT-FDX-master, auto
ue0: <USB Ethernet> on ure0
ue0: Ethernet address: xx:xx:xx:xx:xx:02
ue0: link state changed to DOWN
ubt0 on uhub4
ubt0: <vendor 0x0489 product 0xe0fc, class 224/1, rev 1.10/0.01, addr 3> on usbus1
iichid0: <GTCH1563:00 2A94:A89B I2C HID device> at addr 0x10 on iicbus0
iichid0: Using sampling mode
hidbus0: <HID bus> on iichid0
iichid1: <ELAN0676:00 04F3:3195 I2C HID device> at addr 0x15 on iicbus1
iichid1: Using sampling mode
hidbus1: <HID bus> on iichid1
ue0: link state changed to UP
hmt0: <GTCH1563:00 2A94:A89B TouchScreen> on hidbus0
hmt0: Multitouch touchscreen with 0 external buttons
hmt0: 10 contacts with [] properties. Report range [0:0] - [1920:1200]
hmt1: <ELAN0676:00 04F3:3195 TouchPad> on hidbus1
hconf0: <ELAN0676:00 04F3:3195 Configuration> on hidbus1
hmt1: Multitouch touchpad with 0 external buttons, click-pad
hmt1: 5 contacts with [C] properties. Report range [0:0] - [3528:1793]
hms0: <ELAN0676:00 04F3:3195 Mouse> on hidbus1
hms0: 2 buttons and [XY] coordinates ID=1
wlan0: Ethernet address: xx:xx:xx:xx:xx:01
wlan0: link state changed to DOWN
wlan0: link state changed to UP
