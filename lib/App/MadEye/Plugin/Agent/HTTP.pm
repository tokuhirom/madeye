package App::MadEye::Plugin::Agent::HTTP;
use strict;
use warnings;
use LWP::UserAgent;
use App::MadEye::Plugin::Agent::Base;

our $TIMEOUT = 15;

sub is_dead {
    my ($self, $url) = @_;

    my $ua = LWP::UserAgent->new(
        timeout => $TIMEOUT,
        agent   => $self->config->{config}->{user_agent} || 'App::MadEye',
    );
    my $res = $ua->get($url);

    if ($res->code == 200) {
        return 0;
    } else {
        return join( "\n", $res->code, $res->message, $res->content );
    }
}

1;

