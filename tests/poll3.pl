#!/usr/bin/perl
use 5.36.0;
use warnings FATAL => 'all';
use IO::Handle;

use FindBin;
use lib "$FindBin::Bin";
use Pipes;

say "This test script doesn't work.";
say "I don't know if it's an error in the script or in the test program.";

sub msleep {
  my ($ms) = @_;
  my $sec = $ms / 1000.0;
  select(undef, undef, undef, $sec);
}

my $s_good = 0;
my $s_bad = 0;

for (1..3) {
  make_pipe();
}

my @paths = get_pipe_paths();
my $args = join(' ', @paths);
open(my $prog, "-|", "./poll-sum $args") or die;

say("# test program is running");

my @fhs = ();
for my $path (@paths) {
  open(my $fh, ">", $path) or die;
  $fh->autoflush(1);
  push(@fhs, $fh);
  say("# opened pipe $path");
}

my $sum = 0;

my ($p1, $p2, $p3) = @fhs;

sub roll_nums {
  my @ys = ();
  for (1..4) {
    push(@ys, 1 + int(rand(1 << 31)));
  }
  return @ys;
}

my @n1 = roll_nums();
my $d1 = pack("L*", @n1);
my @n2 = roll_nums();
my $d2 = pack("L*", @n2);
my @n3 = roll_nums();
my $d3 = pack("L*", @n3);

sub send_bytes {
  my ($fh, $buf, $count) = @_;
  my $bs = substr($buf, 0, $count, "");
  $fh->write($bs);
  msleep(100);
}

sub sent_nums {
  for my $xx (@_) {
    say("# Completed send of $xx");
    $sum += $xx;
    my $text = <$prog>;
    chomp $text;
    if ($text =~ /$sum/) {
      $s_good++;
      say("# Good partial sum (sent $xx, want $sum), '$text'");
    }
    else {
      $s_bad++;
      say("# Bad partial sum (sent $xx, want $sum), '$text'");
    }
  }
}

send_bytes($p3, $d3, 9);
sent_nums($n3[0], $n3[1]);

send_bytes($p1, $d1, 7);
sent_nums($n1[0]);

send_bytes($p2, $d2, 3);

send_bytes($p1, $d1, 4);
sent_nums($n1[1]);

send_bytes($p2, $d2, 5);
sent_nums($n2[0], $n2[1]);

send_bytes($p1, $d1, 5);
sent_nums($n1[2], $n1[3]);

send_bytes($p2, $d2, 1);
send_bytes($p2, $d2, 7);
sent_nums($n2[2], $n2[3]);

close($p2);

send_bytes($p3, $d3, 6);
sent_nums($n3[2]);

send_bytes($p3, $d3, 1);
sent_nums($n3[3]);

close($p1);
close($p3);

my $total = <$prog>;
chomp $total;
if ($total =~ /$sum/) {
  $s_good++;
  say("# Good total.");
}
else {
  $s_bad++;
  say("# Bad total.");
}

cleanup_pipes();


my $s_total = $s_good + $s_bad;
say("Summary: $s_good good, $s_bad bad, $s_total total");
