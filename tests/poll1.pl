#!/usr/bin/perl
use 5.36.0;
use warnings FATAL => 'all';
use IO::Handle;

use FindBin;
use lib "$FindBin::Bin";
use Pipes;

our $PROG = "./poll-sum";

# Test with one simple file.
make_pipe();

my ($pipe) = get_pipe_paths();
say("# Created one pipe: $pipe");

open(my $prog, "-|", qq{$PROG "$pipe"}) or die;
say("# test program ($PROG) started");

open(my $fh, ">", $pipe) or die;
$fh->autoflush(1);
say("# opened pipe $pipe for writing");

my $sum = 0;

my $s_good = 0;
my $s_bad = 0;

for (1..10) {
  my $xx = 1 + int(rand(1 << 31));
  $fh->write(pack("L", $xx));
  $sum += $xx;
  say("# Wrote $xx to pipe, expecting partial sum $sum");

  my $text = <$prog>;
  chomp $text;
  if ($text =~ /$sum/) {
    $s_good++;
    say("# Good partial sum (want $sum), '$text'");
  }
  else {
    $s_bad++;
    say("# Bad partial sum (want $sum), '$text'");
  }
}

close($fh) or die;

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

my $s_total = $s_good + $s_bad;
say("Summary: $s_good good, $s_bad bad, $s_total total");

cleanup_pipes();
