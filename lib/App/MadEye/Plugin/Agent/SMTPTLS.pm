package App::MadEye::Plugin::Agent::SMTPTLS;
use strict;
use warnings;
use App::MadEye::Plugin::Agent::Base;

use Net::SMTP::TLS;

sub is_dead {
    my ( $self, $host ) = @_;

    my $conf    = $self->config->{config};
    my $port    = $conf->{port} || 25;
    my $timeout = $conf->{timeout} || 3;

    eval {
        my $smtptls = Net::SMTP::TLS->new(
            $host,
            Hello   => $host,
            Port    => $port,
            NoTLS   => 1,
            Timeout => $timeout,
        );
        warn $smtptls->hello;
        warn $smtptls;
    };
    if ($@) {
        return "dead: $@";
    }
    else {
        return;    # alive!
    }
}

1;

