package Lingua::EN::Number::Format::MixWithWords;

use 5.010;
use strict;
use warnings;

use Math::Round qw(nearest);
use Number::Format;
use POSIX qw(floor log10);

require Exporter;
our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(format_number_mix);

# VERSION

our %SPEC;

$SPEC{format_number_mix} = {
    summary => '',
    args    => {
        num => ['float*' => {
            summary => 'The input number to format',
        }],
        num_decimal => ['int' => {
            summary => 'Number of decimal points to round',
            description => <<'_',
Can be negative, e.g. -1 to round to nearest 10, -2 to nearest 100, and so on.
_
        }],
        min_format => ['float*' => {
            summary => 'Number must be larger than this to be formatted as '.
                'mixture of number and word',
            default => 1000000,
        }],
        min_fraction => ['float*' => {
            summary => 'Whether smaller number can be formatted with 0,x',
            description => <<_,
If min_fraction is 1 (the default) or 0.9, 800000 won't be formatted as 0.9
omillion but will be if min_fraction is 0.8.
_
            default => 1,
            min => 0,
            max => 1,
        }],
    },
    result_naked => 1,
};
sub format_number_mix {
    my %args = @_;

    my $f = Lingua::EN::Number::Format::MixWithWords->new(
        num_decimal   => $args{num_decimal},
        min_format    => $args{min_format},
        min_fraction  => $args{min_fraction},
    );
    $f->_format($args{num});
}

sub new {
    my ($class, %args) = @_;
    $args{decimal_point} //= ".";
    $args{thousands_sep} //= ",";
    $args{names} //= {
        #2   => 'hundred',
        3   => 'thousand',
        6   => 'million',
        9   => 'billion',
       12   => 'trillion',
       15   => 'quadrillion',
       18   => 'quintillion',
       21   => 'sextillion',
       24   => 'septillion',
       27   => 'octillion',
       30   => 'nonillion',
       33   => 'decillion',
       36   => 'undecillion',
       39   => 'duodecillion',
       42   => 'tredecillion',
       45   => 'quattuordecillion',
       48   => 'quindecillion',
       51   => 'sexdecillion',
       54   => 'septendecillion',
       57   => 'octodecillion',
       60   => 'novemdecillion',
       63   => 'vigintillion',
       100  => 'googol',
       303  => 'centillion',
    };
    $args{min_format}   //= 1000000;
    $args{min_fraction} //= 1;

    die "Invalid min_fraction, must be 0 < x <= 1"
        unless $args{min_fraction} > 0 && $args{min_fraction} <= 1;
    $args{_nf} = Number::Format->new(
        THOUSANDS_SEP => $args{thousands_sep},
        DECIMAL_POINT => $args{decimal_point},
    );
    $args{powers} = [sort {$a<=>$b} keys %{$args{names}}];
    bless \%args, $class;
}

sub _format {
    my ($self, $num) = @_;
    return undef unless defined $num;

    if (defined $self->{num_decimal}) {
        $num = nearest(10**-$self->{num_decimal}, $num);
    }
    my ($exp, $mts, $exp_f);
    my $anum = abs($num);
    if ($anum) {
        $exp   = floor(log10($anum));
        $mts   = $anum / 10**$exp;
        $exp_f = floor(log10($anum/$self->{min_fraction}));
    } else {
        $exp   = 0;
        $mts   = 0;
        $exp_f = 0;
    }

    my $p;
    my ($res_n, $res_w);
    for my $i (0..@{$self->{powers}}-1) {
        last if $self->{powers}[$i] > $exp_f;
        $p = $self->{powers}[$i];
    }
    if (defined($p) && $anum >= $self->{min_format}*$self->{min_fraction}) {
        $res_n = $mts * 10**($exp-$p);
        $res_w = $self->{names}{$p};
    } else {
        $res_n = $anum;
        $res_w = "";
    }
    $res_n = $self->{_nf}->format_number($res_n, $self->{num_decimal} // 8);

    ($num < 0 ? "-" : "") . $res_n . ($res_w ? " $res_w" : "");
}

1;
# ABSTRACT: Format number to a mixture of numbers and words (e.g. 12.3 million)
__END__

=head1 SYNOPSIS

 use Lingua::EN::Number::Format::MixWithWords qw(format_number_mix);

 print format_number_mix(num => 1.23e7); # prints "12.3 million"


=head1 DESCRIPTION

This module formats number with English names of large numbers (thousands,
millions, billions, and so on), e.g. 1.23e7 becomes "12.3 million". If number is
too small or too large so it does not have any appropriate names, it will be
formatted like a normal number.


=head1 FUNCTIONS

None of the functions are exported by default, but they are exportable.


=head1 SEE ALSO

L<Lingua::EN::Numbers>

L<Number::Format>

=cut
