package Pipes;
use 5.36.0;
use warnings FATAL => 'all';
use IO::Handle;

use parent 'Exporter';
our @EXPORT = qw(get_pipe_paths make_pipe cleanup_pipes run);

my @paths = ();
my $pno = 0;

sub run($cmd) {
  my $rv = system($cmd);
  if ($rv != 0) {
    die "Command '$cmd' failed with status $rv.\n";
  }
}

sub get_pipe_paths {
  return @paths;
}

sub make_pipe {
  run("mkdir -p /tmp/pipes.$$");
  my $path = "/tmp/pipes.$$/pipe-$pno";
  $pno += 1;
  run(qq{mkfifo "$path"});
  push(@paths, $path);
  say("# Created pipe $path");
}

sub cleanup_pipes {
  for my $path (@paths) {
    unlink($path);
  }
  rmdir("/tmp/pipes.$$");

  @paths = ();
  $pno = 0;
}

END {
  cleanup_pipes();
}

1;
