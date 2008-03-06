package App::MadEye::Rule;
use strict;
use warnings;

sub new {
    my ($class, $config) = @_;
    $config ||= {};
    bless {config => $config}, $class;
}

sub config { $_[0]->{config} }

1;
