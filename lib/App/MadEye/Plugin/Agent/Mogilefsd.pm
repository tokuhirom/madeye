package App::MadEye::Plugin::Agent::Mogilefsd;
use strict;
use warnings;
use App::MadEye::Plugin::Agent::Base;

use MogileFS::Admin;

sub is_dead {
    my ($self, $host) = @_;

    my $conf = $self->config->{config};
    my $retry = $conf->{retry} || 3;

    my $mogadm = MogileFS::Admin->new(hosts => [$host]);

    my @hosts;
    my $error;
    for (my $i=0; $i<$retry; $i++) {
        eval {
            @hosts = $mogadm->get_hosts();
        };
        $error = $@;
        last unless $error;
    }

    if ($error) {
        return "ERROR: $@";
    }
    elsif (scalar(@hosts) == 0) {
        return "THIS TRACKER HAS NO STORE";
    }
    else {
        return; # alive!
    }
}

1;
