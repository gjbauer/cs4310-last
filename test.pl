#!/usr/bin/perl
use v5.16.0;
use warnings FATAL => 'all';
use autodie qw(:all);

use Test::Simple tests => 11;
use IO::Handle;

ok((!-e "simple-sum" && !-e "poll-sum"), "no binaries");

system("(make clean && make) 2>&1 > /dev/null");

if (-e "simple-sum" && -e "poll-sum") {
    ok(1, "it builds");
}
else {
    die("Your program doesn't build.");
}

sub run_test_script {
    my ($path) = @_;
    my $summary = `(timeout -k 20 10 perl "$path" | tail -n 1) 2>/dev/null`;
    if ($summary =~ /(\d+) good, (\d+) bad, (\d+) total/) {
        my ($g, $b, $t) = ($1, $2, $3);
        ok($g > 0, "$path: at least one matching sum");
        ok($g > 3, "$path: at least three matching sums");
        ok($b == 0 && $g == $t, "$path: all sums match");
    }
    else {
        ok(0, "test failed: $path");
        ok(0, "test failed: $path");
        ok(0, "test failed: $path");
    }
}

run_test_script("tests/simple.pl");
run_test_script("tests/poll1.pl");
run_test_script("tests/poll2.pl");

system("make clean 2>&1 > /dev/null");
