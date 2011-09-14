#!perl

use 5.010;
use strict;
use warnings;
use Lingua::EN::Number::Format::MixWithWords qw(format_number_mix);
use Test::More 0.96;

sub test_format {
    my (%args) = @_;
    my $name = $args{name} // $args{num};

    subtest $name => sub {
        my $res;
        my $eval_err;
        eval { $res = format_number_mix(%{$args{args}}) }; $eval_err = $@;

        if ($args{dies}) {
            ok($eval_err, "dies");
        } else {
            ok(!$eval_err, "doesn't die") or diag $eval_err;
        }

        if (exists $args{res}) {
            is($res, $args{res}, "result");
        }
    };
}

test_format args=>{num => 0}, res => '0';
test_format args=>{num => 1}, res => '1';
test_format args=>{num => -1.1}, res => '-1.1';
test_format args=>{num => 23}, res => '23';
test_format args=>{num => 230}, res => '230';
test_format args=>{num => 2300}, res => '2300';
test_format args=>{num => 2400, min_format=>1e3}, res => '2.4 thousand';
test_format args=>{num => 2352001, min_format=>1e9}, res => '2352001';
test_format args=>{num => 2352000}, res => '2.352 million';
test_format args=>{num => -2352000, num_decimals=>2}, res => '-2.4 million';
test_format args=>{num => 123456, num_decimals=>0}, res => '1 million';
test_format args=>{num => 1000000, }, res => '1 million';
test_format args=>{num => 900000, }, res => '900000';
test_format args=>{num => -900000, min_fraction=>0.9}, res => '-0.9 million';
test_format args=>{num => 123457}, res => '1.23457 million';
test_format args=>{num => 123457, format_string=>'%.2f %s'},
    res => '1.23 million';

DONE_TESTING:
done_testing();
