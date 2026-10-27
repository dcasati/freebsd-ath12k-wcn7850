#!/usr/local/bin/perl
# SPDX-License-Identifier: BSD-2-Clause
#
# Render the sequence diagrams in this directory as monochrome SVG.
# Usage: perl seqdiag.pl            (writes fig2-*.svg and fig3-*.svg)
# Core Perl only.

use strict;
use warnings;

my $FONT = 'Times New Roman, Times, Liberation Serif, serif';

sub esc { my $s = shift; $s =~ s/&/&amp;/g; $s =~ s/</&lt;/g; $s =~ s/>/&gt;/g; $s }

# Each step is one of:
#   [ 'msg',   from, to, label, dashed ]
#   [ 'self',  lane, label ]
#   [ 'note',  lane, label ]          (boxed annotation on a lifeline)
#   [ 'phase', label ]                (horizontal divider with a title)
sub render {
	my (%a) = @_;
	my @lanes = @{ $a{lanes} };
	my $w = $a{width};
	my $left = 150;
	my $gap = ($w - $left - 100) / (@lanes - 1);
	my %x;
	$x{$lanes[$_][0]} = $left + $_ * $gap for 0 .. $#lanes;

	my $y = 80;
	my @body;
	for my $s (@{ $a{steps} }) {
		my $k = $s->[0];
		if ($k eq 'phase') {
			$y += 10;
			push @body, sprintf('<line x1="20" y1="%d" x2="%d" y2="%d" stroke="#000" stroke-width="0.8" stroke-dasharray="2 3"/>', $y, $w - 20, $y);
			push @body, sprintf('<text x="20" y="%d" font-size="13" font-style="italic" fill="#000">%s</text>', $y + 16, esc($s->[1]));
			$y += 48;
		} elsif ($k eq 'msg') {
			my ($f, $t, $l, $d) = @$s[1 .. 4];
			my ($x1, $x2) = ($x{$f}, $x{$t});
			my $dir = $x2 > $x1 ? 1 : -1;
			push @body, sprintf('<line x1="%d" y1="%d" x2="%d" y2="%d" stroke="#000" stroke-width="1.2" marker-end="url(#a)"%s/>',
			    $x1, $y, $x2 - $dir * 2, $y, $d ? ' stroke-dasharray="5 3"' : '');
			push @body, sprintf('<text x="%d" y="%d" font-size="12.5" text-anchor="middle" fill="#000" stroke="#fff" stroke-width="5" paint-order="stroke">%s</text>',
			    ($x1 + $x2) / 2, $y - 6, esc($l));
			$y += 34;
		} elsif ($k eq 'self') {
			my ($ln, $l) = @$s[1, 2];
			my $x0 = $x{$ln};
			push @body, sprintf('<path d="M%d,%d h28 v14 h-26" fill="none" stroke="#000" stroke-width="1.2" marker-end="url(#a)"/>', $x0, $y - 8, );
			push @body, sprintf('<text x="%d" y="%d" font-size="12.5" fill="#000" stroke="#fff" stroke-width="5" paint-order="stroke">%s</text>', $x0 + 34, $y + 4, esc($l));
			$y += 32;
		} elsif ($k eq 'note') {
			my ($ln, $l) = @$s[1, 2];
			my @lines = split /\n/, $l;
			my $len = 0;
			for (@lines) { $len = length if length > $len }
			my $bw = $len * 6.3 + 16;
			my $bh = 16 * @lines + 8;
			my $x0 = $x{$ln} - $bw / 2;
			push @body, sprintf('<rect x="%d" y="%d" width="%d" height="%d" fill="url(#h)" stroke="#000" stroke-width="1"/>', $x0, $y - 14, $bw, $bh);
			my $ty = $y + 1;
			for (@lines) {
				push @body, sprintf('<text x="%d" y="%d" font-size="12" text-anchor="middle" fill="#000" stroke="#fff" stroke-width="4" paint-order="stroke">%s</text>', $x{$ln}, $ty, esc($_));
				$ty += 16;
			}
			$y += $bh + 14;
		}
	}
	my $bottom = $y + 6;
	my $h = $bottom + 50;

	my @out;
	push @out, sprintf('<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d" viewBox="0 0 %d %d" font-family="%s" font-size="14">', $w, $h, $w, $h, $FONT);
	push @out, '<defs><marker id="a" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="8" markerHeight="8" orient="auto-start-reverse"><path d="M0,1 L9,5 L0,9 z" fill="#000"/></marker>',
	    '<pattern id="h" width="6" height="6" patternUnits="userSpaceOnUse" patternTransform="rotate(45)"><rect width="6" height="6" fill="#fff"/><line x1="0" y1="0" x2="0" y2="6" stroke="#ccc" stroke-width="2"/></pattern></defs>';
	push @out, sprintf('<rect width="%d" height="%d" fill="#fff"/>', $w, $h);
	for my $ln (@lanes) {
		my ($id, $title, $sub) = @$ln;
		my $x0 = $x{$id};
		push @out, sprintf('<line x1="%d" y1="56" x2="%d" y2="%d" stroke="#000" stroke-width="0.8" stroke-dasharray="1 3"/>', $x0, $x0, $bottom);
		push @out, sprintf('<rect x="%d" y="14" width="150" height="42" fill="#fff" stroke="#000" stroke-width="1.2"/>', $x0 - 75);
		push @out, sprintf('<text x="%d" y="%d" text-anchor="middle" font-weight="bold" fill="#000">%s</text>', $x0, $sub ? 32 : 40, esc($title));
		push @out, sprintf('<text x="%d" y="49" text-anchor="middle" font-size="11.5" font-style="italic" fill="#000">%s</text>', $x0, esc($sub)) if $sub;
	}
	push @out, @body;
	push @out, sprintf('<text x="%d" y="%d" font-size="13" text-anchor="middle" fill="#000"><tspan font-weight="bold">%s</tspan> %s</text>',
	    $w / 2, $h - 18, esc($a{fig}), esc($a{caption}));
	push @out, '</svg>';
	open my $fh, '>', $a{file} or die "$a{file}: $!";
	print $fh join("\n", @out), "\n";
	close $fh;
}

render(
	file => 'fig2-bringup.svg',
	width => 820,
	fig => 'Figure 2.',
	caption => 'Firmware bring-up: MHI boot, then the stock ath12k QMI handshake.',
	lanes => [
		[ 'drv', 'ath12k', 'pci.c, qmi.c, core.c' ],
		[ 'lkpi', 'LinuxKPI', 'MHI host, QRTR, QMI' ],
		[ 'dev', 'WCN7850', 'firmware' ],
	],
	steps => [
		[ 'phase', 'MHI: load and start firmware' ],
		[ 'msg', 'drv', 'lkpi', 'mhi_sync_power_up()' ],
		[ 'self', 'lkpi', 'request_firmware("amss.bin")' ],
		[ 'msg', 'lkpi', 'dev', 'BHI: SBL portion of the image' ],
		[ 'note', 'dev', "PBL runs SBL" ],
		[ 'msg', 'dev', 'lkpi', 'MHI state READY', 1 ],
		[ 'msg', 'lkpi', 'dev', 'BHIe: main ELF image' ],
		[ 'note', 'dev', "execution environment:\nmission mode" ],
		[ 'self', 'lkpi', 'start IPCR channels, QRTR endpoint' ],
		[ 'msg', 'lkpi', 'drv', 'status_cb(MHI_CB_EE_MISSION_MODE)', 1 ],
		[ 'phase', 'QMI over QRTR (unchanged ath12k code)' ],
		[ 'msg', 'dev', 'drv', 'QMI server arrives', 1 ],
		[ 'msg', 'drv', 'dev', 'indication register, host capabilities' ],
		[ 'msg', 'dev', 'drv', 'request memory', 1 ],
		[ 'msg', 'drv', 'dev', 'firmware memory (host DMA)' ],
		[ 'msg', 'dev', 'drv', 'memory ready', 1 ],
		[ 'msg', 'drv', 'dev', 'target capabilities (chip_id, fw_version)' ],
		[ 'msg', 'drv', 'dev', 'BDF download: regdb, board-2.bin, caldata' ],
		[ 'msg', 'drv', 'dev', 'M3 info (m3.bin)' ],
		[ 'msg', 'dev', 'drv', 'firmware ready', 1 ],
		[ 'msg', 'drv', 'dev', 'WLAN mode and config' ],
		[ 'phase', 'HTC/WMI over copy engines' ],
		[ 'msg', 'dev', 'drv', 'WMI service ready', 1 ],
		[ 'msg', 'drv', 'lkpi', 'ieee80211_register_hw()' ],
		[ 'note', 'lkpi', "net80211 attach;\nifconfig wlan0 create" ],
	],
);

render(
	file => 'fig3-controlled-port.svg',
	width => 900,
	fig => 'Figure 3.',
	caption => 'WPA2 controlled port: the link goes UP only after M4 is acknowledged and keys are installed.',
	lanes => [
		[ 'sup', 'wpa_supplicant', 'driver_bsd' ],
		[ 'n80211', 'net80211', 'ieee80211_node.c' ],
		[ 'lkpi', 'LinuxKPI 802.11', 'linux_80211.c' ],
		[ 'drv', 'ath12k', 'and firmware' ],
		[ 'ap', 'Access point', '' ],
	],
	steps => [
		[ 'phase', 'Association' ],
		[ 'msg', 'ap', 'drv', 'association response', 1 ],
		[ 'msg', 'lkpi', 'n80211', 'new state RUN', 1 ],
		[ 'msg', 'n80211', 'lkpi', 'sta_newstate(): iv_port_authorize(ni, true)' ],
		[ 'msg', 'lkpi', 'n80211', 'false: port closed', 1 ],
		[ 'note', 'n80211', "node not authorized;\nWPA2: link UP held back" ],
		[ 'phase', 'EAPOL 4-way handshake (port closed to data)' ],
		[ 'msg', 'ap', 'sup', 'EAPOL M1', 1 ],
		[ 'msg', 'sup', 'ap', 'EAPOL M2' ],
		[ 'msg', 'ap', 'sup', 'EAPOL M3', 1 ],
		[ 'msg', 'sup', 'lkpi', 'EAPOL M4 (tagged by LinuxKPI)' ],
		[ 'msg', 'lkpi', 'ap', 'M4 sent' ],
		[ 'msg', 'drv', 'lkpi', 'TX status: M4 acknowledged', 1 ],
		[ 'msg', 'sup', 'lkpi', 'install PTK and GTK' ],
		[ 'msg', 'lkpi', 'drv', 'set_key()' ],
		[ 'phase', 'LinuxKPI port task' ],
		[ 'note', 'lkpi', "M4 acked, keys installed,\nstate RUN, regulatory allows TX" ],
		[ 'msg', 'lkpi', 'drv', 'sta_state(AUTHORIZED)' ],
		[ 'note', 'drv', "firmware peer\nauthorized" ],
		[ 'msg', 'lkpi', 'n80211', 'ieee80211_node_authorize(); link UP' ],
		[ 'msg', 'n80211', 'sup', 'RTM_IFINFO: link state UP', 1 ],
	],
);
