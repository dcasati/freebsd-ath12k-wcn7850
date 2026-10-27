#!/usr/bin/env perl
# Render the CSV test data in a results directory as SVG charts.
# Usage: plot-results.pl results/<date>
# Needs only core Perl; writes <dir>/*.svg from <dir>/data/*.csv.
use strict;
use warnings;

my $dir = shift or die "usage: $0 results-dir\n";
my @pal = ('#4e79a7', '#f28e2b', '#59a14f', '#e15759', '#76b7b2', '#b07aa1');

sub readcsv {
	my ($f) = @_;
	open(my $fh, '<', "$dir/data/$f") or die "$dir/data/$f: $!\n";
	chomp(my $h = <$fh>);
	my @k = split /,/, $h;
	my @rows;
	while (<$fh>) {
		chomp;
		next unless length;
		my @v = split /,/, $_, -1;
		push @rows, { map { $k[$_] => $v[$_] } 0 .. $#k };
	}
	return @rows;
}

sub esc { my $s = shift; $s =~ s/&/&amp;/g; $s =~ s/</&lt;/g; $s =~ s/>/&gt;/g; $s }

sub svg {
	my ($name, $w, $h, $title, $body) = @_;
	open(my $fh, '>', "$dir/$name") or die "$dir/$name: $!\n";
	print $fh qq{<svg xmlns="http://www.w3.org/2000/svg" width="$w" height="$h" viewBox="0 0 $w $h" font-family="Helvetica,Arial,sans-serif" font-size="12">\n};
	print $fh qq{<rect width="$w" height="$h" fill="#fff"/>\n};
	printf $fh qq{<text x="%d" y="22" text-anchor="middle" font-size="15" font-weight="bold">%s</text>\n}, $w / 2, esc($title);
	print $fh $body, "</svg>\n";
	close $fh;
	print "wrote $dir/$name\n";
}

# Round an axis maximum up to 1, 2 or 5 times a power of ten.
sub nice {
	my $v = shift;
	return 1 if $v <= 0;
	my $p = 10**int(log($v) / log(10));
	for my $m (1, 2, 5, 10) { return $m * $p if $m * $p >= $v }
}

# Horizontal axis grid with labels; returns SVG text.
sub yaxis {
	my ($x0, $y0, $pw, $ph, $max, $label, $fmt) = @_;
	my $s = '';
	for my $i (0 .. 5) {
		my $v = $max * $i / 5;
		my $y = $y0 + $ph - $ph * $i / 5;
		$s .= sprintf qq{<line x1="%d" y1="%.1f" x2="%d" y2="%.1f" stroke="#ddd"/>\n}, $x0, $y, $x0 + $pw, $y;
		$s .= sprintf qq{<text x="%d" y="%.1f" text-anchor="end">%s</text>\n}, $x0 - 6, $y + 4, sprintf($fmt // '%g', $v);
	}
	$s .= sprintf qq{<text transform="translate(%d,%d) rotate(-90)" text-anchor="middle">%s</text>\n}, $x0 - 48, $y0 + $ph / 2, esc($label);
	$s .= sprintf qq{<line x1="%d" y1="%d" x2="%d" y2="%d" stroke="#333"/>\n}, $x0, $y0 + $ph, $x0 + $pw, $y0 + $ph;
	return $s;
}

sub legend {
	my ($x, $y, @items) = @_;
	my $s = '';
	for my $i (0 .. $#items) {
		my ($col, $txt) = @{ $items[$i] };
		$s .= sprintf qq{<rect x="%d" y="%d" width="12" height="12" fill="%s"/><text x="%d" y="%d">%s</text>\n},
		    $x, $y + 18 * $i, $col, $x + 18, $y + 18 * $i + 10, esc($txt);
	}
	return $s;
}

# 1. Allocator growth over 20 unload/reload cycles, before and after the fix.
{
	my @r = readcsv('unload-allocator-delta.csv');
	my @types = do { my %s; grep { !$s{$_}++ } map { $_->{type} } @r };
	my @phases = ('before-fix', 'after-fix');
	my %b = map { ("$_->{type}/$_->{phase}" => $_->{bytes} / 1024) } @r;
	my $max = nice((sort { $b <=> $a } values %b)[0]);
	my ($x0, $y0, $pw, $ph) = (80, 50, 520, 280);
	my $s = yaxis($x0, $y0, $pw, $ph, $max, 'KiB leaked in 20 cycles');
	my $gw = $pw / @types;
	for my $i (0 .. $#types) {
		for my $j (0 .. $#phases) {
			my $v = $b{"$types[$i]/$phases[$j]"} // 0;
			my $bh = $ph * $v / $max;
			my $x = $x0 + $gw * $i + $gw * 0.15 + $j * $gw * 0.35;
			$s .= sprintf qq{<rect x="%.1f" y="%.1f" width="%.1f" height="%.1f" fill="%s"/>\n}, $x, $y0 + $ph - $bh, $gw * 0.33, $bh, $pal[$j];
			$s .= sprintf qq{<text x="%.1f" y="%.1f" text-anchor="middle" font-size="11">%s</text>\n}, $x + $gw * 0.165, $y0 + $ph - $bh - 4, sprintf('%.1f', $v);
		}
		$s .= sprintf qq{<text x="%.1f" y="%d" text-anchor="middle">%s</text>\n}, $x0 + $gw * ($i + 0.5), $y0 + $ph + 18, $types[$i];
	}
	$s .= legend($x0 + $pw - 230, $y0 + 8, [$pal[0], 'before (kernel.ath12k-vht80)'], [$pal[1], 'after (LinuxKPI txq fix)']);
	svg('unload-allocator-delta.svg', 640, 380, 'Kernel malloc growth over 20 if_ath12k unload/reload cycles', $s);
}

# 2. Reconnect time per cycle, one strip per run.
{
	my @r = readcsv('reconnect.csv');
	my @runs = do { my %s; grep { !$s{$_}++ } map { $_->{run} } @r };
	my $max = nice((sort { $b <=> $a } map { $_->{seconds} } @r)[0]);
	my ($x0, $y0, $pw, $ph) = (80, 50, 560, 280);
	my $s = yaxis($x0, $y0, $pw, $ph, $max, 'seconds to WPA COMPLETED');
	my $gw = $pw / @runs;
	for my $i (0 .. $#runs) {
		my @c = grep { $_->{run} eq $runs[$i] } @r;
		my $n = @c;
		my ($sum, $slow) = (0, 0);
		for my $k (0 .. $#c) {
			my $v = $c[$k]{seconds};
			$sum += $v;
			$slow++ if $v > 10;
			my $x = $x0 + $gw * $i + $gw * 0.1 + $gw * 0.8 * ($k + 0.5) / $n;
			$s .= sprintf qq{<circle cx="%.1f" cy="%.1f" r="3.5" fill="%s" fill-opacity="0.75"/>\n}, $x, $y0 + $ph - $ph * $v / $max, $pal[$i % @pal];
		}
		my $lab = $runs[$i];
		$s .= sprintf qq{<text x="%.1f" y="%d" text-anchor="middle">%s</text>\n}, $x0 + $gw * ($i + 0.5), $y0 + $ph + 18, esc($lab);
		$s .= sprintf qq{<text x="%.1f" y="%d" text-anchor="middle" font-size="11" fill="#555">n=%d, mean %.1f s</text>\n}, $x0 + $gw * ($i + 0.5), $y0 + $ph + 34, $n, $sum / $n;
		$s .= sprintf qq{<text x="%.1f" y="%d" text-anchor="middle" font-size="11" fill="#555">%d over 10 s</text>\n}, $x0 + $gw * ($i + 0.5), $y0 + $ph + 48, $slow;
	}
	svg('reconnect.svg', 680, 410, 'wpa_cli disconnect/reconnect: time to reassociate', $s);
}

# 3. Soak RTT over time, one panel per run.
{
	my @r = readcsv('soak-rtt.csv');
	my @runs = do { my %s; grep { !$s{$_}++ } map { $_->{run} } @r };
	my ($x0, $pw, $ph, $gap) = (80, 640, 130, 60);
	my $s = '';
	my $maxseq = (sort { $b <=> $a } map { $_->{seq} } @r)[0] + 1;
	my $max = 20;
	for my $i (0 .. $#runs) {
		my @c = grep { $_->{run} eq $runs[$i] } @r;
		my $y0 = 50 + $i * ($ph + $gap);
		$s .= yaxis($x0, $y0, $pw, $ph, $max, 'RTT ms');
		my ($sum, $top, $clip) = (0, 0, 0);
		my @pts;
		for my $p (@c) {
			my $v = $p->{rtt_ms};
			$sum += $v;
			$top = $v if $v > $top;
			$clip++ if $v > $max;
			$v = $max if $v > $max;
			push @pts, sprintf('%.1f,%.1f', $x0 + $pw * $p->{seq} / $maxseq, $y0 + $ph - $ph * $v / $max);
		}
		$s .= sprintf qq{<polyline points="%s" fill="none" stroke="%s" stroke-width="1"/>\n}, join(' ', @pts), $pal[$i % @pal];
		$s .= sprintf qq{<text x="%d" y="%d" font-weight="bold">%s</text>\n}, $x0, $y0 - 6, esc($runs[$i]);
		$s .= sprintf qq{<text x="%d" y="%d" text-anchor="end" fill="#555">%d/%d replies, avg %.2f ms, max %.1f ms%s</text>\n},
		    $x0 + $pw, $y0 - 6, scalar @c, scalar @c, $sum / @c, $top, $clip ? ", $clip clipped at $max ms" : '';
		for my $m (0 .. int($maxseq / 300)) {
			my $x = $x0 + $pw * $m * 300 / $maxseq;
			$s .= sprintf qq{<text x="%.1f" y="%d" text-anchor="middle" font-size="11">%d min</text>\n}, $x, $y0 + $ph + 14, $m * 5;
		}
	}
	svg('soak-rtt.svg', 760, 50 + @runs * ($ph + $gap), 'Wi-Fi soak: 1 s ping to the access point (0% loss in all runs)', $s);
}

# 4. Unload/reload bring-up time per cycle.
{
	my @r = readcsv('unload-reload.csv');
	my $max = nice((sort { $b <=> $a } map { $_->{seconds} || 0 } @r)[0]);
	my ($x0, $y0, $pw, $ph) = (80, 50, 520, 240);
	my $s = yaxis($x0, $y0, $pw, $ph, $max, 'seconds to WPA + DHCP + ping');
	my $bw = $pw / @r;
	for my $i (0 .. $#r) {
		my $x = $x0 + $bw * $i + $bw * 0.15;
		if ($r[$i]{result} eq 'pass') {
			my $bh = $ph * $r[$i]{seconds} / $max;
			$s .= sprintf qq{<rect x="%.1f" y="%.1f" width="%.1f" height="%.1f" fill="%s"/>\n}, $x, $y0 + $ph - $bh, $bw * 0.7, $bh, $pal[2];
		} else {
			$s .= sprintf qq{<rect x="%.1f" y="%d" width="%.1f" height="%d" fill="%s" fill-opacity="0.25"/>\n}, $x, $y0, $bw * 0.7, $ph, $pal[3];
			$s .= sprintf qq{<text x="%.1f" y="%d" text-anchor="middle" font-size="11" fill="%s">%s</text>\n}, $x + $bw * 0.35, $y0 + 14, $pal[3], 'X';
		}
		$s .= sprintf qq{<text x="%.1f" y="%d" text-anchor="middle" font-size="10">%d</text>\n}, $x + $bw * 0.35, $y0 + $ph + 14, $r[$i]{cycle};
	}
	$s .= sprintf qq{<text x="%d" y="%d" text-anchor="middle">cycle</text>\n}, $x0 + $pw / 2, $y0 + $ph + 32;
	$s .= legend($x0 + $pw - 250, $y0 + 6, [$pal[2], 'pass'], [$pal[3], 'associated, DHCP gave up (manual dhclient)']);
	svg('unload-reload.svg', 640, 350, 'kldunload/kldload if_ath12k: time back to a working link', $s);
}

# 5. iperf3 throughput.
{
	my @r = readcsv('iperf3.csv');
	my $max = nice((sort { $b <=> $a } map { $_->{mbps} } @r)[0]);
	my ($x0, $y0, $pw, $ph) = (80, 50, 640, 260);
	my $s = yaxis($x0, $y0, $pw, $ph, $max, 'Mb/s');
	my $bw = $pw / @r;
	my %col = ('5GHz-VHT80' => $pal[0], '2.4GHz-HT20' => $pal[1]);
	for my $i (0 .. $#r) {
		my $bh = $ph * $r[$i]{mbps} / $max;
		my $x = $x0 + $bw * $i + $bw * 0.15;
		$s .= sprintf qq{<rect x="%.1f" y="%.1f" width="%.1f" height="%.1f" fill="%s"/>\n}, $x, $y0 + $ph - $bh, $bw * 0.7, $bh, $col{ $r[$i]{band} } // $pal[4];
		$s .= sprintf qq{<text x="%.1f" y="%.1f" text-anchor="middle" font-size="11">%s</text>\n}, $x + $bw * 0.35, $y0 + $ph - $bh - 4, $r[$i]{mbps};
		$s .= sprintf qq{<text x="%.1f" y="%d" text-anchor="middle" font-size="10">%s</text>\n}, $x + $bw * 0.35, $y0 + $ph + 14, esc($r[$i]{test});
		$s .= sprintf qq{<text x="%.1f" y="%d" text-anchor="middle" font-size="10">%s</text>\n}, $x + $bw * 0.35, $y0 + $ph + 27, $r[$i]{direction};
	}
	$s .= legend($x0 + $pw - 160, $y0 + 6, [$pal[0], '5 GHz VHT80 (ch 36)'], [$pal[1], '2.4 GHz HT20 (ch 1)']);
	svg('iperf3.svg', 760, 360, 'iperf3 to the access point (router CPU-bound on 5 GHz)', $s);
}
