package Lingua::EN::Number::Format::MixWithWords;

use 5.010;
use strict;
use warnings;

require Exporter;
our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(format_number_mix);

# VERSION

our %SPEC;

$SPEC{format_number_mix} = {
    summary => '',
    args    => {
        num => ['num*' => {
            summary => 'The input number to format',
        }],
        format_string => ['num*' => {
            summary => 'sprintf() pattern to use',
            description => <<'_',
This can be used for example to align resulting string, e.g. "%10.2f %12s".
_
        }],
        num_decimals => ['int' => {
            summary => 'Number of decimal points to round',
            default => undef,
        }],
        min_format => ['num*' => {
            summary => 'Number must be larger than this to be formatted as '.
                'mixture of number and word',
            default => 1000000,
        }],
        min_fraction => ['num*' => {
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
sub parse_number_id {
    my %args = @_;
    my $text = $args{text};

    $text =~ s/^\s+//s;
    return undef unless length($text);

    $text =~ s/^([+-]?[0-9,.]+)// or return undef;
    my $n = _parse_mantissa($1);
    return undef unless defined $n;
    if ($text =~ /[Ee]([+-]?\d+)/) {
        $n *= 10**$1;
    }
    $n;
}

1;
# ABSTRACT: Parse number from Indonesian text
__END__

=head1 SYNOPSIS

 use Parse::Number::ID qw(parse_number_id);

 my @a = map {parse_number_id(text=>$_)}
     ("12.345,67", "-1,2e3", "x123", "1.23");
 # @a = [12345.67, -1200, undef, 1.23]


=head1 DESCRIPTION

This module parses numbers from text, according to Indonesian rule of decimal-
and thousand separators ("," and "." respectively, while English uses "." and
","). Since English numbers are more widespread, it will be parsed too whenever
unambiguous, e.g.:

 12.3     # 12.3
 12.34    # 12.34
 12.345   # 12345

This module does not parse numbers that are written as Indonesian words, e.g.
"seratus dua puluh tiga" (123). See L<Lingua::ID::Words2Nums> for that.


=head1 FUNCTIONS

None of the functions are exported by default, but they are exportable.


=head1 SEE ALSO

L<Lingua::ID::Words2Nums>

=cut
