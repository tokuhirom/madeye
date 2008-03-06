package App::MadEye::Plugin::Agent::Base;
use strict;
use warnings;
use base qw/Class::Component::Plugin/;
use Gearman::Client;
use English;

sub import {
    my $class = shift;
    my $pkg = caller;

    no strict 'refs';
    push @{"$pkg\::ISA"}, $class;

    *{"$pkg\::register_agents"} = sub :Hook('register_jobs') {
        my ($self, $context, $args) = @_;
        my $target = $self->config->{config}->{target};
           $target = [$target] unless ref $target eq 'ARRAY';

        for my $t (@$target) {
            $context->log('debug', "register job: $self, $t");
            $context->register_job( +{ target => $t, plugin => $self, } );
        }
    };
}

1;

