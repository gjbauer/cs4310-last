#!/usr/bin/perl
use 5.36.0;
use warnings FATAL => 'all';
use IO::Handle;

use FindBin;
use lib "$FindBin::Bin";
use Pipes;

my $s_good = 0;
my $s_bad = 0;

sub test_case($nn) {
  for (1..$nn) {
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

  for (1..10) {
    my $xx = 1 + int(rand(1 << 31));
    my $pno = int(rand(scalar @fhs));
    my $pipe = $fhs[$pno];
    $pipe->write(pack("L", $xx));
    $sum += $xx;
    say("# Wrote $xx to pipe $pno, expecting partial sum $sum");
   
    my $text = <$prog>;
    chomp $text;
    if ($text =~ /$sum/) {
      $s_good++;
    }
    else {
      $s_bad++;
      say("Bad partial sum (want $sum), '$text'");
    }
    say("got $text");
  }
  
  for my $fh (@fhs) {
    close($fh) or die;
  }

  my $total = <$prog>;
  chomp $total;
  if ($total =~ /$sum/) {
    $s_good++;
    say("Good total.");
  }
  else {
    $s_bad++;
    say("Bad total.");
  }

  cleanup_pipes();
}

test_case(2);

my $s_total = $s_good + $s_bad;
say("Summary: $s_good good, $s_bad bad, $s_total total");
