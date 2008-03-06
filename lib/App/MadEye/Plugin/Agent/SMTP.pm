package App::MadEye::Plugin::Agent::SMTP;
use strict;
use warnings;
use App::MadEye::Plugin::Agent::Base;

use Net::SMTP;

sub is_dead {
    my ($self, $host) = @_;

    my $conf = $self->config->{config};
    my $timeout = $conf->{timeout} || 5;

    my $smtp = Net::SMTP->new($host, Timeout => $timeout);
    if ($smtp) {
        $smtp->quit;
        return;
    } else {
        return "DEAD";
    }
}

1;
