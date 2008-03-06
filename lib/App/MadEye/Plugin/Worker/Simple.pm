package App::MadEye::Plugin::Worker::Simple;
use strict;
use warnings;
use base qw/Class::Component::Plugin/;
use App::MadEye::Util;
use Params::Validate;

our $TIMEOUT = 60;  # TODO: configurable

sub run_job :Method {
    my ($self, $context, $args) = @_;

    $context->log( debug => "watching $args->{target} by $args->{plugin}" );

    timeout $TIMEOUT, "watching $args->{target} $args->{plugin}", sub {
        if ( my $message = $args->{plugin}->is_dead( $args->{target} ) ) {
            $context->add_result(
                plugin  => $args->{plugin},
                target  => $args->{target},
                message => $message,
            );
        }
    };

    $context->log( debug => "finished $args->{target} by $args->{plugin}" );
}

1;

