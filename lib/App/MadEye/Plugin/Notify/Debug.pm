package App::MadEye::Plugin::Notify::Debug;
use strict;
use warnings;
use base qw/Class::Component::Plugin/;
use YAML;

sub notify :Hook('notify') {
    my ($self, $context, $args) = @_;

    warn Dump($args);
}

1;

