package App::MadEye::Plugin::Agent::Ping;
use strict;
use warnings;
use App::MadEye::Plugin::Agent::Base;

use Net::Ping;

sub is_dead {
    my ($self, $host) = @_;

    my $conf = $self->config->{config};
    my $timeout = $conf->{timeout} or 5;

    my $p = Net::Ping->new("tcp");
    $p->hires(1);
    my ( $ret, ) = $p->ping( $host, $timeout );
    $p->close;

    if ($ret) {
        return; # success
    } else {
        return "dead";
    }
}

1;

