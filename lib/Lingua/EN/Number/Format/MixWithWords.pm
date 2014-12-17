package Lingua::EN::Number::Format::MixWithWords;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use Lingua::Base::Number::Format::MixWithWords;
use parent qw(Lingua::Base::Number::Format::MixWithWords);

use Exporter::Lite;

our @EXPORT_OK = qw(format_number_mix);

our %SPEC;

$SPEC{format_number_mix} = {
    v => 1.1,
    summary => 'Format number to a mixture of numbers and words (e.g. 12.3 million)',
    args    => {
        num => {
            summary => 'The input number to format',
            schema => ['float*' => {}],
        },
        scale => {
            summary => 'Pick long or short scale names',
            description => <<_,
See http://en.wikipedia.org/wiki/Long_scale#Long_scale_countries_and_languages
for details.
_
            schema => ['str*' => {
                in => ['short', 'long'],
            }],
        },
        num_decimal => {
            summary => 'Number of decimal points to round',
            description => <<'_',
Can be negative, e.g. -1 to round to nearest 10, -2 to nearest 100, and so on.
_
            schema => ['int' => {
            }],
        },
        min_format => {
            summary => 'Number must be larger than this to be formatted as '.
                'mixture of number and word',
            schema => ['float*' => {
            }],
            default => 1000000,
        },
        min_fraction => {
            summary => 'Whether smaller number can be formatted with 0,x',
            description => <<_,
If min_fraction is 1 (the default) or 0.9, 800000 won't be formatted as 0.9
omillion but will be if min_fraction is 0.8.
_
            schema => ['float*' => {
                min => 0,
                max => 1,
            }],
            default => 1,
        },
    },
    result_naked => 1,
};
sub format_number_mix {
    my %args = @_;

    my $f = __PACKAGE__->new(
        num_decimal   => $args{num_decimal},
        min_format    => $args{min_format},
        min_fraction  => $args{min_fraction},
        scale         => $args{scale},
    );
    $f->_format($args{num});
}

my $en_short_names = {
    #2    => 'hundred',
    3    => 'thousand',
    6    => 'million',
    9    => 'billion',
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

my $en_long_names = {
    #2    => 'hundred',
    3    => 'thousand',
    6    => 'million',
    12   => 'billion',
    15   => 'billiard',
    18   => 'trillion',
    24   => 'quadrillion',
    30   => 'quintillion',
    36   => 'sextillion',
    42   => 'septillion',
    48   => 'octillion',
    54   => 'nonillion',
    60   => 'decillion',
    66   => 'undecillion',
    72   => 'duodecillion',
    78   => 'tredecillion',
    84   => 'quattuordecillion',
    90   => 'quindecillion',
    96   => 'sexdecillion',
    102  => 'septendecillion',
    108  => 'octodecillion',
    114  => 'novemdecillion',
    120  => 'vigintillion',
    100  => 'googol',
    600  => 'centillion',
};

sub new {
    my ($class, %args) = @_;
    $args{decimal_point} //= ".";
    $args{thousands_sep} //= ",";
    die "Please specify scale" unless $args{scale};
    die "Invalid scale, please use short/long"
        unless $args{scale} =~ /\A(short|long)\z/;
    $args{names} //= ($args{scale} eq 'long' ? $en_long_names:$en_short_names);
    # XXX should use "SUPER"
    my $self = Lingua::Base::Number::Format::MixWithWords->new(%args);
    bless $self, $class;
}

1;
# ABSTRACT:

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
